class AppConstants {
  const AppConstants._();

  static const appName = 'GigLert';
  static const androidPackageName = 'com.giglert.app';
  static const fiverrPackageName = 'com.fiverr.fiverr';

  static const nativeBridgeChannel = 'com.giglert.app/native_bridge';
  static const notificationEventChannel =
      'com.giglert.app/notification_events';

  static const usersCollection = 'users';

  static const settingsKey = 'settings_json';
  static const alertsKey = 'alerts_json';
  static const onboardingKey = 'onboarding_complete';

  static const monitoringNotificationId = 4201;
  static const helperNotificationId = 4202;
  static const maxStoredAlerts = 25;
}
