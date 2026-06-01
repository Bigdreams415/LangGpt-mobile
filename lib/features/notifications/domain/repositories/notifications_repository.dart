import '../../data/models/device_token_model.dart';
import '../../data/models/notification_preferences_model.dart';

abstract class NotificationsRepository {
  Future<NotificationPreferencesModel> getPreferences();
  Future<NotificationPreferencesModel> updatePreferences(Map<String, dynamic> patch);
  Future<DeviceTokenModel> registerDeviceToken({
    required String token,
    required String platform,
    String? deviceInfo,
  });
  Future<void> unregisterDeviceToken(String token);
}
