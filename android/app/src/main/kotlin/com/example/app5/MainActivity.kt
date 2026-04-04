package com.example.app5

import android.app.AlarmManager
import android.content.Intent
import android.net.Uri
import android.os.Build
import android.os.Bundle
import android.provider.Settings
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {

    private val channelName = "com.example.app5/prayer_alarm"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channelName).setMethodCallHandler { call, result ->
            when (call.method) {
                "canScheduleExactAlarms" -> {
                    result.success(canScheduleExactAlarms())
                }
                "openExactAlarmSettings" -> {
                    openExactAlarmSettings()
                    result.success(null)
                }
                "schedulePrayerAlarm" -> {
                    val args = call.arguments as? Map<String, Any?>
                    val timestamp: Long? = (args?.get("timestampMillis") as? Number)?.toLong()
                    val prayerName = args?.get("prayerName") as? String ?: ""
                    val timeFormatted = args?.get("timeFormatted") as? String ?: ""
                    if (timestamp != null && timestamp > 0L) {
                        result.success(AlarmReceiver.scheduleAlarm(this, timestamp, prayerName, timeFormatted))
                    } else {
                        result.success(false)
                    }
                }
                "cancelPrayerAlarm" -> {
                    AlarmReceiver.cancelAlarm(this)
                    result.success(null)
                }
                "scheduleTestAlarm" -> {
                    val args = call.arguments as? Map<String, Any?>
                    val timestamp: Long? = (args?.get("timestampMillis") as? Number)?.toLong()
                    if (timestamp != null && timestamp > 0L) {
                        result.success(AlarmReceiver.scheduleTestAlarm(this, timestamp))
                    } else {
                        result.success(false)
                    }
                }
                "cancelTestAlarm" -> {
                    AlarmReceiver.cancelTestAlarm(this)
                    result.success(null)
                }
                "getAlarmLaunchPayload" -> {
                    val openAlarm = intent?.getBooleanExtra(AlarmReceiver.EXTRA_OPEN_ALARM_SCREEN, false) == true
                    if (openAlarm) {
                        val map = hashMapOf<String, Any?>(
                            "prayerName" to intent?.getStringExtra(AlarmReceiver.EXTRA_PRAYER_NAME),
                            "timeFormatted" to intent?.getStringExtra(AlarmReceiver.EXTRA_TIME_FORMATTED)
                        )
                        intent?.removeExtra(AlarmReceiver.EXTRA_OPEN_ALARM_SCREEN)
                        result.success(map)
                    } else {
                        result.success(null)
                    }
                }
                else -> result.notImplemented()
            }
        }
    }

    private fun canScheduleExactAlarms(): Boolean {
        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            val alarmManager = getSystemService(ALARM_SERVICE) as? AlarmManager
            alarmManager?.canScheduleExactAlarms() ?: true
        } else {
            true
        }
    }

    private fun openExactAlarmSettings() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            val intent = Intent(Settings.ACTION_REQUEST_SCHEDULE_EXACT_ALARM).apply {
                data = Uri.parse("package:$packageName")
                addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
            }
            startActivity(intent)
        }
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            getSplashScreen().setOnExitAnimationListener { splashScreenView -> splashScreenView.remove() }
        }
        super.onCreate(savedInstanceState)
    }
}
