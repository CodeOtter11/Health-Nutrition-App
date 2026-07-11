import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../core/api_config.dart';

class MealApiService {

  // ================= TOKEN =================
  static Future<String> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("auth_token");

    if (token == null) {
      throw Exception("Auth token not found");
    }

    return token;
  }

  // ================= BASE URL =================
  static Future<String> _getBaseUrl() async {
    return await ApiConfig.getBaseUrl();
  }

  // ================= FETCH TODAY SUMMARY =================
  static Future<Map<String, dynamic>?> fetchTodaySummary() async {
    try {

      final token = await _getToken();
      final baseUrl = await _getBaseUrl();

      final response = await http.get(
        Uri.parse("$baseUrl/meals/summary/today"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
      );

      print("📊 Today summary status: ${response.statusCode}");
      print("📊 Today summary response: ${response.body}");

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }

      return null;

    } catch (e) {

      print("❌ fetchTodaySummary error: $e");
      return null;
    }
  }

  // ================= FETCH WEEKLY SUMMARY =================
  static Future<Map<String, dynamic>?> fetchWeeklySummary() async {
    try {

      final token = await _getToken();
      final baseUrl = await _getBaseUrl();

      final response = await http.get(
        Uri.parse("$baseUrl/meals/weekly-summary"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
      );

      print("📊 Weekly summary status: ${response.statusCode}");
      print("📊 Weekly summary response: ${response.body}");

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }

      return null;

    } catch (e) {

      print("❌ fetchWeeklySummary error: $e");
      return null;
    }
  }

  // ================= ADD MEAL =================
  static Future<void> addMeal({
    required String mealType,
    required String name,
    required double calories,
    double protein = 0,
    double carbs = 0,
    double fat = 0,
    required double quantity,
    required String unit,
    required double grams,
  }) async {

    try {

      final token = await _getToken();
      final baseUrl = await _getBaseUrl();

      final url = "$baseUrl/meals";

      print("➕ Add meal URL: $url");

      final response = await http.post(
        Uri.parse(url),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode({
          "mealType": mealType,
          "name": name,
          "calories": calories,
          "protein": protein,
          "carbs": carbs,
          "fat": fat,
          "quantity": quantity,
          "unit": unit,
          "grams": grams,
        }),
      );

      print("➕ Add meal status: ${response.statusCode}");
      print("➕ Add meal response: ${response.body}");

      if (response.statusCode != 201) {
        throw Exception("Failed to save meal");
      }

    } catch (e) {

      print("❌ addMeal error: $e");
      rethrow;

    }
  }

  // ================= GET TODAY MEALS =================
  static Future<List<dynamic>> getTodayMeals() async {

    try {

      final token = await _getToken();
      final baseUrl = await _getBaseUrl();

      final today = DateTime.now().toIso8601String().split("T")[0];

      final url = "$baseUrl/meals?date=$today";

      print("📦 Fetch meals URL: $url");

      final response = await http.get(
        Uri.parse(url),
        headers: {
          "Authorization": "Bearer $token",
        },
      );

      print("📦 Fetch meals status: ${response.statusCode}");
      print("📦 Fetch meals response: ${response.body}");

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }

      throw Exception("Failed to fetch meals");

    } catch (e) {

      print("❌ getTodayMeals error: $e");
      rethrow;

    }
  }

  // ================= DELETE MEAL =================
  static Future<void> deleteMeal(String mealId) async {

    try {

      final token = await _getToken();
      final baseUrl = await _getBaseUrl();

      final url = "$baseUrl/meals/$mealId";

      print("🗑 Delete meal URL: $url");

      final response = await http.delete(
        Uri.parse(url),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
      );

      print("🗑 Delete status: ${response.statusCode}");
      print("🗑 Delete response: ${response.body}");

      if (response.statusCode != 200 &&
          response.statusCode != 204) {
        throw Exception("Failed to delete meal");
      }

    } catch (e) {

      print("❌ deleteMeal error: $e");
      rethrow;

    }
  }
}