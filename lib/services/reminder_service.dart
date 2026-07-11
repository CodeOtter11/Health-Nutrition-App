import 'dart:async';
import 'package:flutter/material.dart';
import '../models/reminder.dart';

class ReminderService {
  static final List<Reminder> _reminders = [];
  static Timer? _timer;
  static BuildContext? _context;
  static final Set<String> _triggeredToday = {};

  /// Start checking reminders (web-safe simulation)
  static void start(BuildContext context) {
    _context = context;

    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 30), (_) {
      _checkReminders();
    });
  }

  static void stop() {
    _timer?.cancel();
  }

  static void addReminder(Reminder reminder) {
    _reminders.add(reminder);
  }

  static void toggle(Reminder reminder, bool enabled) {
    reminder.enabled = enabled;
  }

  static final Set<String> _firedToday = {};

  static void _checkReminders() {
    final now = TimeOfDay.now();
    final currentMinutes = now.hour * 60 + now.minute;

    for (final r in _reminders) {
      if (!r.enabled) continue;

      // Unique key per reminder per day
      final key = "${r.id}-${DateTime.now().day}";

      // Prevent multiple popups
      if (_firedToday.contains(key)) continue;

      // Allow ±1 minute window
      if ((currentMinutes - r.time).abs() <= 1) {
        _firedToday.add(key);
        _showAlert(r.title);
      }
    }
  }

  static void _showAlert(String title) {
    final ctx = _context;
    if (ctx == null) return;

    showDialog(
      context: ctx,
      builder: (_) => AlertDialog(
        title: const Text("⏰ Reminder"),
        content: Text(title),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }
}