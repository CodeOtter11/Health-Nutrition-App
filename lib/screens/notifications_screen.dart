import 'package:flutter/material.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  static const Color _green = Color(0xFF22C55E);
  static const Color _lightHeader = Color(0xFFB9F2C8);
  static const Color _darkHeader = Color(0xFF1F3D2B);
  static const Color _bgLight = Color(0xFFF3F4F6);

  bool pushNotifications = true;
  bool emailNotifications = false;
  bool goalReminders = true;
  bool dailySummary = true;
  bool weeklyReport = false;
  bool achievements = true;
  bool friendActivity = false;
  bool promotions = false;

  Widget _notificationTile({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: theme.dividerColor.withOpacity(0.3),
        ),
        boxShadow: theme.brightness == Brightness.light
            ? [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ]
            : [],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: _green,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: Colors.white,
            activeTrackColor: _green,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final bool isDark = theme.brightness == Brightness.dark;

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

          // ================= TOP CURVES =================

          /// LIGHT CURVE (background)
          Positioned(
            top: -120,
            left: -10,
            right: -50,
            child: Container(
              height: 300,
              decoration: BoxDecoration(
                color: lightCurve,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(300),
                  bottomRight: Radius.circular(520),
                ),
              ),
            ),
          ),

          /// DARK CURVE
          Positioned(
            top: -250,
            left: 10,
            right: -100,
            child: Container(
              height: 380,
              decoration: BoxDecoration(
                color: darkCurve,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(1000),
                  bottomRight: Radius.circular(1300),
                ),
              ),
            ),
          ),

          // ================= CONTENT =================
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding:
                  const EdgeInsets.fromLTRB(16, 50, 16, 0),
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
                        "Notifications",
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

                const SizedBox(height: 40),

                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(
                        20, 60, 20, 20),
                    child: Column(
                      crossAxisAlignment:
                      CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Notification preferences",
                          style: theme.textTheme.titleMedium
                              ?.copyWith(
                            fontWeight:
                            FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 18),

                        _notificationTile(
                          title:
                          "Push Notifications",
                          subtitle:
                          "Receive notifications on your device",
                          value:
                          pushNotifications,
                          onChanged: (v) =>
                              setState(() =>
                              pushNotifications =
                                  v),
                        ),
                        _notificationTile(
                          title:
                          "Email Notifications",
                          subtitle:
                          "Get updates via email",
                          value:
                          emailNotifications,
                          onChanged: (v) =>
                              setState(() =>
                              emailNotifications =
                                  v),
                        ),
                        _notificationTile(
                          title: "Goal Reminders",
                          subtitle:
                          "Remind me about my daily goals",
                          value:
                          goalReminders,
                          onChanged: (v) =>
                              setState(() =>
                              goalReminders =
                                  v),
                        ),
                        _notificationTile(
                          title: "Daily Summary",
                          subtitle:
                          "Receive daily progress summary",
                          value:
                          dailySummary,
                          onChanged: (v) =>
                              setState(() =>
                              dailySummary =
                                  v),
                        ),
                        _notificationTile(
                          title: "Weekly Report",
                          subtitle:
                          "Get weekly achievements reports",
                          value:
                          weeklyReport,
                          onChanged: (v) =>
                              setState(() =>
                              weeklyReport =
                                  v),
                        ),
                        _notificationTile(
                          title: "Achievements",
                          subtitle:
                          "Notify when I earn badges",
                          value:
                          achievements,
                          onChanged: (v) =>
                              setState(() =>
                              achievements =
                                  v),
                        ),
                        _notificationTile(
                          title:
                          "Friend Activity",
                          subtitle:
                          "Updates about friends' progress",
                          value:
                          friendActivity,
                          onChanged: (v) =>
                              setState(() =>
                              friendActivity =
                                  v),
                        ),
                        _notificationTile(
                          title:
                          "Promotions & Offers",
                          subtitle:
                          "Special offers and updates",
                          value:
                          promotions,
                          onChanged: (v) =>
                              setState(() =>
                              promotions = v),
                        ),
                      ],
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
}