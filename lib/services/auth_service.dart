import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  User? get currentUser => _auth.currentUser;

  /// Sign in with email and password
  Future<UserCredential> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    return await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
  }

  /// Sign up with email and password, and set displayName
  Future<UserCredential> signUpWithEmailAndPassword({
    required String email,
    required String password,
    required String name,
  }) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );

    if (credential.user != null) {
      await credential.user!.updateDisplayName(name.trim());
    }

    return credential;
  }

  /// Send password reset link to user's email
  Future<void> sendPasswordResetEmail(String email) async {
    await _auth.sendPasswordResetEmail(email: email.trim());
  }

  /// Update user display name
  Future<void> updateDisplayName(String name) async {
    if (_auth.currentUser != null) {
      await _auth.currentUser!.updateDisplayName(name.trim());
      await _auth.currentUser!.reload();
    }
  }

  /// Change user password (with re-authentication)
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    final user = _auth.currentUser;
    if (user == null || user.email == null) {
      throw FirebaseAuthException(
        code: 'no-user',
        message: 'No authenticated user found.',
      );
    }

    // Re-authenticate first
    final cred = EmailAuthProvider.credential(
      email: user.email!,
      password: currentPassword,
    );
    await user.reauthenticateWithCredential(cred);
    await user.updatePassword(newPassword);
  }

  /// Sign out
  Future<void> signOut() async {
    await _auth.signOut();
  }
}
