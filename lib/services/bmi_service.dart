import 'dart:convert';
import 'package:http/http.dart' as http;
import '../core/api_config.dart';

class BMIService {

  // ================= SAVE BMI =================
  static Future<void> saveBMI({
    required String token,
    required double bmi,
    required double height,
    required double weight,
  }) async {

    final baseUrl = await ApiConfig.getBaseUrl(); // 🔥 USE THIS

    final response = await http.post(
      Uri.parse("$baseUrl/tracker/bmi"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
      body: jsonEncode({
        "bmi": bmi,
        "height": height,
        "weight": weight,
      }),
    );

    if (response.statusCode != 201) {
      throw Exception("Failed to save BMI");
    }
  }

  // ================= GET BMI =================
  static Future<List<dynamic>> getBMIHistory(String token) async {

    final baseUrl = await ApiConfig.getBaseUrl(); // 🔥 USE THIS

    final response = await http.get(
      Uri.parse("$baseUrl/tracker/bmi"),
      headers: {
        "Authorization": "Bearer $token",
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data["data"];
    } else {
      throw Exception("Failed to load BMI history");
    }
  }
}