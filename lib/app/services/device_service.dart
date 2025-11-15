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
    await _fetchFCMToken();
    _listenForTokenRefresh();
  }

  Future<void> _fetchDeviceId() async {
    final info = await DeviceInfoPlugin().androidInfo;
    deviceId = info.id;
  }

  Future<void> _fetchFCMToken() async {
    deviceToken = await FirebaseMessaging.instance.getToken();
  }

  void _listenForTokenRefresh() {
    FirebaseMessaging.instance.onTokenRefresh.listen((newToken) {
      deviceToken = newToken;

      // TODO: Send newToken to backend
      // AuthRepository.updateToken(deviceId!, deviceToken!);
    });
  }
}
