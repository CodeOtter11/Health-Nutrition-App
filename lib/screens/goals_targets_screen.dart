import 'package:flutter/material.dart';

class GoalsTargetsScreen extends StatefulWidget {
  const GoalsTargetsScreen({super.key});

  @override
  State<GoalsTargetsScreen> createState() =>
      _GoalsTargetsScreenState();
}

class _GoalsTargetsScreenState
    extends State<GoalsTargetsScreen> {

  static const Color _green = Color(0xFF22C55E);
  static const Color _darkHeader = Color(0xFF1F3D2B);
  static const Color _bgLight = Color(0xFFF3F4F6);

  List<Map<String, dynamic>> goals = [
    {
      "icon": Icons.directions_walk,
      "title": "Daily Steps",
      "subtitle": "10,000 Steps",
      "progress": 0.0,
    },
    {
      "icon": Icons.nightlight_round,
      "title": "Sleep Hours",
      "subtitle": "8 hrs",
      "progress": 0.0,
    },
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bool isDark = theme.brightness == Brightness.dark;

    final Color lightCurve =
    isDark ? _darkHeader.withOpacity(0.7) : const Color(0xFF77C192);

    final Color darkCurve =
    isDark ? _darkHeader : const Color(0xFF56B278);

    return Scaffold(
      backgroundColor: isDark ? Colors.black : _bgLight,
      body: Stack(
        children: [

          /// CURVE (UNCHANGED)
          Container(
            height: 200,
            child: Stack(
              children: [
                Positioned(
                  top: -100,
                  left: -40,
                  right: -30,
                  child: Container(
                    height: 301,
                    decoration: BoxDecoration(
                      color: lightCurve,
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(600),
                        bottomRight: Radius.circular(520),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: -160,
                  left: -20,
                  right: 10,
                  child: Container(
                    height: 320,
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

          /// CONTENT
          SafeArea(
            child: Column(
              children: [

                /// HEADER
                Padding(
                  padding:
                  const EdgeInsets.fromLTRB(18, 25, 18, 0),
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
                      const SizedBox(width: 10),
                      Text(
                        "Goals & Targets",
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w800,
                          color: isDark
                              ? Colors.white
                              : Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 60),

                /// BODY
                Expanded(
                  child: Center(
                    child: ConstrainedBox(
                      constraints:
                      const BoxConstraints(maxWidth: 420),
                      child: Padding(
                        padding:
                        const EdgeInsets.fromLTRB(
                            16, 50, 16, 20),
                        child: Column(
                          crossAxisAlignment:
                          CrossAxisAlignment.start,
                          children: [

                            Text(
                              "Your Goals",
                              style: theme
                                  .textTheme.labelMedium
                                  ?.copyWith(
                                letterSpacing: 0.8,
                                fontWeight:
                                FontWeight.w600,
                                fontSize: 20,
                              ),
                            ),

                            const SizedBox(height: 16),

                            /// DYNAMIC GOALS LIST
                            Expanded(
                              child: ListView.builder(
                                itemCount: goals.length,
                                itemBuilder: (context, index) {
                                  final goal = goals[index];
                                  return _goalCard(
                                    context: context,
                                    icon: goal["icon"],
                                    title: goal["title"],
                                    subtitle: goal["subtitle"],
                                    progress: goal["progress"],
                                    onDelete: () {
                                      setState(() {
                                        goals.removeAt(index);
                                      });
                                    },
                                  );
                                },
                              ),
                            ),

                            const SizedBox(height: 10),

                            /// ADD BUTTON
                            SizedBox(
                              width: double.infinity,
                              height: 54,
                              child: ElevatedButton.icon(
                                onPressed: () =>
                                    _showAddGoalSheet(context),
                                icon: const Icon(Icons.add),
                                label: const Text(
                                  "Add New Goal",
                                  style: TextStyle(
                                    fontWeight:
                                    FontWeight.w600,
                                    fontSize: 22,
                                  ),
                                ),
                                style:
                                ElevatedButton.styleFrom(
                                  backgroundColor:
                                  _green,
                                  foregroundColor:
                                  Colors.white,
                                  shape:
                                  RoundedRectangleBorder(
                                    borderRadius:
                                    BorderRadius.circular(
                                        16),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
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

  /// GOAL CARD (UNCHANGED DESIGN)
  Widget _goalCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required double progress,
    required VoidCallback onDelete,
  }) {
    final theme = Theme.of(context);

    return Container(
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
            blurRadius: 12,
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
                height: 46,
                width: 46,
                decoration: BoxDecoration(
                  color: _green.withOpacity(0.14),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: _green),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: theme.textTheme.titleSmall),
                    Text(subtitle,
                        style: theme.textTheme.bodySmall),
                  ],
                ),
              ),
              IconButton(
                onPressed: onDelete,
                icon: Icon(
                  Icons.delete_outline,
                  color: theme.iconTheme.color
                      ?.withOpacity(0.6),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          LinearProgressIndicator(
            value: progress,
            minHeight: 6,
            borderRadius: BorderRadius.circular(10),
            backgroundColor: theme.dividerColor,
            valueColor:
            const AlwaysStoppedAnimation<Color>(_green),
          ),
          const SizedBox(height: 8),
          Text("${(progress * 100).toInt()}% complete",
              style: theme.textTheme.bodySmall),
        ],
      ),
    );
  }

  /// ADD GOAL BOTTOM SHEET
  void _showAddGoalSheet(BuildContext context) {
    final theme = Theme.of(context);
    final bool isDark = theme.brightness == Brightness.dark;

    final titleController = TextEditingController();
    final targetController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor:
      isDark ? const Color(0xFF1E1E1E) : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius:
        BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) {
        return Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom:
            MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              /// TITLE
              Text(
                "Add New Goal",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color:
                  isDark ? Colors.white : Colors.black,
                ),
              ),

              const SizedBox(height: 20),

              /// GOAL TITLE FIELD
              TextField(
                controller: titleController,
                cursorColor: _green,
                style: TextStyle(
                    color:
                    isDark ? Colors.white : Colors.black),
                decoration: InputDecoration(
                  labelText: "Goal Title",
                  labelStyle: TextStyle(
                    color: isDark
                        ? Colors.white70
                        : Colors.black54,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius:
                    BorderRadius.circular(14),
                    borderSide: const BorderSide(
                      color: _green,
                      width: 1.6,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius:
                    BorderRadius.circular(14),
                    borderSide: BorderSide(
                      color: isDark
                          ? Colors.white24
                          : const Color(0xFFE5E5E5),
                    ),
                  ),
                  filled: true,
                  fillColor: isDark
                      ? const Color(0xFF2A2A2A)
                      : Colors.grey.shade100,
                ),
              ),

              const SizedBox(height: 16),

              /// TARGET FIELD
              TextField(
                controller: targetController,
                cursorColor: _green,
                style: TextStyle(
                    color:
                    isDark ? Colors.white : Colors.black),
                decoration: InputDecoration(
                  labelText: "Target (e.g. 10,000 steps)",
                  labelStyle: TextStyle(
                    color: isDark
                        ? Colors.white70
                        : Colors.black54,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius:
                    BorderRadius.circular(14),
                    borderSide: const BorderSide(
                      color: _green,
                      width: 1.6,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius:
                    BorderRadius.circular(14),
                    borderSide: BorderSide(
                      color: isDark
                          ? Colors.white24
                          : const Color(0xFFE5E5E5),
                    ),
                  ),
                  filled: true,
                  fillColor: isDark
                      ? const Color(0xFF2A2A2A)
                      : Colors.grey.shade100,
                ),
              ),

              const SizedBox(height: 24),

              /// ADD BUTTON (GREEN MATCHING PAGE)
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    if (titleController.text.isEmpty ||
                        targetController.text.isEmpty) return;

                    setState(() {
                      goals.add({
                        "icon": Icons.flag,
                        "title": titleController.text,
                        "subtitle": targetController.text,
                        "progress": 0.0,
                      });
                    });

                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _green,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius:
                      BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text(
                    "Add Goal",
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
