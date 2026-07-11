import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../services/workout_service.dart';

class LogWorkoutScreen extends StatefulWidget {
  const LogWorkoutScreen({super.key});

  @override
  State<LogWorkoutScreen> createState() => _LogWorkoutScreenState();
}

class _LogWorkoutScreenState extends State<LogWorkoutScreen> {
  int? selectedWorkout;

  final List<Map<String, dynamic>> workoutTypes = [
    {"title": "Strength", "icon": LucideIcons.dumbbell, "duration": 40, "calories": 340},
    {"title": "Cardio", "icon": LucideIcons.zap, "duration": 30, "calories": 200},
    {"title": "Boxing", "icon": LucideIcons.hand, "duration": 40, "calories": 300},
    {"title": "Meditation", "icon": LucideIcons.brain, "duration": 25, "calories": 80},
  ];

  final List<String> quickExercises = [
    "Push-ups",
    "Squats",
    "Plank",
    "Lunges",
    "Burpees",
    "Sit-ups",
  ];

  final Set<String> selectedExercises = {};
  int totalDuration = 0;
  int totalCalories = 0;
  final Set<int> selectedWorkoutIndexes = {};

  String formatDuration(int minutes) {
    if (minutes < 60) {
      return "$minutes min";
    }

    int hours = minutes ~/ 60;
    int remainingMinutes = minutes % 60;

    if (remainingMinutes == 0) {
      return "$hours hr";
    }

    return "$hours hr $remainingMinutes min";
  }

