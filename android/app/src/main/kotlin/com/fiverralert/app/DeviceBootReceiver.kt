package com.giglert.app

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.os.Build

class DeviceBootReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        val action = intent.action ?: return
        if (action != Intent.ACTION_BOOT_COMPLETED && action != Intent.ACTION_MY_PACKAGE_REPLACED) {
            return
        }

        // Android 15+ blocks dataSync foreground services from BOOT_COMPLETED and
        // MY_PACKAGE_REPLACED receivers. Monitoring restarts when the user opens
        // the app or when the notification listener reconnects.
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.VANILLA_ICE_CREAM) {
            return
        }

        val config = AppPreferences.readConfig(context)
        if (config.monitoringEnabled && config.foregroundServiceEnabled) {
            MonitoringForegroundService.start(context)
        }
    }
}
