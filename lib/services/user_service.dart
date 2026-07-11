import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../core/api_config.dart'; // 👈 IMPORT THIS

class UserService {
  static Future<void> saveFcmToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    final jwt = prefs.getString("auth_token");

    print("JWT USED: $jwt"); // 🔥 DEBUG THIS

    final baseUrl = await ApiConfig.getBaseUrl(); // 👈 IMPORTANT

    final response = await http.put(
      Uri.parse("$baseUrl/user/fcm-token"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $jwt",
      },
      body: jsonEncode({
        "fcmToken": token,
      }),
    );

    print("📡 FCM SAVE STATUS: ${response.statusCode}");
    print("📡 FCM SAVE BODY: ${response.body}");
  }
}