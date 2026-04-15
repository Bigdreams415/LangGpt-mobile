import 'package:dio/dio.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_constants.dart';
import '../models/progress_model.dart';

class ProgressRemoteDataSource {
  ProgressRemoteDataSource._();
  static final ProgressRemoteDataSource instance = ProgressRemoteDataSource._();

  Dio get _dio => ApiClient.instance.dio;

  Future<ProgressResponseModel> updateProgress({
    required String userId,
    required String language,
    required String unit,
    required int subtopicIndex,
    required String subtopicName,
    required int score,
    required String level,
  }) async {
    try {
      final response = await _dio.post(
        ApiConstants.updateProgress,
        data: {
          'user_id': userId,
          'language': language,
          'unit': unit,
          'subtopic_index': subtopicIndex,
          'subtopic_name': subtopicName,
          'score': score,
          'level': level,
        },
      );
      return ProgressResponseModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<ProgressResponseModel> getProgress({
    required String userId,
    required String language,
  }) async {
    try {
      final response = await _dio.get(
        '${ApiConstants.getProgress}/$userId/$language',
      );
      return ProgressResponseModel.fromJson(response.data as Map<String, dynamic>);
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
      case 500:
        return 'Server error. Please try again later.';
      default:
        return 'Failed to update progress. Please check your connection.';
    }
  }
}