import 'package:cloud_firestore/cloud_firestore.dart' show FirebaseFirestore;
import 'package:firebase_auth/firebase_auth.dart' show FirebaseAuth;
import 'package:firebase_core/firebase_core.dart'
    show Firebase, FirebaseApp, FirebaseOptions;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

import 'app.dart';
import 'firebase_options.dart';
import 'providers/app_state_provider.dart';
import 'providers/auth_provider.dart';

import 'services/alarm_preview_service.dart';
import 'services/auth_service.dart';
import 'services/firestore_service.dart';
import 'services/local_notification_service.dart';
import 'services/local_storage_service.dart';
import 'services/native_bridge_service.dart';
import 'services/permission_service.dart';
import 'services/analytics_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  FirebaseApp? firebaseApp;
  final FirebaseOptions? firebaseOptions =
      DefaultFirebaseOptions.currentPlatformOrNull;

  if (firebaseOptions != null) {
    try {
      firebaseApp = await Firebase.initializeApp(options: firebaseOptions);
    } catch (_) {
      firebaseApp = null;
    }
  }

  // Analytics doesn't require an extra initialize call beyond `firebase_core`,
  // but the SDK should be available at runtime (added via pubspec).
  if (firebaseApp != null) {
    await AnalyticsService.instance.logAppOpen();
  }

  final LocalStorageService localStorageService = LocalStorageService();
  await localStorageService.initialize();

  final LocalNotificationService localNotificationService =
      LocalNotificationService();
  await localNotificationService.initialize();

  final NativeBridgeService nativeBridgeService = NativeBridgeService();
  final PermissionService permissionService = PermissionService(
    nativeBridge: nativeBridgeService,
    localNotificationService: localNotificationService,
  );
  final AlarmPreviewService alarmPreviewService = AlarmPreviewService();

  final AuthService authService = AuthService(
    firebaseAuth: firebaseApp != null ? FirebaseAuth.instance : null,
    googleSignIn: AuthService.defaultGoogleSignIn(),
  );

  final FirestoreService firestoreService = FirestoreService(
    firestore: firebaseApp != null ? FirebaseFirestore.instance : null,
  );
  AppStateProvider buildAppStateProvider() {
    return AppStateProvider(
      localStorageService: localStorageService,
      firestoreService: firestoreService,
      nativeBridgeService: nativeBridgeService,
      permissionService: permissionService,
      localNotificationService: localNotificationService,
      alarmPreviewService: alarmPreviewService,
    )..initialize();
  }

  runApp(
    MultiProvider(
      providers: <SingleChildWidget>[
        ChangeNotifierProvider<AuthProvider>(
          create: (_) => AuthProvider(authService: authService)..initialize(),
        ),
        ChangeNotifierProxyProvider<AuthProvider, AppStateProvider>(
          create: (_) => buildAppStateProvider(),
          update: (_, AuthProvider authProvider, AppStateProvider? appState) {
            final AppStateProvider resolvedAppState =
                appState ?? buildAppStateProvider();
            resolvedAppState.bindUser(authProvider.user);
            return resolvedAppState;
          },
        ),
      ],
      child: const GigLertApp(),
    ),
  );
}
