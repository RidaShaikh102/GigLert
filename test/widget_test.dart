import 'package:firebase_auth/firebase_auth.dart' show User;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

import 'package:giglert/app.dart';
import 'package:giglert/models/app_settings.dart';
import 'package:giglert/models/notification_record.dart';
import 'package:giglert/providers/app_state_provider.dart';
import 'package:giglert/providers/auth_provider.dart';
import 'package:giglert/screens/dashboard_screen.dart';
import 'package:giglert/screens/home_shell.dart';
import 'package:giglert/screens/onboarding_screen.dart';
import 'package:giglert/screens/sign_in_screen.dart';
import 'package:giglert/screens/splash_screen.dart';
import 'package:giglert/services/permission_service.dart';
import 'package:giglert/widgets/app_logo.dart';

class FakeAppStateProvider extends ChangeNotifier implements AppStateProvider {
  FakeAppStateProvider({
    required AppSettings settings,
    required bool hasCompletedOnboarding,
    bool isInitializing = false,
  }) : _settings = settings,
       _hasCompletedOnboarding = hasCompletedOnboarding,
       _isInitializing = isInitializing;

  final AppSettings _settings;
  final bool _hasCompletedOnboarding;
  final bool _isInitializing;

  @override
  AppSettings get settings => _settings;

  @override
  bool get hasCompletedOnboarding => _hasCompletedOnboarding;

  @override
  bool get isInitializing => _isInitializing;

  @override
  List<NotificationRecord> get alerts => const <NotificationRecord>[];

  @override
  PermissionDashboardState get permissionState =>
      PermissionDashboardState.empty();

  @override
  bool get isPreviewPlaying => false;

  @override
  NotificationRecord? get lastNotification => null;

  @override
  Future<void> initialize() async {}

  @override
  void bindUser(dynamic user) {}

  @override
  Future<void> completeOnboarding() async {}

  @override
  Future<void> resetOnboarding() async {}

  @override
  Future<void> refreshPermissions() async {}

  @override
  Future<void> requestNotificationBundle() async {}

  @override
  Future<void> openNotificationAccessSettings() async {}

  @override
  Future<void> openAppDetailsSettings() async {}

  @override
  Future<void> openBatteryOptimizationSettings() async {}

  @override
  Future<void> requestIgnoreBatteryOptimizations() async {}

  @override
  Future<void> openExactAlarmSettings() async {}

  @override
  Future<void> toggleMonitoring(bool enabled) async {}

  @override
  Future<void> updateSchedule({
    required int startHour,
    required int startMinute,
    required int endHour,
    required int endMinute,
  }) async {}

  @override
  Future<void> updateTheme(AppThemePreference preference) async {}

  @override
  Future<void> updateVibration(bool enabled) async {}

  @override
  Future<void> updateRingtone(String ringtoneId) async {}

  @override
  Future<void> updateAlarmVolume(double value) async {}

  @override
  Future<void> updateRepeatSeconds(int value) async {}

  @override
  Future<void> updateSnoozeMinutes(int value) async {}

  @override
  Future<void> previewTone() async {}

  @override
  Future<void> stopTonePreview() async {}

  @override
  Future<void> runFullAlarmTest() async {}

  @override
  Future<void> stopNativeAlarm() async {}

  @override
  Future<void> showSetupReminder() async {}

  @override
  Future<void> updateNotifyNewMessages(bool value) async {}

  @override
  Future<void> updateNotifyNewOrders(bool value) async {}

  @override
  Future<void> updateNotifyBuyerRequests(bool value) async {}

  @override
  Future<void> updateNotifyCustomOffers(bool value) async {}

  @override
  Future<void> updateNotifyRevisions(bool value) async {}

  @override
  Future<void> updateNotifyCancellations(bool value) async {}

  @override
  Future<void> updateOnlyImportantNotifications(bool value) async {}

  @override
  Future<void> updateKeywordDetection(bool value) async {}

  @override
  Future<void> updateRepeatUrgentMessages(bool value) async {}

  @override
  Future<void> updateFullScreenAlarm(bool value) async {}

  @override
  Future<void> updateStrongSleepAlerts(bool value) async {}

  @override
  Future<void> updateCloudSync(bool value) async {}
}

class FakeAuthProvider extends ChangeNotifier implements AuthProvider {
  FakeAuthProvider({
    required bool isSignedIn,
    bool isInitializing = false,
    bool firebaseConfigured = true,
    bool googleSignInSupported = true,
    String? errorMessage,
  }) : _isSignedIn = isSignedIn,
       _isInitializing = isInitializing,
       _firebaseConfigured = firebaseConfigured,
       _googleSignInSupported = googleSignInSupported,
       _errorMessage = errorMessage;

  final bool _isSignedIn;
  final bool _isInitializing;
  final bool _firebaseConfigured;
  final bool _googleSignInSupported;
  final String? _errorMessage;

  @override
  User? get user => null;

  @override
  bool get isInitializing => _isInitializing;

  @override
  bool get isSigningIn => false;

  @override
  bool get isSignedIn => _isSignedIn;

  @override
  bool get firebaseConfigured => _firebaseConfigured;

  @override
  bool get googleSignInSupported => _googleSignInSupported;

  @override
  String? get errorMessage => _errorMessage;

