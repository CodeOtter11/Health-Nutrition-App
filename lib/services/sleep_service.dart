import 'dart:convert';
import 'package:http/http.dart' as http;
import '../core/api_config.dart';

class SleepService {

  // ================= SAVE SLEEP =================
  static Future<void> saveSleep({
    required String userId,
    required double sleepHours,
    required String date,
  }) async {
    final baseUrl = await ApiConfig.getBaseUrl();

    final url = Uri.parse("$baseUrl/tracker/sleep");

    print("SAVE API: $url"); // 🔥 debug

    final res = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "userId": userId,
        "sleepHours": sleepHours,
        "date": date,
      }),
    );

    print("SAVE RESPONSE: ${res.body}"); // 🔥 debug
  }


  // ================= LOAD TODAY =================
  static Future<double> loadSleep({
    required String userId,
  }) async {
    final baseUrl = await ApiConfig.getBaseUrl();

    final today = DateTime.now().toIso8601String().split('T')[0];

    final url = Uri.parse("$baseUrl/tracker/sleep/$userId/$today");

    print("LOAD TODAY API: $url"); // 🔥 debug

    final res = await http.get(url);

    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);

      return (data["data"]["sleepHours"] ?? 0).toDouble();
    }

    return 0;
  }


  // ================= LOAD WEEKLY =================
  static Future<Map<String, double>> loadWeeklySleep({
    required String userId,
  }) async {
    final baseUrl = await ApiConfig.getBaseUrl();

    final url = Uri.parse("$baseUrl/tracker/sleep/weekly/$userId");

    print("WEEKLY API: $url"); // 🔥 debug

    final res = await http.get(url);

    if (res.statusCode == 200) {
      final json = jsonDecode(res.body);

      final data = json["data"];

      return {
        "Sun": (data["Sun"] ?? 0).toDouble(),
        "Mon": (data["Mon"] ?? 0).toDouble(),
        "Tue": (data["Tue"] ?? 0).toDouble(),
        "Wed": (data["Wed"] ?? 0).toDouble(),
        "Thu": (data["Thu"] ?? 0).toDouble(),
        "Fri": (data["Fri"] ?? 0).toDouble(),
        "Sat": (data["Sat"] ?? 0).toDouble(),
      };
    }

    return {};
  }
}