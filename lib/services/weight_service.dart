import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../core/api_config.dart';

class WeightService {

  // ✅ SAVE GOAL
  static Future<bool> saveGoal({
    required double startWeight,
    required double goalWeight,
    required String goalType,
  }) async {
    try {
      final baseUrl = await ApiConfig.getBaseUrl();
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("auth_token");

      print("TOKEN: $token"); // 🔥 DEBUG

      final response = await http.post(
        Uri.parse("$baseUrl/tracker/weight/goal"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token", // ✅ MUST
        },
        body: jsonEncode({
          "startWeight": startWeight,
          "goalWeight": goalWeight,
          "goalType": goalType,
        }),
      );

      print("STATUS: ${response.statusCode}");
      print("BODY: ${response.body}");

      return response.statusCode == 200;

    } catch (e) {
      print("ERROR: $e");
      return false;
    }
  }

  // ================= ADD WEIGHT =================
  static Future<bool> addWeight(double weight) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("auth_token");

    final baseUrl = await ApiConfig.getBaseUrl();

    final response = await http.post(
      Uri.parse("$baseUrl/tracker/weight"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
      body: jsonEncode({
        "weight": weight,
      }),
    );

    return response.statusCode == 200;
  }

  // ================= GET DATA =================
  static Future<Map<String, dynamic>?> getWeightData() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("auth_token");

    final baseUrl = await ApiConfig.getBaseUrl();

    final response = await http.get(
      Uri.parse("$baseUrl/tracker/weight"),
      headers: {
        "Authorization": "Bearer $token",
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data["data"];
    }

    return null;
  }
}