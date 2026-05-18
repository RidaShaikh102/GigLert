import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/app_state_provider.dart';
import 'providers/auth_provider.dart';
import 'screens/home_shell.dart';
import 'screens/onboarding_screen.dart';
import 'screens/sign_in_screen.dart';
import 'screens/splash_screen.dart';
import 'theme/app_theme.dart';
import 'models/app_settings.dart';

class GigLertApp extends StatefulWidget {
  const GigLertApp({super.key});

  @override
  State<GigLertApp> createState() => _GigLertAppState();
}

class _GigLertAppState extends State<GigLertApp> with WidgetsBindingObserver {
  final List<Timer> _pendingPermissionRefreshes = <Timer>[];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    for (final Timer timer in _pendingPermissionRefreshes) {
      timer.cancel();
    }
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _schedulePermissionRefreshes();
    }
  }

  void _schedulePermissionRefreshes() {
    for (final Timer timer in _pendingPermissionRefreshes) {
      timer.cancel();
    }
    _pendingPermissionRefreshes.clear();

    for (final Duration delay in <Duration>[
      Duration.zero,
      const Duration(milliseconds: 500),
      const Duration(seconds: 1),
    ]) {
      final Timer timer = Timer(delay, () {
        if (!mounted) {
          return;
        }

        final AppStateProvider? appState = context.read<AppStateProvider?>();
        if (appState != null) {
          unawaited(appState.refreshPermissions());
        }
      });
      _pendingPermissionRefreshes.add(timer);
    }
  }

  @override
  Widget build(BuildContext context) {
    final AppStateProvider? appState = context.watch<AppStateProvider?>();

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'GigLert',
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode:
          appState?.settings.themePreference.themeMode ??
          AppThemePreference.system.themeMode,
      home: const _RootGate(),
    );
  }
}

class _RootGate extends StatelessWidget {
  const _RootGate();

  @override
  Widget build(BuildContext context) {
    final AuthProvider? authProvider = context.watch<AuthProvider?>();
    final AppStateProvider? appState = context.watch<AppStateProvider?>();

    if (authProvider == null || appState == null) {
      return const SplashScreen();
    }

    if (authProvider.isInitializing || appState.isInitializing) {
      return const SplashScreen();
    }

    if (!appState.hasCompletedOnboarding) {
      return const OnboardingScreen();
    }

    if (!authProvider.isSignedIn) {
      return const SignInScreen();
    }

    return const HomeShell();
  }
}
