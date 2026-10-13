import 'package:flutter_test/flutter_test.dart';
import 'package:quiz/models/user_model.dart';
import 'package:quiz/models/quiz_model.dart';
import 'package:quiz/models/attempt_model.dart';
import 'package:quiz/services/quiz_seeder_service.dart';
import 'package:quiz/utils/error_helpers.dart';

void main() {
  group('CRT Quiz Unit & Model Tests', () {
    test('UserModel serialization and copyWith test', () {
      final user = UserModel(
        uid: 'user_123',
        name: 'John Student',
        email: 'john@example.com',
        createdAt: DateTime(2026, 1, 1),
        totalQuizzesTaken: 4,
        averageScore: 82.5,
        bestScore: 100.0,
      );

      final map = user.toMap();
      expect(map['uid'], 'user_123');
      expect(map['name'], 'John Student');
      expect(map['totalQuizzesTaken'], 4);
      expect(map['averageScore'], 82.5);

      final updated = user.copyWith(name: 'John Senior');
      expect(updated.name, 'John Senior');
      expect(updated.email, 'john@example.com');
    });

    test('QuizSeederService contains full CRT topic mock quizzes', () {
      final quizzes = QuizSeederService.getSampleQuizzes();
      expect(quizzes.isNotEmpty, true);
      expect(quizzes.length, greaterThanOrEqualTo(4));

      // Verify all quizzes have questions and valid option bounds
      for (final quiz in quizzes) {
        expect(quiz.title.isNotEmpty, true);
        expect(quiz.questions.isNotEmpty, true);
        for (final q in quiz.questions) {
          expect(q.options.length, greaterThanOrEqualTo(2));
          expect(q.correctOptionIndex >= 0 && q.correctOptionIndex < q.options.length, true);
        }
      }
    });

    test('AttemptModel calculates percentage and performance badges accurately', () {
      final attempt1 = AttemptModel(
        id: 'att_1',
        quizId: 'quiz_1',
        quizTitle: 'Speed Math',
        score: 90.0,
        totalQuestions: 10,
        correctCount: 9,
        incorrectCount: 1,
        skippedCount: 0,
        timeTakenSeconds: 120,
        attemptedAt: DateTime.now(),
        answers: const [],
      );

      expect(attempt1.percentage, 90.0);
      expect(attempt1.performanceBadge, 'Mastery');

      final attempt2 = AttemptModel(
        id: 'att_2',
        quizId: 'quiz_2',
        quizTitle: 'Logic',
        score: 40.0,
        totalQuestions: 10,
        correctCount: 4,
        incorrectCount: 6,
        skippedCount: 0,
        timeTakenSeconds: 150,
        attemptedAt: DateTime.now(),
        answers: const [],
      );

      expect(attempt2.percentage, 40.0);
      expect(attempt2.performanceBadge, 'Needs Practice');
    });

    test('ErrorHelpers maps error codes to clear messages', () {
      final genericMsg = ErrorHelpers.getAuthErrorMessage(null);
      expect(genericMsg.isNotEmpty, true);

      final firestoreMsg = ErrorHelpers.getFirestoreErrorMessage('permission-denied');
      expect(firestoreMsg.contains('Permission denied'), true);
    });
  });
}
