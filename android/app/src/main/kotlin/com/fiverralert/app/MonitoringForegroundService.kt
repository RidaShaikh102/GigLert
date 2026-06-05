package com.giglert.app

import android.app.ForegroundServiceStartNotAllowedException
import android.app.PendingIntent
import android.app.Service
import android.content.Context
import android.content.Intent
import android.content.pm.ServiceInfo
import android.os.IBinder
import android.util.Log
import androidx.core.app.NotificationCompat
import androidx.core.app.ServiceCompat
import androidx.core.content.ContextCompat

/**
 * MonitoringForegroundService - Continuous Data Sync Service
 *
 * Android 14+ Compliance:
 * - Foreground Service Type: dataSync
 * - Reason: This service continuously synchronizes data from Fiverr platform,
 *   checking for new job opportunities and notifications at user-configured
 *   intervals.
 *
 * Purpose:
 * Maintains continuous background monitoring of the user's Fiverr account for
 * new job opportunities and platform updates. Runs at user-configured intervals
 * to check for new alerts and notifications.
 *
 * Implementation:
 * - Starts as foreground service via startForeground() with persistent notification
 * - Foreground notification shows monitoring status and current schedule
 * - Can be enabled/disabled by user through app settings
 * - Syncs data at configurable intervals (default 1-30 minutes)
 * - Gracefully stops if monitoring is disabled by user
 *
 * Why Foreground Service is Required:
 * 1. Data sync must continue reliably even during low memory or battery pressure
 * 2. Users depend on timely job opportunity alerts (income-critical)
 * 3. System could otherwise terminate the monitoring process during optimization
 * 4. Transparent notification keeps users informed of monitoring status
 * 5. Users have full control: can enable/disable monitoring at any time
 *
 * User Control:
 * - Monitoring can be enabled/disabled in app settings
 * - Foreground service can be toggled independently
 * - User sees persistent notification during monitoring
 * - Tapping notification launches app with recent opportunities
 *
 * Manifest Declaration:
 * <service
 *     android:name=".MonitoringForegroundService"
 *     android:foregroundServiceType="dataSync"
 *     android:enabled="true"
 *     android:exported="false"
 *     android:stopWithTask="false" />
 *
 * Technical Details:
 * - Data Source: Fiverr API/platform via HTTP requests
 * - Frequency: User-configurable intervals (determined by AppPreferences.readConfig)
 * - Persistence: Stored in local database for offline access
 * - Notifications: System notifications created for new opportunities
 * - Lifecycle: Stops immediately if user disables monitoring
 */
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

        if (!promoteToForeground(config)) {
            stopSelf()
            return START_NOT_STICKY
        }

        return START_STICKY
    }

    private fun promoteToForeground(config: MonitoringConfig): Boolean {
        return try {
            ServiceCompat.startForeground(
                this,
                MONITORING_NOTIFICATION_ID,
                buildNotification(config),
                ServiceInfo.FOREGROUND_SERVICE_TYPE_DATA_SYNC,
            )
            true
        } catch (error: SecurityException) {
            Log.e(
                TAG,
                "Missing FOREGROUND_SERVICE_DATA_SYNC permission in installed APK",
                error,
            )
            false
        } catch (error: Exception) {
            Log.e(TAG, "Failed to start monitoring foreground service", error)
            false
        }
    }

    override fun onTimeout(startId: Int, fgsType: Int) {
        super.onTimeout(startId, fgsType)
        stopForeground(STOP_FOREGROUND_REMOVE)
        stopSelf()
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
        private const val TAG = "MonitoringForegroundService"
        private const val MONITORING_NOTIFICATION_ID = 4401

        fun start(context: Context) {
            try {
                ContextCompat.startForegroundService(
                    context,
                    Intent(context, MonitoringForegroundService::class.java),
                )
            } catch (error: ForegroundServiceStartNotAllowedException) {
                Log.w(TAG, "Monitoring foreground service start blocked by system", error)
            } catch (error: SecurityException) {
                Log.w(TAG, "Monitoring foreground service permission denied", error)
            } catch (error: IllegalStateException) {
                Log.w(TAG, "Monitoring foreground service start failed", error)
            }
        }

        fun stop(context: Context) {
            context.stopService(Intent(context, MonitoringForegroundService::class.java))
        }
    }
}
