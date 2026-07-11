import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:meal_plan/screens/main_shell.dart';
import 'package:meal_plan/models/user_profile_data.dart';
import 'package:meal_plan/services/profile_service.dart';
import 'package:meal_plan/widgets/primary_next_button.dart';


class ReferralSourceScreen extends StatefulWidget {
  final UserProfileData profile;

  const ReferralSourceScreen({
    super.key,
    required this.profile,
  });

  @override
  State<ReferralSourceScreen> createState() =>
      _ReferralSourceScreenState();
}

class _ReferralSourceScreenState
    extends State<ReferralSourceScreen> {
  String? _selectedSource;

  final List<String> _sources = [
    'Family / Friends',
    'Instagram',
    'Facebook',
    'YouTube',
  ];

  bool get _hasSelection => _selectedSource != null;

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
              padding:
              const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  const SizedBox(height: 16),

                  // Back
                  Row(
                    children: [
                      IconButton(
                        icon:
                        const Icon(Icons.arrow_back),
                        onPressed: () =>
                            Navigator.pop(context),
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
                          color: index == 6
                              ? green
                              : Colors.grey.shade300,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  const Text(
                    'How did you get to\nknow about this app?',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Options
                  for (final source in _sources) ...[
                    _optionTile(source),
                    const SizedBox(height: 12),
                  ],

                  const Spacer(),

                  // Next button
                  Center(
                    child: PrimaryNextButton(
                      onPressed: _onNext,
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
  Widget _optionTile(String title) {
    const green = Color(0xFF49B675);
    const lightGreen = Color(0xFFE6F7EC);

    final bool selected = _selectedSource == title;

    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: () {
        setState(() {
          _selectedSource = title;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: selected ? lightGreen : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color:
            selected ? green : Colors.grey.shade300,
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
            Expanded(
              child: Text(
                title,
                style:
                const TextStyle(fontSize: 15),
              ),
            ),
            Icon(
              selected
                  ? Icons.check_circle
                  : Icons.radio_button_unchecked,
              color:
              selected ? green : Colors.grey,
            ),
          ],
        ),
      ),
    );
  }

  // ---------------- NEXT ACTION ----------------
  void _onNext() async {
    widget.profile.referralSource = [_selectedSource!];

    final success =
    await ProfileService().submitProfile(
      widget.profile,
    );

    if (!success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("Failed to save profile")),
      );
      return;
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => const MainShell(),
      ),
    );
  }
}


