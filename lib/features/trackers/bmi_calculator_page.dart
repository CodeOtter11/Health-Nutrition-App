import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../services/bmi_service.dart';
import 'package:intl/intl.dart';

const Color brandGreen = Color(0xFF4CAF50);
const Color softGreen = Color(0xFFE8F5E9);

class BMICalculatorPage extends StatefulWidget {
  const BMICalculatorPage({super.key});

  @override
  State<BMICalculatorPage> createState() => _BMICalculatorPageState();
}

class _BMICalculatorPageState extends State<BMICalculatorPage> {
  final heightCmCtrl = TextEditingController();
  final weightKgCtrl = TextEditingController();
  final feetCtrl = TextEditingController();
  final inchCtrl = TextEditingController();
  final poundCtrl = TextEditingController();

  final heightFocus = FocusNode();
  final weightFocus = FocusNode();
  final feetFocus = FocusNode();
  final inchFocus = FocusNode();
  final poundFocus = FocusNode();

  List<Map<String, dynamic>> historyList = [];

  bool isMetric = true;
  double? bmi;
  String? errorText;

  @override
  void dispose() {
    heightCmCtrl.dispose();
    weightKgCtrl.dispose();
    feetCtrl.dispose();
    inchCtrl.dispose();
    poundCtrl.dispose();
    super.dispose();
  }

