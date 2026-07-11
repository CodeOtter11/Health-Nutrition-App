import 'dart:convert';
import 'package:http/http.dart' as http;

class UserApi {
  static Future<Map<String, dynamic>> getDietPlan(String expertId) async {
    final response = await http.get(
      Uri.parse("http://192.168.1.6:5001/api/diet-plan/$expertId"),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body)["plan"];
    } else {
      throw Exception("Failed to load plan");
    }
  }
  static Future<Map<String, dynamic>> getWeeklyPlan(String userId) async {
    final response = await http.get(
      Uri.parse("http://192.168.1.6:5001/api/diet-plan/weekly/$userId"),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("No weekly plan found");
    }
  }
}