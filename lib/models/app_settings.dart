import 'package:flutter/material.dart';

import 'monitoring_schedule.dart';

enum AppThemePreference { system, light, dark }

extension AppThemePreferenceX on AppThemePreference {
  ThemeMode get themeMode {
    switch (this) {
      case AppThemePreference.system:
        return ThemeMode.system;
      case AppThemePreference.light:
        return ThemeMode.light;
      case AppThemePreference.dark:
        return ThemeMode.dark;
    }
  }

  String get label {
    switch (this) {
      case AppThemePreference.system:
        return 'System';
      case AppThemePreference.light:
        return 'Light';
      case AppThemePreference.dark:
        return 'Dark';
    }
  }
}

class AppSettings {
  const AppSettings({
    required this.monitoringEnabled,
    required this.schedule,
    required this.vibrationEnabled,
    required this.ringtoneId,
    required this.alarmVolume,
    required this.repeatSeconds,
    required this.snoozeMinutes,
    required this.themePreference,
    required this.foregroundServiceEnabled,
    required this.notifyNewMessages,
    required this.notifyNewOrders,
    required this.notifyBuyerRequests,
    required this.notifyCustomOffers,
    required this.notifyRevisions,
    required this.notifyCancellations,
    required this.onlyImportantNotifications,
    required this.keywordDetectionEnabled,
    required this.repeatUrgentMessages,
    required this.fullScreenAlarm,
    required this.strongSleepAlerts,
    required this.cloudSyncEnabled,
    required this.keywords,
    required this.updatedAt,
  });

  final bool monitoringEnabled;
  final MonitoringSchedule schedule;
  final bool vibrationEnabled;
  final String ringtoneId;
  final double alarmVolume;
  final int repeatSeconds;
  final int snoozeMinutes;
  final AppThemePreference themePreference;
  final bool foregroundServiceEnabled;
  final bool notifyNewMessages;
  final bool notifyNewOrders;
  final bool notifyBuyerRequests;
  final bool notifyCustomOffers;
  final bool notifyRevisions;
  final bool notifyCancellations;
  final bool onlyImportantNotifications;
  final bool keywordDetectionEnabled;
  final bool repeatUrgentMessages;
  final bool fullScreenAlarm;
  final bool strongSleepAlerts;
  final bool cloudSyncEnabled;
  final List<String> keywords;
  final DateTime updatedAt;

  factory AppSettings.defaults() {
    return AppSettings(
      monitoringEnabled: true,
      schedule: MonitoringSchedule.defaults(),
      vibrationEnabled: true,
      ringtoneId: 'fiverr_pulse',
      alarmVolume: 0.92,
      repeatSeconds: 20,
      snoozeMinutes: 5,
      themePreference: AppThemePreference.system,
      foregroundServiceEnabled: true,
      notifyNewMessages: true,
      notifyNewOrders: true,
      notifyBuyerRequests: false,
      notifyCustomOffers: false,
      notifyRevisions: true,
      notifyCancellations: true,
      onlyImportantNotifications: false,
      keywordDetectionEnabled: false,
      repeatUrgentMessages: false,
      fullScreenAlarm: true,
      strongSleepAlerts: false,
      cloudSyncEnabled: false,
      keywords: const <String>[],
      updatedAt: DateTime.now(),
    );
  }

