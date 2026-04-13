import 'package:dio/dio.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_constants.dart';
import '../models/auth_response_model.dart';
import '../models/user_model.dart';

class AuthRemoteDataSource {
  AuthRemoteDataSource._();
  static final AuthRemoteDataSource instance = AuthRemoteDataSource._();

  Dio get _dio => ApiClient.instance.dio;

  Future<AuthResponseModel> signup({
    required String fullName,
    required String username,
    required String email,
    required String password,
    String? dateOfBirth,
    String? country,
    String? selectedLanguage,
    String? level,
  }) async {
    final response = await _dio.post(
      ApiConstants.signup,
      data: {
        'full_name': fullName,
        'username': username,
        'email': email,
        'password': password,
        if (dateOfBirth != null) 'date_of_birth': dateOfBirth,
        if (country != null) 'country': country,
        if (selectedLanguage != null) 'selected_language': selectedLanguage,
        'level': level ?? 'beginner',
      },
    );
    return AuthResponseModel.fromJson(response.data as Map<String, dynamic>);
  }

  Future<AuthResponseModel> login({
    required String identifier, // email or username
    required String password,
  }) async {
    final response = await _dio.post(
      ApiConstants.login,
      data: {
        'identifier': identifier,
        'password': password,
      },
    );
    return AuthResponseModel.fromJson(response.data as Map<String, dynamic>);
  }

  Future<AuthResponseModel> googleAuth({
    required String idToken,
    String? selectedLanguage,
    String level = 'beginner',
  }) async {
    final response = await _dio.post(
      ApiConstants.googleAuth,
      data: {
        'id_token': idToken,
        if (selectedLanguage != null) 'selected_language': selectedLanguage,
        'level': level,
      },
    );
    return AuthResponseModel.fromJson(response.data as Map<String, dynamic>);
  }

  Future<void> logout() async {
    await _dio.post(ApiConstants.logout);
  }

  Future<UserModel> getMe() async {
    final response = await _dio.get(ApiConstants.me);
    return UserModel.fromJson(response.data as Map<String, dynamic>);
  }
}