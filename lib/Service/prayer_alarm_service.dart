import 'dart:convert';
import 'dart:io' show Platform;

import 'package:adhan/adhan.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:intl/intl.dart';
import 'package:flutter_timezone/flutter_timezone.dart';

/// Keys for SharedPreferences.
const String _keyEnabledPrayer = 'prayer_alarm_enabled';
const String _keyAlarmLat = 'prayer_alarm_lat';
const String _keyAlarmLng = 'prayer_alarm_lng';

/// Fixed notification IDs to avoid stacking.
const int prayerAlarmNotificationId = 100;
const int snoozeNotificationId = 101;

/// Prayer names that can be enabled (matches UI; "Zuhr" not "Dhuhr" for display). Sunrise added for testing.
const List<String> prayerAlarmOptions = ['Fajr', 'Sunrise', 'Zuhr', 'Asr', 'Maghrib', 'Isha'];

/// Default coordinates (fallback when location not available).
const double _defaultLat = 30.8138;
const double _defaultLng = 73.4534;

/// Payload keys for alarm screen.
const String payloadType = 'type';
const String payloadPrayer = 'prayer';
const String payloadTime = 'time';
const String payloadTypePrayerAlarm = 'prayer_alarm';

/// Snooze duration.
const Duration snoozeDuration = Duration(minutes: 5);

/// Method channel for Android exact-alarm permission (Android 12+).
const MethodChannel _exactAlarmChannel = MethodChannel('com.example.app5/prayer_alarm');

class PrayerAlarmService {
  PrayerAlarmService(this._notificationsPlugin);

  final FlutterLocalNotificationsPlugin _notificationsPlugin;
  static bool _timezoneInitialized = false;
  /// When true, named timezone failed; we build TZDateTime from device local instant instead.
  static bool _timezoneFallback = false;

