import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../models/app_settings.dart';
import '../utils/app_constants.dart';

class LocalNotificationService {
  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    // Minimal initialization to satisfy compilation across flutter_local_notifications versions.
    const AndroidInitializationSettings androidInitializationSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings =
        InitializationSettings(android: androidInitializationSettings);

    await _plugin.initialize(settings: initializationSettings);

    final AndroidFlutterLocalNotificationsPlugin? androidPlugin = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();

    if (androidPlugin == null) return;

    await androidPlugin.createNotificationChannel(
      const AndroidNotificationChannel(
        'monitoring_status',
        'Monitoring status',
        description:
            'Updates when Fiverr Alert monitoring is enabled or paused.',
        importance: Importance.defaultImportance,
      ),
    );

    await androidPlugin.createNotificationChannel(
      const AndroidNotificationChannel(
        'setup_guides',
        'Setup guides',
        description: 'Permission and setup reminders.',
        importance: Importance.high,
      ),
    );
  }

  Future<void> requestAndroidPermissions() async {
    final AndroidFlutterLocalNotificationsPlugin? androidPlugin = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();

    await androidPlugin?.requestNotificationsPermission();
    await androidPlugin?.requestExactAlarmsPermission();
    await androidPlugin?.requestFullScreenIntentPermission();
  }

  Future<void> showMonitoringStatus(AppSettings settings) async {
    await _plugin.show(
      id: AppConstants.monitoringNotificationId,
      title: settings.monitoringEnabled
          ? 'Monitoring enabled'
          : 'Monitoring paused',
      body: settings.monitoringEnabled
          ? 'Fiverr Alert will watch Fiverr during your active hours.'
          : 'Fiverr notification alarms are currently paused.',
      notificationDetails: NotificationDetails(
        android: AndroidNotificationDetails(
          'monitoring_status',
          'Monitoring status',
          channelDescription:
              'Updates when Fiverr Alert monitoring is enabled or paused.',
          importance: Importance.defaultImportance,
          priority: Priority.defaultPriority,
          category: AndroidNotificationCategory.status,
          icon: '@mipmap/ic_launcher',
        ),
      ),
    );
  }

  Future<void> showSetupReminder() async {
    await _plugin.show(
      id: AppConstants.helperNotificationId,
      title: 'Finish Android setup',
      body:
          'Grant notification access and battery exemptions for reliable Fiverr alerts.',
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          'setup_guides',
          'Setup guides',
          channelDescription: 'Permission and setup reminders.',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
      ),
    );
  }
}
