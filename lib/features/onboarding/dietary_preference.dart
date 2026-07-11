import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'health_condition.dart';
import 'package:meal_plan/models/user_profile_data.dart';
import 'package:meal_plan/widgets/primary_next_button.dart';


class DietaryPreferenceScreen extends StatefulWidget {
  final UserProfileData profile;

  const DietaryPreferenceScreen({
    super.key,
    required this.profile,
  });

  @override
  State<DietaryPreferenceScreen> createState() =>
      _DietaryPreferenceScreenState();
}

class _DietaryPreferenceScreenState
    extends State<DietaryPreferenceScreen> {
  String? _selected;

  final List<_DietOption> _options = const [
    _DietOption(title: 'Vegan', icon: LucideIcons.leaf),
    _DietOption(title: 'Vegetarian', icon: LucideIcons.salad),
    _DietOption(title: 'Non-Vegetarian', icon: LucideIcons.drumstick),
    _DietOption(title: 'Eggetarian', icon: LucideIcons.egg),
  ];

  @override
  Widget build(BuildContext context) {
    const green = Color(0xFF49B675);
    const lightGreen = Color(0xFFE6F7EC);

    return Scaffold(
      backgroundColor: Colors.white, // WHITE BACKGROUND
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: constraints.maxWidth < 500
                        ? constraints.maxWidth
                        : 420,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 12),
                    child: Column(
                      children: [
                        const SizedBox(height: 10),

                        // Back button
                        Row(
                          children: [
                            IconButton(
                              onPressed: () =>
                                  Navigator.pop(context),
                              icon: const Icon(Icons.arrow_back),
                            ),
                          ],
                        ),

                        const SizedBox(height: 8),

                        // Logo
                        CircleAvatar(
                          radius: 30,
                          backgroundColor: lightGreen,
                          child: const Icon(
                            LucideIcons.leaf,
                            color: green,
                            size: 32,
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
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: index == 1
                                    ? green
                                    : Colors.grey.shade300,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 24),

                        const Text(
                          "What kind of food do you prefer?",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'RobotoSlab',
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 6),
                        const Text(
                          'To build meal plans that fit you',
                          style: TextStyle(
                            fontFamily: 'RobotoSlab',
                            color: green,
                            fontSize: 13,
                          ),
                        ),

                        const SizedBox(height: 28),

                        // Options
                        for (final option in _options) ...[
                          _dietTile(option),
                          const SizedBox(height: 14),
                        ],

                        const SizedBox(height: 30),

                        // Next button
                        Center(
                          child: PrimaryNextButton(
                            onPressed: () {
                              widget.profile.dietType = _selected!;
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      HealthConditionScreen(profile: widget.profile),
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
            );
          },
        ),
      ),
    );
  }

  // ---------------- UI WIDGETS ----------------

  Widget _dietTile(_DietOption option) {
    const green = Color(0xFF49B675);
    const lightGreen = Color(0xFFE6F7EC);

    final bool isSelected = _selected == option.title;

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () {
        setState(() {
          _selected = option.title;
        });
      },
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isSelected ? lightGreen : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: green,
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.green.withOpacity(0.2),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            // Icon circle
            Container(
              width: 40,
              height: 40,
              decoration: const BoxDecoration(
                color: lightGreen,
                shape: BoxShape.circle,
              ),
              child: Icon(
                option.icon,
                size: 20,
                color: green,
              ),
            ),

            const SizedBox(width: 12),

            Expanded(
              child: Text(
                option.title,
                style: const TextStyle(
                  fontFamily: 'RobotoSlab',
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),

            isSelected
                ? const Icon(
              Icons.check_circle,
              color: green,
            )
                : Icon(
              Icons.radio_button_unchecked,
              color: Colors.grey.shade400,
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------- MODEL ----------------

class _DietOption {
  final String title;
  final IconData icon;

  const _DietOption({
    required this.title,
    required this.icon,
  });
}
