// lib/core/services/push_notifications.dart

import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/material.dart';

class PushNotifications {
  PushNotifications._();
  static final PushNotifications _instance = PushNotifications._();
  static PushNotifications get instance => _instance;

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  late final FlutterLocalNotificationsPlugin _localNotifications;

  // Call this from main() before runApp()
  Future<void> init(Function(RemoteMessage) onNotificationTap) async {
    // 1) Request permission (for iOS; on Android auto‐grants unless Android 13+):
    NotificationSettings settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.denied) {
      print("Push notification permission denied");
    }

    // 2) Initialize flutter_local_notifications
    _localNotifications = FlutterLocalNotificationsPlugin();
    const initializationSettingsAndroid =
    AndroidInitializationSettings('@mipmap/ic_launcher');
    final initializationSettingsIOS = DarwinInitializationSettings();

    await _localNotifications.initialize(
      InitializationSettings(
        android: initializationSettingsAndroid,
        iOS: initializationSettingsIOS,
      ),
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        final payload = response.payload;
        if (payload != null && payload.isNotEmpty) {
          // The payload is our “data” JSON encoded string. Let’s parse it:
          final data = RemoteMessage.fromMap(Map<String, dynamic>.from(
              {"data": {"chatId": payload}}));
          onNotificationTap(data);
        }
      },
    );

    // 3) Foreground message handler
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print("🔔 onMessage: ${message.notification?.title} / ${message.notification?.body}");
      _showLocalNotification(message);
    });

    // 4) When the app is in background (but not terminated) and user taps the notification:
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print("🍎 onMessageOpenedApp: ${message.data}");
      onNotificationTap(message);
    });

    // 5) When the app is completely terminated and launched by tapping a notification:
    final initialMessage = await FirebaseMessaging.instance.getInitialMessage();
    if (initialMessage != null) {
      onNotificationTap(initialMessage);
    }
  }

  // Display a local notification banner
  Future<void> _showLocalNotification(RemoteMessage msg) async {
    final android = msg.notification?.android;
    const androidDetails = AndroidNotificationDetails(
      'chatwave_channel',
      'ChatWave Messages',
      channelDescription: 'Channel for incoming chat messages',
      importance: Importance.max,
      priority: Priority.high,
      ticker: 'ticker',
    );

    const iosDetails = DarwinNotificationDetails();

    final title = msg.notification?.title ?? 'New Message';
    final body = msg.notification?.body ?? '';
    final chatId = msg.data['chatId'] ?? "";

    await _localNotifications.show(
      (DateTime.now().millisecondsSinceEpoch ~/ 1000), // unique id
      title,
      body,
      NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      ),
      payload: chatId,
    );
  }

  // For completeness, expose the FCM token:
  Future<String?> getToken() => _messaging.getToken();
}
