class QuestionModel {
  final String id;
  final String questionText;
  final List<String> options;
  final int correctOptionIndex;
  final String? explanation;

  const QuestionModel({
    required this.id,
    required this.questionText,
    required this.options,
    required this.correctOptionIndex,
    this.explanation,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'questionText': questionText,
      'options': options,
      'correctOptionIndex': correctOptionIndex,
      'explanation': explanation,
    };
  }

  factory QuestionModel.fromMap(Map<String, dynamic> map, {String? id}) {
    return QuestionModel(
      id: id ?? map['id'] ?? '',
      questionText: map['questionText'] ?? '',
      options: (map['options'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      correctOptionIndex: (map['correctOptionIndex'] as num?)?.toInt() ?? 0,
      explanation: map['explanation'] as String?,
    );
  }
}
