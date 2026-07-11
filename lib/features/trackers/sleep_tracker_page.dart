import 'package:flutter/material.dart';
import 'package:meal_plan/widgets/mobile_scaffold.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:meal_plan/services/sleep_service.dart';

class SleepTrackerPage extends StatefulWidget {
  const SleepTrackerPage({super.key});

  @override
  State<SleepTrackerPage> createState() => _SleepTrackerPageState();


}

class _SleepTrackerPageState extends State<SleepTrackerPage> {
  DateTime? sleepTime;
  DateTime? wakeTime;

  Map<String, double> weeklySleep = {
    "Sun": 0,
    "Mon": 0,
    "Tue": 0,
    "Wed": 0,
    "Thu": 0,
    "Fri": 0,
    "Sat": 0,
  };

  Future<void> _loadWeeklySleep() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString("userId");

    if (userId == null) return;

    final data = await SleepService.loadWeeklySleep(userId: userId);
    print("WEEKLY DATA: $data");
    setState(() {
      weeklySleep = Map<String, double>.from(data); // 🔥 IMPORTANT FIX
    });
  }
  @override
  void initState() {
    super.initState();
    _loadSleep();
    _loadWeeklySleep();
  }

  final Color primaryGreen = const Color(0xFF4CAF50);
  final Color softGreen = const Color(0xFFE8F5E9);

  Duration get sleepDuration {
    if (sleepTime == null || wakeTime == null) return Duration.zero;
    return wakeTime!.difference(sleepTime!);
  }

  double get sleepHours => sleepDuration.inMinutes / 60;

  String get sleepQuality {
    if (sleepHours >= 7) return "Good";
    if (sleepHours >= 5) return "Fair";
    return "Poor";
  }

  void _openLogSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => _SleepLogSheet(
          onSave: (sleep, wake) async {

            final newSleepHours =
                wake.difference(sleep).inMinutes / 60;

            final prefs = await SharedPreferences.getInstance();
            final userId = prefs.getString("userId");

            if (userId == null) return;

            final today =
            DateTime.now().toIso8601String().split('T')[0];

            await SleepService.saveSleep(
              userId: userId,
              sleepHours: newSleepHours,
              date: today,
            );

            // 🔥 UPDATE UI IMMEDIATELY FIRST
            setState(() {
              sleepTime = sleep;
              wakeTime = wake;
            });

            // 🔥 THEN reload backend data
            await _loadSleep();
            await _loadWeeklySleep();
          }
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final h = sleepDuration.inHours;
    final m = sleepDuration.inMinutes.remainder(60);
    final progress = (sleepHours / 8).clamp(0.0, 1.0);

    return MobileScaffold(
      title: 'Sleep Tracker',
      subtitle: 'Improve your sleep quality',
      body: SingleChildScrollView(
        child: Column(
          children: [
            _summaryCard(h, m, progress),
            const SizedBox(height: 22),
            _logButton(),
            const SizedBox(height: 22),
            _weeklySleepCard(),
            const SizedBox(height: 18),
            _tipCard(),
          ],
        ),
      ),
    );
  }

  // ================= SUMMARY =================
  Widget _summaryCard(int h, int m, double progress) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [primaryGreen, primaryGreen.withOpacity(0.85)],
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.25),
            blurRadius: 8,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Last Night Sleep",
            style: TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            "$h h $m m",
            style: const TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              _badge("Quality: $sleepQuality"),
              const SizedBox(width: 8),
              _badge("Goal: 8h"),
            ],
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: Colors.white30,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _badge(String text) {
    return Container(
      padding:
      const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white24,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: const TextStyle(color: Colors.white),
      ),
    );
  }

  // ================= LOG BUTTON =================
  Widget _logButton() {
    return SizedBox(
      width: 220,
      child: ElevatedButton(
        onPressed: _openLogSheet,
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryGreen,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 6,
          shadowColor: Colors.black45,
        ),
        child: const Text(
          "+ Log Sleep",
          style: TextStyle(
            fontSize: 16,
            color: Colors.black,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  // ================= WEEKLY =================
  Widget _weeklySleepCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: primaryGreen),
        borderRadius: BorderRadius.circular(18),
        color: Theme.of(context).cardColor,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Weekly Sleep",
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 20),

          SizedBox(
            height: 120, // 🔥 FIX HEIGHT AREA
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: ["Sun","Mon","Tue","Wed","Thu","Fri","Sat"].map((day) {
                final hours = weeklySleep[day] ?? 0;

                double barHeight = (hours / 8) * 100;

                if (hours == 0) barHeight = 5;

                return Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [

                    Text("${hours.toStringAsFixed(1)}h",
                        style: const TextStyle(fontSize: 10)),

                    const SizedBox(height: 6),

                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      width: 16,
                      height: barHeight,
                      decoration: BoxDecoration(
                        color: primaryGreen,
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),

                    const SizedBox(height: 6),

                    Text(day, style: const TextStyle(fontSize: 10)),
                  ],
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  // ================= TIP =================
  Widget _tipCard() {
    final isDark =
        Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark
            ? Theme.of(context).cardColor
            : softGreen,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Icon(Icons.lightbulb, color: primaryGreen),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              "Going to bed at the same time improves sleep quality.",
            ),
          ),
        ],
      ),
    );
  }
  Future<void> _saveSleep() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString("userId");

    if (userId == null) return;

    final today = DateTime.now().toString().split(' ')[0];

    await SleepService.saveSleep(
      userId: userId,
      sleepHours: sleepHours,
      date: today,
    );
  }

  Future<void> _loadSleep() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString("userId");

    if (userId == null) return;

    final value = await SleepService.loadSleep(userId: userId);

    setState(() {
      final now = DateTime.now();

      sleepTime = now;
      wakeTime = now.add(
        Duration(minutes: (value * 60).toInt()),
      );
    });
  }
}

class _SleepLogSheet extends StatefulWidget {
  final Function(DateTime, DateTime) onSave;

  const _SleepLogSheet({required this.onSave});

  @override
  State<_SleepLogSheet> createState() => _SleepLogSheetState();
}

class _SleepLogSheetState extends State<_SleepLogSheet> {
  DateTime? sleep;
  DateTime? wake;

  Future<void> _pickTime(bool isSleep) async {
    final now = DateTime.now();

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (time == null) return;

    final selected = DateTime(
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
    );

    setState(() {
      if (isSleep) {
        sleep = selected;
      } else {
        wake = selected;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius:
        const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 20,
          bottom:
          MediaQuery.of(context).viewInsets.bottom + 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment:
          CrossAxisAlignment.start,
          children: [
            Text(
              "Log Sleep",
              style:
              Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 20),

            ListTile(
              title: const Text("Bed Time"),
              trailing: Text(
                sleep == null
                    ? "--:--"
                    : TimeOfDay.fromDateTime(sleep!)
                    .format(context),
              ),
              onTap: () => _pickTime(true),
            ),

            ListTile(
              title: const Text("Wake Time"),
              trailing: Text(
                wake == null
                    ? "--:--"
                    : TimeOfDay.fromDateTime(wake!)
                    .format(context),
              ),
              onTap: () => _pickTime(false),
            ),

            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed:
                (sleep != null && wake != null)
                    ? () {
                  widget.onSave(
                      sleep!, wake!);
                  Navigator.pop(context);
                }
                    : null,
                child: const Text("Save"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
