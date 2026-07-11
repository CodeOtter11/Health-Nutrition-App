import 'package:flutter/material.dart';
import 'package:meal_plan/widgets/primary_next_button.dart';


/* -------------------- DISEASE CARDS -------------------- */

class DiabetesDetailsCard extends StatelessWidget {
  const DiabetesDetailsCard({super.key});

  @override
  Widget build(BuildContext context) {
    return _CardWrapper(
      title: 'Diabetes Details',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          SelectableChips(options: ['Type 1', 'Type 2', 'Prediabetes']),
          InputField('Fasting Blood Sugar (mg/dL)', 'e.g. 100'),
          InputField('Post-meal Sugar (mg/dL)', 'e.g. 140'),
          InputField('HbA1c (%)', 'e.g. 6.5'),
          YesNoField(label: 'Currently on medication?'),
        ],
      ),
    );
  }
}

class ThyroidDetailsCard extends StatelessWidget {
  const ThyroidDetailsCard({super.key});

  @override
  Widget build(BuildContext context) {
    return _CardWrapper(
      title: 'Thyroid Details',
      child: Column(
        children: const [
          SelectableChips(options: ['Hypothyroid', 'Hyperthyroid']),
          InputField('TSH Value', 'e.g. 4.5'),
          RowInputs('T3', 'Optional', 'T4', 'Optional'),
          YesNoField(label: 'Currently on medication?'),
        ],
      ),
    );
  }
}

/* -------------------- REUSABLE UI -------------------- */

class _CardWrapper extends StatelessWidget {
  final String title;
  final Widget child;

  const _CardWrapper({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(
                  fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

/* -------------------- INPUTS -------------------- */

class InputField extends StatelessWidget {
  final String label;
  final String hint;

  const InputField(this.label, this.hint, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}

class RowInputs extends StatelessWidget {
  final String l1, h1, l2, h2;

  const RowInputs(this.l1, this.h1, this.l2, this.h2, {super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: InputField(l1, h1)),
        const SizedBox(width: 12),
        Expanded(child: InputField(l2, h2)),
      ],
    );
  }
}

/* -------------------- YES / NO -------------------- */

class YesNoField extends StatefulWidget {
  final String label;

  const YesNoField({required this.label, super.key});

  @override
  State<YesNoField> createState() => _YesNoFieldState();
}

class _YesNoFieldState extends State<YesNoField> {
  String? _value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(widget.label),
        const SizedBox(height: 6),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => setState(() => _value = 'Yes'),
                style: OutlinedButton.styleFrom(
                  backgroundColor:
                  _value == 'Yes' ? Colors.green.withValues(alpha: 0.1) : null,
                ),
                child: const Text('Yes'),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: OutlinedButton(
                onPressed: () => setState(() => _value = 'No'),
                style: OutlinedButton.styleFrom(
                  backgroundColor:
                  _value == 'No' ? Colors.green.withValues(alpha: 0.1) : null,
                ),
                child: const Text('No'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
      ],
    );
  }
}

/* -------------------- CHIPS -------------------- */

class SelectableChips extends StatefulWidget {
  final List<String> options;
  final String? title;

  const SelectableChips({required this.options, this.title, super.key});

  @override
  State<SelectableChips> createState() => _SelectableChipsState();
}

class _SelectableChipsState extends State<SelectableChips> {
  String? _selected;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.title != null) Text(widget.title!),
        Wrap(
          spacing: 8,
          children: widget.options
              .map(
                (e) => ChoiceChip(
              label: Text(e),
              selected: _selected == e,
              onSelected: (_) => setState(() => _selected = e),
            ),
          )
              .toList(),
        ),
        const SizedBox(height: 12),
      ],
    );
  }
}
