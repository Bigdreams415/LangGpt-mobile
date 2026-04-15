import '../datasources/quiz_remote_datasource.dart';
import '../models/quiz_model.dart';

class QuizRepositoryImpl {
  QuizRepositoryImpl._();
  static final QuizRepositoryImpl instance = QuizRepositoryImpl._();

  final _remoteDataSource = QuizRemoteDataSource.instance;

  Future<QuizResponseModel> generateQuiz({
    required String language,
    required String level,
    required String unit,
    required int subtopicIndex,
    String? subtopicName,
    int numQuestions = 8,
  }) async {
    return await _remoteDataSource.generateQuiz(
      language: language,
      level: level,
      unit: unit,
      subtopicIndex: subtopicIndex,
      subtopicName: subtopicName,
      numQuestions: numQuestions,
    );
  }

  Future<CheckAnswerResponseModel> checkAnswer({
    required String language,
    required String question,
    required String userAnswer,
    required String correctAnswer,
  }) async {
    return await _remoteDataSource.checkAnswer(
      language: language,
      question: question,
      userAnswer: userAnswer,
      correctAnswer: correctAnswer,
    );
  }
}