  @override
  Future<void> initialize() async {}

  @override
  Future<void> signInWithGoogle() async {}

  @override
  Future<void> signInWithEmail({
    required String email,
    required String password,
  }) async {}

  @override
  Future<void> registerWithEmail({
    required String email,
    required String password,
  }) async {}

  @override
  Future<void> signOut() async {}

  @override
  void clearError() {}
}

Widget wrapWithProviders({
  required AuthProvider authProvider,
  required AppStateProvider appStateProvider,
  required Widget child,
}) {
  return MultiProvider(
    providers: <SingleChildWidget>[
      ChangeNotifierProvider<AuthProvider>.value(value: authProvider),
      ChangeNotifierProvider<AppStateProvider>.value(value: appStateProvider),
    ],
    child: child,
  );
}

Finder findAssetImage(String assetName) {
  return find.byWidgetPredicate(
    (Widget widget) =>
        widget is Image &&
        widget.image is AssetImage &&
        (widget.image as AssetImage).assetName == assetName,
    description: 'Image.asset($assetName)',
  );
}

void main() {
  testWidgets('GigLertApp falls back to SplashScreen without providers', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const GigLertApp());

    expect(find.byType(SplashScreen), findsOneWidget);
  });

  testWidgets('Root gate shows SplashScreen while initializing', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      wrapWithProviders(
        authProvider: FakeAuthProvider(isSignedIn: false, isInitializing: true),
        appStateProvider: FakeAppStateProvider(
          settings: AppSettings.defaults(),
          hasCompletedOnboarding: false,
        ),
        child: const GigLertApp(),
      ),
    );

    expect(find.byType(SplashScreen), findsOneWidget);
  });

  testWidgets(
    'Root gate shows OnboardingScreen when onboarding is incomplete',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        wrapWithProviders(
          authProvider: FakeAuthProvider(isSignedIn: false),
          appStateProvider: FakeAppStateProvider(
            settings: AppSettings.defaults(),
            hasCompletedOnboarding: false,
          ),
          child: const GigLertApp(),
        ),
      );

      expect(find.byType(OnboardingScreen), findsOneWidget);
    },
  );

  testWidgets('Root gate shows SignInScreen when signed out', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      wrapWithProviders(
        authProvider: FakeAuthProvider(isSignedIn: false),
        appStateProvider: FakeAppStateProvider(
          settings: AppSettings.defaults(),
          hasCompletedOnboarding: true,
        ),
        child: const GigLertApp(),
      ),
    );

    expect(find.byType(SignInScreen), findsOneWidget);
  });

  testWidgets(
    'Root gate shows HomeShell when signed in and onboarding complete',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        wrapWithProviders(
          authProvider: FakeAuthProvider(isSignedIn: true),
          appStateProvider: FakeAppStateProvider(
            settings: AppSettings.defaults(),
            hasCompletedOnboarding: true,
          ),
          child: const GigLertApp(),
        ),
      );

      expect(find.byType(HomeShell), findsOneWidget);
    },
  );

  testWidgets('SplashScreen keeps showing the logo mark asset', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: SplashScreen()));

    expect(findAssetImage(AppLogo.markAssetPath), findsOneWidget);
  });

  testWidgets('OnboardingScreen shows the wordmark asset', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      wrapWithProviders(
        authProvider: FakeAuthProvider(isSignedIn: false),
        appStateProvider: FakeAppStateProvider(
          settings: AppSettings.defaults(),
          hasCompletedOnboarding: false,
        ),
        child: const MaterialApp(home: OnboardingScreen()),
      ),
    );

    expect(findAssetImage(AppLogo.wordmarkAssetPath), findsOneWidget);
  });

  testWidgets('SignInScreen shows the wordmark asset', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      wrapWithProviders(
        authProvider: FakeAuthProvider(isSignedIn: false),
        appStateProvider: FakeAppStateProvider(
          settings: AppSettings.defaults(),
          hasCompletedOnboarding: true,
        ),
        child: const MaterialApp(home: SignInScreen()),
      ),
    );

    expect(findAssetImage(AppLogo.wordmarkAssetPath), findsOneWidget);
  });

  testWidgets('DashboardScreen shows Turn off monitoring when enabled', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      wrapWithProviders(
        authProvider: FakeAuthProvider(isSignedIn: true),
        appStateProvider: FakeAppStateProvider(
          settings: AppSettings.defaults(),
          hasCompletedOnboarding: true,
        ),
        child: const MaterialApp(home: Scaffold(body: DashboardScreen())),
      ),
    );

    expect(find.text('Turn off monitoring'), findsOneWidget);
    expect(find.text('Turn on monitoring'), findsNothing);
  });

  testWidgets('DashboardScreen shows Turn on monitoring when disabled', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      wrapWithProviders(
        authProvider: FakeAuthProvider(isSignedIn: true),
        appStateProvider: FakeAppStateProvider(
          settings: AppSettings.defaults().copyWith(monitoringEnabled: false),
          hasCompletedOnboarding: true,
        ),
        child: const MaterialApp(home: Scaffold(body: DashboardScreen())),
      ),
    );

    expect(find.text('Turn on monitoring'), findsOneWidget);
    expect(find.text('Turn off monitoring'), findsNothing);
  });
}
