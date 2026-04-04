import 'dart:convert';

import 'package:app5/Service/notification_provider.dart';
import 'package:app5/Service/prayer_alarm_service.dart'
    show
        payloadPrayer,
        payloadTime,
        payloadType,
        payloadTypePrayerAlarm,
        PrayerAlarmService;
import 'package:app5/Screens/AlarmScreen.dart';
import 'package:app5/Screens/Juz_screen.dart';
import 'package:app5/Screens/SplashScreen.dart';
import 'package:app5/Screens/surah_details.dart';
import 'package:app5/Widget/BottomW.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io' show Platform;

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  const AndroidInitializationSettings androidInit =
      AndroidInitializationSettings('@mipmap/launcher_icon');
  const DarwinInitializationSettings iosInit = DarwinInitializationSettings(
    requestAlertPermission: true,
    requestSoundPermission: true,
    requestBadgePermission: true,
  );
  const InitializationSettings initSettings = InitializationSettings(
    android: androidInit,
    iOS: iosInit,
  );

  final FlutterLocalNotificationsPlugin plugin =
      FlutterLocalNotificationsPlugin();

  try {
    await plugin.initialize(
      settings: initSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        if (response.payload != null && response.payload!.isNotEmpty) {
          _openAlarmScreenIfPrayerPayload(response.payload!);
        }
      },
    );

    await plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(const AndroidNotificationChannel(
          'prayer_alarm_channel',
          'Prayer Alarms',
          description: 'Notifications for prayer times',
          importance: Importance.max,
          playSound: true,
          enableVibration: true,
        ));

    initPrayerAlarmGlobals(plugin);

    await _requestPermissions();
  } catch (e, stack) {
    debugPrint('Startup error: $e');
    debugPrint(stack.toString());
  }

  runApp(MyApp());
}

void _openAlarmScreenIfPrayerPayload(String payload) {
  try {
    final map = jsonDecode(payload) as Map<String, dynamic>;
    if (map[payloadType] == payloadTypePrayerAlarm) {
      navigatorKey.currentState?.pushNamed(
        AlarmScreen.id,
        arguments: payload,
      );
    }
  } catch (_) {}
}

Future<void> _requestPermissions() async {
  await Permission.notification.request();
}

class MyApp extends StatefulWidget {
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _alreadyUsed = false;
  bool _checkedLaunch = false;

  @override
  void initState() {
    super.initState();
    _loadPrefs();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      try {
        await PrayerAlarmService.ensureTimezoneInitialized();
        await prayerAlarmService.rescheduleIfNeeded();
      } catch (_) {}
    });
  }

  Future<void> _loadPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final alreadyUsed = prefs.getBool("already used") ?? false;
    if (mounted) setState(() => _alreadyUsed = alreadyUsed);
  }

  void _checkNotificationLaunch() {
    if (_checkedLaunch) return;
    _checkedLaunch = true;
    notificationsPlugin.getNotificationAppLaunchDetails().then((details) {
      final response = details?.notificationResponse;
      if (details?.didNotificationLaunchApp == true &&
          response?.payload != null &&
          response!.payload!.isNotEmpty) {
        _openAlarmScreenIfPrayerPayload(response.payload!);
      }
    });
    // If app was opened from native alarm (full-screen intent), open AlarmScreen.
    if (Platform.isAndroid) {
      _checkAlarmLaunchPayload();
    }
  }

  Future<void> _checkAlarmLaunchPayload() async {
    try {
      await Future.delayed(const Duration(milliseconds: 500));
      const channel = MethodChannel('com.example.app5/prayer_alarm');
      final payload = await channel
          .invokeMethod<Map<dynamic, dynamic>>('getAlarmLaunchPayload');
      if (payload == null) return;
      if (navigatorKey.currentState == null) return;
      final prayerName = payload['prayerName'] as String? ?? 'Prayer';
      final timeFormatted = payload['timeFormatted'] as String? ?? '';
      final args = jsonEncode({
        payloadPrayer: prayerName,
        payloadTime: timeFormatted,
      });
      navigatorKey.currentState?.pushNamed(AlarmScreen.id, arguments: args);
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF4D8B5E),
          brightness: Brightness.light,
        ),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF4D8B5E),
          brightness: Brightness.dark,
        ),
      ),
      themeMode: ThemeMode.system,
      home: _HomeWithLaunchCheck(
        alreadyUsed: _alreadyUsed,
        onFrameCallback: _checkNotificationLaunch,
      ),
      routes: {
        JuzScreen.id: (context) => JuzScreen(),
        SurahDetails.id: (context) => SurahDetails(),
        AlarmScreen.id: (context) => AlarmScreen(),
      },
    );
  }
}

class _HomeWithLaunchCheck extends StatefulWidget {
  const _HomeWithLaunchCheck({
    required this.alreadyUsed,
    required this.onFrameCallback,
  });

  final bool alreadyUsed;
  final VoidCallback onFrameCallback;

  @override
  State<_HomeWithLaunchCheck> createState() => _HomeWithLaunchCheckState();
}

class _HomeWithLaunchCheckState extends State<_HomeWithLaunchCheck> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.onFrameCallback();
    });
  }

  @override
  Widget build(BuildContext context) {
    return widget.alreadyUsed ? BottomW() : SplashScreen();
  }
}
