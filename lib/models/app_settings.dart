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
      updatedAt: updatedAt ??
          (touchUpdatedAt ? DateTime.now() : this.updatedAt),
    );
  }
}
