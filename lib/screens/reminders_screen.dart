import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/reminder.dart';
import '../services/reminder_service.dart';
import '../services/notification_service.dart';

class RemindersScreen extends StatefulWidget {
  const RemindersScreen({super.key});

  @override
  State<RemindersScreen> createState() => _RemindersScreenState();
}

class _RemindersScreenState extends State<RemindersScreen> {
  static const Color _green = Color(0xFF22C55E);
  static const Color _bgLight = Color(0xFFF3F4F6);

  List<Reminder> reminders = [];

  @override
  void initState() {
    super.initState();
    _initReminders();
  }

  Future<void> _initReminders() async {
    await _loadReminders();
    await _rescheduleAllReminders();
  }

  Future<void> _rescheduleAllReminders() async {
    for (var r in reminders) {
      if (!r.enabled) continue;

      final now = DateTime.now();

      final scheduledTime = DateTime(
        now.year,
        now.month,
        now.day,
        r.time ~/ 60,
        r.time % 60,
      );

      final finalTime = scheduledTime.isBefore(now)
          ? scheduledTime.add(Duration(days: 1))
          : scheduledTime;

      await NotificationService.scheduleNotification(
        id: int.parse(r.id),
        title: r.title,
        body: "Reminder: ${r.title}",
        scheduledTime: finalTime,
      );
    }

    print("🔁 All reminders rescheduled after restart");
  }

  Future<void> _loadReminders() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString('reminders');

