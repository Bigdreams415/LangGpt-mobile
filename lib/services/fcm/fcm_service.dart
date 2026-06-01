import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../../features/notifications/data/datasources/notifications_remote_datasource.dart';
import '../../features/notifications/data/models/device_token_model.dart';
import '../storage/secure_storage_service.dart';

// Runs in a separate isolate — must re-initialize Firebase before doing anything.
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  // FCM renders the tray banner itself for background/terminated messages
  // that have a notification payload. No UI work needed here.
}

class FcmService {
  FcmService._();
  static final FcmService instance = FcmService._();

  final _fm = FirebaseMessaging.instance;
  final _local = FlutterLocalNotificationsPlugin();

  // Exposed so main.dart can pass it to MaterialApp.navigatorKey.
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  static const _androidChannel = AndroidNotificationChannel(
    'kinspeak_default',
    'KinSpeak Notifications',
    description: 'General KinSpeak notifications',
    importance: Importance.high,
  );

  Future<void> initialize() async {
    // Request OS permission (shows the iOS alert dialog; Android 13+ POST_NOTIFICATIONS).
    await _fm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    // Show notifications even when the app is in the foreground on iOS.
    await _fm.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    // Initialize flutter_local_notifications.
    await _local.initialize(
      const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        iOS: DarwinInitializationSettings(),
      ),
      onDidReceiveNotificationResponse: (response) {
        if (response.payload != null) {
          _navigate(response.payload!);
        }
      },
    );

    // Create the Android notification channel.
    await _local
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(_androidChannel);

    // Foreground messages: render a local notification banner.
    FirebaseMessaging.onMessage.listen(_handleForeground);

    // User tapped a notification while the app was in the background.
    FirebaseMessaging.onMessageOpenedApp.listen(_handleTap);

    // FCM token refresh: re-register with the backend.
    _fm.onTokenRefresh.listen(_persistAndPush);

    // Handle the case where a terminated-state notification launched the app.
    final initial = await _fm.getInitialMessage();
    if (initial != null) {
      _handleTap(initial);
    }
  }

  // Fetches the current FCM token and registers it with the backend if it has
  // changed since the last registration. Called after every successful login
  // and at cold-start when a stored session is already present.
  Future<void> registerTokenWithBackend() async {
    try {
      final token = await _fm.getToken();
      if (token == null) return;

      final cached = await SecureStorageService.instance.getFcmToken();
      if (token == cached) return;

      await _persistAndPush(token);
    } catch (_) {
      // Best-effort; will retry on the next cold start or login.
    }
  }

  // Unregisters the cached FCM token from the backend. Call this before
  // clearing secure storage on logout so the bearer token is still valid.
  Future<void> unregisterTokenFromBackend() async {
    try {
      final token = await SecureStorageService.instance.getFcmToken();
      if (token == null) return;
      await NotificationsRemoteDataSource.instance.unregisterDeviceToken(token);
    } catch (_) {
      // Best-effort — the backend will also invalidate on UNREGISTERED response.
    }
  }

  void _handleForeground(RemoteMessage message) {
    final notification = message.notification;
    if (notification == null) return;

    _local.show(
      message.hashCode,
      notification.title,
      notification.body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          _androidChannel.id,
          _androidChannel.name,
          channelDescription: _androidChannel.description,
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: const DarwinNotificationDetails(),
      ),
      payload: message.data['route'] as String?,
    );
  }

  void _handleTap(RemoteMessage message) {
    final route = message.data['route'] as String?;
    if (route != null) {
      _navigate(route);
    }
  }

  void _navigate(String route) {
    navigatorKey.currentState?.pushNamed(route);
  }

  Future<void> _persistAndPush(String token) async {
    await NotificationsRemoteDataSource.instance.registerDeviceToken(
      token: token,
      platform: DeviceTokenModel.currentPlatform(),
    );
    await SecureStorageService.instance.saveFcmToken(token);
  }
}
