import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:device_info_plus/device_info_plus.dart';

class ApiConfig {
  static Future<String> getBaseUrl() async {

    // Web
    if (kIsWeb) {
      return "http://localhost:5000/api";
    }

    // Android
    if (Platform.isAndroid) {
      final deviceInfo = DeviceInfoPlugin();
      final androidInfo = await deviceInfo.androidInfo;

      // Emulator
      if (!androidInfo.isPhysicalDevice) {
        return "http://10.0.2.2:5000/api";
      }

      // Real device
      // return "http://192.168.1.5:5000/api";
      //return "http://192.168.1.5:5000/api";//home
      // return "http://10.219.241.135:5000/api";
      // return "http://192.168.1.13:5000/api"; // your PC IP
      return "http://192.168.1.6:5000/api";
    }

    // iOS or others
    return "http://localhost:5000/api";
  }
}
