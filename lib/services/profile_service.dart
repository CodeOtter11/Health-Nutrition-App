import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:meal_plan/models/user_profile_data.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/api_config.dart';

class ProfileService {

  // ---------------- SAVE / UPDATE PROFILE ----------------
  Future<bool> submitProfile(UserProfileData profile) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("auth_token");

    if (token == null) {
      print("❌ No auth token found");
      return false;
    }

    // FIX: get baseUrl correctly
    final baseUrl = await ApiConfig.getBaseUrl();

    final response = await http.put(
      Uri.parse("$baseUrl/profile/me"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
      body: jsonEncode(profile.toJson()),
    );

    print("Profile save status: ${response.statusCode}");
    print("Profile save body: ${response.body}");

    return response.statusCode == 200 || response.statusCode == 201;
  }

  // ---------------- FETCH PROFILE ----------------
  Future<UserProfileData?> fetchProfile() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("auth_token");

      if (token == null) {
        print("❌ No auth token found");
        return null;
      }

      // FIX: get baseUrl correctly
      final baseUrl = await ApiConfig.getBaseUrl();

      final response = await http.get(
        Uri.parse("$baseUrl/profile/me"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
      );

      print("Profile fetch status: ${response.statusCode}");
      print("Profile fetch body: ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return UserProfileData.fromJson(data["profile"]);
      }

      return null;
    } catch (e) {
      print("❌ Fetch profile error: $e");
      return null;
    }
  }
}