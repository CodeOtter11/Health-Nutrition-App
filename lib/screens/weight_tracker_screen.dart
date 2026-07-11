import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:lucide_icons/lucide_icons.dart';

class WeightTrackerScreen extends StatefulWidget {
  const WeightTrackerScreen({super.key});

  @override
  State<WeightTrackerScreen> createState() => _WeightTrackerScreenState();
}

class _WeightTrackerScreenState extends State<WeightTrackerScreen> {
  List<Map<String, dynamic>> _logs = [];
  double? _goalWeight;
  String _unit = 'kg';

  @override
  void initState() {
    super.initState();
    _loadLogs();
  }

  Future<void> _loadLogs() async {
    final prefs = await SharedPreferences.getInstance();
    final rawLogs = prefs.getStringList('weight_logs') ?? [];
    _goalWeight = prefs.getDouble('goal_weight');
    _unit = prefs.getString('unit') ?? 'kg';

    // Parse logs safely
    final List<Map<String, dynamic>> parsedLogs = [];

    for (final log in rawLogs) {
      final parts = log.split(':');
      if (parts.length != 2) continue;

      final date = DateTime.tryParse(parts[0]);
      final weightKg = double.tryParse(parts[1]);

      if (date == null || weightKg == null) continue;

      final weight = _unit == 'kg' ? weightKg : weightKg / 0.453592;

      parsedLogs.add({'date': date, 'weight': weight});
    }

    // Sort newest first (most recent on top)
    parsedLogs.sort((a, b) {
      final dateA = a['date'] as DateTime;
      final dateB = b['date'] as DateTime;
      return dateB.compareTo(dateA);
    });

    if (mounted) {
      setState(() {
        _logs = parsedLogs;
      });
    }
  }

  double get _averageWeight => _logs.isEmpty
      ? 0
      : _logs.map((e) => e['weight'] as double).reduce((a, b) => a + b) / _logs.length;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Weight Tracker'),
        backgroundColor: Colors.purple.shade50,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Summary
            Card(
              color: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Goal: ${_goalWeight?.toStringAsFixed(1) ?? "--"} $_unit'),
                    const SizedBox(height: 8),
                    Text('Average: ${_averageWeight.toStringAsFixed(1)} $_unit'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Chart
            if (_logs.isNotEmpty)
              SizedBox(
                height: 200,
                child: LineChart(
                  LineChartData(
                    gridData: const FlGridData(show: false),
                    titlesData: const FlTitlesData(show: false),
                    borderData: FlBorderData(show: false),
                    lineBarsData: [
                      LineChartBarData(
                        spots: _logs.reversed.toList().asMap().entries.map((entry) {
                          final index = entry.key.toDouble();
                          final log = entry.value;
                          return FlSpot(index, log['weight'] as double);
                        }).toList(),
                        isCurved: true,
                        color: Colors.purple,
                        dotData: const FlDotData(show: false),
                        belowBarData: BarAreaData(show: false),
                      ),
                    ],
                  ),
                ),
              )
            else
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: Text(
                    'No weight data yet',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ),
              ),
            const SizedBox(height: 24),

            // History list
            Expanded(
              child: _logs.isEmpty
                  ? const Center(child: Text('Log your first weight to see history'))
                  : ListView.builder(
                itemCount: _logs.length,
                itemBuilder: (context, index) {
                  final log = _logs[index];
                  return ListTile(
                    leading: const Icon(LucideIcons.scale, color: Colors.purple),
                    title: Text('${(log['weight'] as double).toStringAsFixed(1)} $_unit'),
                    subtitle: Text(DateFormat('MMM dd, yyyy').format(log['date'] as DateTime)),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}