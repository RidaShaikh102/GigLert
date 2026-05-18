package com.giglert.app

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent

class DeviceBootReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        val action = intent.action ?: return
        if (action != Intent.ACTION_BOOT_COMPLETED && action != Intent.ACTION_MY_PACKAGE_REPLACED) {
            return
        }

        val config = AppPreferences.readConfig(context)
        if (config.monitoringEnabled && config.foregroundServiceEnabled) {
            MonitoringForegroundService.start(context)
        }
    }
}
