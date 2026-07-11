import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:meal_plan/features/onboarding/dietary_preference.dart';
import 'package:meal_plan/models/user_profile_data.dart';
import 'package:meal_plan/widgets/primary_next_button.dart';


class BasicDetailsScreen extends StatefulWidget {
  final UserProfileData profile;


  const BasicDetailsScreen({
    super.key,
    required this.profile,
  });

  @override
  State<BasicDetailsScreen> createState() =>
      _BasicDetailsScreenState();
}

class _BasicDetailsScreenState extends State<BasicDetailsScreen> {
  final TextEditingController _nameCtrl = TextEditingController();
  final TextEditingController _weightCtrl =
  TextEditingController(text: "60");
  final TextEditingController _cityCtrl = TextEditingController();

  final FocusNode _nameFocus = FocusNode();
  final FocusNode _cityFocus = FocusNode();

  bool _nameHover = false;
  bool _cityHover = false;
  final Color primaryGreen = const Color(0xFF22C35D);

  String? _gender;
  DateTime? _dob;

  // Scroll controllers
  late FixedExtentScrollController _weightScroll;
  late FixedExtentScrollController _feetScroll;
  late FixedExtentScrollController _inchScroll;

  int _feet = 5;
  int _inch = 6;

  @override
  void initState() {
    super.initState();

    _nameFocus.addListener(() => setState(() {}));
    _cityFocus.addListener(() => setState(() {}));

    _weightScroll = FixedExtentScrollController(initialItem: 60);
    _feetScroll = FixedExtentScrollController(initialItem: _feet);
    _inchScroll = FixedExtentScrollController(initialItem: _inch);
  }

  @override
  void dispose() {
    _weightScroll.dispose();
    _feetScroll.dispose();
    _inchScroll.dispose();
    super.dispose();
  }

