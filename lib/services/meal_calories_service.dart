import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/meal_calorie_result.dart';

class MealCaloriesService {

  static const String _edamamAppId = "3e062966";
  static const String _edamamAppKey = "d488f91a0118efcd4646c71308b03de1";

  static const String _geminiApiKey =
      "AIzaSyCvlYFhA4o1iCG6yZ_FGXWy3g0uiLjrhdY";

  static const String _geminiEndpoint =
      "https://generativelanguage.googleapis.com/v1/models/gemini-2.5-flash:generateContent";

  static const Map<String, double> _portionToGrams = {
    "cup": 180,
    "cups": 180,
    "bowl": 150,
    "bowls": 150,
    "katori": 150,
    "plate": 200,
    "glass": 200,
    "roti": 40,
    "rotis": 40,
    "piece": 50,
    "pieces": 50,
  };

  // ===============================
  // MAIN METHOD
  // ===============================
  static Future<MealCalorieResult> getEstimatedCaloriesWithMeta(
      String foodInput) async {

    final parsed =
        _tryLocalParse(foodInput) ??
            await _parseFoodWithGemini(foodInput);

    final food = parsed['food'].toString();
    final quantity = (parsed['quantity'] as num).toDouble();
    final unit = parsed['unit'].toString().toLowerCase();

    final gramsPerUnit = _portionToGrams[unit] ?? 100;
    final grams = quantity * gramsPerUnit;

    final ingredient =
    unit == "unit" ? "$quantity $food" : "$quantity $unit $food";

    print("Sending to Edamam: $ingredient");

    final nutrition = await _fetchNutrition(ingredient);

    // ✅ Extract calories properly
    double calories = 0;

    try {
      calories = nutrition["ingredients"][0]["parsed"][0]["nutrients"]
      ["ENERC_KCAL"]["quantity"]
          .toDouble();
    } catch (e) {
      print("⚠️ Could not extract calories");
    }

    return MealCalorieResult(
      food: food,
      calories: calories,
      quantity: quantity,
      unit: unit,
      grams: grams,
    );
  }

  // ===============================
  // FETCH NUTRITION FOR MACROS
  // ===============================
  static Future<Map<String, dynamic>> fetchNutritionForMacros(
      String ingredient) async {
    return _fetchNutrition(ingredient);
  }

  // ===============================
  // EDAMAM CALL
  // ===============================
  static Future<Map<String, dynamic>> _fetchNutrition(
      String ingredient) async {

    final url = Uri.parse(
      "https://api.edamam.com/api/nutrition-data"
          "?app_id=$_edamamAppId"
          "&app_key=$_edamamAppKey"
          "&ingr=${Uri.encodeComponent(ingredient)}",
    );

    final response = await http.get(url);

    print("Edamam response: ${response.body}");

    if (response.statusCode != 200) {
      throw Exception("Edamam API error: ${response.body}");
    }

    return jsonDecode(response.body);
  }

  // ===============================
  // MACROS
  // ===============================
  static Map<String, double> calculateMacros({
    required Map<String, dynamic> apiData,
  }) {

    try {
      final nutrients =
      apiData["ingredients"][0]["parsed"][0]["nutrients"];

      return {
        "protein": (nutrients["PROCNT"]["quantity"] ?? 0).toDouble(),
        "carbs": (nutrients["CHOCDF"]["quantity"] ?? 0).toDouble(),
        "fat": (nutrients["FAT"]["quantity"] ?? 0).toDouble(),
      };
    } catch (e) {
      return {"protein": 0, "carbs": 0, "fat": 0};
    }
  }

  // ===============================
  // GEMINI PARSER
  // ===============================
  static Future<Map<String, dynamic>> _parseFoodWithGemini(
      String foodInput) async {

    final uri =
    Uri.parse("$_geminiEndpoint?key=$_geminiApiKey");

    final res = await http.post(
      uri,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "contents": [
          {
            "parts": [
              {
                "text": """
Extract food quantity.

Return JSON only.

Format:
{
"food": string,
"quantity": number,
"unit": string
}

Input: $foodInput
"""
              }
            ]
          }
        ]
      }),
    );

    final decoded = jsonDecode(res.body);
    final rawText =
    decoded['candidates'][0]['content']['parts'][0]['text'];

    final jsonText = rawText
        .replaceAll(RegExp(r'```json'), '')
        .replaceAll(RegExp(r'```'), '')
        .trim();

    return jsonDecode(jsonText);
  }

  // ===============================
  // LOCAL PARSER
  // ===============================
  static Map<String, dynamic>? _tryLocalParse(String input) {

    final text = input.toLowerCase().trim();

    final regex = RegExp(
      r'(\d+(\.\d+)?)\s*(cup|cups|bowl|bowls|katori|plate|glass|roti|rotis|piece|pieces)?\s*(.+)',
    );

    final match = regex.firstMatch(text);

    if (match == null) return null;

    final quantity = double.parse(match.group(1)!);
    final unit = match.group(3) ?? "unit";
    final food = match.group(4)!.trim();

    return {
      "food": food,
      "quantity": quantity,
      "unit": unit,
    };
  }
}