import 'package:flutter/material.dart';
import '../models/meal_item.dart';
import '../services/meal_storage_service.dart';
import '../services/meal_calories_service.dart';
import '../services/meal_api_service.dart';

class MealDetailScreen extends StatefulWidget {
  final String mealType;

  const MealDetailScreen({
    super.key,
    required this.mealType,
  });

  @override
  State<MealDetailScreen> createState() => _MealDetailScreenState();
}

class _MealDetailScreenState extends State<MealDetailScreen> {
  final TextEditingController _controller = TextEditingController();
  List<MealItem> meals = [];
  bool _isLoading = false;

  final List<String> quickAddItems = [
    "1 cup rice",
    "1 egg",
    "1 banana",
    "1 cup milk",
    "1 roti",
    "1 cup dal",
  ];

  final Color brandGreen = const Color(0xFF47AC6C);

  @override
  void initState() {
    super.initState();
    _loadMeals();
  }

  // ================= LOAD =================
  MealItem _mapFromBackend(dynamic m) {
    return MealItem(
      id: m["_id"],
      name: m["name"],
      calories: (m["calories"] as num).toDouble(),
      quantity: (m["quantity"] as num?)?.toDouble() ?? 1.0,
      unit: m["unit"] ?? "grams",
      grams: (m["grams"] ?? 0).toDouble(),
    );
  }

  Future<void> _loadMeals() async {
    try {
      final backendMeals = await MealApiService.getTodayMeals();

      final filtered = backendMeals
          .where((m) => m["mealType"] == widget.mealType)
          .map(_mapFromBackend)
          .toList();

      setState(() => meals = filtered);

      await MealStorageService.saveMeals(widget.mealType, filtered);
    } catch (e) {
      print("⚠️ Backend load failed, using local storage");

      final localMeals =
      await MealStorageService.getMeals(widget.mealType);

      setState(() => meals = localMeals);
    }
  }

  // ================= ADD MEAL =================
  Future<void> _addMeal(String input) async {
    if (_isLoading || input.trim().isEmpty) return;

    setState(() => _isLoading = true);

    try {
      final result =
      await MealCaloriesService.getEstimatedCaloriesWithMeta(
          input.trim());

      // fetch macros from Edamam
      final apiData =
      await MealCaloriesService.fetchNutritionForMacros(
          "${result.quantity} ${result.unit} ${result.food}");

      final macros =
      MealCaloriesService.calculateMacros(apiData: apiData);

      await MealApiService.addMeal(
        mealType: widget.mealType,
        name: result.food,
        calories: result.calories,
        protein: macros["protein"] ?? 0,
        carbs: macros["carbs"] ?? 0,
        fat: macros["fat"] ?? 0,
        quantity: result.quantity,
        unit: result.unit,
        grams: result.grams,
      );

      _controller.clear();

      await _loadMeals();
    } catch (e) {
      print("❌ Add meal failed: $e");

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Failed to add meal"),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  String formatQuantity(double q) =>
      q % 1 == 0 ? q.toInt().toString() : q.toString();

  // ================= DELETE MEAL =================
  Future<void> _deleteMeal(String mealId) async {
    try {
      print("🗑 Deleting meal id: $mealId");

      await MealApiService.deleteMeal(mealId);

      print("✅ Meal deleted");

      await _loadMeals();
    } catch (e) {
      print("❌ Delete failed: $e");

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Failed to delete meal"),
          ),
        );
      }
    }
  }

  // ================= BUILD =================
  @override
  Widget build(BuildContext context) {
    final isDark =
        Theme.of(context).brightness == Brightness.dark;

    final bgColor =
    isDark ? const Color(0xFF0F0F0F) : const Color(0xFFF3F4F6);

    final cardColor =
    isDark ? const Color(0xFF1A1A1A) : Colors.white;

    final textColor =
    isDark ? Colors.white : Colors.black87;

    final subtitleColor =
    isDark ? Colors.white70 : Colors.black54;

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Column(
          children: [

            // ================= HEADER =================
            Container(
              width: double.infinity,
              padding:
              const EdgeInsets.fromLTRB(20, 20, 20, 40),
              decoration: BoxDecoration(
                color: brandGreen,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(45),
                  bottomRight: Radius.circular(45),
                ),
                boxShadow: [
                  BoxShadow(
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                    color: brandGreen.withOpacity(0.4),
                  )
                ],
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back,
                        color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    widget.mealType,
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),

            // ================= BODY =================
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [

                    // ================= INPUT =================
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              color: cardColor,
                              borderRadius:
                              BorderRadius.circular(16),
                            ),
                            child: TextField(
                              controller: _controller,
                              style:
                              TextStyle(color: textColor),
                              decoration: InputDecoration(
                                hintText:
                                "Add food (e.g. 1 cup rice, 2 eggs...)",
                                hintStyle: TextStyle(
                                    color: subtitleColor),
                                border: InputBorder.none,
                                contentPadding:
                                const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 14),
                              ),
                              onSubmitted: _addMeal,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        CircleAvatar(
                          backgroundColor: brandGreen,
                          child: _isLoading
                              ? const SizedBox(
                            height: 18,
                            width: 18,
                            child:
                            CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                              : IconButton(
                            icon: const Icon(Icons.add,
                                color: Colors.white),
                            onPressed: () =>
                                _addMeal(_controller.text),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 30),

                    // ================= MEALS LIST =================
                    meals.isEmpty
                        ? Center(
                      child: Column(
                        children: [
                          Container(
                            height: 120,
                            width: 120,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: brandGreen,
                            ),
                            child: const Icon(
                              Icons.restaurant_menu,
                              size: 55,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            "No foods added yet",
                            style: TextStyle(
                              fontWeight:
                              FontWeight.w600,
                              fontSize: 16,
                              color: textColor,
                            ),
                          ),
                        ],
                      ),
                    )
                        : Column(
                      children: meals.map((meal) {
                        return Container(
                          margin:
                          const EdgeInsets.only(
                              bottom: 12),
                          decoration: BoxDecoration(
                            color: cardColor,
                            borderRadius:
                            BorderRadius.circular(
                                16),
                          ),
                          child: ListTile(
                            title: Text(
                              "${formatQuantity(meal.quantity)} ${meal.unit} ${meal.name}",
                              style: TextStyle(
                                  color: textColor),
                            ),
                            subtitle: Text(
                              "${meal.calories.toStringAsFixed(0)} kcal",
                              style: TextStyle(
                                  color:
                                  subtitleColor),
                            ),
                            trailing: IconButton(
                              icon: Icon(Icons.close,
                                  color: textColor),
                              onPressed: () =>
                                  _deleteMeal(
                                      meal.id),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}