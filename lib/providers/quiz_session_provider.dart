import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/quiz_model.dart';
import '../models/attempt_model.dart';
import '../services/firestore_service.dart';
import 'auth_provider.dart';

class QuizSessionState {
  final QuizModel quiz;
  final int currentQuestionIndex;
  final Map<int, int?> selectedAnswers; // question index -> option index
  final int remainingSeconds;
  final int timeTakenSeconds;
  final bool isSubmitting;
  final bool isTimeUp;
  final AttemptModel? resultAttempt;

  const QuizSessionState({
    required this.quiz,
    this.currentQuestionIndex = 0,
    this.selectedAnswers = const {},
    required this.remainingSeconds,
    this.timeTakenSeconds = 0,
    this.isSubmitting = false,
    this.isTimeUp = false,
    this.resultAttempt,
  });

  bool get isFirstQuestion => currentQuestionIndex == 0;
  bool get isLastQuestion => currentQuestionIndex == (quiz.questions.length - 1);
  int get answeredCount => selectedAnswers.values.where((v) => v != null).length;
  int get totalQuestions => quiz.questions.length;

  QuizSessionState copyWith({
    QuizModel? quiz,
    int? currentQuestionIndex,
    Map<int, int?>? selectedAnswers,
    int? remainingSeconds,
    int? timeTakenSeconds,
    bool? isSubmitting,
    bool? isTimeUp,
    AttemptModel? resultAttempt,
  }) {
    return QuizSessionState(
      quiz: quiz ?? this.quiz,
      currentQuestionIndex: currentQuestionIndex ?? this.currentQuestionIndex,
      selectedAnswers: selectedAnswers ?? this.selectedAnswers,
      remainingSeconds: remainingSeconds ?? this.remainingSeconds,
      timeTakenSeconds: timeTakenSeconds ?? this.timeTakenSeconds,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      isTimeUp: isTimeUp ?? this.isTimeUp,
      resultAttempt: resultAttempt ?? this.resultAttempt,
    );
  }
}

class QuizSessionNotifier extends StateNotifier<QuizSessionState> {
  final FirestoreService _firestoreService;
  Timer? _timer;

  QuizSessionNotifier(QuizModel quiz, this._firestoreService)
      : super(
          QuizSessionState(
            quiz: quiz,
            remainingSeconds: quiz.timeLimitMinutes * 60,
          ),
        ) {
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (state.remainingSeconds > 0) {
        state = state.copyWith(
          remainingSeconds: state.remainingSeconds - 1,
          timeTakenSeconds: state.timeTakenSeconds + 1,
        );
      } else {
        _timer?.cancel();
        state = state.copyWith(isTimeUp: true);
      }
    });
  }

  void selectOption(int questionIndex, int optionIndex) {
    final updated = Map<int, int?>.from(state.selectedAnswers);
    // If tapping the already selected option, toggle off or keep selected
    if (updated[questionIndex] == optionIndex) {
      updated[questionIndex] = null; // deselect
    } else {
      updated[questionIndex] = optionIndex;
    }
    state = state.copyWith(selectedAnswers: updated);
  }

  void nextQuestion() {
    if (!state.isLastQuestion) {
      state = state.copyWith(currentQuestionIndex: state.currentQuestionIndex + 1);
    }
  }

  void previousQuestion() {
    if (!state.isFirstQuestion) {
      state = state.copyWith(currentQuestionIndex: state.currentQuestionIndex - 1);
    }
  }

  void jumpToQuestion(int index) {
    if (index >= 0 && index < state.quiz.questions.length) {
      state = state.copyWith(currentQuestionIndex: index);
    }
  }

  /// Submit quiz, calculate score, write to Firestore, and update state
  Future<AttemptModel> submitQuiz(String uid) async {
    _timer?.cancel();
    state = state.copyWith(isSubmitting: true);

    int correctCount = 0;
    int incorrectCount = 0;
    int skippedCount = 0;
    final List<AnswerRecord> answerRecords = [];

    for (int i = 0; i < state.quiz.questions.length; i++) {
      final question = state.quiz.questions[i];
      final selected = state.selectedAnswers[i];

      if (selected == null) {
        skippedCount++;
      } else if (selected == question.correctOptionIndex) {
        correctCount++;
      } else {
        incorrectCount++;
      }

      answerRecords.add(
        AnswerRecord(
          questionText: question.questionText,
          selectedIndex: selected,
          correctIndex: question.correctOptionIndex,
          explanation: question.explanation,
        ),
      );
    }

    final totalQuestions = state.quiz.questions.length;
    final scorePercentage = totalQuestions > 0
        ? ((correctCount / totalQuestions) * 100).toDouble()
        : 0.0;

    final attempt = AttemptModel(
      id: '',
      quizId: state.quiz.id,
      quizTitle: state.quiz.title,
      score: double.parse(scorePercentage.toStringAsFixed(1)),
      totalQuestions: totalQuestions,
      correctCount: correctCount,
      incorrectCount: incorrectCount,
      skippedCount: skippedCount,
      timeTakenSeconds: state.timeTakenSeconds,
      attemptedAt: DateTime.now(),
      answers: answerRecords,
    );

    // Save to Firestore if uid is present
    if (uid.isNotEmpty) {
      try {
        await _firestoreService.recordQuizAttempt(
          uid: uid,
          attempt: attempt,
        );
      } catch (_) {
        // Safe local fallback
      }
    }

    state = state.copyWith(
      isSubmitting: false,
      resultAttempt: attempt,
    );

    return attempt;
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

final quizSessionProvider = StateNotifierProvider.autoDispose
    .family<QuizSessionNotifier, QuizSessionState, QuizModel>((ref, quiz) {
  final firestoreService = ref.watch(firestoreServiceProvider);
  return QuizSessionNotifier(quiz, firestoreService);
});
