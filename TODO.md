# TODO

- [x] Add/replace in-app UI logo assets and wire them into `lib/widgets/app_logo.dart`.
- [x] Declare new logo asset(s) in `pubspec.yaml` under `flutter: assets:`.
- [x] Ensure splash/onboarding/sign-in screens still show the updated logo.
- [x] Find existing logo asset: `lib/assets/logo.png`.
- [x] Run `flutter clean && flutter pub get`.
- [x] Run `flutter test` and/or `flutter build web` / `flutter run` to verify.

- [x] Debug: add logcat-friendly logging for Google sign-in vs Firebase sign-in cancellation (`lib/providers/auth_provider.dart`).
- [ ] Fix: update Firebase Android OAuth configuration (SHA-1/SHA-256 for debug+release, re-download `android/app/google-services.json`).


