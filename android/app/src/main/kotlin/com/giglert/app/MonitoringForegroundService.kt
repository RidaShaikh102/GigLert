package com.giglert.app

import android.app.PendingIntent
import android.app.Service
import android.content.Context
import android.content.Intent
import android.os.IBinder
import android.util.Log
import androidx.core.app.NotificationCompat
import androidx.core.content.ContextCompat

class MonitoringForegroundService : Service() {
    override fun onBind(intent: Intent?): IBinder? = null

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        NotificationChannels.ensure(this)
        val config = AppPreferences.readConfig(this)

        if (!config.monitoringEnabled || !config.foregroundServiceEnabled) {
            stopForeground(STOP_FOREGROUND_REMOVE)
            stopSelf()
            return START_NOT_STICKY
        }

        return try {
            startForeground(MONITORING_NOTIFICATION_ID, buildNotification(config))
            START_STICKY
        } catch (error: RuntimeException) {
            Log.w(TAG, "Unable to start monitoring foreground service.", error)
            stopSelf()
            START_NOT_STICKY
        }
    }

    private fun buildNotification(config: MonitoringConfig): android.app.Notification {
        val launchIntent = packageManager.getLaunchIntentForPackage(packageName)
            ?: Intent(this, MainActivity::class.java)
        val pendingIntent = PendingIntent.getActivity(
            this,
            2001,
            launchIntent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
        )

        return NotificationCompat.Builder(this, NotificationChannels.MONITORING_CHANNEL_ID)
            .setSmallIcon(R.mipmap.ic_launcher)
            .setContentTitle("Fiverr Alert is monitoring")
            .setContentText("Watching Fiverr during ${config.scheduleLabel()}")
            .setContentIntent(pendingIntent)
            .setOngoing(true)
            .setCategory(NotificationCompat.CATEGORY_SERVICE)
            .setForegroundServiceBehavior(NotificationCompat.FOREGROUND_SERVICE_IMMEDIATE)
            .build()
    }

    companion object {
        private const val TAG = "MonitoringService"
        private const val MONITORING_NOTIFICATION_ID = 4401

        fun start(context: Context): Boolean {
            return try {
                ContextCompat.startForegroundService(
                    context,
                    Intent(context, MonitoringForegroundService::class.java),
                )
                true
            } catch (error: RuntimeException) {
                Log.w(TAG, "Unable to request monitoring foreground service start.", error)
                false
            }
        }

        fun stop(context: Context) {
            context.stopService(Intent(context, MonitoringForegroundService::class.java))
        }
    }
}
