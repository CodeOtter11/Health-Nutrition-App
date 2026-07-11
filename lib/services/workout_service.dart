import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../core/api_config.dart';

class WorkoutService {

  static Future<bool> saveWorkout({
    required String workoutType,
    required List<String> exercises,
    required int duration,
    required int calories,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("auth_token");

      final baseUrl = await ApiConfig.getBaseUrl();

      final response = await http.post(
        Uri.parse("$baseUrl/tracker/workout"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode({
          "workoutType": workoutType,
          "exercises": exercises,
          "durationMinutes": duration,
          "caloriesBurned": calories,
        }),
      );

      print("WORKOUT STATUS: ${response.statusCode}");
      print("WORKOUT BODY: ${response.body}");

      return response.statusCode == 200;

    } catch (e) {
      print("WORKOUT ERROR: $e");
      return false;
    }
  }
}