  static Future<void> ensureTimezoneInitialized() async {
    if (_timezoneInitialized) return;
    tz_data.initializeTimeZones();
    try {
      final String timeZoneName = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(timeZoneName));
    } catch (_) {
      _timezoneFallback = true;
      if (kDebugMode) {
        debugPrint('Prayer alarm timezone fallback: using device offset');
      }
      tz.setLocalLocation(tz.UTC);
    }
    _timezoneInitialized = true;
  }

  /// Save last known coordinates (call from PrayerScreen when location is obtained).
  static Future<void> saveCoordinates(double lat, double lng) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_keyAlarmLat, lat);
    await prefs.setDouble(_keyAlarmLng, lng);
  }

  static Future<Coordinates> getCoordinates() async {
    final prefs = await SharedPreferences.getInstance();
    final lat = prefs.getDouble(_keyAlarmLat);
    final lng = prefs.getDouble(_keyAlarmLng);
    if (lat != null && lng != null) {
      return Coordinates(lat, lng);
    }
    return Coordinates(_defaultLat, _defaultLng);
  }

  static Future<String?> getEnabledPrayer() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyEnabledPrayer);
  }

  /// On Android 12+, returns whether the app can schedule exact alarms. On other platforms, returns true.
  static Future<bool> canScheduleExactAlarms() async {
    if (!Platform.isAndroid) return true;
    try {
      final r = await _exactAlarmChannel.invokeMethod<bool>('canScheduleExactAlarms');
      return r ?? true;
    } catch (_) {
      return true;
    }
  }

  /// On Android 12+, opens the system screen to allow "Alarms & reminders". No-op on other platforms.
  static Future<void> openExactAlarmSettings() async {
    if (!Platform.isAndroid) return;
    try {
      await _exactAlarmChannel.invokeMethod<void>('openExactAlarmSettings');
    } catch (_) {}
  }

  /// Schedules a one-off test alarm that rings after [fromNow]. Used to verify alarm flow.
  /// Returns true if scheduled (Android only); on other platforms or on error returns false.
  static Future<bool> scheduleTestAlarm(Duration fromNow) async {
    if (!Platform.isAndroid) return false;
    try {
      final triggerAtMillis =
          DateTime.now().add(fromNow).millisecondsSinceEpoch;
      final scheduled = await _exactAlarmChannel.invokeMethod<bool>(
        'scheduleTestAlarm',
        {'timestampMillis': triggerAtMillis},
      );
      return scheduled == true;
    } catch (_) {
      return false;
    }
  }

  /// Cancels the test alarm if one was scheduled. No-op on non-Android.
  static Future<void> cancelTestAlarm() async {
    if (!Platform.isAndroid) return;
    try {
      await _exactAlarmChannel.invokeMethod<void>('cancelTestAlarm');
    } catch (_) {}
  }

  /// Enable alarm for one prayer or disable all. Cancels previous and reschedules if enabling.
  Future<void> setEnabledPrayer(String? prayerName) async {
    final prefs = await SharedPreferences.getInstance();
    if (prayerName == null || prayerName.isEmpty) {
      await prefs.remove(_keyEnabledPrayer);
      await _cancelAll();
      await _cancelNativeAlarm();
      return;
    }
    if (!prayerAlarmOptions.contains(prayerName)) return;
    await prefs.setString(_keyEnabledPrayer, prayerName);
    await _cancelAll();
    await _cancelNativeAlarm();
    await _scheduleNext(prayerName);
  }

  /// Cancel native Android alarm (so phone alarm stops when user disables).
  static Future<void> _cancelNativeAlarm() async {
    if (!Platform.isAndroid) return;
    try {
      await _exactAlarmChannel.invokeMethod<void>('cancelPrayerAlarm');
    } catch (_) {}
  }

  /// Cancel all prayer-related notifications (main and snooze).
  Future<void> _cancelAll() async {
    await _notificationsPlugin.cancel(id: prayerAlarmNotificationId);
    await _notificationsPlugin.cancel(id: snoozeNotificationId);
  }

  /// Schedule the next occurrence for [prayerName]. If today's time has passed, schedule for tomorrow.
  /// On Android uses native AlarmManager so the alarm actually rings on the device.
  Future<void> _scheduleNext(String prayerName) async {
    await ensureTimezoneInitialized();
    final coordinates = await getCoordinates();
    final params = CalculationMethod.karachi.getParameters();
    params.madhab = Madhab.hanafi;

    final now = DateTime.now();
    PrayerTimes prayerTimes = PrayerTimes.today(coordinates, params);
    DateTime scheduledTime = _getPrayerDateTime(prayerTimes, prayerName);

    if (scheduledTime.isBefore(now) || scheduledTime.isAtSameMomentAs(now)) {
      final tomorrow = now.add(const Duration(days: 1));
      prayerTimes = PrayerTimes(
        coordinates,
        DateComponents.from(tomorrow),
        params,
      );
      scheduledTime = _getPrayerDateTime(prayerTimes, prayerName);
    }

    final timeFormatted = DateFormat.jm().format(scheduledTime);
    final triggerAtMillis = scheduledTime.millisecondsSinceEpoch;

    // On Android: use native AlarmManager so alarm rings at exact time (even when app is closed).
    if (Platform.isAndroid) {
      try {
        final scheduled = await _exactAlarmChannel.invokeMethod<bool>('schedulePrayerAlarm', {
          'timestampMillis': triggerAtMillis,
          'prayerName': prayerName,
          'timeFormatted': timeFormatted,
        });
        if (scheduled == true) return;
      } catch (_) {}
    }

    // Fallback: scheduled notification (iOS or if native scheduling failed).
    final payload = jsonEncode({
      payloadType: payloadTypePrayerAlarm,
      payloadPrayer: prayerName,
      payloadTime: timeFormatted,
    });

    final tz.TZDateTime tzDate;
    if (_timezoneFallback) {
      final instantMs = scheduledTime.millisecondsSinceEpoch;
      tzDate = tz.TZDateTime.fromMillisecondsSinceEpoch(tz.UTC, instantMs);
    } else {
      tzDate = tz.TZDateTime.from(scheduledTime, tz.local);
    }
    await _notificationsPlugin.zonedSchedule(
      id: prayerAlarmNotificationId,
      title: 'Prayer Time',
      body: "It's time for $prayerName",
      scheduledDate: tzDate,
      notificationDetails: NotificationDetails(
        android: AndroidNotificationDetails(
          'prayer_alarm_channel',
          'Prayer Alarms',
          channelDescription: 'Notifications for prayer times',
          importance: Importance.max,
          priority: Priority.max,
          fullScreenIntent: true,
          category: AndroidNotificationCategory.alarm,
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentSound: true,
          interruptionLevel: InterruptionLevel.timeSensitive,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      payload: payload,
    );
  }

  DateTime _getPrayerDateTime(PrayerTimes prayerTimes, String prayerName) {
    switch (prayerName) {
      case 'Fajr':
        return prayerTimes.fajr;
      case 'Sunrise':
        return prayerTimes.sunrise;
      case 'Zuhr':
        return prayerTimes.dhuhr;
      case 'Asr':
        return prayerTimes.asr;
      case 'Maghrib':
        return prayerTimes.maghrib;
      case 'Isha':
        return prayerTimes.isha;
      default:
        return prayerTimes.fajr;
    }
  }

  /// Call on app start or when Prayer screen loads to reschedule after reboot or new day.
  Future<void> rescheduleIfNeeded() async {
    final enabled = await getEnabledPrayer();
    if (enabled == null || enabled.isEmpty) return;
    await _cancelAll();
    await _cancelNativeAlarm();
    await _scheduleNext(enabled);
  }

  /// Schedule a snooze: show alarm again after [snoozeDuration] with same payload.
  Future<void> scheduleSnooze(String prayerName, String timeFormatted) async {
    await _notificationsPlugin.cancel(id: snoozeNotificationId);
    await ensureTimezoneInitialized();
    final tz.TZDateTime when;
    if (_timezoneFallback) {
      final nowMs = DateTime.now().millisecondsSinceEpoch;
      when = tz.TZDateTime.fromMillisecondsSinceEpoch(tz.UTC, nowMs).add(snoozeDuration);
    } else {
      when = tz.TZDateTime.now(tz.local).add(snoozeDuration);
    }
    final payload = jsonEncode({
      payloadType: payloadTypePrayerAlarm,
      payloadPrayer: prayerName,
      payloadTime: timeFormatted,
    });
    await _notificationsPlugin.zonedSchedule(
      id: snoozeNotificationId,
      title: 'Prayer Time',
      body: "It's time for $prayerName",
      scheduledDate: when,
      notificationDetails: NotificationDetails(
        android: AndroidNotificationDetails(
          'prayer_alarm_channel',
          'Prayer Alarms',
          channelDescription: 'Notifications for prayer times',
          importance: Importance.max,
          priority: Priority.max,
          fullScreenIntent: true,
          category: AndroidNotificationCategory.alarm,
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentSound: true,
          interruptionLevel: InterruptionLevel.timeSensitive,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      payload: payload,
    );
  }

  /// Cancel snooze (e.g. when user disables prayer alarm).
  Future<void> cancelSnooze() async {
    await _notificationsPlugin.cancel(id: snoozeNotificationId);
  }
}
