package com.giglert.app

import android.app.NotificationChannel
import android.app.NotificationManager
import android.content.Context
import android.os.Build

object NotificationChannels {
    const val MONITORING_CHANNEL_ID = "fiverr_alert_monitoring"
    const val ALARM_CHANNEL_ID = "fiverr_alert_alarm"

    fun ensure(context: Context) {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.O) {
            return
        }

        val manager = context.getSystemService(NotificationManager::class.java)

        val monitoringChannel = NotificationChannel(
            MONITORING_CHANNEL_ID,
            "Monitoring service",
            NotificationManager.IMPORTANCE_LOW,
        ).apply {
            description = "Persistent service status while Fiverr monitoring is active."
            setSound(null, null)
            enableVibration(false)
        }

        val alarmChannel = NotificationChannel(
            ALARM_CHANNEL_ID,
            "Fiverr alarms",
            NotificationManager.IMPORTANCE_HIGH,
        ).apply {
            description = "High-priority full-screen Fiverr notification alarms."
            lockscreenVisibility = android.app.Notification.VISIBILITY_PUBLIC
            setSound(null, null)
            enableVibration(false)
        }

        manager.createNotificationChannel(monitoringChannel)
        manager.createNotificationChannel(alarmChannel)
    }
}
