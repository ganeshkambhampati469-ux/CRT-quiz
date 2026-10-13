import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/attempt_model.dart';
import 'auth_provider.dart';

/// Stream of attempts for the currently authenticated user
final userAttemptsProvider = StreamProvider<List<AttemptModel>>((ref) {
  final authState = ref.watch(authStateProvider);
  final user = authState.value;
  if (user == null) {
    return Stream.value([]);
  }
  final firestoreService = ref.watch(firestoreServiceProvider);
  return firestoreService.getUserAttemptsStream(user.uid);
});

/// Cached recent attempt provider (for navigation to Results/Review)
final currentAttemptResultProvider = StateProvider<AttemptModel?>((ref) => null);