    if (data != null) {
      final List<dynamic> decoded = jsonDecode(data);
      setState(() {
        reminders = decoded
            .map((e) => Reminder.fromJson(e as Map<String, dynamic>))
            .toList();
      });
    }
  }

  Future<void> _saveReminders() async {
    final prefs = await SharedPreferences.getInstance();
    final data =
    jsonEncode(reminders.map((e) => e.toJson()).toList());
    await prefs.setString('reminders', data);
  }

  String _formatTime(int minutes) {
    final hour = minutes ~/ 60;
    final minute = minutes % 60;
    return TimeOfDay(hour: hour, minute: minute).format(context);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bool isDark = theme.brightness == Brightness.dark;

    const Color _lightHeader = Color(0xFFB9F2C8);
    const Color _darkHeader = Color(0xFF1F3D2B);

    final Color mainHeaderColor =
    isDark ? _darkHeader : _lightHeader;

    final Color lightCurve =
    isDark ? _darkHeader.withOpacity(0.7) : const Color(0xFF77C192);

    final Color darkCurve =
    isDark ? _darkHeader : const Color(0xFF56B278);

    return Scaffold(
      backgroundColor: isDark ? Colors.black : _bgLight,
      body: Stack(
        children: [

          /// ================= TOP CURVES =================

          Container(
            height: 260,
            child: Stack(
              children: [

                /// LIGHT CURVE (background)
                Positioned(
                  top: -166,
                  left: -75,
                  right:-20,
                  child: Container(
                    height: 380,
                    decoration: BoxDecoration(
                      color: lightCurve,
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(600),
                        bottomRight: Radius.circular(520),
                      ),
                    ),
                  ),
                ),

                /// DARK CURVE
                Positioned(
                  top: -250,
                  left: -30,
                  right: -160,
                  child: Container(
                    height: 400,
                    decoration: BoxDecoration(
                      color: darkCurve,
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(1000),
                        bottomRight: Radius.circular(1300),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          /// ================= CONTENT =================
          SafeArea(
            child: Column(
              children: [

                /// HEADER TEXT
                Padding(
                  padding:
                  const EdgeInsets.fromLTRB(16, 40, 16, 0),
                  child: Row(
                    children: [
                      IconButton(
                        padding: EdgeInsets.zero,
                        icon: Icon(
                          Icons.arrow_back,
                          color: isDark
                              ? Colors.white
                              : Colors.black,
                        ),
                        onPressed: () =>
                            Navigator.pop(context),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        "Reminders",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: isDark
                              ? Colors.white
                              : Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 30),

                Padding(
                  padding:
                  const EdgeInsets.fromLTRB(
                      20, 60, 20, 20),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Active Reminders",
                      style: theme.textTheme.titleSmall
                          ?.copyWith(
                          fontWeight:
                          FontWeight.w600),
                    ),
                  ),
                ),

                const SizedBox(height: 14),

                Expanded(
                  child: Padding(
                    padding:
                    const EdgeInsets.symmetric(horizontal: 20),
                    child: ListView.builder(
                      itemCount: reminders.length,
                      itemBuilder: (_, i) =>
                          _reminderTile(reminders[i]),
                    ),
                  ),
                ),

                Padding(
                  padding:
                  const EdgeInsets.fromLTRB(20, 0, 20, 20),
                  child: SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _green,
                        shape: RoundedRectangleBorder(
                          borderRadius:
                          BorderRadius.circular(20),
                        ),
                      ),
                      onPressed: () =>
                          _openReminderSheet(),
                      child:
                      const Text("Add Reminder"),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _openReminderSheet({Reminder? reminder}) {
    final titleController =
    TextEditingController(text: reminder?.title ?? "");
    TimeOfDay selectedTime = reminder != null
        ? TimeOfDay(hour: reminder.time ~/ 60, minute: reminder.time % 60)
        : TimeOfDay.now();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius:
        BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (ctx) {
        final theme = Theme.of(ctx);

        return Padding(
          padding: EdgeInsets.fromLTRB(
            20,
            20,
            20,
            MediaQuery.of(ctx).viewInsets.bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                reminder == null
                    ? "Add Reminder"
                    : "Edit Reminder",
                style: theme.textTheme.titleMedium
                    ?.copyWith(
                    fontWeight:
                    FontWeight.bold),
              ),
              const SizedBox(height: 20),

              TextField(
                controller: titleController,
                decoration: InputDecoration(
                  hintText: "Reminder title",
                  filled: true,
                  fillColor: theme.brightness ==
                      Brightness.dark
                      ? Colors.grey[800]
                      : _bgLight,
                  border: OutlineInputBorder(
                    borderRadius:
                    BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              GestureDetector(
                onTap: () async {
                  final picked =
                  await showTimePicker(
                    context: context,
                    initialTime: selectedTime,
                  );
                  if (picked != null) {
                    selectedTime = picked;
                    (ctx as Element)
                        .markNeedsBuild();
                  }
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16),
                  decoration: BoxDecoration(
                    color: theme.brightness ==
                        Brightness.dark
                        ? Colors.grey[800]
                        : _bgLight,
                    borderRadius:
                    BorderRadius.circular(
                        14),
                  ),
                  child: Row(
                    mainAxisAlignment:
                    MainAxisAlignment
                        .spaceBetween,
                    children: [
                      Text(selectedTime
                          .format(context)),
                      const Icon(
                          Icons.access_time),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton
                      .styleFrom(
                    backgroundColor:
                    _green,
                    shape:
                    RoundedRectangleBorder(
                      borderRadius:
                      BorderRadius
                          .circular(
                          16),
                    ),
                  ),
                  onPressed: () async {
                    if (titleController.text
                        .trim()
                        .isEmpty) return;

                    final minutes =
                        selectedTime.hour *
                            60 +
                            selectedTime
                                .minute;

                    setState(() {
                      if (reminder ==
                          null) {
                        reminders.add(
                          Reminder(
                            id: DateTime
                                .now()
                                .millisecondsSinceEpoch
                                .toString(),
                            title:
                            titleController
                                .text
                                .trim(),
                            time:
                            minutes,
                          ),
                        );
                      } else {
                        reminder.title =
                            titleController
                                .text
                                .trim();
                        reminder.time =
                            minutes;
                      }
                    });

                    final reminderObj = reminder ?? reminders.last;

                    final now = DateTime.now();

                    final scheduledTime = DateTime(
                      now.year,
                      now.month,
                      now.day,
                      selectedTime.hour,
                      selectedTime.minute,
                    );

                    final finalTime = scheduledTime.isBefore(now)
                        ? scheduledTime.add(Duration(days: 1))
                        : scheduledTime;

                    // ✅ ADD THIS
                    await NotificationService.cancelNotification(int.parse(reminderObj.id));

                    await NotificationService.scheduleNotification(
                      id: int.parse(reminderObj.id),
                      title: reminderObj.title,
                      body: "Reminder: ${reminderObj.title}",
                      scheduledTime: finalTime,
                    );

                    await _saveReminders();

                    print("✅ Reminder scheduled: ${reminderObj.title}");

                    Navigator.pop(context);
                  },
                  child:
                  const Text("Save"),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _reminderTile(Reminder r) {
    final theme = Theme.of(context);

    return Container(
      margin:
      const EdgeInsets.only(bottom: 16),
      padding:
      const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius:
        BorderRadius.circular(18),
        boxShadow:
        theme.brightness ==
            Brightness.light
            ? [
          BoxShadow(
            color: Colors.black
                .withOpacity(
                0.05),
            blurRadius: 12,
            offset:
            const Offset(
                0, 6),
          ),
        ]
            : [],
      ),
      child: Row(
        children: [
          Container(
            height: 42,
            width: 42,
            decoration: BoxDecoration(
              color: _green
                  .withOpacity(0.15),
              borderRadius:
              BorderRadius.circular(
                  12),
            ),
            child: const Icon(
              LucideIcons.bell,
              color: _green,
              size: 20,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment
                  .start,
              children: [
                Text(
                  r.title,
                  style: theme
                      .textTheme
                      .bodyLarge
                      ?.copyWith(
                      fontWeight:
                      FontWeight
                          .w600),
                ),
                const SizedBox(
                    height: 4),
                Text(
                  _formatTime(
                      r.time),
                  style: theme
                      .textTheme
                      .bodySmall,
                ),
                const Text(
                  "Everyday",
                  style: TextStyle(
                      fontSize: 12,
                      color:
                      Colors.grey),
                ),
              ],
            ),
          ),
          Switch(
            value: r.enabled,
            activeColor: _green,
            onChanged: (v) async {
              setState(() => r.enabled = v);

              if (v) {
                await NotificationService.cancelNotification(int.parse(r.id)); // prevent duplicate
                final now = DateTime.now();

                final scheduledTime = DateTime(
                  now.year,
                  now.month,
                  now.day,
                  r.time ~/ 60,
                  r.time % 60,
                );

                final finalTime = scheduledTime.isBefore(now)
                    ? scheduledTime.add(Duration(days: 1))
                    : scheduledTime;

                await NotificationService.scheduleNotification(
                  id: int.parse(r.id),
                  title: r.title,
                  body: "Reminder: ${r.title}",
                  scheduledTime: finalTime,
                );

                print("🔔 Enabled & scheduled");
              } else {
                await NotificationService.cancelNotification(int.parse(r.id));
                print("❌ Notification cancelled");
              }

              _saveReminders();
            },
          ),
        ],
      ),
    );
  }
}