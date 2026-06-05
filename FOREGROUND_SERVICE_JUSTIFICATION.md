# Foreground Service Type Justifications
## GigLert v1 (Build 14)

### Submission to Google Play Console

---

## 1. MonitoringForegroundService - `dataSync` Type

### Service Overview
**Service Name:** `com.giglert.app.MonitoringForegroundService`  
**Foreground Service Type:** `dataSync`  
**Play Console category:** Local processing → Other  
**Min SDK:** Android 14+

### Purpose and Functionality
The MonitoringForegroundService keeps continuous Fiverr notification monitoring active while the app is in the background. It works alongside `FiverrNotificationListenerService`, which reads Fiverr notifications posted by the Fiverr app on the device. This service does **not** make network requests to Fiverr's API.

### Why Foreground Service is Required

1. **Reliability During System Pressure**
   - Without foreground status, Android's system may terminate background monitoring during memory pressure or battery optimization
   - Users would miss critical job opportunities if the monitoring process stops
   - This service is essential to the app's core functionality

2. **User Control & Transparency**
   - Users can enable/disable monitoring through app settings
   - Users can toggle the foreground service independently
   - The foreground notification displays the monitoring status and active schedule
   - Users have full transparency about when the app is monitoring for jobs

3. **On-Device Notification Processing**
   - `FiverrNotificationListenerService` receives Fiverr notification events from the system
   - Detected notification data is processed and synchronized into the app for classification and alerting
   - Monitoring runs according to the user's configured schedule (active hours)

4. **User Experience Enhancement**
   - Persistent notification shows monitoring is active
   - Tapping the notification opens the app
   - Users control the monitoring schedule based on their preferences

### Technical Implementation
```
- Triggered by: FiverrNotificationListenerService.onListenerConnected()
- Also started on: boot, app launch (when monitoring enabled)
- Service starts via: ContextCompat.startForegroundService()
- Monitoring enabled flag: configurable in app settings
- Foreground service enabled flag: toggleable by user
- Notification channel: MONITORING_CHANNEL_ID with CATEGORY_SERVICE
- Status text: "Watching Fiverr during [schedule label]"
- Data source: Fiverr app notifications (on-device), not HTTP API polling
```

---

## 2. AlarmPlaybackService - `mediaPlayback` Type

### Service Overview
**Service Name:** `com.giglert.app.AlarmPlaybackService`  
**Foreground Service Type:** `mediaPlayback`  
**Play Console category:** Media playback  
**Min SDK:** Android 14+

### Purpose and Functionality
The AlarmPlaybackService plays audio alarms and triggers vibration when new Fiverr job opportunities are detected. This service ensures users are promptly alerted even when the app is not active.

### Why Foreground Service is Required

1. **Critical Alerts Delivery**
   - When a new job opportunity arrives, the system must immediately alert the user
   - Audio alarms must complete even if the device is in low-power mode or under memory pressure
   - Foreground status guarantees the alert audio plays to completion

2. **MediaPlayer Management**
   - The service directly manages audio playback through Android's MediaPlayer API
   - Plays system alarm, ringtone, or notification sounds configured by the user
   - Controls vibration patterns through Vibrator API for multi-sensory alerts
   - Acquires WakeLock to ensure the device stays awake during alert playback

3. **System Resource Protection**
   - Without foreground status, system could terminate the service mid-alarm
   - MediaPlayer resources could be deallocated by the system
   - Audio could be interrupted or silenced

4. **User Experience Requirements**
   - Users depend on reliable job opportunity notifications
   - As a freelancer platform, missed notifications = missed income opportunities
   - Persistent alarm notification shows the ongoing alert with snooze and stop controls
   - Users can interact with the alarm (snooze or dismiss) through notification actions

### Technical Implementation
```
- Triggered by: FiverrNotificationListenerService.onNotificationPosted()
- Also triggered by: "Full alarm test" in Dashboard/Settings (for testing)
- Service starts via: startForeground(ALARM_NOTIFICATION_ID, notification)
- Audio sources: System alarm, ringtone, or notification tones
- Vibration patterns: User-configurable vibration settings
- WakeLock: PowerManager.WakeLock to prevent device sleep
- Interactive controls: Stop and Snooze buttons in notification
- Category: CATEGORY_ALARM with PRIORITY_MAX
```

---

## Play Console Compliance Summary

| Service | Type | Play Console Category | Justification | User Control |
|---------|------|----------------------|---------------|--------------|
| MonitoringForegroundService | dataSync | Local processing → Other | Keeps on-device Fiverr notification monitoring active | Fully enabled/disabled in settings |
| AlarmPlaybackService | mediaPlayback | Media playback | Reliable audio/vibration alert delivery | User configures sounds, vibration, and can stop/snooze |

### Key Points for Reviewers
- ✅ Both services are **essential** to the app's core freelancer alert functionality
- ✅ Both services provide **persistent foreground notifications** with user context
- ✅ Both services are **user-controlled** with clear enable/disable settings
- ✅ Both services use **appropriate foreground service types** per Android guidelines
- ✅ Service descriptions match actual implementation (notification listener + media playback)
- ✅ Users have **transparency** about when services are running via persistent notifications

---

## Additional Notes

### Android 14+ Compliance
GigLert is fully compliant with Android 14 foreground service requirements:
- All foreground services declare appropriate `android:foregroundServiceType` attributes
- All foreground services use `ContextCompat.startForegroundService()`
- All foreground services display persistent notifications
- All foreground services can be controlled by users
- No background execution without explicit foreground service usage

### Testing & Verification
All foreground services have been tested on:
- Android 14 (API 34)
- Android 15 (API 35)
- Various device manufacturers and configurations

Use **Dashboard → Run alarm test** or **Settings → Full alarm test** to record the Play Console media playback demonstration video.

---

**Document Version:** 1.1  
**App:** GigLert  
**Release:** v1.0.1 (Build 14)  
**Last Updated:** 2026-06-05
