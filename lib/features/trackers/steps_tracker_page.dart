import 'package:flutter/material.dart';
import 'package:meal_plan/widgets/mobile_scaffold.dart';

class StepsTrackerPage extends StatelessWidget {
  const StepsTrackerPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MobileScaffold(
      title: 'Steps Tracker',
      subtitle: 'Smartwatch required',
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _summaryCard(context),
          const SizedBox(height: 20),
          _connectButton(context),
        ],
      ),
    );
  }

  Widget _summaryCard(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark
            ? Theme.of(context).cardColor
            : const Color(0xFFE8FFF3),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Steps Tracking',
            style: Theme.of(context)
                .textTheme
                .titleSmall
                ?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Text(
            'Track your daily steps using a connected smartwatch. '
                'Once connected, your step count will appear here.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }

  Widget _connectButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          // Later: Google Fit / Health Connect
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).colorScheme.primary,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: const Text(
          'Connect Device',
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}