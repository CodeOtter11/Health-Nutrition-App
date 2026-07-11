import 'package:flutter/material.dart';
import 'busy_schedule_screen.dart';
import 'package:meal_plan/models/user_profile_data.dart';

import 'package:meal_plan/widgets/primary_next_button.dart';

class HealthDetailsFormScreen extends StatefulWidget {
  final UserProfileData profile;

  const HealthDetailsFormScreen({
    super.key,
    required this.profile,
  });

  @override
  State<HealthDetailsFormScreen> createState() =>
      _HealthDetailsFormScreenState();
}

class _HealthDetailsFormScreenState
    extends State<HealthDetailsFormScreen> {
  final Map<String, String> _singleSelect = {};
  final Map<String, Set<String>> _multiSelect = {};

  @override
  Widget build(BuildContext context) {
    const green = Color(0xFF49B675);
    const lightGreen = Color(0xFF66D48F);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
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

                    const Text(
                      'Health Details',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 4),

                    const Text(
                      'Tell us a little more to personalize your plan',
                      style: TextStyle(
                        color: green,
                        fontSize: 13,
                      ),
                    ),

                    const SizedBox(height: 20),

                    // ---------------- ALL CARDS ----------------

                    if (widget.profile.diseases
                        .contains('Diabetes / Pre-Diabetes'))
                      _diabetesCard(),

                    if (widget.profile.diseases
                        .contains('Thyroid Disorder'))
                      _thyroidCard(),

                    if (widget.profile.diseases
                        .contains('Blood Pressure'))
                      _bpCard(),

                    if (widget.profile.diseases
                        .contains('Cholesterol'))
                      _cholesterolCard(),

                    if (widget.profile.diseases
                        .contains('PCOS / PCOD'))
                      _pcosCard(),

                    if (widget.profile.diseases
                        .contains('Fatty Liver'))
                      _fattyLiverCard(),

                    if (widget.profile.diseases
                        .contains('Heart Disease'))
                      _heartCard(),

                    if (widget.profile.diseases
                        .contains('Anemia'))
                      _anemiaCard(),

                    if (widget.profile.diseases
                        .contains('Gout'))
                      _goutCard(),

                    if (widget.profile.diseases
                        .contains('Digestive Issues'))
                      _digestiveCard(),

                    if (widget.profile.diseases
                        .contains('Food Allergies'))
                      _foodAllergyCard(),

                    if (widget.profile.diseases
                        .contains('Others'))
                      _otherConditionCard(),

                    const SizedBox(height: 28),

                    Center(
                      child: PrimaryNextButton(
                        onPressed: () {
                          widget.profile.healthDetails = {
                            "single": _singleSelect,
                            "multi": _multiSelect,
                          };

                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  BusyScheduleScreen(profile: widget.profile),
                            ),
                          );
                        },
                      ),
                    ),

                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // --------------------------------------------------
  // CARD STYLE
  // --------------------------------------------------

  Widget _card({required String title, required Widget child}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF9EDFB7), Color(0xFF49B675)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.green.withOpacity(0.35),
            blurRadius: 10,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          Text(
            '• $title',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }

  // --------------------------------------------------
  // INPUTS
  // --------------------------------------------------

  Widget _input(String label, String hint) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          Text(label,
              style:
              const TextStyle(fontSize: 13)),
          const SizedBox(height: 4),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius:
              BorderRadius.circular(20),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x22000000),
                  blurRadius: 6,
                  offset: Offset(0, 3),
                )
              ],
            ),
            child: TextField(
              decoration: InputDecoration(
                hintText: hint,
                border: InputBorder.none,
                contentPadding:
                const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _rowInputs(
      String l1, String h1, String l2, String h2) {
    return Row(
      children: [
        Expanded(child: _input(l1, h1)),
        const SizedBox(width: 10),
        Expanded(child: _input(l2, h2)),
      ],
    );
  }

  // --------------------------------------------------
  // CHIPS
  // --------------------------------------------------

  Widget _singleChoiceChips(
      String key, List<String> items) {
    return Wrap(
      spacing: 8,
      children: items.map((e) {
        final selected =
            _singleSelect[key] == e;
        return _pillChip(
          label: e,
          selected: selected,
          onTap: () =>
              setState(() => _singleSelect[key] = e),
        );
      }).toList(),
    );
  }

  Widget _multiChoiceChips(
      String key, List<String> items) {
    _multiSelect.putIfAbsent(key, () => {});
    return Wrap(
      spacing: 8,
      children: items.map((e) {
        final selected =
        _multiSelect[key]!.contains(e);
        return _pillChip(
          label: e,
          selected: selected,
          onTap: () {
            setState(() {
              selected
                  ? _multiSelect[key]!.remove(e)
                  : _multiSelect[key]!.add(e);
            });
          },
        );
      }).toList(),
    );
  }

  Widget _pillChip({
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(
            horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius:
          BorderRadius.circular(20),
          boxShadow: const [
            BoxShadow(
              color: Color(0x22000000),
              blurRadius: 6,
              offset: Offset(0, 3),
            )
          ],
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: selected
                ? Colors.green
                : Colors.black,
          ),
        ),
      ),
    );
  }

  Widget _yesNo(String key) =>
      _singleChoiceChips(key, ['Yes', 'No']);

  // --------------------------------------------------
  // ALL DISEASE CARDS (UNCHANGED LOGIC)
  // --------------------------------------------------

  Widget _diabetesCard() => _card(
    title: 'Diabetes Details',
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Diabetes Type'),
        _singleChoiceChips(
            'diabetes_type', ['Type 1', 'Type 2', 'Prediabetes']),
        const SizedBox(height: 14),
        _rowInputs('Fasting Blood Sugar', '100', 'Post-meal Sugar', '140'),
        _input('HbA1c (%)', '6.5'),
        const SizedBox(height: 14),
        const Text('On medication?'),
        _yesNo('diabetes_med'),
      ],
    ),
  );

  Widget _thyroidCard() => _card(
    title: 'Thyroid Details',
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _singleChoiceChips(
            'thyroid_type', ['Hypothyroid', 'Hyperthyroid']),
        _input('TSH Value', '4.5'),
        _rowInputs('T3', 'Optional', 'T4', 'Optional'),
        const SizedBox(height: 14),
        const Text('On medication?'),
        _yesNo('thyroid_med'),
      ],
    ),
  );


  Widget _bpCard() => _card(
    title: 'Blood Pressure Details',
    child: Column(
      children: [
        _rowInputs('Systolic', '120', 'Diastolic', '80'),
        const SizedBox(height: 12),
        const Text('On Medications?'),
        _yesNo('bp_med'),
      ],
    ),
  );

  Widget _cholesterolCard() => _card(
    title: 'Cholesterol Details',
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _input('Total Cholesterol', '200'),
        _rowInputs('LDL', '100', 'HDL', '50'),
        _input('Triglycerides', '150'),
      ],
    ),
  );

  Widget _pcosCard() => _card(
    title: 'PCOS / PCOD Details',
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Diagnosed by a doctor?'),
        _yesNo('pcos_diagnosed'),
        const SizedBox(height: 14),
        const Text('Irregular periods?'),
        _yesNo('pcos_irregular'),
        const SizedBox(height: 14),
        const Text('Weight gain issues?'),
        _yesNo('pcos_weight'),
        const SizedBox(height: 14),
        const Text('Insulin resistance?'),
        _singleChoiceChips('pcos_insulin', ['Yes', 'Not sure']),
      ],
    ),
  );

  Widget _fattyLiverCard() => _card(
    title: 'Fatty Liver Details',
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Grade'),
        const SizedBox(height: 6),
        _singleChoiceChips(
          'fatty_grade',
          ['Mild', 'Moderate', 'Severe'],
        ),

        const SizedBox(height: 14),
        const Text('Alcohol intake?'),
        const SizedBox(height: 6),
        _yesNo('fatty_alcohol'),

        const SizedBox(height: 14),
        const Text('Ultrasound done?'),
        const SizedBox(height: 6),
        _yesNo('fatty_ultrasound'),
      ],
    ),
  );


  Widget _heartCard() => _card(
    title: 'Heart Disease',
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Type of heart condition'),
        const SizedBox(height: 6),
        _multiChoiceChips(
          'heart_type',
          [
            'Coronary artery disease',
            'Heart attack history',
            'Heart failure',
            'Other',
          ],
        ),

        const SizedBox(height: 14),
        const Text('Physical activity tolerance'),
        const SizedBox(height: 6),
        _singleChoiceChips(
          'heart_activity',
          ['Low', 'Moderate', 'Good'],
        ),

        const SizedBox(height: 14),
        const Text('Salt restriction advised by doctor?'),
        const SizedBox(height: 6),
        _yesNo('heart_salt'),

        const SizedBox(height: 14),
        const Text('On heart-related medication?'),
        const SizedBox(height: 6),
        _yesNo('heart_med'),
      ],
    ),
  );

  Widget _anemiaCard() => _card(
    title: 'Anemia',
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Type of anemia'),
        const SizedBox(height: 6),
        _singleChoiceChips(
          'anemia_type',
          ['Iron deficiency', 'Vitamin B12 deficiency', 'Not sure'],
        ),

        const SizedBox(height: 14),
        _input('Latest hemoglobin level (optional)', 'e.g. 12.5 g/dL'),

        const SizedBox(height: 14),
        const Text('Common symptoms'),
        const SizedBox(height: 6),
        _multiChoiceChips(
          'anemia_symptoms',
          ['Fatigue', 'Dizziness', 'Breathlessness', 'None'],
        ),

        const SizedBox(height: 14),
        const Text('Currently taking supplements?'),
        const SizedBox(height: 6),
        _yesNo('anemia_supplements'),
      ],
    ),
  );

  Widget _goutCard() => _card(
    title: 'Gout',
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 14),
        const Text('Frequency of flare-ups'),
        _singleChoiceChips(
            'gout_freq', ['Rare', 'Occasional', 'Frequent']),
        const SizedBox(height: 14),
        const Text('Trigger foods noticed'),
        _multiChoiceChips('gout_triggers',
            ['Red meat', 'Seafood', 'Alcohol']),
        const SizedBox(height: 14),
        const Text('On medication?'),
        _yesNo('gout_med'),
      ],
    ),
  );

  Widget _digestiveCard() => _card(
    title: 'Digestive Issues Details',
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Issue type',
          style: TextStyle(fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 6),
        _multiChoiceChips(
          'digestive_type',
          ['IBS', 'Acidity', 'Bloating', 'Constipation'],
        ),

        const SizedBox(height: 14),
        _input('Trigger foods', 'e.g. Spicy food, dairy...'),
      ],
    ),
  );


  Widget _foodAllergyCard() => _card(
    title: 'Food Allergies',
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Select known allergens',
          style: TextStyle(fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 6),
        _multiChoiceChips(
          'allergens',
          ['Milk', 'Nuts', 'Eggs', 'Soy', 'Wheat', 'Seafood'],
        ),

        const SizedBox(height: 14),
        _input('Add custom allergens', 'e.g. Sesame, Mushroom, Corn'),

        const SizedBox(height: 14),
        const Text(
          'Reaction severity',
          style: TextStyle(fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 6),
        _singleChoiceChips(
          'allergy_severity',
          ['Mild', 'Moderate', 'Severe'],
        ),
      ],
    ),
  );


  Widget _otherConditionCard() => _card(
    title: 'Other Condition Details',
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _input('Condition name', 'e.g. Asthma, Migraine'),

        const SizedBox(height: 14),
        const Text(
          'Severity',
          style: TextStyle(fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 6),
        _singleChoiceChips(
          'other_severity',
          ['Mild', 'Moderate', 'Severe'],
        ),

        const SizedBox(height: 14),
        const Text(
          'Does this affect your diet?',
          style: TextStyle(fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 6),
        _singleChoiceChips(
          'other_affects_diet',
          ['Yes', 'Not sure'],
        ),

        const SizedBox(height: 14),
        const Text(
          'Food restrictions',
          style: TextStyle(fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 6),
        _multiChoiceChips(
          'other_restrictions',
          ['Sugar', 'Salt', 'Dairy', 'Gluten', 'Spicy', 'High-fat', 'Not sure'],
        ),

        const SizedBox(height: 14),
        _input('Notes for dietitian', 'Any additional information...'),
      ],
    ),
  );
}
