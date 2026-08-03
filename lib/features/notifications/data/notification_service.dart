import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// Top-level so it can be used as a `@pragma('vm:entry-point')` background
/// message handler, as FCM on Android requires.
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint('Handling a background message: ${message.messageId}');
}

/// Wraps Firebase Cloud Messaging + local notification display. Every method
/// is a safe no-op when Firebase hasn't been initialized (see
/// docs/ARCHITECTURE.md §9) — call sites don't need to check
/// `AppConfig.firebaseEnabled` themselves.
class NotificationService {
  NotificationService(this._localNotifications);

  final FlutterLocalNotificationsPlugin _localNotifications;

  static const _androidChannel = AndroidNotificationChannel(
    'high_importance_channel',
    'Order & promotion updates',
    description: 'Order status changes, shipping updates, and offers.',
    importance: Importance.high,
  );

  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) return;

    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosInit = DarwinInitializationSettings();
    await _localNotifications.initialize(
      settings: const InitializationSettings(
        android: androidInit,
        iOS: iosInit,
      ),
    );

    final androidPlugin = _localNotifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    await androidPlugin?.createNotificationChannel(_androidChannel);

    try {
      await FirebaseMessaging.instance.requestPermission();
      FirebaseMessaging.onMessage.listen(_showForegroundNotification);
      FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
    } catch (error) {
      debugPrint(
        'FirebaseMessaging unavailable, push notifications disabled: $error',
      );
    }

    _initialized = true;
  }

  Future<String?> getDeviceToken() async {
    try {
      return await FirebaseMessaging.instance.getToken();
    } catch (_) {
      return null;
    }
  }

  Future<void> _showForegroundNotification(RemoteMessage message) async {
    final notification = message.notification;
    if (notification == null) return;

    await _localNotifications.show(
      id: notification.hashCode,
      title: notification.title,
      body: notification.body,
      notificationDetails: NotificationDetails(
        android: AndroidNotificationDetails(
          _androidChannel.id,
          _androidChannel.name,
          channelDescription: _androidChannel.description,
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: const DarwinNotificationDetails(),
      ),
    );
  }
}