  bool get _isFormValid {
    return _nameCtrl.text
        .trim()
        .isNotEmpty &&
        _weightCtrl.text
            .trim()
            .isNotEmpty &&
        _cityCtrl.text
            .trim()
            .isNotEmpty &&
        _dob != null &&
        _gender != null;
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
                    const SizedBox(height: 24),

                    // Logo
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
                            (index) =>
                            Container(
                              margin:
                              const EdgeInsets.symmetric(
                                  horizontal: 3),
                              width: 7,
                              height: 7,
                              decoration: BoxDecoration(
                                color: index == 0
                                    ? green
                                    : Colors.grey.shade300,
                                shape: BoxShape.circle,
                              ),
                            ),
                      ),
                    ),

                    const SizedBox(height: 18),

                    const Text(
                      'Basic Details',
                      style: TextStyle(
                        fontFamily: 'RobotoSlab',
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      "Let's make this about you",
                      style: TextStyle(
                        fontFamily: 'RobotoSlab',
                        color: green,
                        fontSize: 13,
                      ),
                    ),

                    const SizedBox(height: 22),

                    _label('Full Name'),
                    _inputField(
                      controller: _nameCtrl,
                      hint: 'Full Name',
                      icon: LucideIcons.user,
                      focusNode: _nameFocus,
                    ),

                    const SizedBox(height: 14),

                    _label('Gender'),
                    _dropdownField(),

                    const SizedBox(height: 14),

                    _label('Date of Birth'),
                    _dateField(context),


                    const SizedBox(height: 14),

                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment:
                            CrossAxisAlignment.start,
                            children: [
                              _smallLabel('Weight(Kg)'),
                              _selectorField(
                                icon: LucideIcons.scale,
                                child: _weightPicker(),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment:
                            CrossAxisAlignment.start,
                            children: [
                              _smallLabel('Height(ft)'),
                              _selectorField(
                                icon: LucideIcons.ruler,
                                child: _heightPicker(),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 14),

                    _label('City'),
                    _inputField(
                      controller: _cityCtrl,
                      hint: 'City',
                      icon: LucideIcons.mapPin,
                      focusNode: _cityFocus,
                    ),

                    const SizedBox(height: 28),

                    // Next button
                    Center(
                      child: PrimaryNextButton(
                        onPressed: _goNext,
                      ),
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

  void _openDatePicker() async {
    const green = Color(0xFF49B675);

    DateTime tempDate =
        _dob ?? DateTime.now().subtract(const Duration(days: 365 * 20));

    await showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return Container(
          height: 320,
          padding: const EdgeInsets.only(top: 12),
          child: Column(
            children: [

              // Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text(
                        "Cancel",
                        style: TextStyle(
                          color: green,
                          fontFamily: 'RobotoSlab',
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),

                    const Text(
                      "Select Date of Birth",
                      style: TextStyle(
                        fontFamily: 'RobotoSlab',
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    TextButton(
                      onPressed: () {
                        setState(() => _dob = tempDate);
                        Navigator.pop(context);
                      },
                      child: const Text(
                        "Done",
                        style: TextStyle(
                          color: green,
                          fontFamily: 'RobotoSlab',
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Divider for cleaner look
              const Divider(height: 1),

              Expanded(
                child: CupertinoDatePicker(
                  mode: CupertinoDatePickerMode.date,
                  initialDateTime: tempDate,
                  maximumDate: DateTime.now(),
                  minimumYear: 1950,
                  onDateTimeChanged: (date) {
                    tempDate = date;
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ---------------- PICKERS ----------------

  Widget _weightPicker() {
    return CupertinoPicker(
      itemExtent: 24,
      scrollController: _weightScroll,
      useMagnifier: true,
      magnification: 1.05,
      onSelectedItemChanged: (index) {
        setState(() {
          _weightCtrl.text = index.toString();
        });
      },
      children: List.generate(
        150,
            (index) =>
            Center(
              child: Text(
                index.toString(),
                style: const TextStyle(
                  fontSize: 14,
                  fontFamily: 'RobotoSlab',
                ),
              ),
            ),
      ),
    );
  }

  Widget _heightPicker() {
    return Row(
      children: [
        Expanded(
          child: CupertinoPicker(
            itemExtent: 24,
            scrollController: _feetScroll,
            useMagnifier: true,
            magnification: 1.05,
            onSelectedItemChanged: (value) {
              setState(() {
                _feet = value;
              });
            },

            children: List.generate(
              8,
                  (index) =>
                  Center(
                    child: Text(
                      "$index ft",
                      style: const TextStyle(
                        fontSize: 14,
                        fontFamily: 'RobotoSlab',
                      ),
                    ),
                  ),
            ),
          ),
        ),
        Expanded(
          child: CupertinoPicker(
            itemExtent: 24,
            scrollController: _inchScroll,
            useMagnifier: true,
            magnification: 1.05,
            onSelectedItemChanged: (value) {
              setState(() {
                _inch = value;
              });
            },

            children: List.generate(
              12,
                  (index) =>
                  Center(
                    child: Text(
                      "$index in",
                      style:
                      const TextStyle(fontSize: 14),
                    ),
                  ),
            ),
          ),
        ),
      ],
    );
  }

  // ---------------- HELPERS ----------------

  void _goNext() {
    widget.profile.gender = _gender;
    widget.profile.weight = int.tryParse(_weightCtrl.text);
    widget.profile.height = _feet;
    widget.profile.name = _nameCtrl.text.trim();
    widget.profile.city = _cityCtrl.text.trim();

    final today = DateTime.now();
    int age = today.year - _dob!.year;
    if (today.month < _dob!.month ||
        (today.month == _dob!.month &&
            today.day < _dob!.day)) {
      age--;
    }
    widget.profile.age = age;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) =>
            DietaryPreferenceScreen(profile: widget.profile),
      ),
    );
  }

  Widget _label(String text) {
    return Container(
      width: double.infinity, // take full width
      padding: const EdgeInsets.only(bottom: 12),
      alignment: Alignment.centerLeft, // left align
      child: Text(
        text,
        style: const TextStyle(
          fontFamily: 'RobotoSlab',
          fontWeight: FontWeight.w500,
          fontSize: 20,
        ),
      ),
    );
  }

  Widget _smallLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 10, bottom: 6),
      child: Text(
        text,
        style: const TextStyle(
          fontFamily: 'RobotoSlab',
          fontWeight: FontWeight.w500,
          fontSize: 20,
        ),
      ),
    );
  }


  Widget _selectorField({required IconData icon, required Widget child}) {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF66D48F)),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.green.withOpacity(0.18),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          const SizedBox(width: 2),
          Padding(
            padding: const EdgeInsets.all(6),
            child: Container(
              width: 34,
              height: 34,
              decoration: const BoxDecoration(
                color: Color(0x63078E39),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Icon(
                  icon,
                  size: 18,
                  color: Color(0xFF078E39),
                ),
              ),
            ),
          ),
          Expanded(child: child),
        ],
      ),
    );
  }

  Widget _inputField({
    required String hint,
    required IconData icon,
    required TextEditingController controller,
    FocusNode? focusNode,
    TextInputAction? textInputAction,
    ValueChanged<String>? onSubmitted,
    bool obscure = false,
    Widget? suffix,
  }) {
    return TextField(
      controller: controller,
      focusNode: focusNode,
      obscureText: obscure,
      textInputAction: textInputAction,
      onSubmitted: onSubmitted,

      style: const TextStyle(   // ADD THIS
        fontFamily: 'RobotoSlab',
        fontSize: 18,
        color: Colors.black,
      ),

      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(
          fontFamily: 'RobotoSlab',
          fontSize: 18,
          fontWeight: FontWeight.w400,
          color: Color(0x63000000), // 39% black opacity
        ),
        prefixIcon: Padding(
          padding: const EdgeInsets.all(6),
          child: Container(
            width: 34,
            height: 34,
            decoration: const BoxDecoration(
              color: Color(0x63078E39), // your hex background
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Icon(
                icon,
                size: 18,
                color: Color(0xFF078E39), // strong green icon
              ),
            ),
          ),
        ),
        suffixIcon: suffix,
        filled: true,
        fillColor: Colors.white,

        // Default border (without focus)
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: primaryGreen, width: 1.4),
        ),

        // Focused border (when typing)
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: primaryGreen, width: 2),
        ),

        // Hover border (desktop/web)
        hoverColor: primaryGreen.withOpacity(0.08),

        // Error border (optional good practice)
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.red, width: 1.5),
        ),
      ),
    );
  }

  Widget _dropdownField() {
    return DropdownButtonFormField<String>(
      style: const TextStyle(
        fontFamily: 'RobotoSlab',
        color: Colors.black,
        fontSize: 20,
      ),
      value: _gender,
      hint: const Text(
        'Select Your Gender',
        style: TextStyle(
          fontFamily: 'RobotoSlab',
          fontSize: 20,
        ),
      ),
      items: const [
        DropdownMenuItem(value: 'Male', child: Text('Male')),
        DropdownMenuItem(value: 'Female', child: Text('Female')),
        DropdownMenuItem(value: 'Other', child: Text('Other')),
      ],
      onChanged: (value) => setState(() => _gender = value),

      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white,

        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: primaryGreen, width: 1.4),
        ),

        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: primaryGreen, width: 2),
        ),

        prefixIcon: Padding(
          padding: const EdgeInsets.all(6),
          child: Container(
            width: 34,
            height: 34,
            decoration: const BoxDecoration(
              color: Color(0x63078E39),
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Icon(
                LucideIcons.user, // gender icon
                size: 18,
                color: Color(0xFF078E39),
              ),
            ),
          ),
        ),

        contentPadding: const EdgeInsets.only(
          top: 10,
          left: 12,
        ),
      ),
    );
  }

  Widget _dateField(BuildContext context) {
    return TextField(
      readOnly: true,
      style: const TextStyle(
        fontFamily: 'RobotoSlab',
        fontSize: 14,
        color: Colors.black,
      ),
      decoration: InputDecoration(
        hintText: _dob == null
            ? 'Select Date'
            : '${_dob!.day}/${_dob!.month}/${_dob!.year}',

        hintStyle: const TextStyle(
          fontFamily: 'RobotoSlab',
          fontSize: 20,
          color: Colors.black54,
        ),

        prefixIcon: Padding(
          padding: const EdgeInsets.all(6),
          child: Container(
            width: 34,
            height: 34,
            decoration: const BoxDecoration(
              color: Color(0x63078E39),
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Icon(
                LucideIcons.calendar,
                size: 18,
                color: Color(0xFF078E39),
              ),
            ),
          ),
        ),

        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: primaryGreen, width: 1.4),
        ),

        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: primaryGreen, width: 2),
        ),
        isDense: true,
        contentPadding: const EdgeInsets.only(
          top: 10,   // move text downward
          left: 12,
        ),
      ),
        onTap: _openDatePicker,
    );
  }
}