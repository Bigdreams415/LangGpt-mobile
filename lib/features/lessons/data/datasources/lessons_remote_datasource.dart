import 'package:dio/dio.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_constants.dart';
import '../models/lesson_model.dart';

class LessonsRemoteDataSource {
  LessonsRemoteDataSource._();
  static final LessonsRemoteDataSource instance = LessonsRemoteDataSource._();

  Dio get _dio => ApiClient.instance.dio;

  Future<LessonsListResponseModel> getLessonsList({
    required String language,
    String? level,
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      final response = await _dio.get(
        '${ApiConstants.lessonsList}/$language',
        queryParameters: {
          if (level != null) 'level': level,
          'limit': limit,
          'offset': offset,
        },
      );
      return LessonsListResponseModel.fromJson(
          response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<LessonDetailModel> getLessonDetail({
    required String language,
    required String topicId,
  }) async {
    try {
      final response = await _dio.get(
        '${ApiConstants.lessonDetail}/$language/$topicId',
      );
      return LessonDetailModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<LessonResponseModel> generateLesson({
    required String language,
    required String level,
    required String unit,
    required int subtopicIndex,
    String? subtopicName,
  }) async {
    try {
      final response = await _dio.post(
        ApiConstants.generateLesson,
        data: {
          'language': language,
          'level': level,
          'unit': unit,
          'subtopic_index': subtopicIndex,
          if (subtopicName != null) 'subtopic_name': subtopicName,
        },
      );
      return LessonResponseModel.fromJson(
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
        return 'Invalid request. Please check your input.';
      case 401:
        return 'Session expired. Please login again.';
      case 404:
        return 'Lesson not found.';
      case 500:
        return 'Server error. Please try again later.';
      default:
        return 'Failed to load lessons. Please check your connection.';
    }
  }
}