  Widget _historySection() {
    if (historyList.isEmpty) return const SizedBox();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            blurRadius: 12,
            color: Colors.black.withOpacity(0.1),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "BMI History",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),

          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () async {

                setState(() {
                  historyList.clear();
                });
              },
              child: const Text("Clear All"),
            ),
          ),
          const SizedBox(height: 12),

          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: historyList.length,
            itemBuilder: (context, index) {
              final item = historyList[historyList.length - 1 - index];

              final double bmiValue = (item["bmi"] as num).toDouble();
              final rawDate = item["date"];
              final parsedDate = DateTime.parse(rawDate);
              final date = DateFormat('dd MMM yyyy').format(parsedDate);
              final category = getBMICategory(bmiValue);
              final color = categoryColor(category);

              return Container(
                margin: const EdgeInsets.symmetric(vertical: 6),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      bmiValue.toStringAsFixed(1),
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    ),
                    Text(
                      category,
                      style: TextStyle(color: color),
                    ),
                    Text(
                      date,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // ================= BMI LOGIC =================
  Future<void> calculateBMI() async {
    setState(() => errorText = null);

    FocusScope.of(context).unfocus();

    double heightMeters;
    double weightKg;

    if (isMetric) {
      final h = double.tryParse(heightCmCtrl.text);
      final w = double.tryParse(weightKgCtrl.text);

      if (h == null || w == null || h <= 0 || w <= 0) {
        setState(() => errorText = "Please enter valid height & weight");
        return;
      }

      heightMeters = h / 100;
      weightKg = w;

      final calculatedBMI = weightKg / (heightMeters * heightMeters);

      setState(() {
        bmi = calculatedBMI;
      });

      // ✅ SAVE DATA
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("auth_token");

      if (token == null) {
        setState(() => errorText = "User not logged in");
        return;
      }

      await BMIService.saveBMI(
        token: token!,
        bmi: calculatedBMI,
        height: h,
        weight: w,
      );

      await loadBMIHistory();

    } else {
      final ft = double.tryParse(feetCtrl.text);
      final inch = double.tryParse(inchCtrl.text);
      final lb = double.tryParse(poundCtrl.text);

      if (ft == null || inch == null || lb == null) {
        setState(() => errorText = "Please fill all standard fields");
        return;
      }

      final totalInches = (ft * 12) + inch;
      heightMeters = totalInches * 0.0254;
      weightKg = lb * 0.453592;

      final calculatedBMI = weightKg / (heightMeters * heightMeters);

      setState(() {
        bmi = calculatedBMI;
      });

      // ✅ SAVE DATA
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("auth_token");

      if (token == null) {
        setState(() => errorText = "User not logged in");
        return;
      }

      await BMIService.saveBMI(
        token: token!,
        bmi: calculatedBMI,
        height: heightMeters * 100,
        weight: weightKg,
      );

      await loadBMIHistory();
    }
  }

  Future<void> loadBMIHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("auth_token");

    if (token == null) {
      setState(() => errorText = "User not logged in");
      return;
    }

    final data = await BMIService.getBMIHistory(token!);

    setState(() {
      historyList = List<Map<String, dynamic>>.from(data);
    });
  }

  @override
  void initState() {
    super.initState();
    checkToken();
    loadBMIHistory();
  }

  Future<void> checkToken() async {
    final prefs = await SharedPreferences.getInstance();
    print("TOKEN DEBUG: ${prefs.getString("auth_token")}");
  }

  void resetBMI() {
    heightCmCtrl.clear();
    weightKgCtrl.clear();
    feetCtrl.clear();
    inchCtrl.clear();
    poundCtrl.clear();

    setState(() {
      bmi = null;
      errorText = null;
    });
  }

  String getBMICategory(double v) {
    if (v < 18.5) return "Underweight";
    if (v < 25) return "Healthy";
    if (v < 30) return "Overweight";
    return "Obesity";
  }

  Color categoryColor(String c) {
    switch (c) {
      case "Healthy":
        return brandGreen;
      case "Underweight":
        return Colors.orange;
      case "Overweight":
        return Colors.deepOrange;
      default:
        return Colors.red;
    }
  }

  // ================= UI =================
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Column(
        children: [
          _headerCard(isDark),

          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 20),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: _unitToggle(isDark),
                  ),

                  const SizedBox(height: 20),

                  _inputCard(isDark),

                  if (errorText != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        errorText!,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.error,
                        ),
                      ),
                    ),

                  const SizedBox(height: 16),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: _actionButtons(),
                  ),

                  if (bmi != null) ...[
                    const SizedBox(height: 28),
                    _resultCard(),
                    const SizedBox(height: 20),
                    _categoryTable(),
                  ],

                  if (historyList.isNotEmpty) ...[
                    const SizedBox(height: 20),
                    _historySection(),
                  ],

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ================= HEADER =================
  Widget _headerCard(bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 60, 16, 60),
      decoration: BoxDecoration(
        color: isDark
            ? const Color(0xFF2E7D32)
            : const Color(0xFFA5D6A7),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(80),
          bottomRight: Radius.circular(80),
        ),
        boxShadow: [
          BoxShadow(
            blurRadius: 20,
            offset: const Offset(0, 8),
            color: Colors.black.withOpacity(0.25),
          )
        ],
      ),
      child: Row(
        children: [
          InkWell(
            onTap: () => Navigator.pop(context),
            child: const Icon(Icons.arrow_back, color: Colors.black),
          ),
          const SizedBox(width: 12),
          const CircleAvatar(
            radius: 20,
            backgroundColor: Colors.white,
            child: Icon(
              Icons.monitor_weight,
              size: 22,
              color: brandGreen,
            ),
          ),
          const SizedBox(width: 14),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "BMI Calculator",
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black),
              ),
              SizedBox(height: 4),
              Text(
                "Track your body health",
                style: TextStyle(
                    fontSize: 14,
                    color: Colors.black87),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ================= UNIT TOGGLE =================
  Widget _unitToggle(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: softGreen,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            blurRadius: 10,
            color: Colors.black.withOpacity(0.15),
          )
        ],
      ),
      child: Row(
        children: [
          _toggle("Metric", isMetric, () {
            setState(() => isMetric = true);
          }),
          _toggle("Standard", !isMetric, () {
            setState(() => isMetric = false);
          }),
        ],
      ),
    );
  }

  Widget _toggle(String t, bool active, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: active ? brandGreen : Colors.transparent,
            borderRadius: BorderRadius.circular(14),
          ),
          alignment: Alignment.center,
          child: Text(
            t,
            style: TextStyle(
              color: active ? Colors.white : Colors.black,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  // ================= INPUT CARD =================
  Widget _inputCard(bool isDark) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            blurRadius: 14,
            color: Colors.black.withOpacity(0.15),
          )
        ],
      ),
      child: isMetric ? _metricInputs() : _standardInputs(),
    );
  }

  Widget _metricInputs() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Height (cm)"),
        TextField(controller: heightCmCtrl),
        const SizedBox(height: 16),
        const Text("Weight (kg)"),
        TextField(controller: weightKgCtrl),
      ],
    );
  }

  Widget _standardInputs() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Height(f't)"),
        Row(
          children: [
            Expanded(child: TextField(controller: feetCtrl)),
            const SizedBox(width: 10),
            Expanded(child: TextField(controller: inchCtrl)),
          ],
        ),
        const SizedBox(height: 16),
        const Text("Weight (pounds)"),
        TextField(controller: poundCtrl),
      ],
    );
  }

  Widget _actionButtons() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            onPressed: calculateBMI,
            style: ElevatedButton.styleFrom(
              backgroundColor: brandGreen,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: const Text("Calculate BMI"),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: OutlinedButton(
            onPressed: resetBMI,
            child: const Text("Reset"),
          ),
        ),
      ],
    );
  }

  Widget _resultCard() {
    final category = getBMICategory(bmi!);
    final color = categoryColor(category);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            blurRadius: 14,
            color: Colors.black.withOpacity(0.15),
          )
        ],
      ),
      child: Column(
        children: [
          Text(
            bmi!.toStringAsFixed(1),
            style: TextStyle(
              fontSize: 40,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            category,
            style: TextStyle(
              fontSize: 18,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _categoryTable() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFF2F2F2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black54, width: 1),
        boxShadow: [
          BoxShadow(
            blurRadius: 10,
            offset: const Offset(0, 5),
            color: Colors.black.withOpacity(0.25),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "BMI Categories",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),

          _bmiRow("Underweight", "Below 18.5", Colors.orange),
          _bmiRow("Healthy", "18.5 - 24.9", brandGreen, highlight: true),
          _bmiRow("Overweight", "25-29.9", Colors.deepOrange),
          _bmiRow("Obesity", "30 or above", Colors.red),
        ],
      ),
    );
  }
}


Widget _bmiRow(String title, String value, Color valueColor,
    {bool highlight = false}) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 6),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        highlight
            ? Container(
          padding:
          const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.green.withOpacity(0.2),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
        )
            : Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        Text(
          value,
          style: TextStyle(
            color: valueColor,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    ),
  );
}