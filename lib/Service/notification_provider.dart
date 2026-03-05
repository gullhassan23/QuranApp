import 'package:app5/Service/prayer_alarm_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

FlutterLocalNotificationsPlugin? _plugin;
PrayerAlarmService? _prayerAlarmService;

void initPrayerAlarmGlobals(FlutterLocalNotificationsPlugin plugin) {
  _plugin = plugin;
  _prayerAlarmService = PrayerAlarmService(plugin);
}

FlutterLocalNotificationsPlugin get notificationsPlugin {
  if (_plugin == null) throw StateError('Prayer alarm not initialized');
  return _plugin!;
}

PrayerAlarmService get prayerAlarmService {
  if (_prayerAlarmService == null) throw StateError('Prayer alarm not initialized');
  return _prayerAlarmService!;
}
