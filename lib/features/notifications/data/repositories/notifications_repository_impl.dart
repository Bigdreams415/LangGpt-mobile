import '../../domain/repositories/notifications_repository.dart';
import '../datasources/notifications_remote_datasource.dart';
import '../models/device_token_model.dart';
import '../models/notification_preferences_model.dart';

class NotificationsRepositoryImpl implements NotificationsRepository {
  NotificationsRepositoryImpl._();
  static final NotificationsRepositoryImpl instance =
      NotificationsRepositoryImpl._();

  final _datasource = NotificationsRemoteDataSource.instance;

  @override
  Future<NotificationPreferencesModel> getPreferences() =>
      _datasource.getPreferences();

  @override
  Future<NotificationPreferencesModel> updatePreferences(
    Map<String, dynamic> patch,
  ) =>
      _datasource.updatePreferences(patch);

  @override
  Future<DeviceTokenModel> registerDeviceToken({
    required String token,
    required String platform,
    String? deviceInfo,
  }) =>
      _datasource.registerDeviceToken(
        token: token,
        platform: platform,
        deviceInfo: deviceInfo,
      );

  @override
  Future<void> unregisterDeviceToken(String token) =>
      _datasource.unregisterDeviceToken(token);
}
