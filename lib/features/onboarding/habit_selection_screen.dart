import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'referral_source_screen.dart';
import 'package:meal_plan/models/user_profile_data.dart';
import 'package:meal_plan/widgets/primary_next_button.dart';

class HabitSelectionScreen extends StatefulWidget {
  final UserProfileData profile;

  const HabitSelectionScreen({
    super.key,
    required this.profile,
  });

  @override
  State<HabitSelectionScreen> createState() =>
      _HabitSelectionScreenState();
}

class _HabitSelectionScreenState
    extends State<HabitSelectionScreen> {
  final Set<String> _selectedHabits = {};
  final Map<String, HabitDetail> _habitDetails = {};

  final List<String> _alcoholUnits = [
    'Peg',
    'Glass',
    'Litre',
    'ML'
  ];

  final List<_HabitOption> _habits = const [
    _HabitOption('Smoking', LucideIcons.cigarette),
    _HabitOption('Alcohol', LucideIcons.wine),
    _HabitOption('No bad habits', LucideIcons.checkCircle),
  ];

  bool get _noHabitSelected =>
      _selectedHabits.contains('No bad habits');

  Future<void> _onNext() async {
    widget.profile.habits = _selectedHabits.toList();

    final prefs = await SharedPreferences.getInstance();

    final bool hasHabitTracker =
        _selectedHabits.isNotEmpty &&
            !_selectedHabits.contains('No bad habits');

    await prefs.setBool('hasHabitTracker', hasHabitTracker);

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) =>
            ReferralSourceScreen(profile: widget.profile),
      ),
    );
  }

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

                  CircleAvatar(
                    radius: 28,
                    backgroundColor: lightGreen,
                    child: const Icon(
                      LucideIcons.repeat,
                      color: green,
                      size: 28,
                    ),
                  ),

                  const SizedBox(height: 12),

                  const SizedBox(height: 13),

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
                          color: index == 4
                              ? green
                              : Colors.grey.shade300,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  const Text(
                    'Do you want to track any habits?',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 6),

                  const Text(
                    'This helps us personalize your daily goals',
                    style: TextStyle(color: Colors.grey),
                  ),

                  const SizedBox(height: 24),

                  for (final habit in _habits) ...[
                    _habitTile(habit),
                    const SizedBox(height: 12),
                  ],

                  const Spacer(),

                  Center(
                    child: PrimaryNextButton(
                      text: "Continue",
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

  // ---------------- HABIT DETAIL SHEET ----------------

  Future<HabitDetail?> _showHabitDetailSheet(
      String habit) {
    String currentFrequency = 'Daily';
    int currentQuantity = 1;
    String currentUnit = 'ML';

    String targetFrequency = 'Daily';
    int targetQuantity = 1;
    String targetUnit = 'ML';

    return showModalBottomSheet<HabitDetail>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius:
        BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModal) {
            return Padding(
              padding: EdgeInsets.only(
                left: 24,
                right: 24,
                top: 24,
                bottom: MediaQuery.of(context)
                    .viewInsets
                    .bottom +
                    24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment:
                CrossAxisAlignment.start,
                children: [
                  Text(
                    '$habit Details',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 16),

                  const Text('How often do you consume?'),
                  _frequencyDropdown(
                    value: currentFrequency,
                    onChanged: (v) =>
                        setModal(() => currentFrequency = v),
                  ),

                  const SizedBox(height: 12),

                  if (habit == 'Alcohol') ...[
                    const Text('Quantity'),
                    Row(
                      children: [
                        Expanded(
                          child: _numberField(
                            value: currentQuantity,
                            onChanged: (v) =>
                                setModal(() =>
                                currentQuantity = v),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _unitDropdown(
                            value: currentUnit,
                            onChanged: (v) =>
                                setModal(() =>
                                currentUnit = v),
                          ),
                        ),
                      ],
                    ),
                  ] else ...[
                    const Text(
                        'How many cigarettes?'),
                    _counter(
                      value: currentQuantity,
                      onChanged: (v) =>
                          setModal(() =>
                          currentQuantity = v),
                    ),
                  ],

                  const SizedBox(height: 20),

                  const Text('Set your limit'),
                  _frequencyDropdown(
                    value: targetFrequency,
                    onChanged: (v) =>
                        setModal(() => targetFrequency = v),
                  ),

                  const SizedBox(height: 12),

                  if (habit == 'Alcohol') ...[
                    Row(
                      children: [
                        Expanded(
                          child: _numberField(
                            value: targetQuantity,
                            onChanged: (v) =>
                                setModal(() =>
                                targetQuantity = v),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _unitDropdown(
                            value: targetUnit,
                            onChanged: (v) =>
                                setModal(() =>
                                targetUnit = v),
                          ),
                        ),
                      ],
                    ),
                  ] else ...[
                    _counter(
                      value: targetQuantity,
                      onChanged: (v) =>
                          setModal(() =>
                          targetQuantity = v),
                    ),
                  ],

                  const SizedBox(height: 20),

                  SizedBox(
                    width: double.infinity,
                    height: 46,
                    child: ElevatedButton(
                      style:
                      ElevatedButton.styleFrom(
                        backgroundColor:
                        const Color(0xFF49B675),
                      ),
                      onPressed: () {
                        Navigator.pop(
                          context,
                          HabitDetail(
                            habit: habit,
                            currentFrequency:
                            currentFrequency,
                            currentQuantity:
                            currentQuantity,
                            currentUnit: currentUnit,
                            targetFrequency:
                            targetFrequency,
                            targetQuantity:
                            targetQuantity,
                            targetUnit: targetUnit,
                          ),
                        );
                      },
                      child: const Text('Save'),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _frequencyDropdown({
    required String value,
    required ValueChanged<String> onChanged,
  }) {
    const options = ['Daily', 'Weekly', 'Monthly'];

    return DropdownButtonFormField<String>(
      value: value,
      items: options
          .map((e) => DropdownMenuItem(
        value: e,
        child: Text(e),
      ))
          .toList(),
      onChanged: (v) => onChanged(v!),
    );
  }

  Widget _unitDropdown({
    required String value,
    required ValueChanged<String> onChanged,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      items: _alcoholUnits
          .map((e) => DropdownMenuItem(
        value: e,
        child: Text(e),
      ))
          .toList(),
      onChanged: (v) => onChanged(v!),
    );
  }

  Widget _numberField({
    required int value,
    required ValueChanged<int> onChanged,
  }) {
    return TextFormField(
      initialValue: value.toString(),
      keyboardType: TextInputType.number,
      onChanged: (v) =>
          onChanged(int.tryParse(v) ?? 1),
      decoration: const InputDecoration(
        border: OutlineInputBorder(),
        labelText: 'Quantity',
      ),
    );
  }

  Widget _counter({
    required int value,
    required ValueChanged<int> onChanged,
  }) {
    return Row(
      children: [
        IconButton(
          icon: const Icon(Icons.remove),
          onPressed:
          value > 1 ? () => onChanged(value - 1) : null,
        ),
        Text('$value'),
        IconButton(
          icon: const Icon(Icons.add),
          onPressed: () => onChanged(value + 1),
        ),
      ],
    );
  }

  Widget _habitTile(_HabitOption habit) {
    final bool isSelected =
    _selectedHabits.contains(habit.title);

    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: () async {
        if (habit.title == 'No bad habits') {
          setState(() {
            _selectedHabits.clear();
            _selectedHabits.add(habit.title);
          });
          return;
        }

        final result =
        await _showHabitDetailSheet(habit.title);

        if (result == null) return;

        setState(() {
          _selectedHabits.remove('No bad habits');
          _selectedHabits.add(habit.title);
          _habitDetails[habit.title] = result;
        });
      },
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFFE6F7EC)
              : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF49B675)
                : Colors.grey.shade300,
          ),
          boxShadow: [
            BoxShadow(
              color:
              const Color(0xFF49B675).withOpacity(0.18),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(habit.icon,
                color: const Color(0xFF49B675)),
            const SizedBox(width: 12),
            Expanded(child: Text(habit.title)),
            Icon(
              isSelected
                  ? Icons.check_circle
                  : Icons.radio_button_unchecked,
              color: isSelected
                  ? const Color(0xFF49B675)
                  : Colors.grey,
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------- MODELS ----------------

class _HabitOption {
  final String title;
  final IconData icon;

  const _HabitOption(this.title, this.icon);
}

class HabitDetail {
  final String habit;
  final String currentFrequency;
  final int currentQuantity;
  final String currentUnit;
  final String targetFrequency;
  final int targetQuantity;
  final String targetUnit;

  HabitDetail({
    required this.habit,
    required this.currentFrequency,
    required this.currentQuantity,
    required this.currentUnit,
    required this.targetFrequency,
    required this.targetQuantity,
    required this.targetUnit,
  });

  String toStorage() =>
      '$habit|$currentFrequency|$currentQuantity$currentUnit|'
          '$targetFrequency|$targetQuantity$targetUnit';
}
