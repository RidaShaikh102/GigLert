import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/app_settings.dart';
import '../models/notification_record.dart';
import '../utils/app_constants.dart';

class LocalStorageService {
  late final SharedPreferencesWithCache _preferences;

  Future<void> initialize() async {
    _preferences = await SharedPreferencesWithCache.create(
      cacheOptions: SharedPreferencesWithCacheOptions(
        allowList: <String>{
          AppConstants.settingsKey,
          AppConstants.alertsKey,
          AppConstants.onboardingKey,
        },
      ),
    );
  }

  AppSettings loadSettings() {
    final String? rawJson = _preferences.getString(AppConstants.settingsKey);
    if (rawJson == null || rawJson.isEmpty) {
      return AppSettings.defaults();
    }

    try {
      return AppSettings.fromJson(
        jsonDecode(rawJson) as Map<String, dynamic>,
      );
    } catch (_) {
      return AppSettings.defaults();
    }
  }

  Future<void> saveSettings(AppSettings settings) async {
    await _preferences.setString(
      AppConstants.settingsKey,
      jsonEncode(settings.toJson()),
    );
  }

  List<NotificationRecord> loadAlertHistory() {
    final String? rawJson = _preferences.getString(AppConstants.alertsKey);
    if (rawJson == null || rawJson.isEmpty) {
      return <NotificationRecord>[];
    }

    try {
      final List<dynamic> decoded = jsonDecode(rawJson) as List<dynamic>;
      return decoded
          .map(
            (dynamic item) => NotificationRecord.fromJson(
              (item as Map<Object?, Object?>).cast<String, dynamic>(),
            ),
          )
          .toList();
    } catch (_) {
      return <NotificationRecord>[];
    }
  }

  Future<void> saveAlertHistory(List<NotificationRecord> alerts) async {
    await _preferences.setString(
      AppConstants.alertsKey,
      jsonEncode(
        alerts
            .take(AppConstants.maxStoredAlerts)
            .map((NotificationRecord item) => item.toJson())
            .toList(),
      ),
    );
  }

  bool loadOnboardingCompleted() {
    return _preferences.getBool(AppConstants.onboardingKey) ?? false;
  }

  Future<void> saveOnboardingCompleted(bool value) async {
    await _preferences.setBool(AppConstants.onboardingKey, value);
  }
}
