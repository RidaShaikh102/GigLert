package com.giglert.app

import android.content.Context
import android.content.Intent
import android.os.Bundle
import org.json.JSONObject
import java.util.Calendar

data class MonitoringConfig(
    val monitoringEnabled: Boolean = true,
    val startHour: Int = 8,
    val startMinute: Int = 0,
    val endHour: Int = 22,
    val endMinute: Int = 0,
    val vibrationEnabled: Boolean = true,
    val ringtoneId: String = "fiverr_pulse",
    val alarmVolume: Float = 0.92f,
    val repeatSeconds: Int = 20,
    val snoozeMinutes: Int = 5,
    val foregroundServiceEnabled: Boolean = true,
    val userId: String? = null,
) {
    fun isWithinActiveHours(now: Calendar = Calendar.getInstance()): Boolean {
        val currentMinutes = (now.get(Calendar.HOUR_OF_DAY) * 60) + now.get(Calendar.MINUTE)
        val startTotal = (startHour * 60) + startMinute
        val endTotal = (endHour * 60) + endMinute

        if (startTotal == endTotal) {
            return true
        }

        return if (startTotal < endTotal) {
            currentMinutes in startTotal until endTotal
        } else {
            currentMinutes >= startTotal || currentMinutes < endTotal
        }
    }

    fun scheduleLabel(): String {
        return String.format("%02d:%02d - %02d:%02d", startHour, startMinute, endHour, endMinute)
    }

    companion object {
        fun fromMap(map: Map<*, *>): MonitoringConfig {
            return MonitoringConfig(
                monitoringEnabled = map["monitoringEnabled"] as? Boolean ?: true,
                startHour = (map["startHour"] as? Number)?.toInt() ?: 8,
                startMinute = (map["startMinute"] as? Number)?.toInt() ?: 0,
                endHour = (map["endHour"] as? Number)?.toInt() ?: 22,
                endMinute = (map["endMinute"] as? Number)?.toInt() ?: 0,
                vibrationEnabled = map["vibrationEnabled"] as? Boolean ?: true,
                ringtoneId = map["ringtoneId"] as? String ?: "fiverr_pulse",
                alarmVolume = ((map["alarmVolume"] as? Number)?.toDouble() ?: 0.92).toFloat(),
                repeatSeconds = (map["repeatSeconds"] as? Number)?.toInt() ?: 20,
                snoozeMinutes = (map["snoozeMinutes"] as? Number)?.toInt() ?: 5,
                foregroundServiceEnabled = map["foregroundServiceEnabled"] as? Boolean ?: true,
                userId = map["userId"] as? String,
            )
        }
    }
}

data class AlertPayload(
    val id: String,
    val packageName: String,
    val title: String,
    val body: String,
    val type: String,
    val receivedAt: Long,
    val alarmTriggered: Boolean,
) {
    fun dedupeSignature(): String {
        return listOf(packageName, title.trim(), body.trim(), type.trim())
            .joinToString("|")
            .lowercase()
    }

    fun toFlutterMap(): HashMap<String, Any> {
        return hashMapOf(
            "id" to id,
            "packageName" to packageName,
            "title" to title,
            "body" to body,
            "type" to type,
            "receivedAt" to receivedAt,
            "alarmTriggered" to alarmTriggered,
        )
    }

    fun toBundle(): Bundle {
        return Bundle().apply {
            putString("id", id)
            putString("packageName", packageName)
            putString("title", title)
            putString("body", body)
            putString("type", type)
            putLong("receivedAt", receivedAt)
            putBoolean("alarmTriggered", alarmTriggered)
        }
    }

    fun toJsonString(): String {
        return JSONObject(toFlutterMap() as Map<*, *>).toString()
    }

    companion object {
        fun fromIntent(intent: Intent?): AlertPayload? {
            return fromBundle(intent?.extras)
        }

        fun fromBundle(bundle: Bundle?): AlertPayload? {
            bundle ?: return null
            val id = bundle.getString("id") ?: return null
            return AlertPayload(
                id = id,
                packageName = bundle.getString("packageName") ?: AppPreferences.FIVERR_PACKAGE,
                title = bundle.getString("title") ?: "Fiverr alert",
                body = bundle.getString("body") ?: "",
                type = bundle.getString("type") ?: "general",
                receivedAt = bundle.getLong("receivedAt", System.currentTimeMillis()),
                alarmTriggered = bundle.getBoolean("alarmTriggered", true),
            )
        }

        fun fromJsonString(json: String): AlertPayload? {
            return try {
                val payload = JSONObject(json)
                AlertPayload(
                    id = payload.optString("id"),
                    packageName = payload.optString("packageName", AppPreferences.FIVERR_PACKAGE),
                    title = payload.optString("title", "Fiverr alert"),
                    body = payload.optString("body", ""),
                    type = payload.optString("type", "general"),
                    receivedAt = payload.optLong("receivedAt", System.currentTimeMillis()),
                    alarmTriggered = payload.optBoolean("alarmTriggered", true),
                )
            } catch (_: Exception) {
                null
            }
        }
    }
}

