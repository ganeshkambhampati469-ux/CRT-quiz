import 'package:firebase_auth/firebase_auth.dart';

class ErrorHelpers {
  /// Converts FirebaseAuthException error codes into friendly user explanations.
  static String getAuthErrorMessage(dynamic error) {
    if (error is FirebaseAuthException) {
      switch (error.code) {
        case 'user-not-found':
          return 'No account found with this email. Please check the email or sign up.';
        case 'wrong-password':
          return 'Incorrect password. Please verify your credentials and try again.';
        case 'invalid-credential':
          return 'Invalid credentials. Please check your email and password.';
        case 'email-already-in-use':
          return 'An account already exists with this email address.';
        case 'invalid-email':
          return 'The email address is invalid or poorly formatted.';
        case 'weak-password':
          return 'The password is too weak. Please use at least 6 characters with letters & numbers.';
        case 'user-disabled':
          return 'This user account has been disabled by an administrator.';
        case 'too-many-requests':
          return 'Too many attempts. Please wait a few minutes before trying again.';
        case 'network-request-failed':
          return 'Network error. Please check your internet connection and try again.';
        case 'requires-recent-login':
          return 'This operation is sensitive and requires a recent login. Please log in again.';
        default:
          return error.message ?? 'Authentication failed. Please try again.';
      }
    }
    return error?.toString() ?? 'An unexpected error occurred. Please try again.';
  }

  /// General Firestore error mapper
  static String getFirestoreErrorMessage(dynamic error) {
    if (error.toString().contains('permission-denied')) {
      return 'Permission denied. Please check your account authorization.';
    } else if (error.toString().contains('unavailable')) {
      return 'The service is currently unavailable. Please check your internet connection.';
    }
    return 'Failed to sync data. Please try again.';
  }
}
