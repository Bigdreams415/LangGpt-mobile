class UserModel {
  final String id;
  final String fullName;
  final String username;
  final String email;
  final String? dateOfBirth;
  final String? country;
  final String? avatarUrl;
  final String? selectedLanguage;
  final String? level;
  final String authProvider;
  final bool isVerified;
  final int streakCount;
  final int totalXp;
  final DateTime createdAt;

  const UserModel({
    required this.id,
    required this.fullName,
    required this.username,
    required this.email,
    this.dateOfBirth,
    this.country,
    this.avatarUrl,
    this.selectedLanguage,
    this.level,
    required this.authProvider,
    required this.isVerified,
    required this.streakCount,
    required this.totalXp,
    required this.createdAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      fullName: json['full_name'] as String,
      username: json['username'] as String,
      email: json['email'] as String,
      dateOfBirth: json['date_of_birth'] as String?,
      country: json['country'] as String?,
      avatarUrl: json['avatar_url'] as String?,
      selectedLanguage: json['selected_language'] as String?,
      level: json['level'] as String?,
      authProvider: json['auth_provider'] as String,
      isVerified: json['is_verified'] as bool,
      streakCount: json['streak_count'] as int? ?? 0,
      totalXp: json['total_xp'] as int? ?? 0,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'full_name': fullName,
        'username': username,
        'email': email,
        'date_of_birth': dateOfBirth,
        'country': country,
        'avatar_url': avatarUrl,
        'selected_language': selectedLanguage,
        'level': level,
        'auth_provider': authProvider,
        'is_verified': isVerified,
        'streak_count': streakCount,
        'total_xp': totalXp,
        'created_at': createdAt.toIso8601String(),
      };

  UserModel copyWith({
    String? selectedLanguage,
    String? level,
    String? country,
    String? fullName,
    String? username,
  }) {
    return UserModel(
      id: id,
      fullName: fullName ?? this.fullName,
      username: username ?? this.username,
      email: email,
      dateOfBirth: dateOfBirth,
      country: country ?? this.country,
      avatarUrl: avatarUrl,
      selectedLanguage: selectedLanguage ?? this.selectedLanguage,
      level: level ?? this.level,
      authProvider: authProvider,
      isVerified: isVerified,
      streakCount: streakCount,
      totalXp: totalXp,
      createdAt: createdAt,
    );
  }
}