  void _selectWorkout(int index) {
    setState(() {
      final workout = workoutTypes[index];

      if (selectedWorkoutIndexes.contains(index)) {
        // REMOVE
        selectedWorkoutIndexes.remove(index);
        totalDuration -= workout["duration"] as int;
        totalCalories -= workout["calories"] as int;
      } else {
        // ADD
        selectedWorkoutIndexes.add(index);
        totalDuration += workout["duration"] as int;
        totalCalories += workout["calories"] as int;
      }

      selectedWorkout = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final cardColor =
    isDark ? const Color(0xFF121212) : const Color(0xFFEFEFEF);
    final chipColor =
    isDark ? const Color(0xFF1F3D2B) : const Color(0xFF9ED4A8);
    final summaryColor =
    isDark ? const Color(0xFF254F39) : const Color(0xFF9ED4A8);
    final textColor = isDark ? Colors.white : Colors.black;

    return Scaffold(
      backgroundColor:
      isDark ? const Color(0xFF000000) : const Color(0xFFF2F2F2),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  // HEADER (UNCHANGED)
                  Container(
                    width: double.infinity,
                    height: 190,
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                    decoration: BoxDecoration(
                      color: isDark
                          ? const Color(0xFF1F3D2B)
                          : const Color(0xFF9ED4A8),
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(40),
                        bottomRight: Radius.circular(40),
                      ),
                    ),
                    child: Stack(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            IconButton(
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                              icon: Icon(Icons.arrow_back,
                                  color: isDark
                                      ? Colors.white
                                      : Colors.black),
                              onPressed: () =>
                                  Navigator.pop(context),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              "Activity Log",
                              style: TextStyle(
                                fontSize: 30,
                                fontWeight: FontWeight.bold,
                                color: textColor,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "Let’s Get Moving",
                              style: TextStyle(
                                fontSize: 16,
                                color: isDark
                                    ? const Color(0xFF7EDC9D)
                                    : const Color(0xFF0F7A39),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        Positioned(
                          right: 0,
                          bottom: 0,
                          child: Image.asset(
                            "assets/images/workout_header.png",
                            height: 160,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // CONTENT
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 14, 20, 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [

                        Text("Workout Type",
                            style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: textColor)),
                        const SizedBox(height: 10),

                        // ✅ UPDATED WORKOUT TYPE ONLY
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(22),
                            border: Border.all(
                              color: const Color(0xFF22C55E),
                              width: 1.2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF22C55E)
                                    .withOpacity(0.25),
                                blurRadius: 18,
                                spreadRadius: 1,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: SizedBox(
                            height: 120,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: workoutTypes.length,
                              itemBuilder: (_, index) {
                                final w = workoutTypes[index];
                                final selected =
                                    selectedWorkout == index;

                                return GestureDetector(
                                  onTap: () =>
                                      _selectWorkout(index),
                                  child: Container(
                                    width: 120,
                                    margin:
                                    const EdgeInsets.only(
                                        right: 14),
                                    padding:
                                    const EdgeInsets.all(14),
                                    decoration: BoxDecoration(
                                      color: cardColor,
                                      borderRadius:
                                      BorderRadius.circular(
                                          22),
                                      border: Border.all(
                                        color: Colors.black
                                            .withOpacity(0.6),
                                        width: 1.2,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black
                                              .withOpacity(0.12),
                                          blurRadius: 8,
                                          offset:
                                          const Offset(
                                              0, 4),
                                        ),
                                      ],
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                      CrossAxisAlignment
                                          .start,
                                      children: [
                                        Icon(w["icon"],
                                            color:
                                            const Color(
                                                0xFF22C55E),
                                            size: 29),
                                        const Spacer(),
                                        Text(
                                          w["title"],
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight:
                                            FontWeight
                                                .w800,
                                            color:
                                            textColor,
                                          ),
                                        ),
                                        const SizedBox(
                                            height: 6),
                                        Text(
                                          "${w["duration"]} min•${w["calories"]}cal",
                                          style:
                                          const TextStyle(
                                            fontSize: 12,
                                            color: Color(
                                                0xFF22C55E),
                                            fontWeight:
                                            FontWeight
                                                .w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),

                        const SizedBox(height: 18),

                        // REST OF YOUR UI UNCHANGED BELOW

                        Text("Quick Add Exercises",
                            style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: textColor)),
                        const SizedBox(height: 10),

                        _outlinedCard(
                          cardColor,
                          child: LayoutBuilder(
                            builder: (context, constraints) {
                              double totalWidth =
                                  constraints.maxWidth;
                              double spacing = 10;
                              double itemWidth =
                                  (totalWidth -
                                      (spacing * 2)) /
                                      3;

                              return Wrap(
                                spacing: spacing,
                                runSpacing: spacing,
                                children:
                                quickExercises.map((e) {
                                  final isSelected = selectedExercises.contains(e);

                                  return SizedBox(
                                    width: itemWidth,
                                    child: GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          if (isSelected) {
                                            selectedExercises.remove(e);
                                          } else {
                                            selectedExercises.add(e);
                                          }
                                        });
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(vertical: 10),
                                        decoration: BoxDecoration(
                                          color: isSelected ? Colors.green : chipColor,
                                          borderRadius: BorderRadius.circular(20),
                                          border: Border.all(
                                            color: const Color(0xFF2E7D32),
                                            width: 1,
                                          ),
                                        ),
                                        alignment: Alignment.center,
                                        child: Text(
                                          e,
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w500,
                                            color: textColor,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                    ),
                                  );
                                }).toList(),
                              );
                            },
                          ),
                        ),

                        const SizedBox(height: 18),

                        Text("Workout Summary",
                            style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: textColor)),
                        const SizedBox(height: 10),

                        _outlinedCard(
                          cardColor,
                          child: Row(
                            mainAxisAlignment:
                            MainAxisAlignment
                                .spaceAround,
                            children: [
                              _summaryBox(
                                summaryColor,
                                textColor,
                                formatDuration(totalDuration),
                                "Duration",
                              ),
                              _summaryBox(summaryColor, textColor, "$totalCalories", "Calories"),
                              _summaryBox(summaryColor, textColor, "${selectedExercises.length}", "Exercises"),
                            ],
                          ),
                        ),

                        const SizedBox(height: 24),

                        Center(
                          child: GestureDetector(
                            onTap: () async {
                              if (selectedWorkout == null) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text("Please select workout type")),
                                );
                                return;
                              }

                              final selected = workoutTypes[selectedWorkout!];

                              final success = await WorkoutService.saveWorkout(
                                workoutType: selected["title"],
                                exercises: selectedExercises.toList(),
                                duration: totalDuration,
                                calories: totalCalories,
                              );

                              if (success) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text("Workout saved successfully ✅")),
                                );
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text("Failed to save workout ❌")),
                                );
                              }
                            },
                            child: Container(
                              width: 293,   // ✅ exact
                              height: 58,   // ✅ exact
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFF7CEAA4),
                                    Color(0xFF49D57C),
                                    // Color(0xFF21C55D),
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),

                                borderRadius: BorderRadius.circular(13), // ✅ exact

                                border: Border.all(
                                  color: Colors.black,
                                  width: 1, // ✅ exact from Figma
                                ),
                              ),
                              child: const Center(
                                child: Text(
                                  "Save workout",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
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

  Widget _outlinedCard(Color cardColor,
      {required Widget child}) {
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF22C55E)),
      ),
      child: child,
    );
  }

  Widget _summaryBox(Color bg, Color textColor,
      String value, String label) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          Text(value,
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: textColor)),
          Text(label,
              style: TextStyle(
                  fontSize: 12, color: textColor)),
        ],
      ),
    );
  }
}
