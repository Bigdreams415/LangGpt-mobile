import 'package:dio/dio.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_constants.dart';
import '../models/conversation_model.dart';

class ConversationRemoteDataSource {
  ConversationRemoteDataSource._();
  static final ConversationRemoteDataSource instance =
      ConversationRemoteDataSource._();

  Dio get _dio => ApiClient.instance.dio;

  Future<ConversationResponseModel> sendMessage({
    required ConversationRequestModel request,
  }) async {
    try {
      final response = await _dio.post(
        ApiConstants.conversation,
        data: request.toJson(),
      );
      return ConversationResponseModel.fromJson(
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
        return 'Invalid request. Check your conversation context.';
      case 401:
        return 'Session expired. Please login again.';
      case 500:
        return 'AI tutor is unavailable. Please try again.';
      default:
        return 'Failed to send message. Check your connection.';
    }
  }
}
