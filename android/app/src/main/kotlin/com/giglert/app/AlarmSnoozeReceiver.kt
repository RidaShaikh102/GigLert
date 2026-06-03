package com.giglert.app

import android.app.AlarmManager
import android.app.PendingIntent
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.os.Build

class AlarmSnoozeReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        val payload = AlertPayload.fromIntent(intent) ?: AppPreferences.readPendingAlert(context)
        payload ?: return
        AlarmPlaybackService.start(context, payload)
    }

    companion object {
        private const val REQUEST_CODE = 4408

        fun schedule(context: Context, payload: AlertPayload, snoozeMinutes: Int) {
            val alarmManager = context.getSystemService(AlarmManager::class.java)
            val triggerAtMillis = System.currentTimeMillis() + (snoozeMinutes * 60_000L)
            val pendingIntent = buildPendingIntent(context, payload)

            cancel(context)

            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S && !alarmManager.canScheduleExactAlarms()) {
                alarmManager.setAndAllowWhileIdle(
                    AlarmManager.RTC_WAKEUP,
                    triggerAtMillis,
                    pendingIntent,
                )
            } else {
                alarmManager.setExactAndAllowWhileIdle(
                    AlarmManager.RTC_WAKEUP,
                    triggerAtMillis,
                    pendingIntent,
                )
            }
        }

        fun cancel(context: Context) {
            val alarmManager = context.getSystemService(AlarmManager::class.java)
            alarmManager.cancel(buildPendingIntent(context, null))
        }

        private fun buildPendingIntent(
            context: Context,
            payload: AlertPayload?,
        ): PendingIntent {
            val intent = Intent(context, AlarmSnoozeReceiver::class.java).apply {
                payload?.let { putExtras(it.toBundle()) }
            }
            return PendingIntent.getBroadcast(
                context,
                REQUEST_CODE,
                intent,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
            )
        }
    }
}
