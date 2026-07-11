import 'dart:math';
import 'package:flutter/material.dart';
import '../services/meal_api_service.dart';

class ProgressScreen extends StatefulWidget {
  const ProgressScreen({super.key});

  @override
  State<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen> {

  int consumedCalories = 0;
  int goalCalories = 2000;
  int remainingCalories = 2000;

  int protein = 0;
  int carbs = 0;
  int fat = 0;
  int fiber = 0;
  int sugar = 0;
  int saturatedFats = 0;


  bool isLoading = true;

  Map<String, int> weeklyCalories = {};

  @override
  @override
  void initState() {
    super.initState();
    loadTodayProgress();
  }

  Future<void> loadTodayProgress() async {
    try {
      final data = await MealApiService.fetchTodaySummary();
      final weeklyData = await MealApiService.fetchWeeklySummary();

      if (!mounted) return;

      setState(() {
        if (data != null) {
          final macros = data["macros"] ?? {};

          consumedCalories = (data["totalCalories"] ?? 0).toInt();
          goalCalories = (data["goalCalories"] ?? 2000).toInt();
          remainingCalories =
              (data["remainingCalories"] ?? (goalCalories - consumedCalories))
                  .toInt();

          protein = (macros["protein"] ?? 0).round();
          carbs = (macros["carbs"] ?? 0).round();
          fat = (macros["fat"] ?? 0).round();
        }

        if (weeklyData != null) {
          weeklyCalories = weeklyData.map<String, int>((key, value) {
            return MapEntry(key, (value as num).toInt());
          });
        }

        isLoading = false;
      });

    } catch (e) {
      debugPrint("Progress load error: $e");
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  // ================= HEADER =================
  Widget _header() {
    final isDark = Theme
        .of(context)
        .brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 60, 20, 90),
      decoration: BoxDecoration(
        color: isDark
            ? const Color(0xFF2E7D32)
            : const Color(0xFFA5D6A7),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(90),
          bottomRight: Radius.circular(90),
        ),
      ),
      child: const Text(
        "Progress",
        style: TextStyle(
          fontSize: 26,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  // ================= DAILY GOAL CARD =================
  Widget _dailyGoalCard() {
    final isDark = Theme
        .of(context)
        .brightness == Brightness.dark;

    double progress =
    goalCalories == 0 ? 0 : consumedCalories / goalCalories;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark
            ? const Color(0xFF388E3C)
            : const Color(0xFF5FB46B),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            blurRadius: 6,
            color: Colors.black.withOpacity(0.1),
            offset: const Offset(0, 3),
          )
        ],
      ),
      child: Row(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                height: 110,
                width: 110,
                child: CustomPaint(
                  painter: _RingPainter(progress: progress),
                ),
              ),
              Text(
                "${(progress * 100).toInt()}%",
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(width: 20),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Daily goal",
                  style: TextStyle(color: Colors.white70)),
              Text("$goalCalories kcal",
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              const Text("Consumed",
                  style: TextStyle(color: Colors.white70)),
              Text("$consumedCalories kcal",
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600)),
            ],
          )
        ],
      ),
    );
  }

  // ================= WEEK + MACROS =================
  Widget _weekAndMacros() {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(child: _weekCard()),
          const SizedBox(width: 12),
          Expanded(child: _macrosCard()),
        ],
      ),
    );
  }

  Widget _weeklyStats() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Your Weekly Stats",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),

        Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFF6FCF7A), width: 1.2),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: const [
              _StatItem(icon: Icons.fitness_center, value: "0 g", label: "Workouts"),
              _StatItem(icon: Icons.monitor_weight_outlined, value: "0 g", label: "Weight"),
              _StatItem(icon: Icons.flash_on_outlined, value: "0 g", label: "Streak"),
            ],
          ),
        ),
      ],
    );
  }

  Widget _achievements() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Achievements",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),

        _achievementCard(
          "7-Day Streak",
          "Log meals for 7 days straight",
        ),
        _achievementCard(
          "Goal Crusher",
          "Hit your calorie goal 5 times",
        ),
        _achievementCard(
          "Workout Warrior",
          "Complete 10 workouts",
        ),
      ],
    );
  }
  Widget _achievementCard(String title, String subtitle) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF6FCF7A), width: 1.2),
      ),
      child: Row(
        children: [
          const Icon(Icons.lock_outline, color: Colors.green),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
              Text(subtitle, style: const TextStyle(fontSize: 12)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _insightHint() {
    return Container(
      margin: const EdgeInsets.only(top: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.green.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: const [
          Icon(Icons.lightbulb_outline, color: Colors.green),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              "Start logging meals and workouts to unlock AI insights",
              style: TextStyle(fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  // ================= WEEK CARD =================
  Widget _weekCard() {

    // Match backend order
    List<String> days = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"];

    return _smallCard(
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "This Week",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          for (var d in days)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Row(
                children: [
                  Text(d),
                  const Spacer(),
                  Text("${weeklyCalories[d] ?? 0} kcal"), // ✅ USE MAP
                ],
              ),
            ),
        ],
      ),
    );
  }

  // ================= MACROS CARD =================
  Widget _macrosCard() {
    return _smallCard(
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Macros",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),

          _macroLine("Protein", protein),

          _macroLine("Carbs", carbs),
          _macroSubLine("Fiber", fiber),
          _macroSubLine("Sugar", sugar),

          _macroLine("Fats", fat),
          _macroSubLine("Saturated fats", saturatedFats),
        ],
      ),
    );
  }
  Widget _macroSubLine(String label, int value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          const SizedBox(width: 14), // indentation
          Text(
            label,
            style: TextStyle(fontSize: 13, color: Theme.of(context).textTheme.bodyMedium!.color),
          ),
          const Spacer(),
          Text(
            "$value g",
            style: TextStyle(fontSize: 13, color: Theme.of(context).textTheme.bodyMedium!.color),
          ),
        ],
      ),
    );
  }

  // ================= HELPERS =================
  Widget _smallCard(Widget child) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFF6FCF7A),
          width: 1.2,
        ),
      ),
      child: child,
    );
  }

  Widget _macroLine(String label, int value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Text(label),
          const Spacer(),
          Text("$value g"),
        ],
      ),
    );
  }

  // ================= BUILD =================
  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFEDEDED),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Scaffold(
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            body: SafeArea(
              child: Column(
                children: [

                  // SCROLLABLE CONTENT
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.only(bottom: 120),
                      child: Column(
                        children: [
                          _header(),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                            child: Column(
                              children: [
                                Transform.translate(
                                  offset: const Offset(0, 15),
                                  child: _dailyGoalCard(),
                                ),
                                const SizedBox(height: 40),
                                _weekAndMacros(),
                                const SizedBox(height: 20),
                                _weeklyStats(),
                                const SizedBox(height: 20),
                                _achievements(),
                                const SizedBox(height: 10),
                                _insightHint(),
                              ],
                            ),
                          ),
                        ],
                      ),
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
}
class _StatItem extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;

  const _StatItem({
    required this.icon,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: Colors.green),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 2),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}

// ================= RING PAINTER =================
class _RingPainter extends CustomPainter {
  final double progress;

  _RingPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final stroke = 12.0;
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - stroke) / 2;

    final bgPaint = Paint()
      ..color = Colors.white.withOpacity(0.25)
      ..strokeWidth = stroke
      ..style = PaintingStyle.stroke;

    final progressPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = stroke
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, bgPaint);

    final sweepAngle = 2 * pi * progress.clamp(0.0, 1.0);

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -pi / 2,
      sweepAngle,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _RingPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }

}