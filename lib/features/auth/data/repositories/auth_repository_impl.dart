import 'dart:convert';
import 'package:google_sign_in/google_sign_in.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';
import '../models/auth_response_model.dart';
import '../models/user_model.dart';
import '../../../../services/storage/secure_storage_service.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl._();
  static final AuthRepositoryImpl instance = AuthRepositoryImpl._();

  final _remote = AuthRemoteDataSource.instance;
  final _storage = SecureStorageService.instance;

  final _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
    serverClientId:
        '916229269228-98gae4ve5t23e9fglq2eqf8de4ek02um.apps.googleusercontent.com',
  );

  // ── Signup ────────────────────────────────────────────────────────────────
  @override
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
    final response = await _remote.signup(
      fullName: fullName,
      username: username,
      email: email,
      password: password,
      dateOfBirth: dateOfBirth,
      country: country,
      selectedLanguage: selectedLanguage,
      level: level,
    );
    await _persistAuthData(response);
    return response;
  }

  // ── Login ─────────────────────────────────────────────────────────────────
  @override
  Future<AuthResponseModel> login({
    required String identifier,
    required String password,
  }) async {
    final response = await _remote.login(
      identifier: identifier,
      password: password,
    );
    await _persistAuthData(response);
    return response;
  }

  // ── Google Sign-In ────────────────────────────────────────────────────────
  @override
  Future<AuthResponseModel> googleSignIn({
    String? selectedLanguage,
  }) async {
    // Clear any cached session so a fresh token is generated
    // with the correct serverClientId audience
    await _googleSignIn.signOut();

    // Step 1: Trigger Google sign-in on device
    final googleUser = await _googleSignIn.signIn();
    if (googleUser == null) {
      throw Exception('Google sign-in was cancelled');
    }

    // Step 2: Get the auth credentials (contains ID token)
    final googleAuth = await googleUser.authentication;
    final idToken = googleAuth.idToken;

    if (idToken == null) {
      throw Exception('Failed to get Google ID token');
    }

    // Step 3: Send ID token to our backend
    final response = await _remote.googleAuth(
      idToken: idToken,
      selectedLanguage: selectedLanguage,
    );

    await _persistAuthData(response);
    return response;
  }

  // ── Logout ────────────────────────────────────────────────────────────────
  @override
  Future<void> logout() async {
    try {
      await _remote.logout(); // Tell backend to invalidate token
    } catch (_) {
      // Even if backend call fails, clear local data
    }
    try {
      await _googleSignIn.signOut(); // Clear Google session
    } catch (_) {}
    await _storage.clearAll();
  }

  // ── Stored user ───────────────────────────────────────────────────────────
  @override
  Future<UserModel?> getStoredUser() async {
    final json = await _storage.getUserJson();
    if (json == null) return null;
    try {
      return UserModel.fromJson(jsonDecode(json) as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<bool> isLoggedIn() => _storage.isLoggedIn();

  // ── Helper ────────────────────────────────────────────────────────────────
  Future<void> _persistAuthData(AuthResponseModel response) async {
    await Future.wait([
      _storage.saveAccessToken(response.tokens.accessToken),
      _storage.saveRefreshToken(response.tokens.refreshToken),
      _storage.saveUserId(response.user.id),
      _storage.saveUserJson(jsonEncode(response.user.toJson())),
    ]);
  }
}
