# Google Play Console Submission - Foreground Service Permissions
## GigLert v1 - Build 14+

---

## SECTION 1: FOREGROUND_SERVICE_DATA_SYNC

### What tasks require your app to use the FOREGROUND_SERVICE_DATA_SYNC permission?

**PRIMARY SELECTION: ✅ Local processing**

**SECONDARY SELECTION (under Local processing): ✅ Other**

| Sub-option | Select? | Why |
|---|---|---|
| Media transcoding | ❌ No | GigLert does not convert or transcode audio/video files in this service |
| Importing, exporting | ❌ No | GigLert does not import or export files in this service |
| **Other** | ✅ **Yes** | On-device processing of Fiverr notification events for continuous monitoring |

**DO NOT SELECT:** Network processing — GigLert does not poll the Fiverr API from this service.

### Description for Google Play Console:

The MonitoringForegroundService uses the `dataSync` foreground service type to keep continuous Fiverr notification monitoring active in the background. The service:

- **Processes Fiverr notification events on-device** via `FiverrNotificationListenerService` (Android notification access)
- **Synchronizes detected notification data** into the app so alerts can be classified and delivered
- **Maintains monitoring state** so background processing is not terminated by the system
- **Shows a persistent foreground notification** ("Fiverr Alert is monitoring") with the active schedule

The foreground service designation is necessary because:
1. **Reliability**: Without foreground status, Android may terminate background monitoring during memory pressure or battery optimization, causing users to miss job opportunities
2. **User Control**: Users can enable/disable monitoring and the foreground service in app settings
3. **Transparency**: The persistent notification displays monitoring status and the active schedule
4. **Critical Functionality**: Notification monitoring is the core purpose of the app; interruptions directly result in missed income opportunities for freelancers

### How monitoring actually works (for your reference)

```
Fiverr app posts notification
        ↓
FiverrNotificationListenerService (notification access)
        ↓
MonitoringForegroundService (keeps monitoring alive, shows status notification)
        ↓
AlarmPlaybackService (plays alarm when a relevant notification is detected)
```

---

## SECTION 2: FOREGROUND_SERVICE_MEDIA_PLAYBACK

### What tasks require your app to use the FOREGROUND_SERVICE_MEDIA_PLAYBACK permission?

**PRIMARY SELECTION: ✅ Media playback**

**DO NOT SELECT:** Show picture in picture — GigLert does not use PiP.

### Description for Google Play Console:

The AlarmPlaybackService uses the `mediaPlayback` foreground service type to deliver critical audio alerts when new Fiverr job opportunities are detected. The service:

- **Plays audio alarms and ringtones** using Android's MediaPlayer API
- **Plays user-configured alert sounds** (alarm, ringtone, or notification tone)
- **Controls vibration patterns** through the Vibrator API for multi-sensory alerts
- **Manages WakeLock** to ensure the device stays awake during alert playback
- **Shows an ongoing notification** with Stop and Snooze actions

The foreground service designation is necessary because:
1. **Critical Alerts**: When new job opportunities arrive, the system must immediately alert the user with audio
2. **Completion Guarantee**: Audio must play to completion even if the device is in low-power mode or under memory pressure
3. **Resource Protection**: Without foreground status, the system could deallocate MediaPlayer resources, interrupting alerts
4. **User Experience**: Users depend on reliable notifications; missed alerts = missed income opportunities

---

## SECTION 3: VIDEO REQUIREMENT FOR MEDIA_PLAYBACK

Google Play requires a video link demonstrating `FOREGROUND_SERVICE_MEDIA_PLAYBACK` usage.

### Video Demonstration Requirements:

**Your video should demonstrate:**

1. **Monitoring is enabled** (persistent "Fiverr Alert is monitoring" notification visible)
2. **Alarm test is triggered** via Dashboard or Settings → "Run alarm test" / "Full alarm test"
3. **AlarmPlaybackService activates** and begins audio playback
4. **Foreground notification appears** showing the alarm with Stop and Snooze actions
5. **Audio alarm plays** clearly (audible in the recording)
6. **Full-screen alert UI appears** (if shown on your device)
7. **User taps Stop** to dismiss the alarm

### Video Recording Instructions:

