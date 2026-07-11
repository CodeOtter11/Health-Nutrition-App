import 'package:flutter/material.dart';
import 'features/trackers/bmi_calculator_page.dart';
import 'features/trackers/sleep_tracker_page.dart';
import 'features/trackers/water_tracker_page.dart';
import 'features/trackers/steps_tracker_page.dart';
import 'features/trackers/heart_rate_page.dart';

class AllTrackersPage extends StatelessWidget {
  const AllTrackersPage({super.key});

  static const Color green = Color(0xFF22C55E);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,

      // -------- HEADER --------
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Row(
              children: [
                IconButton(
                  icon: Icon(Icons.arrow_back, color: theme.iconTheme.color),
                  onPressed: () => Navigator.pop(context),
                ),
                const SizedBox(width: 4),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'All Trackers',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      'Track your health metrics',
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),

      // -------- BODY --------
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _summaryCard(context),
                const SizedBox(height: 20),

                _trackerCard(
                  context: context,
                  icon: Icons.monitor_weight,
                  title: 'BMI Calculator',
                  subtitle:
                  'Check your body mass index and get health insights',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const BMICalculatorPage(),
                      ),
                    );
                  },
                ),



                _trackerCard(
                  context: context,
                  icon: Icons.favorite_border,
                  title: 'Heart Rate',
                  subtitle: 'Monitor your heart rate and track patterns',
                  smartwatch: true,
                  connectText: 'Connect Device',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const HeartRatePage(),
                      ),
                    );
                  },
                ),

                _trackerCard(
                  context: context,
                  icon: Icons.nightlight_round,
                  title: 'Sleep Tracker',
                  subtitle: 'Track your sleep duration and quality',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const SleepTrackerPage(),
                      ),
                    );
                  },
                ),

                _trackerCard(
                  context: context,
                  icon: Icons.water_drop,
                  title: 'Water Tracker',
                  subtitle: 'Monitor your daily hydration',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const WaterTrackerPage(),
                      ),
                    );
                  },
                ),

                _trackerCard(
                  context: context,
                  icon: Icons.directions_walk,
                  title: 'Steps Tracker',
                  subtitle: 'Track your daily steps',
                  smartwatch: true,
                  connectText: 'Connect Device',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const StepsTrackerPage(),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// TRACKER CARD
// ---------------------------------------------------------------------------
Widget _trackerCard({
  required BuildContext context,
  required IconData icon,
  required String title,
  required String subtitle,
  bool smartwatch = false,
  String? connectText,
  required VoidCallback onTap,
}) {
  final theme = Theme.of(context);

  return GestureDetector(
    onTap: onTap,
    child: Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: theme.dividerColor.withOpacity(0.15),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: const Color(0xFF22C55E).withOpacity(0.14),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  icon,
                  color: const Color(0xFF22C55E),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              if (smartwatch)
                Container(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF22C55E).withOpacity(0.14),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'Smartwatch',
                    style: TextStyle(
                      fontSize: 11,
                      color: Color(0xFF22C55E),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            subtitle,
            style: theme.textTheme.bodySmall,
          ),
          if (connectText != null) ...[
            const SizedBox(height: 12),
            const Divider(),
            Text(
              connectText,
              style: const TextStyle(
                color: Color(0xFF22C55E),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ],
      ),
    ),
  );
}

// ---------------------------------------------------------------------------
// SUMMARY CARD
// ---------------------------------------------------------------------------
Widget _summaryCard(BuildContext context) {
  final theme = Theme.of(context);
  final isDark = theme.brightness == Brightness.dark;

  return Container(
    width: double.infinity,
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(18),
      gradient: isDark
          ? null
          : const LinearGradient(
        colors: [
          Color(0xFFE8FFF3),
          Color(0xFFF3FFFA),
        ],
      ),
      color: isDark ? theme.cardColor : null,
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Available Trackers',
          style: TextStyle(
            color: Color(0xFF22C55E),
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          '5 Health Metrics',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Track everything in one place',
          style: theme.textTheme.bodySmall,
        ),
      ],
    ),
  );
}
