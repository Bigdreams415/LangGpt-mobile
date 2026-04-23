import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageService {
  SecureStorageService._();
  static final SecureStorageService instance = SecureStorageService._();

  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  static const _keyAccessToken = 'access_token';
  static const _keyRefreshToken = 'refresh_token';
  static const _keyUserId = 'user_id';
  static const _keyUserJson = 'user_json';

  // Access Token 
  Future<void> saveAccessToken(String token) =>
      _storage.write(key: _keyAccessToken, value: token);

  Future<String?> getAccessToken() =>
      _storage.read(key: _keyAccessToken);

  // Refresh Token
  Future<void> saveRefreshToken(String token) =>
      _storage.write(key: _keyRefreshToken, value: token);

  Future<String?> getRefreshToken() =>
      _storage.read(key: _keyRefreshToken);

  // User Data
  Future<void> saveUserId(String id) =>
      _storage.write(key: _keyUserId, value: id);

  Future<String?> getUserId() =>
      _storage.read(key: _keyUserId);

  Future<void> saveUserJson(String json) =>
      _storage.write(key: _keyUserJson, value: json);

  Future<String?> getUserJson() =>
      _storage.read(key: _keyUserJson);

  // Clear all (logout)
  Future<void> clearAll() => _storage.deleteAll();

  // Check if logged in
  Future<bool> isLoggedIn() async {
    final token = await getAccessToken();
    return token != null && token.isNotEmpty;
  }
}