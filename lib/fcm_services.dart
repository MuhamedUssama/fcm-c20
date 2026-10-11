import 'dart:developer';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();

  log("Handling a background message: ${message.messageId}");
}

class FcmServices {
  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  static Future<void> init() async {
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    await _requestPermission();
    await _getFCMToken();
    await _handleForgroundNotifications();
  }

  static Future<void> _requestPermission() async {
    final settings = await _messaging.requestPermission(
      badge: true,
      alert: true,
      announcement: true,
      carPlay: false,
      criticalAlert: false,
      sound: true,
    );

    log('User permission is: ${settings.authorizationStatus}');
  }

  static Future<void> _getFCMToken() async {
    final token = await _messaging.getToken();

    log('FCM Token: $token');
  }

  static Future<void> _handleForgroundNotifications() async {
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      "high_importance_channel",
      "High Importance Channel",
      description: "This channel send high importace notifications",
      importance: .max,
    );

    final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
        FlutterLocalNotificationsPlugin();

    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(channel);

    FirebaseMessaging.onMessage.listen((message) {
      RemoteNotification? notification = message.notification;
      AndroidNotification? andriod = message.notification?.android;

      if (notification != null && andriod != null) {
        flutterLocalNotificationsPlugin.show(
          id: notification.hashCode,
          title: notification.title,
          body: notification.body,
          notificationDetails: NotificationDetails(
            android: AndroidNotificationDetails(
              channel.id,
              channel.name,
              channelDescription: channel.description,
              importance: channel.importance,
              icon: "@mipmap/ic_launcher",
            ),
          ),
        );
      }
    });
  }
}

///
/// Fourgound
/// Background
/// Terminated
///
///
