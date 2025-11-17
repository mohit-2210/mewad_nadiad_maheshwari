import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class DeviceService {
  static final DeviceService _instance = DeviceService._();
  DeviceService._();
  static DeviceService get instance => _instance;

  String? deviceId;
  String? deviceToken;

  Future<void> init() async {
    await _fetchDeviceId();

    // iOS: Must request permission first
    await _requestNotificationPermission();

    // iOS: Must wait until APNS token is available
    if (Platform.isIOS) {
      await _waitForAPNSToken();
    }

    // Now safe to fetch FCM token
    await _fetchFCMToken();

    // Listen for token refresh
    _listenForTokenRefresh();
  }

  Future<void> _fetchDeviceId() async {
    final info = DeviceInfoPlugin();

    if (Platform.isAndroid) {
      final android = await info.androidInfo;
      deviceId = android.id;
    } else if (Platform.isIOS) {
      final ios = await info.iosInfo;
      deviceId = ios.identifierForVendor;
    }
  }

  /// --- FIX: Wait until Apple provides APNS token ---
  Future<void> _waitForAPNSToken() async {
    String? apnsToken;

    // Retry until APNS token arrives
    while (apnsToken == null) {
      apnsToken = await FirebaseMessaging.instance.getAPNSToken();
      await Future.delayed(Duration(milliseconds: 200));
    }

    print("APNS Token Ready: $apnsToken");
  }

  /// --- Now safe to get FCM token ---
  Future<void> _fetchFCMToken() async {
    deviceToken = await FirebaseMessaging.instance.getToken();
    print("FCM Token: $deviceToken");
  }

  void _listenForTokenRefresh() {
    FirebaseMessaging.instance.onTokenRefresh.listen((newToken) {
      deviceToken = newToken;
      print("Token refreshed: $newToken");

      // TODO: send to backend if needed
      // AuthRepository.updateDeviceToken(deviceId!, newToken);
    });
  }

  Future<void> _requestNotificationPermission() async {
    final settings = await FirebaseMessaging.instance.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    print("Permission: ${settings.authorizationStatus}");
  }
}