**Option 1: Built-in alarm test (recommended — easiest)**

1. Install the same build uploaded to Play Console (internal/closed testing track)
2. Grant notification access and turn monitoring ON
3. Open **Dashboard** or **Settings**
4. Tap **"Run alarm test"** or **"Full alarm test"**
5. Record 30–60 seconds showing the alarm sound, notification, and Stop/Snooze controls

**Option 2: Real Fiverr notification**

1. Enable monitoring with notification access granted
2. Receive a real Fiverr notification that triggers an alert
3. Record the full sequence from notification to alarm playback
4. Duration: 30–60 seconds

### Video upload:

- Record with Android's built-in screen recorder
- Upload to **YouTube (Unlisted)** or **Google Drive (anyone with link)**
- Paste the URL in the Play Console **Video link** field

**Video Requirements:**
- **Format**: MP4, WebM, or MOV
- **Resolution**: Minimum 720p (1080p preferred)
- **Audio**: Clear sound to demonstrate alarm audio
- **No screen recording watermarks** or overlays (standard Android screen recording is fine)
- **Aspect Ratio**: Portrait orientation (phone format)

---

## SUBMISSION CHECKLIST

### Before Submitting to Google Play Console:

- [ ] Foreground service permissions are declared in `AndroidManifest.xml`
  - ✅ `FOREGROUND_SERVICE`
  - ✅ `FOREGROUND_SERVICE_DATA_SYNC`
  - ✅ `FOREGROUND_SERVICE_MEDIA_PLAYBACK`

- [ ] Services are properly configured
  - ✅ `MonitoringForegroundService` with `android:foregroundServiceType="dataSync"`
  - ✅ `AlarmPlaybackService` with `android:foregroundServiceType="mediaPlayback"`

- [ ] User has control and transparency
  - ✅ Monitoring can be enabled/disabled in app settings
  - ✅ Foreground service can be toggled in app settings
  - ✅ Monitoring schedule is configurable by user
  - ✅ Foreground notifications clearly display monitoring/alert status

- [ ] All required information collected:
  - ✅ Service purposes documented
  - ✅ Task categories selected (**Local processing → Other**, **Media playback**)
  - ✅ Video demonstrating media playback uploaded and link ready

---

## GOOGLE PLAY CONSOLE FORM RESPONSES

### Copy-Paste Ready Responses:

#### Question 1: What tasks require your app to use the FOREGROUND_SERVICE_DATA_SYNC permission?

**Selected Categories:**
- ✅ Local processing
- ✅ Other *(sub-option under Local processing)*

**Description:**
"GigLert's MonitoringForegroundService runs as a dataSync foreground service to keep continuous Fiverr notification monitoring active when the app is in the background. The service processes incoming Fiverr notification events on the device via Android notification access, classifies them (orders, messages, replies), and synchronizes detected notification data into the app so users receive timely job alerts. A persistent foreground notification shows monitoring status and the active schedule. Users can enable or disable monitoring in app settings."

---

#### Question 2: What tasks require your app to use the FOREGROUND_SERVICE_MEDIA_PLAYBACK permission?

**Selected Categories:**
- ✅ Media playback

**Description:**
"GigLert's AlarmPlaybackService plays audio alarms when new Fiverr job opportunities are detected. The service uses Android's MediaPlayer API to play alarm, ringtone, or notification sounds configured by the user, triggers vibration patterns for multi-sensory alerts, and maintains a WakeLock so the device stays awake during alert playback. An ongoing notification with Stop and Snooze actions is shown while the alarm plays. The foreground service is required to guarantee audio completes even during low-power mode."

---

#### Video Link:
"[Paste your YouTube Unlisted or Google Drive link here after recording the Full alarm test]"

---

## COMPLIANCE NOTES

This submission complies with Google Play's foreground service policy:
- ✅ Services perform tasks noticeable to users (persistent notifications + audible alarms)
- ✅ Tasks are necessary for the app's core functionality
- ✅ Users have control and full transparency
- ✅ Foreground notifications clearly communicate the service purpose
- ✅ Descriptions match actual implementation (on-device notification monitoring, not API polling)

---

**Last Updated:** June 5, 2026
**App Version:** 1.0.1 (Build 14)
**Target Android:** 14+