  factory AppSettings.fromJson(Map<String, dynamic> json) {
    return AppSettings(
      monitoringEnabled: json['monitoringEnabled'] as bool? ?? true,
      schedule: MonitoringSchedule.fromJson(
        (json['schedule'] as Map?)?.cast<String, dynamic>() ??
            <String, dynamic>{},
      ),
      vibrationEnabled: json['vibrationEnabled'] as bool? ?? true,
      ringtoneId: json['ringtoneId'] as String? ?? 'fiverr_pulse',
      alarmVolume: (json['alarmVolume'] as num?)?.toDouble() ?? 0.92,
      repeatSeconds: json['repeatSeconds'] as int? ?? 20,
      snoozeMinutes: json['snoozeMinutes'] as int? ?? 5,
      themePreference: AppThemePreference.values.firstWhere(
        (AppThemePreference value) =>
            value.name == (json['themePreference'] as String? ?? 'system'),
        orElse: () => AppThemePreference.system,
      ),
      foregroundServiceEnabled:
          json['foregroundServiceEnabled'] as bool? ?? true,
      notifyNewMessages: json['notifyNewMessages'] as bool? ?? true,
      notifyNewOrders: json['notifyNewOrders'] as bool? ?? true,
      notifyBuyerRequests: json['notifyBuyerRequests'] as bool? ?? false,
      notifyCustomOffers: json['notifyCustomOffers'] as bool? ?? false,
      notifyRevisions: json['notifyRevisions'] as bool? ?? true,
      notifyCancellations: json['notifyCancellations'] as bool? ?? true,
      onlyImportantNotifications:
          json['onlyImportantNotifications'] as bool? ?? false,
      keywordDetectionEnabled:
          json['keywordDetectionEnabled'] as bool? ?? false,
      repeatUrgentMessages: json['repeatUrgentMessages'] as bool? ?? false,
      fullScreenAlarm: json['fullScreenAlarm'] as bool? ?? true,
      strongSleepAlerts: json['strongSleepAlerts'] as bool? ?? false,
      cloudSyncEnabled: json['cloudSyncEnabled'] as bool? ?? false,
      keywords: ((json['keywords'] as List?) ?? <dynamic>[]) .cast<String>(),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(
        json['updatedAt'] as int? ?? DateTime.now().millisecondsSinceEpoch,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'monitoringEnabled': monitoringEnabled,
      'schedule': schedule.toJson(),
      'vibrationEnabled': vibrationEnabled,
      'ringtoneId': ringtoneId,
      'alarmVolume': alarmVolume,
      'repeatSeconds': repeatSeconds,
      'snoozeMinutes': snoozeMinutes,
      'themePreference': themePreference.name,
      'foregroundServiceEnabled': foregroundServiceEnabled,
      'notifyNewMessages': notifyNewMessages,
      'notifyNewOrders': notifyNewOrders,
      'notifyBuyerRequests': notifyBuyerRequests,
      'notifyCustomOffers': notifyCustomOffers,
      'notifyRevisions': notifyRevisions,
      'notifyCancellations': notifyCancellations,
      'onlyImportantNotifications': onlyImportantNotifications,
      'keywordDetectionEnabled': keywordDetectionEnabled,
      'repeatUrgentMessages': repeatUrgentMessages,
      'fullScreenAlarm': fullScreenAlarm,
      'strongSleepAlerts': strongSleepAlerts,
      'cloudSyncEnabled': cloudSyncEnabled,
      'keywords': keywords,
      'updatedAt': updatedAt.millisecondsSinceEpoch,
    };
  }

  AppSettings copyWith({
    bool? monitoringEnabled,
    MonitoringSchedule? schedule,
    bool? vibrationEnabled,
    String? ringtoneId,
    double? alarmVolume,
    int? repeatSeconds,
    int? snoozeMinutes,
    AppThemePreference? themePreference,
    bool? foregroundServiceEnabled,
    bool? notifyNewMessages,
    bool? notifyNewOrders,
    bool? notifyBuyerRequests,
    bool? notifyCustomOffers,
    bool? notifyRevisions,
    bool? notifyCancellations,
    bool? onlyImportantNotifications,
    bool? keywordDetectionEnabled,
    bool? repeatUrgentMessages,
    bool? fullScreenAlarm,
    bool? strongSleepAlerts,
    bool? cloudSyncEnabled,
    List<String>? keywords,
    DateTime? updatedAt,
    bool touchUpdatedAt = false,
  }) {
    return AppSettings(
      monitoringEnabled: monitoringEnabled ?? this.monitoringEnabled,
      schedule: schedule ?? this.schedule,
      vibrationEnabled: vibrationEnabled ?? this.vibrationEnabled,
      ringtoneId: ringtoneId ?? this.ringtoneId,
      alarmVolume: alarmVolume ?? this.alarmVolume,
      repeatSeconds: repeatSeconds ?? this.repeatSeconds,
      snoozeMinutes: snoozeMinutes ?? this.snoozeMinutes,
      themePreference: themePreference ?? this.themePreference,
      foregroundServiceEnabled:
          foregroundServiceEnabled ?? this.foregroundServiceEnabled,
      notifyNewMessages: notifyNewMessages ?? this.notifyNewMessages,
      notifyNewOrders: notifyNewOrders ?? this.notifyNewOrders,
      notifyBuyerRequests: notifyBuyerRequests ?? this.notifyBuyerRequests,
      notifyCustomOffers: notifyCustomOffers ?? this.notifyCustomOffers,
      notifyRevisions: notifyRevisions ?? this.notifyRevisions,
      notifyCancellations: notifyCancellations ?? this.notifyCancellations,
      onlyImportantNotifications:
          onlyImportantNotifications ?? this.onlyImportantNotifications,
      keywordDetectionEnabled:
          keywordDetectionEnabled ?? this.keywordDetectionEnabled,
      repeatUrgentMessages: repeatUrgentMessages ?? this.repeatUrgentMessages,
      fullScreenAlarm: fullScreenAlarm ?? this.fullScreenAlarm,
      strongSleepAlerts: strongSleepAlerts ?? this.strongSleepAlerts,
      cloudSyncEnabled: cloudSyncEnabled ?? this.cloudSyncEnabled,
      keywords: keywords ?? this.keywords,
      updatedAt: updatedAt ??
          (touchUpdatedAt ? DateTime.now() : this.updatedAt),
    );
  }
}
