import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';

import 'local_notification_service.dart';
import 'native_bridge_service.dart';

class PermissionDashboardState {
  const PermissionDashboardState({
    required this.postNotificationsGranted,
    required this.notificationListenerEnabled,
    required this.batteryOptimizationIgnored,
    required this.exactAlarmGranted,
    required this.fullScreenIntentGranted,
  });

  final bool postNotificationsGranted;
  final bool notificationListenerEnabled;
  final bool batteryOptimizationIgnored;
  final bool exactAlarmGranted;
  final bool fullScreenIntentGranted;

  factory PermissionDashboardState.empty() {
    return const PermissionDashboardState(
      postNotificationsGranted: false,
      notificationListenerEnabled: false,
      batteryOptimizationIgnored: false,
      exactAlarmGranted: false,
      fullScreenIntentGranted: false,
    );
  }

  int get completedCount => <bool>[
        postNotificationsGranted,
        notificationListenerEnabled,
        batteryOptimizationIgnored,
        exactAlarmGranted,
        fullScreenIntentGranted,
      ].where((bool item) => item).length;
}

class PermissionService {
  PermissionService({
    required NativeBridgeService nativeBridge,
    required LocalNotificationService localNotificationService,
  })  : _nativeBridge = nativeBridge,
        _localNotificationService = localNotificationService;

  final NativeBridgeService _nativeBridge;
  final LocalNotificationService _localNotificationService;

  Future<PermissionDashboardState> refreshSnapshot() async {
    if (kIsWeb || defaultTargetPlatform != TargetPlatform.android) {
      return PermissionDashboardState.empty();
    }

    final PermissionStatus notificationStatus = await Permission.notification
        .status;
    final NativePermissionSnapshot nativeSnapshot =
        await _nativeBridge.getPermissionSnapshot();

    return PermissionDashboardState(
      postNotificationsGranted: notificationStatus.isGranted ||
          notificationStatus.isLimited ||
          notificationStatus.isProvisional,
      notificationListenerEnabled: nativeSnapshot.notificationListenerEnabled,
      batteryOptimizationIgnored:
          nativeSnapshot.batteryOptimizationIgnored,
      exactAlarmGranted: nativeSnapshot.exactAlarmGranted,
      fullScreenIntentGranted: nativeSnapshot.fullScreenIntentGranted,
    );
  }

  Future<void> requestAndroidNotificationBundle() async {
    if (kIsWeb || defaultTargetPlatform != TargetPlatform.android) {
      return;
    }

    await Permission.notification.request();
    await _localNotificationService.requestAndroidPermissions();
  }
}
