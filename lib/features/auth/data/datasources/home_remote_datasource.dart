import 'package:dio/dio.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_constants.dart';
import '../models/home_dashboard_model.dart';

class HomeRemoteDataSource {
  HomeRemoteDataSource._();
  static final HomeRemoteDataSource instance = HomeRemoteDataSource._();

  Dio get _dio => ApiClient.instance.dio;

  /// Fetch all home screen data in one request
  Future<HomeDashboardModel> getHomeDashboard() async {
    try {
      final response = await _dio.get(ApiConstants.homeDashboard);
      return HomeDashboardModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Parse Dio errors into user-friendly messages
  String _handleError(DioException e) {
    final data = e.response?.data;
    if (data is Map<String, dynamic> && data['detail'] != null) {
      return data['detail'] as String;
    }
    
    switch (e.response?.statusCode) {
      case 401:
        return 'Session expired. Please login again.';
      case 403:
        return 'You don\'t have permission to access this resource.';
      case 404:
        return 'Resource not found.';
      case 500:
        return 'Server error. Please try again later.';
      default:
        return 'Failed to load home data. Please check your connection.';
    }
  }
}