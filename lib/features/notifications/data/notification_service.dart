import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// Local notification display via flutter_local_notifications. There is no
/// push / Firebase Cloud Messaging integration — the app does not use Firebase.
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

    _initialized = true;
  }

  /// Shows a local (on-device) notification. Kept for future in-app triggers;
  /// there is no remote/push delivery.
  Future<void> showLocalNotification({
    required String title,
    required String body,
  }) async {
    await _localNotifications.show(
      id: title.hashCode,
      title: title,
      body: body,
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
