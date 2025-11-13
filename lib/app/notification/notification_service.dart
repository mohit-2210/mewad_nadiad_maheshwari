import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:mmsn/app/notification/local_notification_service.dart';

class NotificationService {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final LocalNotificationService _localNotification = LocalNotificationService();

  /// Initialize notification system
  Future<void> initialize() async {
    await _requestPermission();
    await _initListeners();

    String? token = await _messaging.getToken();
    print("FCM Token: $token");
  }

  /// Ask user permission for notifications
  Future<void> _requestPermission() async {
    if (Platform.isIOS || Platform.isAndroid) {
      NotificationSettings settings = await _messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );

      print("Notification permission: ${settings.authorizationStatus}");
      if (settings.authorizationStatus == AuthorizationStatus.denied) {
        print("User denied notification permission.");
      }
    }
  }

  /// Setup message handlers
  Future<void> _initListeners() async {
    // Foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print("Foreground message: ${message.notification?.title}");
      _localNotification.showNotification(message);
    });

    // When app opened from notification (background)
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print("Notification opened: ${message.notification?.title}");
      // Handle navigation or logic here
    });
  }
}
