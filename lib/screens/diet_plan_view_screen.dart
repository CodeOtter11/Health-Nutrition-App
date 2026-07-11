import 'package:flutter/material.dart';
import '../services/user_api.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/notification_service.dart';

class DietPlanViewScreen extends StatefulWidget {
  const DietPlanViewScreen({super.key});

  @override
  State<DietPlanViewScreen> createState() => _DietPlanViewScreenState();
}

class _DietPlanViewScreenState extends State<DietPlanViewScreen> {
  Map<String, dynamic>? weeklyPlan;
  bool isLoading = true;

  static const Color green = Color(0xFF22C55E);

  @override
  void initState() {
    super.initState();
    loadPlan();
  }

  Future<void> loadPlan() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String userId = prefs.getString("userId")!;

      // 🔥 CALL WEEKLY API
      final result = await UserApi.getWeeklyPlan(userId);

      setState(() {
        weeklyPlan = result;
        isLoading = false;
      });

      // 🔔 SMART NOTIFICATION
      String? lastPlan = prefs.getString("last_plan");
      String currentPlan = result.toString();

      if (lastPlan != currentPlan) {
        await NotificationService.showNotification(
          "New Weekly Diet Plan 🍽️",
          "Your dietitian has updated your weekly plan",
        );

        await prefs.setString("last_plan", currentPlan);
      }

    } catch (e) {
      print("Error: $e");
      setState(() => isLoading = false);
    }
  }

  Widget buildDayCard(String day, Map data) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.black26),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            day.toUpperCase(),
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: green,
            ),
          ),
          const SizedBox(height: 10),

          Text("🍳 Breakfast: ${data['breakfast'] ?? ""}"),
          Text("🍎 Snacks: ${data['snacks'] ?? ""}"),
          Text("🍛 Lunch: ${data['lunch'] ?? ""}"),
          Text("🍽️ Dinner: ${data['dinner'] ?? ""}"),
          Text("🥤 Juices: ${data['juices'] ?? ""}"),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (weeklyPlan == null) {
      return const Scaffold(
        body: Center(child: Text("No weekly diet plan available")),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Weekly Diet Plan"),
        backgroundColor: green,
      ),
      backgroundColor: const Color(0xFFF3F4F6),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: weeklyPlan!.keys.map((day) {
            return buildDayCard(day, weeklyPlan![day]);
          }).toList(),
        ),
      ),
    );
  }
}