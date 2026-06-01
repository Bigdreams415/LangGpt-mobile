import 'dart:io';

class DeviceTokenModel {
  final String id;
  final String platform;
  final bool isActive;
  final DateTime lastUsedAt;

  const DeviceTokenModel({
    required this.id,
    required this.platform,
    required this.isActive,
    required this.lastUsedAt,
  });

  factory DeviceTokenModel.fromJson(Map<String, dynamic> json) {
    return DeviceTokenModel(
      id: json['id'] as String,
      platform: json['platform'] as String,
      isActive: json['is_active'] as bool,
      lastUsedAt: DateTime.parse(json['last_used_at'] as String),
    );
  }

  // Returns the platform string for the current device.
  static String currentPlatform() {
    if (Platform.isIOS) return 'ios';
    if (Platform.isAndroid) return 'android';
    return 'web';
  }
}
