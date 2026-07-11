import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../services/weight_service.dart';

enum GoalType { lose, gain, maintain }

class WeightEntry {
  final double weight;
  final DateTime date;

  WeightEntry(this.weight, this.date);
}

class LogWeightScreen extends StatefulWidget {
  const LogWeightScreen({super.key});

  @override
  State<LogWeightScreen> createState() => _LogWeightScreenState();
}

class _LogWeightScreenState extends State<LogWeightScreen> {

  bool setupDone = false;
  double? startWeight;
  double? goalWeight;
  GoalType? goalType;

  // ✅ EMPTY LIST (NO RANDOM DATA)
  final List<WeightEntry> weightHistory = [];

  // ✅ PROPER CHANGE CALCULATION
  double get weightChange {
    if (weightHistory.length < 2) return 0.0;
    return weightHistory.last.weight -
        weightHistory[weightHistory.length - 2].weight;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffECECEC),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 380),
            child: setupDone ? _buildLogUI() : _buildSetupUI(),
          ),
        ),
      ),
    );
  }
  @override
  void initState() {
    super.initState();
    loadWeightData();
  }

  // ================= HEADER =================

  Widget _roundedHeader(String title) {
    return Container(
      height: 180,
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Color(0xffA8E6BE),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(60),
          bottomRight: Radius.circular(60),
        ),
        boxShadow: [
          BoxShadow(
            blurRadius: 8,
            color: Colors.black26,
            offset: Offset(0, 4),
          )
        ],
      ),
      padding: const EdgeInsets.only(left: 16, top: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: () {
              if (setupDone) {
                setState(() => setupDone = false);
              } else {
                Navigator.pop(context);
              }
            },
            child: const Icon(Icons.arrow_back, size: 28),
          ),
          const SizedBox(height: 18),
          Text(
            title,
            style: const TextStyle(
                fontSize: 34, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  // ================= SETUP =================

  Widget _buildSetupUI() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _roundedHeader("Set your goal"),
          const SizedBox(height: 20),

          _input("Current weight",
                  (v) => startWeight = double.tryParse(v)),

          const SizedBox(height: 16),

          _input("Goal weight",
                  (v) => goalWeight = double.tryParse(v)),

          const SizedBox(height: 20),

          const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              "What do you want to do?",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),

          const SizedBox(height: 10),

          Row(
            children: [
              _goalButton("Lose", GoalType.lose),
              const SizedBox(width: 8),
              _goalButton("Gain", GoalType.gain),
              const SizedBox(width: 8),
              _goalButton("Maintain", GoalType.maintain),
            ],
          ),

          const Spacer(),

          SizedBox(
            width: double.infinity,
            height: 55,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xffE9E3F5),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30)),
              ),
              onPressed: () async {
                if (startWeight != null &&
                    goalWeight != null &&
                    goalType != null) {

                  final success = await WeightService.saveGoal(
                    startWeight: startWeight!,
                    goalWeight: goalWeight!,
                    goalType: goalType!.name,
                  );

                  print("SAVE GOAL SUCCESS: $success");

                  if (success) {
                    await loadWeightData();
                    setState(() => setupDone = true);
                  } else {
                    print("API FAILED ❌");
                  }
                } else {
                  print("FIELDS MISSING ❌");
                }
              },
              child: const Text(
                "Continue",
                style: TextStyle(
                    color: Colors.deepPurple,
                    fontWeight: FontWeight.bold),
              ),
            ),
          )
        ],
      ),
    );
  }

  Future<void> loadWeightData() async {
    final data = await WeightService.getWeightData();

    if (data == null) {
      debugPrint("Failed to load weight data");
      return;
    }

    final history = data["history"] ?? [];

    setState(() {
      weightHistory.clear();

      for (var item in history) {
        weightHistory.add(
          WeightEntry(
            (item["weight"] as num).toDouble(),
            DateTime.parse(item["date"]),
          ),
        );
      }

      startWeight = (data["startWeight"] as num?)?.toDouble();
      goalWeight = (data["goalWeight"] as num?)?.toDouble();

      if (data["goalType"] != null) {
        goalType = GoalType.values.firstWhere(
              (e) => e.name == data["goalType"],
        );
      }

      // 🔥 AUTO SKIP SETUP SCREEN
      setupDone = data["goalType"] != null;
    });
  }

  // ================= LOG UI =================

  Widget _buildLogUI() {
    return SingleChildScrollView(
      child: Column(
        children: [
          _roundedHeader("Log Weight"),
          const SizedBox(height: 20),
          _goalCard(),
          const SizedBox(height: 16),
          _chartCard(),
          const SizedBox(height: 16),
          _statsRow(),
          const SizedBox(height: 20),

          FloatingActionButton(
            backgroundColor: const Color(0xff49B26B),
            child: const Icon(Icons.add, size: 30),
            onPressed: _showAddWeightDialog,
          ),

          const SizedBox(height: 30),
        ],
      ),
    );
  }

  // ================= ADD WEIGHT =================

  void _showAddWeightDialog() {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Enter current weight"),
        content: TextField(
          controller: controller,
          keyboardType:
          const TextInputType.numberWithOptions(decimal: true),
          decoration: const InputDecoration(hintText: "kg"),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () async {
              final value = double.tryParse(controller.text);
              if (value != null) {
                await WeightService.addWeight(value);
                await loadWeightData();
              }
              Navigator.pop(context);
            },
            child: const Text("Save"),
          )
        ],
      ),
    );
  }

  // ================= GOAL CARD =================

  Widget _goalCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xff49B26B),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Goal: ${goalType == GoalType.lose ? "Lose weight" : goalType == GoalType.gain ? "Gain weight" : "Maintain"}",
            style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 20),
          ),
          Text(
            "Target: ${goalWeight ?? 0} Kg",
            style: const TextStyle(color: Colors.white70),
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: _progressValue(),
            backgroundColor: Colors.white,
            color: Colors.white70,
          )
        ],
      ),
    );
  }

  double _progressValue() {
    if (startWeight == null ||
        goalWeight == null ||
        weightHistory.isEmpty) return 0;

    final current = weightHistory.last.weight;

    double total;
    double progress;

    if (goalType == GoalType.lose) {
      total = (startWeight! - goalWeight!);
      if (total == 0) return 0;
      progress = (startWeight! - current) / total;
    } else if (goalType == GoalType.gain) {
      total = (goalWeight! - startWeight!);
      if (total == 0) return 0;
      progress = (current - startWeight!) / total;
    } else {
      return 1;
    }

    return progress.clamp(0, 1);
  }

  // ================= CHART =================

  Widget _chartCard() {
    if (weightHistory.length < 2) {
      return const SizedBox();
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      height: 320,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xff49B26B),
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        children: [
          Text(
            "${weightHistory.last.weight.toStringAsFixed(1)}kg",
            style: const TextStyle(
                fontSize: 52,
                color: Colors.white,
                fontWeight: FontWeight.w300),
          ),
          Expanded(
            child: LineChart(
              LineChartData(
                gridData: FlGridData(show: false),
                borderData: FlBorderData(show: false),
                titlesData: FlTitlesData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: weightHistory
                        .asMap()
                        .entries
                        .map((e) =>
                        FlSpot(e.key.toDouble(), e.value.weight))
                        .toList(),
                    isCurved: true,
                    color: Colors.white,
                    barWidth: 4,
                    dotData: FlDotData(show: true),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ================= STATS =================

  Widget _statsRow() {
    if (weightHistory.isEmpty) return const SizedBox();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _statBox(weightHistory.last.weight.toStringAsFixed(1), "Now"),
          _statBox(
            "${weightChange >= 0 ? "+" : ""}${weightChange.toStringAsFixed(1)}",
            "Change",
          ),
          _statBox("${goalWeight ?? 0}", "Target"),
        ],
      ),
    );
  }

  Widget _statBox(String value, String label) {
    return Container(
      width: 105,
      height: 90,
      decoration: BoxDecoration(
        color: const Color(0xff49B26B),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(value,
              style: const TextStyle(
                  fontSize: 24,
                  color: Colors.white,
                  fontWeight: FontWeight.bold)),
          Text(label,
              style: const TextStyle(color: Colors.white70)),
        ],
      ),
    );
  }

  Widget _goalButton(String label, GoalType type) {
    final selected = goalType == type;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => goalType = type),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: selected ? Colors.green : Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(child: Text(label)),
        ),
      ),
    );
  }

  Widget _input(String label, Function(String) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 6),
        TextField(
          keyboardType:
          const TextInputType.numberWithOptions(decimal: true),
          onChanged: onChanged,
          decoration: InputDecoration(
            hintText: "kg",
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
      ],
    );
  }
}