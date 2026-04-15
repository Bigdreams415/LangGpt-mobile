import 'package:dio/dio.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_constants.dart';
import '../models/quiz_model.dart';

class QuizRemoteDataSource {
  QuizRemoteDataSource._();
  static final QuizRemoteDataSource instance = QuizRemoteDataSource._();

  Dio get _dio => ApiClient.instance.dio;

  Future<QuizResponseModel> generateQuiz({
    required String language,
    required String level,
    required String unit,
    required int subtopicIndex,
    String? subtopicName,
    int numQuestions = 8,
  }) async {
    try {
      final response = await _dio.post(
        ApiConstants.generateQuiz,
        data: {
          'language': language,
          'level': level,
          'unit': unit,
          'subtopic_index': subtopicIndex,
          if (subtopicName != null) 'subtopic_name': subtopicName,
          'num_questions': numQuestions,
        },
      );
      return QuizResponseModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<CheckAnswerResponseModel> checkAnswer({
    required String language,
    required String question,
    required String userAnswer,
    required String correctAnswer,
  }) async {
    try {
      final response = await _dio.post(
        ApiConstants.checkAnswer,
        data: {
          'language': language,
          'question': question,
          'user_answer': userAnswer,
          'correct_answer': correctAnswer,
        },
      );
      return CheckAnswerResponseModel.fromJson(
          response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  String _handleError(DioException e) {
    final data = e.response?.data;
    if (data is Map<String, dynamic> && data['detail'] != null) {
      return data['detail'] as String;
    }

    switch (e.response?.statusCode) {
      case 400:
        return 'Invalid quiz request.';
      case 401:
        return 'Session expired. Please login again.';
      case 404:
        return 'Quiz content not found for this topic.';
      case 500:
        return 'Server error while generating quiz.';
      default:
        return 'Failed to load quiz. Please check your connection.';
    }
  }
}
