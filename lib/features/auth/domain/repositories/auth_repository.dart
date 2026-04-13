import '../../data/models/auth_response_model.dart';
import '../../data/models/user_model.dart';

abstract class AuthRepository {
  Future<AuthResponseModel> signup({
    required String fullName,
    required String username,
    required String email,
    required String password,
    String? dateOfBirth,
    String? country,
    String? selectedLanguage,
    String? level,
  });

  Future<AuthResponseModel> login({
    required String identifier,
    required String password,
  });

  Future<AuthResponseModel> googleSignIn({
    String? selectedLanguage,
  });

  Future<void> logout();

  Future<UserModel?> getStoredUser();

  Future<bool> isLoggedIn();
}