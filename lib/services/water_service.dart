import 'dart:convert';
import 'package:http/http.dart' as http;
import '../core/api_config.dart';

class WaterService {

  static Future<void> saveWater({
    required String userId,
    required int totalWaterMl,
    required int glasses,
    required int goalMl,
    required String date,
  }) async {
    final baseUrl = await ApiConfig.getBaseUrl();

    print("🚀 Sending water data to backend");

    final response = await http.post(
      Uri.parse("$baseUrl/tracker/water"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "userId": userId,
        "totalWaterMl": totalWaterMl,
        "glasses": glasses,
        "goalMl": goalMl,
        "date": date
      }),
    );

    print("📡 Status Code: ${response.statusCode}");
    print("📡 Response: ${response.body}");
  }
  static Future<Map<String, dynamic>> loadWater({
    required String userId,
  }) async {
    final baseUrl = await ApiConfig.getBaseUrl();

    // 🔥 GET TODAY DATE
    final today = DateTime.now().toString().split(' ')[0];

    final response = await http.get(
      Uri.parse("$baseUrl/tracker/water/$userId/$today"),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      if (data["success"]) {
        return data["data"];
      }
    }

    // 🔥 IF NO DATA FOUND (NEW DAY)
    return {
      "totalWaterMl": 0,
      "glasses": 0,
      "goalMl": 2000,
    };
  }
  static Future<Map<String, int>> loadWeeklyWater({
    required String userId,
  }) async {
    final baseUrl = await ApiConfig.getBaseUrl();

    final response = await http.get(
      Uri.parse("$baseUrl/tracker/water/weekly/$userId"),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      if (data["success"]) {
        return Map<String, int>.from(data["data"]);
      }
    }

    return {
      "Sun": 0,
      "Mon": 0,
      "Tue": 0,
      "Wed": 0,
      "Thu": 0,
      "Fri": 0,
      "Sat": 0,
    };
  }
}