import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../models/app_settings.dart';
import '../models/notification_record.dart';
import '../utils/app_constants.dart';

class NativePermissionSnapshot {
  const NativePermissionSnapshot({
    required this.notificationListenerEnabled,
    required this.batteryOptimizationIgnored,
    required this.exactAlarmGranted,
    required this.fullScreenIntentGranted,
  });

  final bool notificationListenerEnabled;
  final bool batteryOptimizationIgnored;
  final bool exactAlarmGranted;
  final bool fullScreenIntentGranted;

  factory NativePermissionSnapshot.empty() {
    return const NativePermissionSnapshot(
      notificationListenerEnabled: false,
      batteryOptimizationIgnored: false,
      exactAlarmGranted: false,
      fullScreenIntentGranted: false,
    );
  }

  factory NativePermissionSnapshot.fromJson(Map<String, dynamic> json) {
    return NativePermissionSnapshot(
      notificationListenerEnabled:
          json['notificationListenerEnabled'] as bool? ?? false,
      batteryOptimizationIgnored:
          json['batteryOptimizationIgnored'] as bool? ?? false,
      exactAlarmGranted: json['exactAlarmGranted'] as bool? ?? false,
      fullScreenIntentGranted:
          json['fullScreenIntentGranted'] as bool? ?? false,
    );
  }
}

class NativeBridgeService {
  NativeBridgeService();

  static const MethodChannel _channel = MethodChannel(
    AppConstants.nativeBridgeChannel,
  );
  static const EventChannel _eventChannel = EventChannel(
    AppConstants.notificationEventChannel,
  );

  Stream<NotificationRecord>? _events;

  bool get isAvailable =>
      !kIsWeb && defaultTargetPlatform == TargetPlatform.android;

  Stream<NotificationRecord> get notificationEvents {
    if (!isAvailable) {
      return const Stream<NotificationRecord>.empty();
    }

    _events ??= _eventChannel
        .receiveBroadcastStream()
        .map(
          (dynamic event) => NotificationRecord.fromJson(
            (event as Map<Object?, Object?>).cast<String, dynamic>(),
          ),
        )
        .asBroadcastStream();
    return _events!;
  }

  Future<NativePermissionSnapshot> getPermissionSnapshot() async {
    if (!isAvailable) {
      return NativePermissionSnapshot.empty();
    }

    try {
      final Map<dynamic, dynamic>? rawResponse = await _channel
          .invokeMethod<Map<dynamic, dynamic>>('getPermissionSnapshot');

      if (rawResponse == null) {
        return NativePermissionSnapshot.empty();
      }

      return NativePermissionSnapshot.fromJson(
        rawResponse.cast<String, dynamic>(),
      );
    } on MissingPluginException {
      return NativePermissionSnapshot.empty();
    }
  }

  Future<void> syncMonitoringConfig(
    AppSettings settings, {
    String? userId,
  }) async {
    if (!isAvailable) {
      return;
    }

    try {
      await _channel
          .invokeMethod<void>('syncMonitoringConfig', <String, dynamic>{
            'monitoringEnabled': settings.monitoringEnabled,
            'startHour': settings.schedule.startHour,
            'startMinute': settings.schedule.startMinute,
            'endHour': settings.schedule.endHour,
            'endMinute': settings.schedule.endMinute,
            'vibrationEnabled': settings.vibrationEnabled,
            'ringtoneId': settings.ringtoneId,
            'alarmVolume': settings.alarmVolume,
            'repeatSeconds': settings.repeatSeconds,
            'snoozeMinutes': settings.snoozeMinutes,
            'foregroundServiceEnabled': settings.foregroundServiceEnabled,
            'userId': userId,
          });
    } on MissingPluginException {
      return;
    }
  }

  Future<void> openNotificationAccessSettings() async {
    if (!isAvailable) {
      return;
    }

    try {
      await _channel.invokeMethod<void>('openNotificationAccessSettings');
    } on MissingPluginException {
      return;
    }
  }

  Future<void> openAppDetailsSettings() async {
    if (!isAvailable) {
      return;
    }

    try {
      await _channel.invokeMethod<void>('openAppDetailsSettings');
    } on MissingPluginException {
      return;
    }
  }

  Future<void> openBatteryOptimizationSettings() async {
    if (!isAvailable) {
      return;
    }

    try {
      await _channel.invokeMethod<void>('openBatteryOptimizationSettings');
    } on MissingPluginException {
      return;
    }
  }

  Future<void> requestIgnoreBatteryOptimizations() async {
    if (!isAvailable) {
      return;
    }

    try {
      await _channel.invokeMethod<void>('requestIgnoreBatteryOptimizations');
    } on MissingPluginException {
      return;
    }
  }

  Future<void> openExactAlarmSettings() async {
    if (!isAvailable) {
      return;
    }

    try {
      await _channel.invokeMethod<void>('openExactAlarmSettings');
    } on MissingPluginException {
      return;
    }
  }

  Future<void> startNativeAlarmPreview(AppSettings settings) async {
    if (!isAvailable) {
      return;
    }

    try {
      await _channel
          .invokeMethod<void>('startNativeAlarmPreview', <String, dynamic>{
            'title': 'Test Fiverr alert',
            'body': 'This is how the full-screen alarm experience behaves.',
            'type': 'test',
            'vibrationEnabled': settings.vibrationEnabled,
            'ringtoneId': settings.ringtoneId,
            'alarmVolume': settings.alarmVolume,
            'repeatSeconds': settings.repeatSeconds,
            'snoozeMinutes': settings.snoozeMinutes,
          });
    } on MissingPluginException {
      return;
    }
  }

  Future<void> stopNativeAlarm() async {
    if (!isAvailable) {
      return;
    }

    try {
      await _channel.invokeMethod<void>('stopNativeAlarm');
    } on MissingPluginException {
      return;
    }
  }
}
