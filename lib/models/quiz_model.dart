import 'question_model.dart';

class QuizModel {
  final String id;
  final String title;
  final String topic;
  final String difficulty;
  final int questionCount;
  final int timeLimitMinutes;
  final List<QuestionModel> questions;

  const QuizModel({
    required this.id,
    required this.title,
    required this.topic,
    required this.difficulty,
    required this.questionCount,
    required this.timeLimitMinutes,
    this.questions = const [],
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'topic': topic,
      'difficulty': difficulty,
      'questionCount': questionCount,
      'timeLimitMinutes': timeLimitMinutes,
      'questions': questions.map((q) => q.toMap()).toList(),
    };
  }

  factory QuizModel.fromMap(Map<String, dynamic> map, {String? id}) {
    final rawQuestions = map['questions'];
    List<QuestionModel> parsedQuestions = [];
    if (rawQuestions is List) {
      parsedQuestions = rawQuestions.asMap().entries.map((entry) {
        final item = entry.value;
        if (item is Map<String, dynamic>) {
          return QuestionModel.fromMap(item, id: item['id'] ?? 'q_${entry.key}');
        } else if (item is Map) {
          return QuestionModel.fromMap(
            Map<String, dynamic>.from(item),
            id: item['id']?.toString() ?? 'q_${entry.key}',
          );
        }
        return QuestionModel(
          id: 'q_${entry.key}',
          questionText: 'Question',
          options: const [],
          correctOptionIndex: 0,
        );
      }).toList();
    }

    return QuizModel(
      id: id ?? map['id'] ?? '',
      title: map['title'] ?? '',
      topic: map['topic'] ?? '',
      difficulty: map['difficulty'] ?? 'Medium',
      questionCount: (map['questionCount'] as num?)?.toInt() ?? parsedQuestions.length,
      timeLimitMinutes: (map['timeLimitMinutes'] as num?)?.toInt() ?? 10,
      questions: parsedQuestions,
    );
  }

  QuizModel copyWith({
    String? id,
    String? title,
    String? topic,
    String? difficulty,
    int? questionCount,
    int? timeLimitMinutes,
    List<QuestionModel>? questions,
  }) {
    return QuizModel(
      id: id ?? this.id,
      title: title ?? this.title,
      topic: topic ?? this.topic,
      difficulty: difficulty ?? this.difficulty,
      questionCount: questionCount ?? this.questionCount,
      timeLimitMinutes: timeLimitMinutes ?? this.timeLimitMinutes,
      questions: questions ?? this.questions,
    );
  }
}
