import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  static GoogleSignIn defaultGoogleSignIn() => GoogleSignIn.instance;

  AuthService({
    required FirebaseAuth? firebaseAuth,
    required GoogleSignIn googleSignIn,
  })  : _firebaseAuth = firebaseAuth,
        _googleSignIn = googleSignIn;

  final FirebaseAuth? _firebaseAuth;
  final GoogleSignIn _googleSignIn;

  bool _googleSignInInitialized = false;
  bool _supportsInteractiveSignIn = false;

  bool get isAvailable => _firebaseAuth != null;
  bool get supportsInteractiveSignIn =>
      isAvailable && _supportsInteractiveSignIn;

  User? get currentUser => _firebaseAuth?.currentUser;

  Stream<User?> authStateChanges() {
    if (!isAvailable) {
      return const Stream<User?>.empty();
    }

    return _firebaseAuth!.userChanges();
  }

  Future<void> initialize() async {
    if (_googleSignInInitialized || !isAvailable) {
      return;
    }

    await _googleSignIn.initialize();
    try {
      _supportsInteractiveSignIn = _googleSignIn.supportsAuthenticate();
    } on UnsupportedError {
      _supportsInteractiveSignIn = false;
    }
    _googleSignInInitialized = true;
  }

  Future<UserCredential> signInWithGoogle() async {
    if (!isAvailable) {
      throw StateError('Firebase is not configured for this platform yet.');
    }

    await initialize();

    if (!supportsInteractiveSignIn) {
      throw StateError(
        'Google Sign-In is not supported on this platform/build.',
      );
    }

    final GoogleSignInAccount googleUser = await _googleSignIn.authenticate();
    final GoogleSignInAuthentication googleAuth = googleUser.authentication;
    final String? idToken = googleAuth.idToken;

    if (idToken == null || idToken.isEmpty) {
      throw StateError(
        'Google Sign-In did not return an ID token. Refresh your Firebase OAuth client configuration and google-services.json.',
      );
    }

    final AuthCredential credential = GoogleAuthProvider.credential(
      idToken: idToken,
    );

    return _firebaseAuth!.signInWithCredential(credential);
  }

  Future<void> signOut() async {
    if (_googleSignInInitialized) {
      await _googleSignIn.signOut();
    }
    await _firebaseAuth?.signOut();
  }
}
