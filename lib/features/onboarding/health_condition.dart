import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'health_details_form_screen.dart';
import 'busy_schedule_screen.dart';
import 'package:meal_plan/models/user_profile_data.dart';
import 'package:meal_plan/widgets/primary_next_button.dart';


class HealthConditionScreen extends StatefulWidget {
  final UserProfileData profile;

  const HealthConditionScreen({
    super.key,
    required this.profile,
  });

  @override
  State<HealthConditionScreen> createState() =>
      _HealthConditionScreenState();
}

class _HealthConditionScreenState
    extends State<HealthConditionScreen> {
  final Set<String> _selectedConditions = {};
  bool _confirmed = false;

  final List<_HealthOption> _options = const [
    _HealthOption('No Medical Condition', LucideIcons.sparkles),
    _HealthOption('Thyroid Disorder', LucideIcons.activity),
    _HealthOption('Diabetes / Pre-Diabetes', LucideIcons.droplet),
    _HealthOption('Blood Pressure', LucideIcons.heartPulse),
    _HealthOption('Cholesterol', LucideIcons.pill),
    _HealthOption('PCOS/PCOD', LucideIcons.circle),
    _HealthOption('Fatty Liver', LucideIcons.flame),
    _HealthOption('Heart Issues', LucideIcons.heart),
    _HealthOption('Anemia', LucideIcons.droplet),
    _HealthOption('Gout', LucideIcons.alertTriangle),
    _HealthOption('Digestive Issues', LucideIcons.utensils),
    _HealthOption('Food Allergies', LucideIcons.apple),
    _HealthOption('Others', LucideIcons.fileText),
  ];

  bool get _noMedicalSelected =>
      _selectedConditions.contains('No Medical Condition');

  bool get _canProceed =>
      _confirmed && _selectedConditions.isNotEmpty;

  void _handleNext() {
    if (_selectedConditions.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select at least one condition'),
        ),
      );
      return;
    }

    if (!_confirmed) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please confirm the information'),
        ),
      );
      return;
    }

    widget.profile.diseases =
        _selectedConditions.toList();

    if (_noMedicalSelected) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) =>
              BusyScheduleScreen(profile: widget.profile),
        ),
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) =>
              HealthDetailsFormScreen(profile: widget.profile),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    const green = Color(0xFF49B675);
    const lightGreen = Color(0xFFE6F7EC);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Padding(
                padding:
                const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    const SizedBox(height: 16),

                    Row(
                      children: [
                        IconButton(
                          onPressed: () =>
                              Navigator.pop(context),
                          icon: const Icon(Icons.arrow_back),
                        ),
                      ],
                    ),

                    const SizedBox(height: 4),

                    CircleAvatar(
                      radius: 28,
                      backgroundColor: lightGreen,
                      child: const Icon(
                        LucideIcons.stethoscope,
                        color: green,
                        size: 28,
                      ),
                    ),

                    const SizedBox(height: 12),

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
                            color: index == 2
                                ? green
                                : Colors.grey.shade300,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    const Text(
                      'Select any health conditions\nthat apply to you.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 20),

                    for (final option in _options) ...[
                      _healthTile(option),
                      const SizedBox(height: 10),
                    ],

                    const SizedBox(height: 16),

                    // Confirmation
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius:
                        BorderRadius.circular(14),
                        border: Border.all(
                            color: green.withOpacity(0.4)),
                        boxShadow: [
                          BoxShadow(
                            color: green.withOpacity(0.15),
                            blurRadius: 6,
                            offset:
                            const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Checkbox(
                            value: _confirmed,
                            activeColor: green,
                            onChanged: (value) {
                              setState(() {
                                _confirmed =
                                    value ?? false;
                              });
                            },
                          ),
                          const Expanded(
                            child: Text(
                              'I confirm the information provided is accurate to the best of my knowledge.',
                              style: TextStyle(fontSize: 12),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Next button
                    PrimaryNextButton(
                      onPressed: _handleNext,
                    ),


                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ---------------- TILE ----------------

  Widget _healthTile(_HealthOption option) {
    const green = Color(0xFF49B675);
    const lightGreen = Color(0xFFE6F7EC);

    final bool isSelected =
    _selectedConditions.contains(option.title);

    final bool isNoMedical =
        option.title == 'No Medical Condition';

    final bool isDisabled =
        _noMedicalSelected && !isNoMedical;

    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: isDisabled
          ? null
          : () {
        setState(() {
          if (isSelected) {
            _selectedConditions
                .remove(option.title);
          } else {
            if (isNoMedical) {
              _selectedConditions.clear();
            } else {
              _selectedConditions.remove(
                  'No Medical Condition');
            }
            _selectedConditions
                .add(option.title);
          }
        });
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected
              ? lightGreen
              : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: green,
            width: 1.1,
          ),
          boxShadow: [
            BoxShadow(
              color: green.withOpacity(0.18),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Opacity(
          opacity: isDisabled ? 0.4 : 1,
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: const BoxDecoration(
                  color: lightGreen,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  option.icon,
                  size: 18,
                  color: green,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  option.title,
                  style: const TextStyle(
                    fontSize: 14,
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
      ),
    );
  }
}

// ---------------- MODEL ----------------

class _HealthOption {
  final String title;
  final IconData icon;

  const _HealthOption(this.title, this.icon);
}