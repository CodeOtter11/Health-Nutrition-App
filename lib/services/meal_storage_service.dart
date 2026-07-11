import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/meal_item.dart';

class MealStorageService {
  // 🔒 Normalize key (FIXES YOUR QUICK ADD ISSUE)
  static String _key(String mealType) =>
      "meals_${mealType.toLowerCase()}";

  // ✅ GET MEALS
  static Future<List<MealItem>> getMeals(String mealType) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_key(mealType));

    if (jsonString == null) return [];

    final List decoded = json.decode(jsonString);
    return decoded.map((e) => MealItem.fromJson(e)).toList();
  }

  // ✅ ADD MEAL
  static Future<void> addMeal(String mealType, MealItem item) async {
    final meals = await getMeals(mealType);
    meals.add(item);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _key(mealType),
      json.encode(meals.map((e) => e.toJson()).toList()),
    );
  }

  // ✅ REMOVE MEAL (SAFE + STABLE)
  static Future<void> removeMeal(String mealType, String mealName) async {
    final meals = await getMeals(mealType);

    meals.removeWhere((meal) => meal.name == mealName);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _key(mealType),
      json.encode(meals.map((e) => e.toJson()).toList()),
    );
  }
  static Future<double> getTotalCaloriesForToday() async {
    double total = 0;

    final mealTypes = [
      "Breakfast",
      "Lunch",
      "Snacks",
      "Beverages",
      "Dinner",
    ];

    for (final meal in mealTypes) {
      final items = await getMeals(meal);
      for (final item in items) {
        total += item.calories;
      }
    }

    return total;
  }
  static const String _waterKey = "daily_water_glasses";

  static String _todayWaterKey() {
    final today = DateTime.now();
    return "$_waterKey${today.year}-${today.month}-${today.day}";
  }

  static Future<int> getWaterGlassesForToday() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_todayWaterKey()) ?? 0;
  }

  static Future<void> addWaterGlass() async {
    final prefs = await SharedPreferences.getInstance();
    final current = prefs.getInt(_todayWaterKey()) ?? 0;
    await prefs.setInt(_todayWaterKey(), current + 1);
  }

  static Future<void> resetWaterForToday() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_todayWaterKey());
  }

  // ✅ SAVE MEALS (USED WHEN SYNCING FROM BACKEND)
  static Future<void> saveMeals(
      String mealType,
      List<MealItem> meals,
      ) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString(
      _key(mealType),
      json.encode(meals.map((e) => e.toJson()).toList()),
    );
  }

}