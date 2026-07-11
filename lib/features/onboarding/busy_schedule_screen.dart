import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:meal_plan/features/onboarding/habit_selection_screen.dart';
import 'package:meal_plan/models/user_profile_data.dart';
import 'package:meal_plan/widgets/primary_next_button.dart';


class BusyScheduleScreen extends StatefulWidget {
  final UserProfileData profile;

  const BusyScheduleScreen({
    super.key,
    required this.profile,
  });

  @override
  State<BusyScheduleScreen> createState() =>
      _BusyScheduleScreenState();
}

class _BusyScheduleScreenState
    extends State<BusyScheduleScreen> {
  String? _selectedOption;

  final List<String> _options = [
    'I barely have any time for myself',
    'I\'m busy but try to reserve some time each day to relax',
    'I\'m not too busy and keep time for different things',
    'My schedule is fairly open and flexible',
  ];

  @override
  Widget build(BuildContext context) {
    const green = Color(0xFF49B675);
    const lightGreen = Color(0xFFE6F7EC);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: 24),
              child: Column(
                children: [
                  const SizedBox(height: 16),

                  // Back button
                  Row(
                    children: [
                      IconButton(
                        onPressed: () =>
                            Navigator.pop(context),
                        icon:
                        const Icon(Icons.arrow_back),
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  // Leaf icon
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: lightGreen,
                    child: const Icon(
                      LucideIcons.leaf,
                      color: green,
                      size: 28,
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Progress dots
                  Row(
                    mainAxisAlignment:
                    MainAxisAlignment.center,
                    children: List.generate(
                      7,
                          (index) => Container(
                        margin:
                        const EdgeInsets.symmetric(
                            horizontal: 3),
                        width: 7,
                        height: 7,
                        decoration: BoxDecoration(
                          color: index == 3
                              ? green
                              : Colors.grey.shade300,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 22),

                  const Text(
                    'How busy are you\non an average day?',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Options
                  for (final option in _options) ...[
                    _optionTile(option),
                    const SizedBox(height: 12),
                  ],

                  const Spacer(),

                  // Next button
                  Center(
                    child: PrimaryNextButton(
                      onPressed: () {
                        widget.profile.activityLevel = _selectedOption;

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                HabitSelectionScreen(profile: widget.profile),
                          ),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ---------------- OPTION TILE ----------------

  Widget _optionTile(String text) {
    const green = Color(0xFF49B675);
    const lightGreen = Color(0xFFE6F7EC);

    final bool selected = _selectedOption == text;

    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: () {
        setState(() {
          _selectedOption = text;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: selected ? lightGreen : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected
                ? green
                : Colors.grey.shade300,
          ),
          boxShadow: [
            BoxShadow(
              color: green.withOpacity(0.18),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(
              selected
                  ? Icons.check_circle
                  : Icons.radio_button_unchecked,
              color:
              selected ? green : Colors.grey,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                text,
                style:
                const TextStyle(fontSize: 14),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
