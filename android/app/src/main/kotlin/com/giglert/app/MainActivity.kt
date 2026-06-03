package com.giglert.app

import android.app.AlarmManager
import android.app.NotificationManager
import android.content.ComponentName
import android.content.Intent
import android.net.Uri
import android.os.Build
import android.os.PowerManager
import android.provider.Settings
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        EventChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            "com.giglert.app/notification_events",
        ).setStreamHandler(NotificationEventStreamHandler)

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            "com.giglert.app/native_bridge",
        ).setMethodCallHandler(::handleMethodCall)
    }

    private fun handleMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "getPermissionSnapshot" -> {
                result.success(
                    hashMapOf(
                        "notificationListenerEnabled" to isNotificationListenerEnabled(),
                        "batteryOptimizationIgnored" to isIgnoringBatteryOptimizations(),
                        "exactAlarmGranted" to canScheduleExactAlarms(),
                        "fullScreenIntentGranted" to canUseFullScreenIntent(),
                    ),
                )
            }

            "syncMonitoringConfig" -> {
                val arguments = call.arguments<Map<*, *>>() ?: emptyMap<String, Any>()
                val config = MonitoringConfig.fromMap(arguments)
                AppPreferences.saveConfig(this, config)
                NotificationChannels.ensure(this)

                if (config.monitoringEnabled && config.foregroundServiceEnabled) {
                    MonitoringForegroundService.start(this)
                } else {
                    MonitoringForegroundService.stop(this)
                }

                result.success(null)
            }

            "openNotificationAccessSettings" -> {
                startActivity(Intent(Settings.ACTION_NOTIFICATION_LISTENER_SETTINGS))
                result.success(null)
            }

            "openAppDetailsSettings" -> {
                startActivity(
                    Intent(Settings.ACTION_APPLICATION_DETAILS_SETTINGS).apply {
                        data = Uri.parse("package:$packageName")
                    },
                )
                result.success(null)
            }

            "openBatteryOptimizationSettings" -> {
                startActivity(Intent(Settings.ACTION_IGNORE_BATTERY_OPTIMIZATION_SETTINGS))
                result.success(null)
            }

            "requestIgnoreBatteryOptimizations" -> {
                startActivity(
                    Intent(Settings.ACTION_REQUEST_IGNORE_BATTERY_OPTIMIZATIONS).apply {
                        data = Uri.parse("package:$packageName")
                    },
                )
                result.success(null)
            }

            "openExactAlarmSettings" -> {
                val intent =
                    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
                        Intent(Settings.ACTION_REQUEST_SCHEDULE_EXACT_ALARM).apply {
                            data = Uri.parse("package:$packageName")
                        }
                    } else {
                        Intent(Settings.ACTION_APPLICATION_DETAILS_SETTINGS).apply {
                            data = Uri.parse("package:$packageName")
                        }
                    }
                startActivity(intent)
                result.success(null)
            }

            "startNativeAlarmPreview" -> {
                val arguments = call.arguments<Map<*, *>>() ?: emptyMap<String, Any>()
                val payload = AlertPayload(
                    id = System.currentTimeMillis().toString(),
                    packageName = AppPreferences.FIVERR_PACKAGE,
                    title = arguments["title"] as? String ?: "Test Fiverr alert",
                    body = arguments["body"] as? String
                        ?: "This is a native full-screen preview of the Fiverr alarm flow.",
                    type = arguments["type"] as? String ?: "test",
                    receivedAt = System.currentTimeMillis(),
                    alarmTriggered = true,
                )
                AlarmPlaybackService.start(this, payload)
                result.success(null)
            }

            "stopNativeAlarm" -> {
                AlarmPlaybackService.stop(this)
                result.success(null)
            }

            else -> result.notImplemented()
        }
    }

    private fun isNotificationListenerEnabled(): Boolean {
        val componentName = ComponentName(this, FiverrNotificationListenerService::class.java)
        val enabledListeners =
            Settings.Secure.getString(contentResolver, "enabled_notification_listeners")
                ?: return false
        return enabledListeners.contains(componentName.flattenToString())
    }

    private fun isIgnoringBatteryOptimizations(): Boolean {
        val powerManager = getSystemService(PowerManager::class.java)
        return powerManager.isIgnoringBatteryOptimizations(packageName)
    }

    private fun canScheduleExactAlarms(): Boolean {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.S) {
            return true
        }

        val alarmManager = getSystemService(AlarmManager::class.java)
        return alarmManager.canScheduleExactAlarms()
    }

    private fun canUseFullScreenIntent(): Boolean {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.UPSIDE_DOWN_CAKE) {
            return true
        }

        val notificationManager = getSystemService(NotificationManager::class.java)
        return notificationManager.canUseFullScreenIntent()
    }
}
