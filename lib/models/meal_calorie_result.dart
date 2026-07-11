class MealCalorieResult {
  final String food;
  final double calories;
  final double protein;
  final double carbs;
  final double fat;
  final double quantity;
  final String unit;
  final double grams;

  const MealCalorieResult({
    required this.food,
    required this.calories,
    this.protein = 0,
    this.carbs = 0,
    this.fat = 0,
    required this.quantity,
    required this.unit,
    required this.grams,
  });

  /// Optional helper if we ever want to create object from API
  factory MealCalorieResult.fromApi({
    required String food,
    required Map<String, dynamic> apiData,
    required double quantity,
    required String unit,
    required double grams,
  }) {
    final nutrients = apiData["totalNutrients"] ?? {};

    return MealCalorieResult(
      food: food,
      calories: (apiData["calories"] as num?)?.toDouble() ?? 0,
      protein: (nutrients["PROCNT"]?["quantity"] ?? 0).toDouble(),
      carbs: (nutrients["CHOCDF"]?["quantity"] ?? 0).toDouble(),
      fat: (nutrients["FAT"]?["quantity"] ?? 0).toDouble(),
      quantity: quantity,
      unit: unit,
      grams: grams,
    );
  }
}