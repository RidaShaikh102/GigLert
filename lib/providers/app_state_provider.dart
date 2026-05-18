import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../models/app_settings.dart';
import '../models/notification_record.dart';
import '../models/ringtone_profile.dart';
import '../services/alarm_preview_service.dart';
import '../services/firestore_service.dart';
import '../services/local_notification_service.dart';
import '../services/local_storage_service.dart';
import '../services/native_bridge_service.dart';
import '../services/permission_service.dart';
import '../utils/app_constants.dart';

class AppStateProvider extends ChangeNotifier {
  AppStateProvider({
    required LocalStorageService localStorageService,
    required FirestoreService firestoreService,
    required NativeBridgeService nativeBridgeService,
    required PermissionService permissionService,
    required LocalNotificationService localNotificationService,
    required AlarmPreviewService alarmPreviewService,
  }) : _localStorageService = localStorageService,
       _firestoreService = firestoreService,
       _nativeBridgeService = nativeBridgeService,
       _permissionService = permissionService,
       _localNotificationService = localNotificationService,
       _alarmPreviewService = alarmPreviewService;

  final LocalStorageService _localStorageService;
  final FirestoreService _firestoreService;
  final NativeBridgeService _nativeBridgeService;
  final PermissionService _permissionService;
  final LocalNotificationService _localNotificationService;
  final AlarmPreviewService _alarmPreviewService;

  StreamSubscription<NotificationRecord>? _notificationSubscription;

  AppSettings _settings = AppSettings.defaults();
  List<NotificationRecord> _alerts = <NotificationRecord>[];
  PermissionDashboardState _permissionState = PermissionDashboardState.empty();

  bool _isInitializing = false;

  bool _hasCompletedOnboarding = false;
  bool _isPreviewPlaying = false;
  User? _boundUser;

  AppSettings get settings => _settings;
  List<NotificationRecord> get alerts =>
      List<NotificationRecord>.unmodifiable(_alerts);
  PermissionDashboardState get permissionState => _permissionState;
  bool get isInitializing => _isInitializing;
  bool get hasCompletedOnboarding => _hasCompletedOnboarding;
  bool get isPreviewPlaying => _isPreviewPlaying;
  NotificationRecord? get lastNotification =>
      _alerts.isEmpty ? null : _alerts.first;

  Future<void> initialize() async {
    _isInitializing = true;
    notifyListeners();

    try {
      _settings = _localStorageService.loadSettings();
      _alerts = _localStorageService.loadAlertHistory();
      _hasCompletedOnboarding = _localStorageService.loadOnboardingCompleted();
      _permissionState = await _permissionService.refreshSnapshot();

      _notificationSubscription ??= _nativeBridgeService.notificationEvents
          .listen(_handleNotificationEvent);

      await _nativeBridgeService.syncMonitoringConfig(
        _settings,
        userId: _boundUser?.uid,
      );
    } finally {
      _isInitializing = false;
      notifyListeners();
    }
  }

  void bindUser(User? user) {
    if (_boundUser?.uid == user?.uid) {
      return;
    }

    _boundUser = user;

    if (user == null) {
      notifyListeners();
      return;
    }

    unawaited(_synchronizeUserState(user));
  }

  Future<void> _synchronizeUserState(User user) async {
    final AppSettings? remoteSettings = await _firestoreService.fetchSettings(
      user.uid,
    );

    if (remoteSettings != null &&
        remoteSettings.updatedAt.isAfter(_settings.updatedAt)) {
      _settings = remoteSettings;
      await _localStorageService.saveSettings(_settings);
      await _nativeBridgeService.syncMonitoringConfig(
        _settings,
        userId: user.uid,
      );
    }

    await _firestoreService.upsertUserProfile(user, _settings);
    notifyListeners();
  }

  Future<void> completeOnboarding() async {
    _hasCompletedOnboarding = true;
    await _localStorageService.saveOnboardingCompleted(true);
    notifyListeners();
  }

  Future<void> resetOnboarding() async {
    _hasCompletedOnboarding = false;
    await _localStorageService.saveOnboardingCompleted(false);
    notifyListeners();
  }

  Future<void> refreshPermissions() async {
    _permissionState = await _permissionService.refreshSnapshot();
    notifyListeners();
  }

  Future<void> requestNotificationBundle() async {
    await _permissionService.requestAndroidNotificationBundle();
    await refreshPermissions();
  }

  Future<void> openNotificationAccessSettings() async {
    await _nativeBridgeService.openNotificationAccessSettings();
  }

  Future<void> openAppDetailsSettings() async {
    await _nativeBridgeService.openAppDetailsSettings();
  }

