import 'package:dio/dio.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_constants.dart';
import '../models/translation_model.dart';

class TranslationRemoteDataSource {
  TranslationRemoteDataSource._();
  static final TranslationRemoteDataSource instance =
      TranslationRemoteDataSource._();

  Dio get _dio => ApiClient.instance.dio;

  Future<TranslationResponseModel> translate({
    required TranslationRequestModel request,
  }) async {
    try {
      final response = await _dio.post(
        ApiConstants.translate,
        data: request.toJson(),
      );
      return TranslationResponseModel.fromJson(
        response.data as Map<String, dynamic>,
      );
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
        return 'Invalid translation request.';
      case 401:
        return 'Session expired. Please login again.';
      case 500:
        return 'Translation service is unavailable. Please try again.';
      default:
        return 'Failed to translate. Check your connection.';
    }
  }
}
