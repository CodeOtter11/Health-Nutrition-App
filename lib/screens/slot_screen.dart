import 'package:flutter/material.dart';

class SlotScreen extends StatefulWidget {
  final String title;

  const SlotScreen({super.key, required this.title});

  @override
  State<SlotScreen> createState() => _SlotScreenState();
}

class _SlotScreenState extends State<SlotScreen> {
  String? selectedSlot;

  final List<String> slots = [
    "morning",
    "afternoon",
    "evening",
  ];

  String getSlotText(String slot) {
    if (slot == "morning") return "Morning";
    if (slot == "afternoon") return "Afternoon";
    return "Evening";
  }

  String getSlotTime(String slot) {
    if (slot == "morning") return "9 AM - 12 PM";
    if (slot == "afternoon") return "1 PM - 5 PM";
    return "6 PM - 9 PM";
  }

  IconData getSlotIcon(String slot) {
    if (slot == "morning") return Icons.wb_sunny_outlined;
    if (slot == "afternoon") return Icons.wb_cloudy_outlined;
    return Icons.nightlight_round;
  }

  // ONLY UI CHANGED (LOGIC SAME)
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,

      body: Column(
        children: [

          // HEADER
          Container(
            padding: const EdgeInsets.only(
                top: 50, left: 16, right: 16, bottom: 20),
            decoration: BoxDecoration(
              color: isDark
                  ? const Color(0xFF2E7D32)
                  : const Color(0xFFA5D6A7),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(25),
                bottomRight: Radius.circular(25),
              ),
            ),
            child: Row(
              children: [
                Text(
                  widget.title,
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),

          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [

                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: theme.cardColor,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Column(
                      children: slots.map((slot) {
                        final selected = selectedSlot == slot;

                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              selectedSlot = slot;
                            });
                          },
                          child: Container(
                            margin:
                            const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: selected
                                  ? const Color(0xff4CAF50)
                                  : theme.cardColor,
                              borderRadius:
                              BorderRadius.circular(14),
                            ),
                            child: Row(
                              children: [
                                Icon(getSlotIcon(slot)),
                                const SizedBox(width: 10),
                                Text(getSlotText(slot)),
                                const Spacer(),
                                Icon(selected
                                    ? Icons.radio_button_checked
                                    : Icons.radio_button_off),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),

                  const Spacer(),

                  ElevatedButton(
                    onPressed: selectedSlot == null
                        ? null
                        : () {
                      Navigator.pop(context, selectedSlot);
                    },
                    child: const Text("Continue"),
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}