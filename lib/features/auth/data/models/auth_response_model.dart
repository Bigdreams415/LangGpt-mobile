import 'user_model.dart';

class TokenModel {
  final String accessToken;
  final String refreshToken;
  final String tokenType;
  final int expiresIn;

  const TokenModel({
    required this.accessToken,
    required this.refreshToken,
    required this.tokenType,
    required this.expiresIn,
  });

  factory TokenModel.fromJson(Map<String, dynamic> json) {
    return TokenModel(
      accessToken: json['access_token'] as String,
      refreshToken: json['refresh_token'] as String,
      tokenType: json['token_type'] as String? ?? 'bearer',
      expiresIn: json['expires_in'] as int? ?? 1800,
    );
  }
}

class AuthResponseModel {
  final UserModel user;
  final TokenModel tokens;
  final bool isNewUser;

  const AuthResponseModel({
    required this.user,
    required this.tokens,
    required this.isNewUser,
  });

  factory AuthResponseModel.fromJson(Map<String, dynamic> json) {
    return AuthResponseModel(
      user: UserModel.fromJson(json['user'] as Map<String, dynamic>),
      tokens: TokenModel.fromJson(json['tokens'] as Map<String, dynamic>),
      isNewUser: json['is_new_user'] as bool? ?? false,
    );
  }
}