  Future<void> openBatteryOptimizationSettings() async {
    await _nativeBridgeService.openBatteryOptimizationSettings();
  }

  Future<void> requestIgnoreBatteryOptimizations() async {
    await _nativeBridgeService.requestIgnoreBatteryOptimizations();
  }

  Future<void> openExactAlarmSettings() async {
    await _nativeBridgeService.openExactAlarmSettings();
  }

  Future<void> toggleMonitoring(bool enabled) async {
    _settings = _settings.copyWith(
      monitoringEnabled: enabled,
      touchUpdatedAt: true,
    );
    notifyListeners();
    await _persistAndSync();
    await _localNotificationService.showMonitoringStatus(_settings);
  }

  Future<void> updateSchedule({
    required int startHour,
    required int startMinute,
    required int endHour,
    required int endMinute,
  }) async {
    _settings = _settings.copyWith(
      schedule: _settings.schedule.copyWith(
        startHour: startHour,
        startMinute: startMinute,
        endHour: endHour,
        endMinute: endMinute,
      ),
      touchUpdatedAt: true,
    );
    notifyListeners();
    await _persistAndSync();
  }

  Future<void> updateTheme(AppThemePreference preference) async {
    _settings = _settings.copyWith(
      themePreference: preference,
      touchUpdatedAt: true,
    );
    notifyListeners();
    await _persistAndSync();
  }

  Future<void> updateVibration(bool enabled) async {
    _settings = _settings.copyWith(
      vibrationEnabled: enabled,
      touchUpdatedAt: true,
    );
    notifyListeners();
    await _persistAndSync();
  }

  Future<void> updateRingtone(String ringtoneId) async {
    _settings = _settings.copyWith(
      ringtoneId: ringtoneId,
      touchUpdatedAt: true,
    );
    notifyListeners();
    await _persistAndSync();
  }

  Future<void> updateAlarmVolume(double value) async {
    _settings = _settings.copyWith(
      alarmVolume: value.clamp(0.1, 1.0),
      touchUpdatedAt: true,
    );
    notifyListeners();
    await _persistAndSync();
  }

  Future<void> updateRepeatSeconds(int value) async {
    _settings = _settings.copyWith(
      repeatSeconds: value.clamp(10, 60),
      touchUpdatedAt: true,
    );
    notifyListeners();
    await _persistAndSync();
  }

  Future<void> updateSnoozeMinutes(int value) async {
    _settings = _settings.copyWith(
      snoozeMinutes: value.clamp(1, 15),
      touchUpdatedAt: true,
    );
    notifyListeners();
    await _persistAndSync();
  }

  Future<void> previewTone() async {
    final RingtoneProfile profile = RingtoneProfile.byId(_settings.ringtoneId);
    _isPreviewPlaying = true;
    notifyListeners();
    await _alarmPreviewService.playPreview(
      profile: profile,
      volume: _settings.alarmVolume,
    );
  }

  Future<void> stopTonePreview() async {
    await _alarmPreviewService.stop();
    _isPreviewPlaying = false;
    notifyListeners();
  }

  Future<void> runFullAlarmTest() async {
    await stopTonePreview();
    await _nativeBridgeService.startNativeAlarmPreview(_settings);
  }

  Future<void> stopNativeAlarm() async {
    await _nativeBridgeService.stopNativeAlarm();
  }

  Future<void> showSetupReminder() async {
    await _localNotificationService.showSetupReminder();
  }

  void _handleNotificationEvent(NotificationRecord record) {
    _alerts = <NotificationRecord>[
      record,
      ..._alerts.where((NotificationRecord item) => item.id != record.id),
    ].take(AppConstants.maxStoredAlerts).toList();

    unawaited(_localStorageService.saveAlertHistory(_alerts));

    final User? user = _boundUser;
    if (user != null) {
      unawaited(_firestoreService.syncLastAlert(user.uid, record));
    }

    notifyListeners();
  }

  Future<void> _persistAndSync() async {
    try {
      await _localStorageService.saveSettings(_settings);
    } catch (error) {
      debugPrint('Failed to save local settings: $error');
    }

    try {
      await _nativeBridgeService.syncMonitoringConfig(
        _settings,
        userId: _boundUser?.uid,
      );
    } catch (error) {
      debugPrint('Failed to sync native monitoring config: $error');
    }

    final User? user = _boundUser;
    if (user != null) {
      try {
        await _firestoreService.upsertUserProfile(user, _settings);
      } catch (error) {
        debugPrint('Failed to sync settings to Firestore: $error');
      }
    }
  }

  @override
  void dispose() {
    _notificationSubscription?.cancel();
    unawaited(_alarmPreviewService.dispose());
    super.dispose();
  }
}
