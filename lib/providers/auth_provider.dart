import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';

final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});

final firestoreServiceProvider = Provider<FirestoreService>((ref) {
  return FirestoreService();
});

/// Stream of auth state changes (null when logged out)
final authStateProvider = StreamProvider<User?>((ref) {
  final authService = ref.watch(authServiceProvider);
  return authService.authStateChanges;
});

/// Stream of the current user profile from Firestore
final userProfileProvider = StreamProvider<UserModel?>((ref) {
  final authState = ref.watch(authStateProvider);
  final user = authState.value;
  if (user == null) {
    return Stream.value(null);
  }
  final firestoreService = ref.watch(firestoreServiceProvider);
  return firestoreService.getUserProfileStream(user.uid);
});

/// State notifier for Auth actions (login, signup, reset password, logout)
class AuthController extends StateNotifier<AsyncValue<void>> {
  final AuthService _authService;
  final FirestoreService _firestoreService;

  AuthController(this._authService, this._firestoreService)
      : super(const AsyncValue.data(null));

  Future<bool> signIn(String email, String password) async {
    state = const AsyncValue.loading();
    try {
      await _authService.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      state = const AsyncValue.data(null);
      return true;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }

  Future<bool> signUp({
    required String name,
    required String email,
    required String password,
  }) async {
    state = const AsyncValue.loading();
    try {
      final cred = await _authService.signUpWithEmailAndPassword(
        email: email,
        password: password,
        name: name,
      );
      if (cred.user != null) {
        final newUser = UserModel(
          uid: cred.user!.uid,
          name: name.trim(),
          email: email.trim(),
          createdAt: DateTime.now(),
          totalQuizzesTaken: 0,
          averageScore: 0.0,
          bestScore: 0.0,
        );
        await _firestoreService.createUserProfile(newUser);
      }
      state = const AsyncValue.data(null);
      return true;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }

  Future<bool> sendPasswordReset(String email) async {
    state = const AsyncValue.loading();
    try {
      await _authService.sendPasswordResetEmail(email);
      state = const AsyncValue.data(null);
      return true;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }

  Future<bool> updateDisplayName(String newName) async {
    state = const AsyncValue.loading();
    try {
      await _authService.updateDisplayName(newName);
      final uid = _authService.currentUser?.uid;
      if (uid != null) {
        await _firestoreService.updateUserProfile(uid, {'name': newName.trim()});
      }
      state = const AsyncValue.data(null);
      return true;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }

  Future<bool> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    state = const AsyncValue.loading();
    try {
      await _authService.changePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
      );
      state = const AsyncValue.data(null);
      return true;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }

  Future<void> signOut() async {
    state = const AsyncValue.loading();
    try {
      await _authService.signOut();
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

final authControllerProvider =
    StateNotifierProvider<AuthController, AsyncValue<void>>((ref) {
  final authService = ref.watch(authServiceProvider);
  final firestoreService = ref.watch(firestoreServiceProvider);
  return AuthController(authService, firestoreService);
});
