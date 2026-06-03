# GigLert

## Play Store listing text (copy/paste)

**Short description:**
GigLert sends loud, persistent alerts for important Fiverr notification events on Android.

**Full description:**
GigLert is an Android app for Fiverr freelancers that monitors notification events and helps you stay on top of important Fiverr activity.

With GigLert, you can enable reliable alerting (including repeat and full-screen alarm options) so you never miss messages, orders, revisions, cancellations, or other relevant Fiverr updates.

**Not affiliated with Fiverr**
GigLert is an independent app and is not affiliated with, sponsored by, or endorsed by Fiverr.

**About permissions**
GigLert requests Android notification access so it can detect notification events related to Fiverr activity and trigger alerts according to your settings. You control notification access in your Android app settings.

**Data & syncing**
GigLert stores your monitoring and alert preferences locally on your device. If you enable cloud sync, your settings and the latest detected alert can be stored in your Firebase account (Firestore).

**No guarantee**
Notification behavior can vary by device and Android version. While GigLert is designed to improve alert reliability, we cannot guarantee that every notification will be detected.

---

GigLert is a Flutter app for Android freelancers who want loud, persistent alerts when Fiverr notifications arrive. The app uses:


- Firebase Authentication with Google sign-in
- Cloud Firestore for syncing per-user settings and the latest detected alert
- Native Android notification-listener and foreground-service code for reliable background monitoring

## What is already wired up

- FlutterFire config in `lib/firebase_options.dart`
- Android Firebase app config in `android/app/google-services.json`
- Firestore security rules in `firestore.rules`
- Firestore index config in `firestore.indexes.json`
- Storage security rules in `storage.rules`

## Firebase deploy

Run these commands from the project root after logging into the Firebase CLI:

```bash
firebase deploy --only firestore:rules,firestore:indexes,storage
```

If you also want Hosting or other Firebase products later, add them separately.

## Required Firebase Console checks

These still need to be correct in the Firebase project itself:

1. Enable `Authentication > Sign-in method > Google`.
2. Make sure the Android app package is `com.giglert.app`.
3. Add your Android SHA-1 and SHA-256 fingerprints in the Firebase Android app settings.
4. Download the refreshed `google-services.json` after adding SHA fingerprints if Google sign-in still fails.
5. Confirm that `android/app/google-services.json` contains a `client` entry for `com.giglert.app` whose `oauth_client` array is no longer empty.

At the moment, the checked-in `android/app/google-services.json` still has empty `oauth_client` arrays, and it also contains a legacy `com.fiverralert.app` client entry alongside `com.giglert.app`. That usually means the Android SHA fingerprints still need attention and the file should be re-downloaded from Firebase before Google sign-in will fully work.

## Local run

```bash
flutter pub get
flutter run
```

## Android install and signing notes

- GigLert relies on Android `NotificationListenerService`, which is treated as a sensitive capability because it can read notification content.
- Google Play Protect can block APKs installed from browsers, chat apps, or file managers when those APKs declare notification-listener, SMS, or accessibility-style sensitive access. This is especially common for sideloaded builds.
- On Android 13 and newer, if notification access is blocked for security reasons after install, open `Settings > Apps > GigLert > More` and choose `Allow restricted settings`, then retry notification access.
- Release builds should be signed with your own keystore. This project no longer falls back to the debug certificate for `release`.

Create `android/key.properties` before building a production release:

```properties
storeFile=../your-upload-keystore.jks
storePassword=YOUR_STORE_PASSWORD
keyAlias=YOUR_KEY_ALIAS
keyPassword=YOUR_KEY_PASSWORD
```

Build and install a signed release directly over ADB instead of sharing the APK through chat apps:

```powershell
.\tools\install_release.ps1
```

Or run the steps manually:

```powershell
D:\flutter_windows_3.35.5-stable\flutter\bin\flutter.bat build apk --release
C:\Users\yahya\AppData\Local\Android\Sdk\platform-tools\adb.exe install -r .\build\app\outputs\flutter-apk\app-release.apk
```

## Data model

The app stores one Firestore document per user:

```text
users/{uid}
```

That document contains:

- profile fields from Firebase Auth
- a `preferences` map for monitoring/alarm settings
- a `lastAlert` map with the latest detected Fiverr notification
- sync timestamps such as `updatedAt` and `lastSeenAt`

## Platform notes

- The real notification-listener and full-screen alarm flow is Android-only.
- Desktop platforms currently boot in a degraded mode: unsupported Firebase auth targets and Android-native channels are skipped instead of crashing, and Google sign-in stays disabled until that platform has matching FlutterFire/Google configuration.
- Web and iOS Firebase options exist in `lib/firebase_options.dart`, but this repo is still centered on Android behavior.
