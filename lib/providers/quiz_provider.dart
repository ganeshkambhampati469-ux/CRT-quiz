import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/quiz_model.dart';
import '../services/quiz_seeder_service.dart';
import 'auth_provider.dart';

/// Currently selected topic filter (e.g. 'All Topics', 'Quantitative Aptitude', etc.)
final selectedTopicFilterProvider = StateProvider<String>((ref) => 'All Topics');

/// Search query provider
final searchQueryProvider = StateProvider<String>((ref) => '');

/// Stream of quizzes from Firestore with automatic seeding / sample fallback
final quizzesStreamProvider = StreamProvider<List<QuizModel>>((ref) async* {
  final firestoreService = ref.watch(firestoreServiceProvider);

  // Attempt initial auto-seed in background if empty
  QuizSeederService.seedInitialQuizzesIfEmpty();

  await for (final quizzes in firestoreService.getQuizzesStream()) {
    if (quizzes.isNotEmpty) {
      yield quizzes;
    } else {
      // Fall back to sample quizzes if Firestore hasn't synced yet
      yield QuizSeederService.getSampleQuizzes();
    }
  }
});

/// Filtered list of quizzes based on search query and category topic filter
final filteredQuizzesProvider = Provider<List<QuizModel>>((ref) {
  final quizzesAsync = ref.watch(quizzesStreamProvider);
  final selectedTopic = ref.watch(selectedTopicFilterProvider);
  final searchQuery = ref.watch(searchQueryProvider).trim().toLowerCase();

  final quizzes = quizzesAsync.value ?? QuizSeederService.getSampleQuizzes();

  return quizzes.where((quiz) {
    final matchesTopic =
        selectedTopic == 'All Topics' || quiz.topic.toLowerCase() == selectedTopic.toLowerCase();

    final matchesSearch = searchQuery.isEmpty ||
        quiz.title.toLowerCase().contains(searchQuery) ||
        quiz.topic.toLowerCase().contains(searchQuery) ||
        quiz.difficulty.toLowerCase().contains(searchQuery);

    return matchesTopic && matchesSearch;
  }).toList();
});

/// Single quiz fetch provider by ID
final quizDetailProvider = FutureProvider.family<QuizModel?, String>((ref, quizId) async {
  final firestoreService = ref.watch(firestoreServiceProvider);
  final firestoreQuiz = await firestoreService.getQuizById(quizId);
  if (firestoreQuiz != null) {
    return firestoreQuiz;
  }
  // Check in sample quizzes
  final sample = QuizSeederService.getSampleQuizzes().where((q) => q.id == quizId).toList();
  return sample.isNotEmpty ? sample.first : null;
});
