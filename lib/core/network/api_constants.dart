class ApiConstants {
  ApiConstants._();

  static const String baseUrl = 'http://localhost:8000'; 
  static const String apiPrefix = '/api/v1';

  // Auth
  static const String signup = '$apiPrefix/auth/signup';
  static const String login = '$apiPrefix/auth/login';
  static const String googleAuth = '$apiPrefix/auth/google';
  static const String refresh = '$apiPrefix/auth/refresh';
  static const String logout = '$apiPrefix/auth/logout';
  static const String me = '$apiPrefix/auth/me';

  // User
  static const String updateProfile = '$apiPrefix/users/me';
  static const String changePassword = '$apiPrefix/users/me/change-password';

  static const Duration connectTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 30);
}