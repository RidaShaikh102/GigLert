import 'package:firebase_analytics/firebase_analytics.dart';

class AnalyticsService {
  AnalyticsService._();

  static final AnalyticsService instance = AnalyticsService._();

  final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;

  Map<String, Object>? _userParams(String? userId) {
    if (userId == null) return null;
    return <String, Object>{'user_id': userId};
  }

  Future<void> logAppOpen({String? userId}) async {
    await _analytics.logEvent(
      name: 'app_open',
      parameters: _userParams(userId),
    );
  }

  Future<void> logDashboardView({String? userId}) async {
    await _analytics.logEvent(
      name: 'dashboard_view',
      parameters: _userParams(userId),
    );
  }

  Future<void> logOnboardingComplete({String? userId}) async {
    await _analytics.logEvent(
      name: 'onboarding_complete',
      parameters: _userParams(userId),
    );
  }

  Future<void> logMonitoringToggle({
    required bool enabled,
    String? userId,
  }) async {
    final Map<String, Object>? params = userId == null
        ? <String, Object>{'enabled': enabled}
        : <String, Object>{'enabled': enabled, 'user_id': userId};

    await _analytics.logEvent(name: 'monitoring_toggle', parameters: params);
  }

  Future<void> logSettingsChanged({
    required String setting,
    String? userId,
  }) async {
    final Map<String, Object>? params = userId == null
        ? <String, Object>{'setting': setting}
        : <String, Object>{'setting': setting, 'user_id': userId};

    await _analytics.logEvent(name: 'settings_changed', parameters: params);
  }
}
