import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';

/// Exposes the current Firebase [User] as a stream.
final firebaseUserProvider = StreamProvider<User?>((ref) {
  try {
    return FirebaseAuth.instance.authStateChanges();
  } catch (_) {
    // Firebase not initialized (offline-only mode) — emit null once.
    return Stream.value(null);
  }
});

/// True when the user is signed in with a real (non-anonymous) account.
final isSignedInProvider = Provider<bool>((ref) {
  final userAsync = ref.watch(firebaseUserProvider);
  return userAsync.whenOrNull(
        data: (user) => user != null && !user.isAnonymous,
      ) ??
      false;
});

class FirebaseAuthService {
  final FirebaseAuth _auth;
  final GoogleSignIn _googleSignIn;

  FirebaseAuthService({
    FirebaseAuth? auth,
    GoogleSignIn? googleSignIn,
  })  : _auth = auth ?? FirebaseAuth.instance,
        _googleSignIn = googleSignIn ?? GoogleSignIn();

  User? get currentUser => _auth.currentUser;

  /// Sign in with Google. Falls back to anonymous if cancelled or on error.
  Future<User?> signInWithGoogle() async {
    try {
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return _auth.currentUser; // user cancelled

      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      final result = await _auth.signInWithCredential(credential);
      return result.user;
    } catch (_) {
      return _auth.currentUser;
    }
  }

  /// Sign in anonymously (for local-only cloud-free mode).
  Future<User?> signInAnonymously() async {
    try {
      final result = await _auth.signInAnonymously();
      return result.user;
    } catch (_) {
      return null;
    }
  }

  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
      await _auth.signOut();
    } catch (_) {}
  }
}

final firebaseAuthServiceProvider = Provider<FirebaseAuthService>(
  (ref) => FirebaseAuthService(),
);
