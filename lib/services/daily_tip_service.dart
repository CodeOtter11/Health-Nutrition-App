import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class DailyTipService {
  static const String _apiKey = "AIzaSyCvlYFhA4o1iCG6yZ_FGXWy3g0uiLjrhdY";

  static const String _endpoint =
      "https://generativelanguage.googleapis.com/v1beta/openai/chat/completions";

  /// MAIN METHOD USED BY DASHBOARD
  static Future<String> getDailyTip() async {
    final prefs = await SharedPreferences.getInstance();
    final todayKey = _todayKey();

    // ✅ If already fetched today, reuse it
    final cachedTip = prefs.getString(todayKey);
    if (cachedTip != null) {
      return cachedTip;
    }

    try {
      final tip = await _fetchFromGemini();
      await prefs.setString(todayKey, tip);
      return tip;
    } catch (e) {
      // ✅ graceful fallback (no crash)
      return "Drink water regularly and eat balanced meals.";
    }
  }

  /// GEMINI CALL (your logic, cleaned)
  static Future<String> _fetchFromGemini() async {
    final res = await http.post(
      Uri.parse(_endpoint),
      headers: {
        "Authorization": "Bearer $_apiKey",
        "Content-Type": "application/json",
      },
      body: jsonEncode({
        "model": "gemini-2.5-flash",
        "messages": [
          {
            "role": "system",
            "content":
            "You are a friendly nutrition coach. Speak in very simple, everyday words that anyone can understand. Avoid medical or complex terms. Give ONE short, practical nutrition tip."
          },
          {
            "role": "user",
            "content":
            "Give one easy daily food or health tip in simple words. Under 12 words."
          }
        ],
      }),
    );

    if (res.statusCode != 200) {
      throw Exception("Gemini error ${res.statusCode}");
    }

    final decoded = utf8.decode(res.bodyBytes);
    final map = jsonDecode(decoded);

    return map['choices'][0]['message']['content'].toString().trim();
  }

  /// UNIQUE KEY PER DAY
  static String _todayKey() {
    final now = DateTime.now();
    return "daily_tip_${now.year}_${now.month}_${now.day}";
  }
}
