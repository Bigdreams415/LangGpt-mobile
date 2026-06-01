import 'package:dio/dio.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_constants.dart';
import '../models/device_token_model.dart';
import '../models/notification_preferences_model.dart';

class NotificationsRemoteDataSource {
  NotificationsRemoteDataSource._();
  static final NotificationsRemoteDataSource instance =
      NotificationsRemoteDataSource._();

  Dio get _dio => ApiClient.instance.dio;

  Future<NotificationPreferencesModel> getPreferences() async {
    try {
      final response = await _dio.get(ApiConstants.notificationPreferences);
      return NotificationPreferencesModel.fromJson(
        response.data as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<NotificationPreferencesModel> updatePreferences(
    Map<String, dynamic> patch,
  ) async {
    try {
      final response = await _dio.put(
        ApiConstants.notificationPreferences,
        data: patch,
      );
      return NotificationPreferencesModel.fromJson(
        response.data as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<DeviceTokenModel> registerDeviceToken({
    required String token,
    required String platform,
    String? deviceInfo,
  }) async {
    try {
      final response = await _dio.post(
        ApiConstants.deviceToken,
        data: {
          'token': token,
          'platform': platform,
          if (deviceInfo != null) 'device_info': deviceInfo,
        },
      );
      return DeviceTokenModel.fromJson(
        response.data as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<void> unregisterDeviceToken(String token) async {
    try {
      await _dio.delete(
        ApiConstants.deviceToken,
        data: {'token': token},
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> sendTestNotification({String? route}) async {
    try {
      final response = await _dio.post(
        ApiConstants.testNotification,
        data: {
          'title': 'KinSpeak',
          'body': 'Test push notification',
          if (route != null) 'route': route,
        },
      );
      return response.data as Map<String, dynamic>;
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
      case 401:
        return 'Session expired. Please login again.';
      case 403:
        return 'Not authorised.';
      case 500:
        return 'Server error. Please try again later.';
      default:
        return 'Failed to update notifications. Check your connection.';
    }
  }
}
