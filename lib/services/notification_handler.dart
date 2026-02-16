import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// Must be a top-level function for background message handler
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint('Handling background message: ${message.messageId}');
}

class NotificationHandler {
  static const String _topicAllUsers = 'all_users';
  static const String _dataKeyType = 'type';
  static const String _typeWishPromo = 'WISH_PROMO';

  static const String _androidChannelId = 'phoneking_foreground';
  static const String _androidChannelName = 'Phone King';

  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  static final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  static RemoteMessage? _pendingInitialMessage;

  static Future<void> initialize() async {
    await FirebaseMessaging.instance.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    await _initLocalNotifications();

    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    await FirebaseMessaging.instance.subscribeToTopic(_topicAllUsers);

    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
    FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationTap);

    _pendingInitialMessage = await FirebaseMessaging.instance.getInitialMessage();
  }

  static Future<void> _initLocalNotifications() async {
    const androidInit = AndroidInitializationSettings('ic_notification');
    final iosInit = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
    );
    final initSettings = InitializationSettings(
      android: androidInit,
      iOS: iosInit,
    );
    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onLocalNotificationTap,
    );

    if (Platform.isAndroid) {
      final channel = AndroidNotificationChannel(
        _androidChannelId,
        _androidChannelName,
        description: 'Notifications when app is in use',
        importance: Importance.high,
        playSound: true,
      );
      await _localNotifications
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(channel);
    }
  }

  static void _onLocalNotificationTap(NotificationResponse response) {
    // Optional: handle tap (e.g. open notification list). Wish/Promo = no nav.
  }

  /// Call after first frame when navigator is ready.
  static void handlePendingInitialMessage() {
    if (_pendingInitialMessage != null) {
      final message = _pendingInitialMessage!;
      _pendingInitialMessage = null;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _handleNotificationPayload(message);
      });
    }
  }

  static void _handleForegroundMessage(RemoteMessage message) {
    final notification = message.notification;
    final title = notification?.title ?? 'Notification';
    final body = notification?.body ?? '';

    const androidDetails = AndroidNotificationDetails(
      _androidChannelId,
      _androidChannelName,
      channelDescription: 'Notifications when app is in use',
      importance: Importance.high,
      priority: Priority.high,
      icon: 'ic_notification',
    );
    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );
    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    _localNotifications.show(
      message.messageId.hashCode,
      title,
      body,
      details,
    );
  }

  static void _handleNotificationTap(RemoteMessage message) {
    _handleNotificationPayload(message);
  }

  static void _handleNotificationPayload(RemoteMessage message) {
    final data = message.data;
    final type = data[_dataKeyType];

    if (type == _typeWishPromo) {
      // Wish/Promo: notification only, no navigation
    }
  }
}
