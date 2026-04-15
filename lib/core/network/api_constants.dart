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

  // Home
  static const String homeDashboard = '$apiPrefix/home/dashboard';

  // Lessons
  static const String lessonsList = '$apiPrefix/lessons/list';
  static const String lessonDetail = '$apiPrefix/lessons/unit';
  static const String generateLesson = '$apiPrefix/lessons/';
  
  // Quiz
  static const String generateQuiz = '$apiPrefix/quiz/';
  static const String checkAnswer = '$apiPrefix/quiz/check';
  
  // Progress
  static const String updateProgress = '$apiPrefix/progress/update';
  static const String getProgress = '$apiPrefix/progress';

  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
}