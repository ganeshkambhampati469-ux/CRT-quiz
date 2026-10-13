import 'package:cloud_firestore/cloud_firestore.dart';

class AnswerRecord {
  final String questionText;
  final int? selectedIndex;
  final int correctIndex;
  final String? explanation;

  const AnswerRecord({
    required this.questionText,
    required this.selectedIndex,
    required this.correctIndex,
    this.explanation,
  });

  bool get isCorrect => selectedIndex != null && selectedIndex == correctIndex;
  bool get isSkipped => selectedIndex == null;

  Map<String, dynamic> toMap() {
    return {
      'questionText': questionText,
      'selectedIndex': selectedIndex,
      'correctIndex': correctIndex,
      'explanation': explanation,
    };
  }

  factory AnswerRecord.fromMap(Map<String, dynamic> map) {
    return AnswerRecord(
      questionText: map['questionText'] ?? '',
      selectedIndex: (map['selectedIndex'] as num?)?.toInt(),
      correctIndex: (map['correctIndex'] as num?)?.toInt() ?? 0,
      explanation: map['explanation'] as String?,
    );
  }
}

class AttemptModel {
  final String id;
  final String quizId;
  final String quizTitle;
  final double score; // Percentage (0-100) or total correct
  final int totalQuestions;
  final int correctCount;
  final int incorrectCount;
  final int skippedCount;
  final int timeTakenSeconds;
  final DateTime attemptedAt;
  final List<AnswerRecord> answers;

  const AttemptModel({
    required this.id,
    required this.quizId,
    required this.quizTitle,
    required this.score,
    required this.totalQuestions,
    required this.correctCount,
    required this.incorrectCount,
    required this.skippedCount,
    required this.timeTakenSeconds,
    required this.attemptedAt,
    required this.answers,
  });

  double get percentage =>
      totalQuestions > 0 ? (correctCount / totalQuestions) * 100 : 0.0;

  String get performanceBadge {
    final pct = percentage;
    if (pct >= 85) return 'Mastery';
    if (pct >= 70) return 'Passed';
    if (pct >= 50) return 'Average';
    return 'Needs Practice';
  }

  Map<String, dynamic> toMap() {
    return {
      'quizId': quizId,
      'quizTitle': quizTitle,
      'score': score,
      'totalQuestions': totalQuestions,
      'correctCount': correctCount,
      'incorrectCount': incorrectCount,
      'skippedCount': skippedCount,
      'timeTakenSeconds': timeTakenSeconds,
      'attemptedAt': Timestamp.fromDate(attemptedAt),
      'answers': answers.map((a) => a.toMap()).toList(),
    };
  }

  factory AttemptModel.fromMap(Map<String, dynamic> map, {String? id}) {
    DateTime parseDate(dynamic val) {
      if (val is Timestamp) return val.toDate();
      if (val is String) return DateTime.tryParse(val) ?? DateTime.now();
      return DateTime.now();
    }

    final rawAnswers = map['answers'];
    List<AnswerRecord> parsedAnswers = [];
    if (rawAnswers is List) {
      parsedAnswers = rawAnswers.map((item) {
        if (item is Map<String, dynamic>) {
          return AnswerRecord.fromMap(item);
        } else if (item is Map) {
          return AnswerRecord.fromMap(Map<String, dynamic>.from(item));
        }
        return const AnswerRecord(
          questionText: '',
          selectedIndex: null,
          correctIndex: 0,
        );
      }).toList();
    }

    return AttemptModel(
      id: id ?? map['id'] ?? '',
      quizId: map['quizId'] ?? '',
      quizTitle: map['quizTitle'] ?? '',
      score: (map['score'] as num?)?.toDouble() ?? 0.0,
      totalQuestions: (map['totalQuestions'] as num?)?.toInt() ?? parsedAnswers.length,
      correctCount: (map['correctCount'] as num?)?.toInt() ?? 0,
      incorrectCount: (map['incorrectCount'] as num?)?.toInt() ?? 0,
      skippedCount: (map['skippedCount'] as num?)?.toInt() ?? 0,
      timeTakenSeconds: (map['timeTakenSeconds'] as num?)?.toInt() ?? 0,
      attemptedAt: parseDate(map['attemptedAt']),
      answers: parsedAnswers,
    );
  }
}
