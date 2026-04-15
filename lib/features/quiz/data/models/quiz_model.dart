class QuizQuestionModel {
  final String question;
  final List<String> options;
  final String correctAnswer;
  final String explanation;

  const QuizQuestionModel({
    required this.question,
    required this.options,
    required this.correctAnswer,
    required this.explanation,
  });

  factory QuizQuestionModel.fromJson(Map<String, dynamic> json) {
    return QuizQuestionModel(
      question: json['question'] as String,
      options: (json['options'] as List).cast<String>(),
      correctAnswer: json['correct_answer'] as String,
      explanation: json['explanation'] as String,
    );
  }
}

class QuizResponseModel {
  final String language;
  final String unit;
  final String subtopic;
  final List<QuizQuestionModel> questions;

  const QuizResponseModel({
    required this.language,
    required this.unit,
    required this.subtopic,
    required this.questions,
  });

  factory QuizResponseModel.fromJson(Map<String, dynamic> json) {
    return QuizResponseModel(
      language: json['language'] as String,
      unit: json['unit'] as String,
      subtopic: json['subtopic'] as String,
      questions: (json['questions'] as List)
          .map((e) => QuizQuestionModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class CheckAnswerResponseModel {
  final bool isCorrect;
  final String feedback;
  final String encouragement;

  const CheckAnswerResponseModel({
    required this.isCorrect,
    required this.feedback,
    required this.encouragement,
  });

  factory CheckAnswerResponseModel.fromJson(Map<String, dynamic> json) {
    return CheckAnswerResponseModel(
      isCorrect: json['is_correct'] as bool,
      feedback: json['feedback'] as String,
      encouragement: json['encouragement'] as String,
    );
  }
}