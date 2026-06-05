package com.giglert.app

import android.os.Build
import android.os.Bundle
import android.view.WindowManager
import android.widget.Button
import android.widget.TextView
import androidx.appcompat.app.AppCompatActivity
import androidx.core.view.WindowCompat
import java.text.SimpleDateFormat
import java.util.Date
import java.util.Locale

class AlertActivity : AppCompatActivity() {
    private val formatter = SimpleDateFormat("MMM dd, h:mm a", Locale.getDefault())

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        // Enable edge-to-edge rendering (Android 5.0+)
        // This prevents deprecated API calls for setStatusBarColor and setNavigationBarColor
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
            WindowCompat.setDecorFitsSystemWindows(window, false)
        }
        unlockScreenForAlert()
        setContentView(R.layout.activity_alert)
        bindPayload(AlertPayload.fromIntent(intent))
        bindActions()
    }

    override fun onNewIntent(intent: android.content.Intent) {
        super.onNewIntent(intent)
        setIntent(intent)
        bindPayload(AlertPayload.fromIntent(intent))
    }

    private fun bindPayload(payload: AlertPayload?) {
        if (payload == null) {
            finish()
            return
        }

        findViewById<TextView>(R.id.alertBadge).text = payload.type.uppercase(Locale.getDefault())
        findViewById<TextView>(R.id.alertTitle).text = payload.title
        findViewById<TextView>(R.id.alertBody).text = payload.body
        findViewById<TextView>(R.id.alertTimestamp).text =
            "Detected ${formatter.format(Date(payload.receivedAt))}"
    }

    private fun bindActions() {
        findViewById<Button>(R.id.stopButton).setOnClickListener {
            AlarmPlaybackService.stop(this)
            finish()
        }

        findViewById<Button>(R.id.snoozeButton).setOnClickListener {
            AlarmPlaybackService.snooze(this)
            finish()
        }
    }

    private fun unlockScreenForAlert() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O_MR1) {
            setShowWhenLocked(true)
            setTurnScreenOn(true)
        } else {
            @Suppress("DEPRECATION")
            window.addFlags(
                WindowManager.LayoutParams.FLAG_SHOW_WHEN_LOCKED or
                    WindowManager.LayoutParams.FLAG_TURN_SCREEN_ON,
            )
        }

        window.addFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON)
    }
}
