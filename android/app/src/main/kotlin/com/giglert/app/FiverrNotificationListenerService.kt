package com.giglert.app

import android.app.Notification
import android.content.ComponentName
import android.service.notification.NotificationListenerService
import android.service.notification.StatusBarNotification
import java.util.Locale

class FiverrNotificationListenerService : NotificationListenerService() {
    override fun onListenerConnected() {
        super.onListenerConnected()
        val config = AppPreferences.readConfig(this)
        if (config.monitoringEnabled && config.foregroundServiceEnabled) {
            MonitoringForegroundService.start(this)
        }
    }

    override fun onListenerDisconnected() {
        super.onListenerDisconnected()
        requestRebind(ComponentName(this, FiverrNotificationListenerService::class.java))
    }

    override fun onNotificationPosted(sbn: StatusBarNotification) {
        if (sbn.packageName != AppPreferences.FIVERR_PACKAGE) {
            return
        }

        if (sbn.notification.flags and Notification.FLAG_GROUP_SUMMARY != 0) {
            return
        }

        val config = AppPreferences.readConfig(this)
        val shouldTrigger = config.monitoringEnabled && config.isWithinActiveHours()
        val payload = extractPayload(sbn, shouldTrigger)
        val pendingAlert = AppPreferences.readPendingAlert(this)

        if (pendingAlert?.dedupeSignature() == payload.dedupeSignature()) {
            return
        }

        NotificationEventStreamHandler.emit(payload)

        if (shouldTrigger) {
            AlarmPlaybackService.start(this, payload)
        }
    }

    private fun extractPayload(
        sbn: StatusBarNotification,
        alarmTriggered: Boolean,
    ): AlertPayload {
        val extras = sbn.notification.extras
        val title = extras.getCharSequence(Notification.EXTRA_TITLE)?.toString()?.trim().orEmpty()
        val text = extras.getCharSequence(Notification.EXTRA_TEXT)?.toString()?.trim().orEmpty()
        val subText = extras.getCharSequence(Notification.EXTRA_SUB_TEXT)?.toString()?.trim().orEmpty()
        val body = listOf(text, subText)
            .filter { it.isNotBlank() }
            .distinct()
            .joinToString(" | ")
            .ifBlank { sbn.notification.tickerText?.toString()?.trim().orEmpty() }

        val safeTitle = title.ifBlank { "Fiverr notification" }
        val safeBody = body.ifBlank { "New Fiverr activity detected." }
        val type = inferType(safeTitle, safeBody)

        return AlertPayload(
            id = "${sbn.postTime}-${sbn.id}",
            packageName = sbn.packageName,
            title = safeTitle,
            body = safeBody,
            type = type,
            receivedAt = sbn.postTime,
            alarmTriggered = alarmTriggered,
        )
    }

    private fun inferType(title: String, body: String): String {
        val haystack = "$title $body".lowercase(Locale.getDefault())
        return when {
            "order" in haystack -> "order"
            "reply" in haystack || "response" in haystack -> "reply"
            "message" in haystack || "buyer" in haystack || "inbox" in haystack -> "message"
            else -> "general"
        }
    }
}
