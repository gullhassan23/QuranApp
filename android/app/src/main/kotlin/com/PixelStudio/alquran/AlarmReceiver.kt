package com.PixelStudio.alquran

import android.app.AlarmManager
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.media.AudioAttributes
import android.net.Uri
import android.os.Build
import androidx.core.app.NotificationCompat
import androidx.core.app.NotificationManagerCompat

/**
 * Receives alarm from AlarmManager and shows a high-priority notification with sound
 * so the prayer alarm actually rings on the device.
 */
class AlarmReceiver : BroadcastReceiver() {

    override fun onReceive(context: Context, intent: Intent) {
        if (intent.action != ACTION_PRAYER_ALARM) return

        val prayerName = intent.getStringExtra(EXTRA_PRAYER_NAME) ?: "Prayer"
        val timeFormatted = intent.getStringExtra(EXTRA_TIME_FORMATTED) ?: ""
        val isTestAlarm = intent.getBooleanExtra(EXTRA_IS_TEST_ALARM, false)
        val notificationId = if (isTestAlarm) NOTIFICATION_ID_TEST else NOTIFICATION_ID

        createAlarmChannel(context)
        showAlarmNotification(context, prayerName, timeFormatted, notificationId)
    }

    private fun createAlarmChannel(context: Context) {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.O) return
        val soundUri = getAlarmSoundUri(context)
        val channel = NotificationChannel(
            CHANNEL_ID,
            "Prayer Alarms",
            NotificationManager.IMPORTANCE_HIGH
        ).apply {
            description = "Notifications for prayer times"
            setBypassDnd(true)
            enableVibration(true)
            setSound(
                soundUri,
                AudioAttributes.Builder()
                    .setUsage(AudioAttributes.USAGE_ALARM)
                    .setContentType(AudioAttributes.CONTENT_TYPE_SONIFICATION)
                    .build()
            )
        }
        val manager = context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
        manager.createNotificationChannel(channel)
    }

    /** Custom alarm tune from res/raw/alarm.wav; falls back to system default if missing. */
    private fun getAlarmSoundUri(context: Context): Uri {
        return Uri.parse("android.resource://${context.packageName}/raw/alarm")
    }

    private fun showAlarmNotification(context: Context, prayerName: String, timeFormatted: String, notificationId: Int = NOTIFICATION_ID) {
        val fullScreenIntent = Intent(context, MainActivity::class.java).apply {
            flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP or
                    Intent.FLAG_ACTIVITY_EXCLUDE_FROM_RECENTS or Intent.FLAG_ACTIVITY_NO_USER_ACTION
            putExtra(EXTRA_PRAYER_NAME, prayerName)
            putExtra(EXTRA_TIME_FORMATTED, timeFormatted)
            putExtra(EXTRA_OPEN_ALARM_SCREEN, true)
        }
        val fullScreenPending = PendingIntent.getActivity(
            context,
            notificationId,
            fullScreenIntent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )

        val notification = NotificationCompat.Builder(context, CHANNEL_ID)
            .setSmallIcon(android.R.drawable.ic_lock_idle_alarm)
            .setContentTitle("Prayer Time")
            .setContentText("It's time for $prayerName")
            .setPriority(NotificationCompat.PRIORITY_MAX)
            .setCategory(NotificationCompat.CATEGORY_ALARM)
            .setVisibility(NotificationCompat.VISIBILITY_PUBLIC)
            .setAutoCancel(true)
            .setSound(
                getAlarmSoundUri(context),
                android.media.AudioManager.STREAM_ALARM
            )
            .setVibrate(longArrayOf(0, 500, 200, 500))
            .setFullScreenIntent(fullScreenPending, true)
            .setContentIntent(fullScreenPending)
            .build()

        try {
            NotificationManagerCompat.from(context).notify(notificationId, notification)
        } catch (_: SecurityException) {}
    }

    companion object {
        const val ACTION_PRAYER_ALARM = "com.PixelStudio.alquran.PRAYER_ALARM"
        const val CHANNEL_ID = "prayer_alarm_channel_v2"
        const val NOTIFICATION_ID = 100

        const val EXTRA_PRAYER_NAME = "prayer_name"
        const val EXTRA_TIME_FORMATTED = "time_formatted"
        const val EXTRA_OPEN_ALARM_SCREEN = "open_alarm_screen"
        const val EXTRA_IS_TEST_ALARM = "is_test_alarm"

        private const val REQUEST_CODE_ALARM = 2001
        private const val REQUEST_CODE_TEST_ALARM = 2003
        private const val NOTIFICATION_ID_TEST = 102

        fun scheduleAlarm(context: Context, triggerAtMillis: Long, prayerName: String, timeFormatted: String): Boolean {
            val alarmManager = context.getSystemService(Context.ALARM_SERVICE) as? AlarmManager ?: return false
            val intent = Intent(context, AlarmReceiver::class.java).apply {
                action = ACTION_PRAYER_ALARM
                putExtra(EXTRA_PRAYER_NAME, prayerName)
                putExtra(EXTRA_TIME_FORMATTED, timeFormatted)
            }
            val pending = PendingIntent.getBroadcast(
                context,
                REQUEST_CODE_ALARM,
                intent,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
            )
            return try {
                // setAlarmClock: works without SCHEDULE_EXACT_ALARM, fires at exact time, shows alarm icon in status bar.
                val showIntent = Intent(context, MainActivity::class.java).apply {
                    putExtra(EXTRA_PRAYER_NAME, prayerName)
                    putExtra(EXTRA_TIME_FORMATTED, timeFormatted)
                    putExtra(EXTRA_OPEN_ALARM_SCREEN, true)
                }
                val showPending = PendingIntent.getActivity(
                    context,
                    REQUEST_CODE_ALARM + 1,
                    showIntent,
                    PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
                )
                val alarmClockInfo = AlarmManager.AlarmClockInfo(triggerAtMillis, showPending)
                alarmManager.setAlarmClock(alarmClockInfo, pending)
                true
            } catch (_: Exception) {
                false
            }
        }

        fun cancelAlarm(context: Context) {
            val alarmManager = context.getSystemService(Context.ALARM_SERVICE) as? AlarmManager ?: return
            val intent = Intent(context, AlarmReceiver::class.java).apply { action = ACTION_PRAYER_ALARM }
            val pending = PendingIntent.getBroadcast(
                context,
                REQUEST_CODE_ALARM,
                intent,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
            )
            alarmManager.cancel(pending)
            (context.getSystemService(Context.NOTIFICATION_SERVICE) as? NotificationManager)?.cancel(NOTIFICATION_ID)
        }

        fun scheduleTestAlarm(context: Context, triggerAtMillis: Long): Boolean {
            val alarmManager = context.getSystemService(Context.ALARM_SERVICE) as? AlarmManager ?: return false
            val minutes = ((triggerAtMillis - System.currentTimeMillis()) / 60_000).toInt().coerceAtLeast(0)
            val timeFormatted = if (minutes <= 1) "In 1 min" else "In $minutes min"
            val intent = Intent(context, AlarmReceiver::class.java).apply {
                action = ACTION_PRAYER_ALARM
                putExtra(EXTRA_PRAYER_NAME, "Test alarm")
                putExtra(EXTRA_TIME_FORMATTED, timeFormatted)
                putExtra(EXTRA_IS_TEST_ALARM, true)
            }
            val pending = PendingIntent.getBroadcast(
                context,
                REQUEST_CODE_TEST_ALARM,
                intent,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
            )
            return try {
                val showIntent = Intent(context, MainActivity::class.java).apply {
                    putExtra(EXTRA_PRAYER_NAME, "Test alarm")
                    putExtra(EXTRA_TIME_FORMATTED, timeFormatted)
                    putExtra(EXTRA_OPEN_ALARM_SCREEN, true)
                }
                val showPending = PendingIntent.getActivity(
                    context,
                    REQUEST_CODE_TEST_ALARM + 1,
                    showIntent,
                    PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
                )
                val alarmClockInfo = AlarmManager.AlarmClockInfo(triggerAtMillis, showPending)
                alarmManager.setAlarmClock(alarmClockInfo, pending)
                true
            } catch (_: Exception) {
                false
            }
        }

        fun cancelTestAlarm(context: Context) {
            val alarmManager = context.getSystemService(Context.ALARM_SERVICE) as? AlarmManager ?: return
            val intent = Intent(context, AlarmReceiver::class.java).apply { action = ACTION_PRAYER_ALARM }
            val pending = PendingIntent.getBroadcast(
                context,
                REQUEST_CODE_TEST_ALARM,
                intent,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
            )
            alarmManager.cancel(pending)
            (context.getSystemService(Context.NOTIFICATION_SERVICE) as? NotificationManager)?.cancel(NOTIFICATION_ID_TEST)
        }
    }
}
