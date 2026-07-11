import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'meal_detail_screen.dart';
import '../services/meal_storage_service.dart';

class MealTypes {
  static const breakfast = "Breakfast";
  static const lunch = "Lunch";
  static const snacks = "Snacks";
  static const beverages = "Juices";
  static const dinner = "Dinner";
}

class MealPlanScreen extends StatefulWidget {
  const MealPlanScreen({super.key});

  @override
  State<MealPlanScreen> createState() => _MealPlanScreenState();
}

class _MealPlanScreenState extends State<MealPlanScreen> {
  double totalCalories = 0;
  int waterGlasses = 0;

  double get dynamicCalorieGoal =>
      ((totalCalories ~/ 2000) + 1) * 2000;

  int get dynamicWaterGoal =>
      ((waterGlasses ~/ 8) + 1) * 8;

  @override
  void initState() {
    super.initState();
    _loadDailyCalories();
    _loadWater();
  }

  Future<void> _loadDailyCalories() async {
    final calories =
    await MealStorageService.getTotalCaloriesForToday();
    setState(() => totalCalories = calories);
  }

  Future<void> _loadWater() async {
    final water =
    await MealStorageService.getWaterGlassesForToday();
    setState(() => waterGlasses = water);
  }

  @override
  Widget build(BuildContext context) {
    final isDark =
        Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
      isDark ? const Color(0xFF000000) : const Color(0xFFF2F2F2),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: SingleChildScrollView(
              child: Column(
                children: [

                  // ================= RESPONSIVE HEADER =================
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final width = constraints.maxWidth;
                      final headerHeight = width * 0.50;

                      return Container(
                        width: double.infinity,
                        height: headerHeight,
                        clipBehavior: Clip.hardEdge,
                        decoration: BoxDecoration(
                          color: isDark
                              ? const Color(0xFF078E39)
                              : const Color(0xFFA5D6A7),
                          borderRadius: const BorderRadius.only(
                            bottomLeft: Radius.circular(90),
                            bottomRight: Radius.circular(90),
                          ),
                        ),
                        child: Stack(
                          children: [

                            // FOOD IMAGE
                            Positioned(
                              right: -width * 0.10,
                              top: headerHeight * 0.45,
                              child: ClipRRect(
                                borderRadius: const BorderRadius.only(
                                  topLeft:
                                  Radius.elliptical(300, 220),
                                  bottomLeft:
                                  Radius.elliptical(300, 220),
                                ),
                                child: SizedBox(
                                  width: width * 0.65,
                                  height: headerHeight * 0.70,
                                  child: Image.asset(
                                    'assets/images/meal_header.png',
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            ),

                            // TEXT + BACK BUTTON
                            Padding(
                              padding:
                              const EdgeInsets.fromLTRB(
                                  20, 0, 20, 20),
                              child: Column(
                                crossAxisAlignment:
                                CrossAxisAlignment.start,
                                children: [

                                  // BACK BUTTON (RESTORED)
                                  IconButton(
                                    icon: Icon(
                                      Icons.arrow_back,
                                      color: isDark
                                          ? Colors.white
                                          : Colors.black,
                                    ),
                                    onPressed: () =>
                                        Navigator.pop(context),
                                  ),

                                  SizedBox(
                                      height:
                                      headerHeight * 0.08),

                                  Text(
                                    "Meal Plan",
                                    style: TextStyle(
                                      fontSize:
                                      width * 0.075,
                                      fontWeight:
                                      FontWeight.w800,
                                      color: isDark
                                          ? Colors.white
                                          : Colors.black,
                                    ),
                                  ),

                                  const SizedBox(height: 4),

                                  Text(
                                    "Today's nutrition",
                                    style: TextStyle(
                                      fontSize:
                                      width * 0.038,
                                      fontWeight:
                                      FontWeight.w500,
                                      color: isDark
                                          ? const Color(
                                          0xFF8EE4AF)
                                          : const Color(
                                          0xFF078E39),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 20),

                  // ================= SUMMARY CARDS =================
                  Padding(
                    padding:
                    const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        Expanded(
                          child: _summaryCard(
                            context,
                            "Calories",
                            LucideIcons.flame,
                            "${totalCalories.toStringAsFixed(0)} / ${dynamicCalorieGoal.toStringAsFixed(0)} kcal",
                            (totalCalories /
                                dynamicCalorieGoal)
                                .clamp(0, 1),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: GestureDetector(
                            onTap: () async {
                              await MealStorageService
                                  .addWaterGlass();
                              _loadWater();
                            },
                            child: _summaryCard(
                              context,
                              "Water",
                              LucideIcons.droplet,
                              "$waterGlasses / $dynamicWaterGoal glasses",
                              (waterGlasses /
                                  dynamicWaterGoal)
                                  .clamp(0, 1),
                              showAdd: true,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  const Padding(
                    padding:
                    EdgeInsets.symmetric(horizontal: 20),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "Today's Meals",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF22C55E),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 14),

                  // ================= MEAL TILES =================
                  Padding(
                    padding:
                    const EdgeInsets.symmetric(horizontal: 10),
                    child: Column(
                      children: [
                        _mealTile(context, "Breakfast",
                            LucideIcons.coffee,
                            MealTypes.breakfast),
                        _mealTile(context, "Lunch",
                            LucideIcons.sun,
                            MealTypes.lunch),
                        _mealTile(context, "Snacks",
                            LucideIcons.apple,
                            MealTypes.snacks),
                        _mealTile(context, "Juices",
                            LucideIcons.glassWater,
                            MealTypes.beverages),
                        _mealTile(context, "Dinner",
                            LucideIcons.moon,
                            MealTypes.dinner),
                        const SizedBox(height: 90),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ================= SUMMARY CARD =================
  Widget _summaryCard(
      BuildContext context,
      String title,
      IconData icon,
      String value,
      double progress, {
        bool showAdd = false,
      }) {
    final isDark =
        Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color:
        isDark ? const Color(0xFF121212) : Colors.white,
        borderRadius:
        BorderRadius.circular(18),
        border: Border.all(
            color: const Color(0xFF22C55E)),
      ),
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor:
                const Color(0xFF22C55E),
                child: Icon(icon,
                    color: Colors.white,
                    size: 18),
              ),
              const SizedBox(width: 8),
              Expanded(child: Text(title)),
              if (showAdd)
                const CircleAvatar(
                  radius: 12,
                  backgroundColor:
                  Color(0xFF22C55E),
                  child: Icon(Icons.add,
                      size: 14,
                      color: Colors.white),
                ),
            ],
          ),
          const SizedBox(height: 10),
          LinearProgressIndicator(
            value: progress,
            color:
            const Color(0xFF22C55E),
          ),
          const SizedBox(height: 6),
          Text(value),
        ],
      ),
    );
  }

  // ================= MEAL TILE (ROUTES RESTORED) =================
  Widget _mealTile(BuildContext context,
      String title,
      IconData icon,
      String mealType) {
    final isDark =
        Theme.of(context).brightness ==
            Brightness.dark;

    return GestureDetector(
      onTap: () async {
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) =>
                MealDetailScreen(mealType: mealType),
          ),
        );
        _loadDailyCalories(); // reload after returning
      },
      child: Container(
        margin:
        const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color:
          isDark ? const Color(0xFF121212) : Colors.white,
          borderRadius:
          BorderRadius.circular(18),
          border: Border.all(
              color: const Color(0xFF22C55E)),
        ),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor:
              const Color(0xFF22C55E),
              child:
              Icon(icon, color: Colors.white),
            ),
            const SizedBox(width: 12),
            Expanded(child: Text(title)),
            const CircleAvatar(
              radius: 14,
              backgroundColor:
              Color(0xFF22C55E),
              child: Icon(Icons.add,
                  size: 16,
                  color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}