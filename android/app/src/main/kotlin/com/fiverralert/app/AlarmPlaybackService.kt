package com.giglert.app

import android.app.PendingIntent
import android.app.Service
import android.content.Context
import android.content.Intent
import android.media.AudioAttributes
import android.media.MediaPlayer
import android.media.RingtoneManager
import android.os.Build
import android.os.IBinder
import android.os.PowerManager
import android.os.VibrationEffect
import android.os.Vibrator
import android.os.VibratorManager
import androidx.core.app.NotificationCompat
import androidx.core.content.ContextCompat

class AlarmPlaybackService : Service() {
    private var mediaPlayer: MediaPlayer? = null
    private var wakeLock: PowerManager.WakeLock? = null
    private var activePayload: AlertPayload? = null

    override fun onBind(intent: Intent?): IBinder? = null

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        NotificationChannels.ensure(this)
        val action = intent?.action ?: ACTION_START

        return when (action) {
            ACTION_STOP -> {
                stopAlarm(clearPendingAlert = true)
                stopSelf()
                START_NOT_STICKY
            }

            ACTION_SNOOZE -> {
                val payload = activePayload ?: AppPreferences.readPendingAlert(this)
                val snoozeMinutes = AppPreferences.readConfig(this).snoozeMinutes
                if (payload != null) {
                    AlarmSnoozeReceiver.schedule(this, payload, snoozeMinutes)
                }
                stopAlarm(clearPendingAlert = false)
                stopSelf()
                START_NOT_STICKY
            }

            else -> {
                val payload = AlertPayload.fromIntent(intent) ?: AppPreferences.readPendingAlert(this)
                if (payload == null) {
                    stopSelf()
                    START_NOT_STICKY
                } else {
                    startAlarm(payload)
                    START_STICKY
                }
            }
        }
    }

    private fun startAlarm(payload: AlertPayload) {
        val config = AppPreferences.readConfig(this)
        activePayload = payload
        AppPreferences.savePendingAlert(this, payload)
        startForeground(ALARM_NOTIFICATION_ID, buildNotification(payload))
        acquireWakeLock()
        playAudio(config)
        startVibration(config)
        launchAlertActivity(payload)
    }

    private fun buildNotification(payload: AlertPayload): android.app.Notification {
        val stopIntent = PendingIntent.getService(
            this,
            3001,
            Intent(this, AlarmPlaybackService::class.java).setAction(ACTION_STOP),
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
        )
        val snoozeIntent = PendingIntent.getService(
            this,
            3002,
            Intent(this, AlarmPlaybackService::class.java).setAction(ACTION_SNOOZE),
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
        )
        val fullscreenIntent = PendingIntent.getActivity(
            this,
            3003,
            Intent(this, AlertActivity::class.java).apply {
                flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_SINGLE_TOP
                putExtras(payload.toBundle())
            },
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
        )

        return NotificationCompat.Builder(this, NotificationChannels.ALARM_CHANNEL_ID)
            .setSmallIcon(R.mipmap.ic_launcher)
            .setContentTitle(payload.title)
            .setContentText(payload.body.ifBlank { "New Fiverr activity detected" })
            .setCategory(NotificationCompat.CATEGORY_ALARM)
            .setPriority(NotificationCompat.PRIORITY_MAX)
            .setOngoing(true)
            .setVisibility(NotificationCompat.VISIBILITY_PUBLIC)
            .setAutoCancel(false)
            .setFullScreenIntent(fullscreenIntent, true)
            .addAction(0, "Stop", stopIntent)
            .addAction(0, "Snooze", snoozeIntent)
            .build()
    }

    private fun playAudio(config: MonitoringConfig) {
        mediaPlayer?.stop()
        mediaPlayer?.release()

        val notificationType = when (config.ringtoneId) {
            "order_beacon" -> RingtoneManager.TYPE_RINGTONE
            "reply_siren" -> RingtoneManager.TYPE_NOTIFICATION
            else -> RingtoneManager.TYPE_ALARM
        }

        val alertUri = RingtoneManager.getDefaultUri(notificationType)
            ?: RingtoneManager.getDefaultUri(RingtoneManager.TYPE_ALARM)

        mediaPlayer = MediaPlayer().apply {
            setDataSource(this@AlarmPlaybackService, alertUri)
            setAudioAttributes(
                AudioAttributes.Builder()
                    .setContentType(AudioAttributes.CONTENT_TYPE_SONIFICATION)
                    .setUsage(AudioAttributes.USAGE_ALARM)
                    .build(),
            )
            isLooping = false
            setVolume(config.alarmVolume, config.alarmVolume)
            setOnCompletionListener {
                it.release()
                if (mediaPlayer === it) {
                    mediaPlayer = null
                }
            }
            prepare()
            start()
        }
    }

    private fun startVibration(config: MonitoringConfig) {
        if (!config.vibrationEnabled) {
            return
        }

        val pattern = longArrayOf(0, 1200, 500)
        val vibrator = defaultVibrator() ?: return

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            vibrator.vibrate(VibrationEffect.createWaveform(pattern, -1))
        } else {
            @Suppress("DEPRECATION")
            vibrator.vibrate(pattern, -1)
        }
    }

    private fun stopVibration() {
        defaultVibrator()?.cancel()
    }

    private fun defaultVibrator(): Vibrator? {
        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            getSystemService(VibratorManager::class.java)?.defaultVibrator
        } else {
            @Suppress("DEPRECATION")
            getSystemService(VIBRATOR_SERVICE) as? Vibrator
        }
    }

    private fun acquireWakeLock() {
        if (wakeLock?.isHeld == true) {
            return
        }

        val powerManager = getSystemService(PowerManager::class.java)
        wakeLock = powerManager.newWakeLock(
            PowerManager.PARTIAL_WAKE_LOCK,
            "giglert:alarm",
        ).apply {
            acquire(10 * 60 * 1000L)
        }
    }

    private fun launchAlertActivity(payload: AlertPayload) {
        startActivity(
            Intent(this, AlertActivity::class.java).apply {
                flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_SINGLE_TOP
                putExtras(payload.toBundle())
            },
        )
    }

    private fun stopAlarm(clearPendingAlert: Boolean) {
        mediaPlayer?.stop()
        mediaPlayer?.release()
        mediaPlayer = null

        stopVibration()

        wakeLock?.let { lock ->
            if (lock.isHeld) {
                lock.release()
            }
        }
        wakeLock = null

        stopForeground(STOP_FOREGROUND_REMOVE)

        AlarmSnoozeReceiver.cancel(this)

        if (clearPendingAlert) {
            AppPreferences.clearPendingAlert(this)
        }
    }

    override fun onDestroy() {
        stopAlarm(clearPendingAlert = false)
        super.onDestroy()
    }

    companion object {
        private const val ACTION_START = "com.giglert.app.action.START_ALERT"
        private const val ACTION_STOP = "com.giglert.app.action.STOP_ALERT"
        private const val ACTION_SNOOZE = "com.giglert.app.action.SNOOZE_ALERT"
        private const val ALARM_NOTIFICATION_ID = 4402

        fun start(context: Context, payload: AlertPayload) {
            ContextCompat.startForegroundService(
                context,
                Intent(context, AlarmPlaybackService::class.java).apply {
                    action = ACTION_START
                    putExtras(payload.toBundle())
                },
            )
        }

        fun stop(context: Context) {
            context.startService(
                Intent(context, AlarmPlaybackService::class.java).setAction(ACTION_STOP),
            )
        }

        fun snooze(context: Context) {
            context.startService(
                Intent(context, AlarmPlaybackService::class.java).setAction(ACTION_SNOOZE),
            )
        }
    }
}
