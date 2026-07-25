// Package imports:
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

// Core imports:
import '/core/errors/exceptions.dart';

// Features imports:
import '/features/auth/data/models/auth_user_model.dart';

abstract class AuthRemoteDataSource {
  Future<AuthUserModel> signInWithGoogle();
  Future<AuthUserModel> signInAnonymously();
  Future<void> signOut();
  Future<AuthUserModel> getCurrentUser();
  Stream<AuthUserModel?> watchAuthState();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  const AuthRemoteDataSourceImpl({
    required this._firebaseAuth,
    required this._googleSignIn,
  });

  final FirebaseAuth _firebaseAuth;
  final GoogleSignIn _googleSignIn;

  // ── Google ─────────────────────────────────────────────────────────────────

  @override
  Future<AuthUserModel> signInWithGoogle() async {
    try {
      await _googleSignIn.initialize();

      final GoogleSignInAccount googleUser = await _googleSignIn.authenticate();
      final GoogleSignInAuthentication googleAuth = googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
      );

      final userCredential = await _firebaseAuth.signInWithCredential(
        credential,
      );

      final user = userCredential.user;

      if (user == null) {
        throw const AuthException(message: 'Failed to retrieve user');
      }

      // Refresh user profile data from Firebase
      await user.reload();

      final refreshedUser = _firebaseAuth.currentUser;

      if (refreshedUser == null) {
        throw const AuthException(message: 'Failed to refresh user data');
      }

      return AuthUserModel(
        uid: refreshedUser.uid,
        email: refreshedUser.email,
        displayName: refreshedUser.displayName ?? googleUser.displayName,
        photoUrl: refreshedUser.photoURL,
        isAnonymous: refreshedUser.isAnonymous,
      );
    } on AuthException {
      rethrow;
    } on FirebaseAuthException catch (e) {
      throw AuthException(message: e.message ?? 'Authentication failed');
    } catch (e) {
      throw AuthException(message: e.toString());
    }
  }

  // ── Anonymous ──────────────────────────────────────────────────────────────

  @override
  Future<AuthUserModel> signInAnonymously() async {
    try {
      final result = await _firebaseAuth.signInAnonymously();

      if (result.user == null) {
        throw const AuthException(message: 'Failed to sign in anonymously');
      }

      return AuthUserModel.fromFirebaseUser(result.user!);
    } on FirebaseAuthException catch (e) {
      throw AuthException(
        message: e.message ?? 'Firebase authentication error',
      );
    } catch (e) {
      throw AuthException(message: e.toString());
    }
  }

  // ── Sign-out ───────────────────────────────────────────────────────────────

  @override
  Future<void> signOut() async {
    try {
      await _firebaseAuth.signOut();
    } on FirebaseAuthException catch (e) {
      throw AuthException(message: e.message ?? 'Sign out failed');
    } catch (e) {
      throw AuthException(message: e.toString());
    }
  }

  // ── Session check ──────────────────────────────────────────────────────────

  @override
  Stream<AuthUserModel?> watchAuthState() {
    return _firebaseAuth.authStateChanges().map(
      (user) => user == null ? null : AuthUserModel.fromFirebaseUser(user),
    );
  }

  @override
  Future<AuthUserModel> getCurrentUser() async {
    final user = _firebaseAuth.currentUser;
    if (user == null) {
      throw const AuthException(message: 'No user is currently signed in');
    }
    return AuthUserModel.fromFirebaseUser(user);
  }
}