object AppPreferences {
    const val FIVERR_PACKAGE = "com.fiverr.fiverr"

    private const val FILE_NAME = "fiverr_alert_native"
    private const val KEY_MONITORING_ENABLED = "monitoring_enabled"
    private const val KEY_START_HOUR = "start_hour"
    private const val KEY_START_MINUTE = "start_minute"
    private const val KEY_END_HOUR = "end_hour"
    private const val KEY_END_MINUTE = "end_minute"
    private const val KEY_VIBRATION_ENABLED = "vibration_enabled"
    private const val KEY_RINGTONE_ID = "ringtone_id"
    private const val KEY_ALARM_VOLUME = "alarm_volume"
    private const val KEY_REPEAT_SECONDS = "repeat_seconds"
    private const val KEY_SNOOZE_MINUTES = "snooze_minutes"
    private const val KEY_FOREGROUND_SERVICE_ENABLED = "foreground_service_enabled"
    private const val KEY_USER_ID = "user_id"
    private const val KEY_PENDING_ALERT = "pending_alert"

    private fun prefs(context: Context) =
        context.getSharedPreferences(FILE_NAME, Context.MODE_PRIVATE)

    fun saveConfig(context: Context, config: MonitoringConfig) {
        prefs(context).edit().apply {
            putBoolean(KEY_MONITORING_ENABLED, config.monitoringEnabled)
            putInt(KEY_START_HOUR, config.startHour)
            putInt(KEY_START_MINUTE, config.startMinute)
            putInt(KEY_END_HOUR, config.endHour)
            putInt(KEY_END_MINUTE, config.endMinute)
            putBoolean(KEY_VIBRATION_ENABLED, config.vibrationEnabled)
            putString(KEY_RINGTONE_ID, config.ringtoneId)
            putFloat(KEY_ALARM_VOLUME, config.alarmVolume)
            putInt(KEY_REPEAT_SECONDS, config.repeatSeconds)
            putInt(KEY_SNOOZE_MINUTES, config.snoozeMinutes)
            putBoolean(KEY_FOREGROUND_SERVICE_ENABLED, config.foregroundServiceEnabled)
            putString(KEY_USER_ID, config.userId)
            apply()
        }
    }

    fun readConfig(context: Context): MonitoringConfig {
        val prefs = prefs(context)
        return MonitoringConfig(
            monitoringEnabled = prefs.getBoolean(KEY_MONITORING_ENABLED, true),
            startHour = prefs.getInt(KEY_START_HOUR, 8),
            startMinute = prefs.getInt(KEY_START_MINUTE, 0),
            endHour = prefs.getInt(KEY_END_HOUR, 22),
            endMinute = prefs.getInt(KEY_END_MINUTE, 0),
            vibrationEnabled = prefs.getBoolean(KEY_VIBRATION_ENABLED, true),
            ringtoneId = prefs.getString(KEY_RINGTONE_ID, "fiverr_pulse") ?: "fiverr_pulse",
            alarmVolume = prefs.getFloat(KEY_ALARM_VOLUME, 0.92f),
            repeatSeconds = prefs.getInt(KEY_REPEAT_SECONDS, 20),
            snoozeMinutes = prefs.getInt(KEY_SNOOZE_MINUTES, 5),
            foregroundServiceEnabled = prefs.getBoolean(KEY_FOREGROUND_SERVICE_ENABLED, true),
            userId = prefs.getString(KEY_USER_ID, null),
        )
    }

    fun savePendingAlert(context: Context, payload: AlertPayload) {
        prefs(context).edit().putString(KEY_PENDING_ALERT, payload.toJsonString()).apply()
    }

    fun readPendingAlert(context: Context): AlertPayload? {
        val rawJson = prefs(context).getString(KEY_PENDING_ALERT, null) ?: return null
        return AlertPayload.fromJsonString(rawJson)
    }

    fun clearPendingAlert(context: Context) {
        prefs(context).edit().remove(KEY_PENDING_ALERT).apply()
    }
}
