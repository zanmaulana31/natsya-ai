import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// Singleton service for displaying local notifications.
class NotificationService {
  static final NotificationService instance = NotificationService._internal();

  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  /// Initializes the notification plugin with Android and iOS settings.
  Future<void> initialize() async {
    if (_initialized) return;

    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const darwinSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: darwinSettings,
      macOS: darwinSettings,
    );

    await _plugin.initialize(initSettings);

    const channel = AndroidNotificationChannel(
      'natsya_ai_model',
      'Natsya AI Model',
      description: 'Notifications for AI model readiness',
      importance: Importance.high,
    );

    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    _initialized = true;
  }

  /// Displays the "model ready" local notification.
  Future<void> showModelReadyNotification() async {
    if (!_initialized) return;

    const androidDetails = AndroidNotificationDetails(
      'natsya_ai_model',
      'Natsya AI Model',
      channelDescription: 'Notifications for AI model readiness',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
    );

    const darwinDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: darwinDetails,
      macOS: darwinDetails,
    );

    await _plugin.show(
      1,
      'Natsya AI',
      'Natsya AI can you try right now!',
      details,
      payload: 'model_ready',
    );
  }
}
