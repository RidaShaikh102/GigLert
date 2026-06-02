import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  AuthProvider({required AuthService authService}) : _authService = authService;

  final AuthService _authService;

  StreamSubscription<User?>? _authSubscription;

  User? _user;
  bool _isInitializing = false;
  bool _googleSignInSupported = false;
  bool _isSigningIn = false;
  String? _errorMessage;

  User? get user => _user;
  bool get isInitializing => _isInitializing;
  bool get isSigningIn => _isSigningIn;
  bool get isSignedIn => _user != null;
  bool get firebaseConfigured => _authService.isAvailable;
  bool get googleSignInSupported => _googleSignInSupported;
  String? get errorMessage => _errorMessage;

  Future<void> initialize() async {
    _isInitializing = true;
    _errorMessage = null;
    _user = _authService.currentUser;
    notifyListeners();

    try {
      await _authService.initialize();
      _googleSignInSupported = _authService.supportsInteractiveSignIn;
      _authSubscription = _authService.authStateChanges().listen(
        (User? user) {
          _user = user;
          _isInitializing = false;
          notifyListeners();
        },
        onError: (Object error) {
          _errorMessage = _mapError(error);
          _isInitializing = false;
          notifyListeners();
        },
      );
    } catch (error) {
      _googleSignInSupported = false;
      _errorMessage = _mapError(error);
      _isInitializing = false;
      notifyListeners();
      return;
    }

    _isInitializing = false;
    notifyListeners();
  }

  Future<void> signInWithGoogle() async {
    _isSigningIn = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _authService.signInWithGoogle();
    } on FirebaseAuthException catch (error) {
      // Helps distinguish Firebase rejection vs Google UI cancellation.
      if (kDebugMode) {
        debugPrint(
          '[AuthProvider] FirebaseAuthException in signInWithGoogle: code=${error.code}, message=${error.message}, details=${error.toString()}',
        );
      }
      _errorMessage = _mapFirebaseError(error);
    } on GoogleSignInException catch (error) {
      // Helps distinguish user cancel vs configuration problems.
      if (kDebugMode) {
        debugPrint(
          '[AuthProvider] GoogleSignInException in signInWithGoogle: code=${error.code}, description=${error.description}, details=${error.toString()}',
        );
      }
      _errorMessage = _mapGoogleSignInError(error);
    } on StateError catch (error) {
      if (kDebugMode) {
        debugPrint('[AuthProvider] StateError in signInWithGoogle: $error');
      }
      _errorMessage = error.message.toString();
    } catch (error) {
      if (kDebugMode) {
        debugPrint('[AuthProvider] Unexpected error in signInWithGoogle: $error');
      }
      _errorMessage = _mapError(error);
    } finally {
      _isSigningIn = false;
      notifyListeners();
    }
  }

  Future<void> signOut() async {
    await _authService.signOut();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  String _mapFirebaseError(FirebaseAuthException error) {
    switch (error.code) {
      case 'network-request-failed':
        return 'The network request failed. Check your connection and try again.';
      case 'sign_in_canceled':
        return 'Google sign-in was canceled.';
      case 'too-many-requests':
        return 'Too many sign-in attempts. Please wait a moment and retry.';
      case 'operation-not-allowed':
        return 'Google Sign-In is not enabled in your Firebase project yet.';
      default:
        return error.message ?? 'Unable to complete Google sign-in.';
    }
  }

  String _mapGoogleSignInError(GoogleSignInException error) {
    switch (error.code) {
      case GoogleSignInExceptionCode.canceled:
        return 'Google sign-in was canceled.';
      case GoogleSignInExceptionCode.interrupted:
        return 'Google sign-in was interrupted. Please try again.';
      case GoogleSignInExceptionCode.clientConfigurationError:
        return 'Google Sign-In is misconfigured. Add the SHA-1 and SHA-256 fingerprints for com.giglert.app in Firebase, then download an updated android/app/google-services.json with populated OAuth client entries.';
      case GoogleSignInExceptionCode.providerConfigurationError:
        return 'Google Sign-In is not enabled or the native Google services configuration is incomplete for this build.';
      case GoogleSignInExceptionCode.uiUnavailable:
        return 'Google sign-in UI is unavailable on this platform/build.';
      case GoogleSignInExceptionCode.userMismatch:
        return 'Google sign-in switched accounts unexpectedly. Please sign out and try again.';
      case GoogleSignInExceptionCode.unknownError:
        return error.description ?? 'Unable to complete Google sign-in.';
    }
  }

  String _mapError(Object error) {
    if (error is FirebaseAuthException) {
      return _mapFirebaseError(error);
    }
    if (error is GoogleSignInException) {
      return _mapGoogleSignInError(error);
    }
    if (error is StateError) {
      return error.message.toString();
    }
    return error.toString();
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }
}
