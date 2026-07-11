import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/api_config.dart';
import 'package:meal_plan/services/water_service.dart';

class WaterTrackerPage extends StatefulWidget {
  const WaterTrackerPage({super.key});

  @override
  State<WaterTrackerPage> createState() => _WaterTrackerPageState();
}

class _WaterTrackerPageState extends State<WaterTrackerPage>
    with SingleTickerProviderStateMixin {
  int currentWater = 0;
  int targetWater = 2000;
  int glasses = 0;

  Map<String, int> weeklyWater = {
    "Sun": 0,
    "Mon": 0,
    "Tue": 0,
    "Wed": 0,
    "Thu": 0,
    "Fri": 0,
    "Sat": 0,
  };

  double get progress {
    if (targetWater == 0) return 0;
    return (currentWater / targetWater).clamp(0.0, 1.0);
  }

  AnimationController? waveController;
  Animation<double>? waveAnimation;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEDEDED),

      body: SafeArea(
        child: SingleChildScrollView(
        child: Column(
          children: [
            _header(),
            const SizedBox(height: 25),
            _timeCard(),
            const SizedBox(height: 35),
            _progressSection(),
            const SizedBox(height: 35),
            _dashboardButton(),
            const SizedBox(height: 25),
            _weeklySummary(),
            const SizedBox(height: 100),
          ],
        ),
      ),
      ),

      // FLOATING + BUTTON
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddWaterDialog,
        backgroundColor: const Color(0xFF47AC6C),
        elevation: 6,
        shape: const CircleBorder(
          side: BorderSide(
            color: Colors.black, // black border
            width: 1,            // border thickness
          ),
        ),
        child: const Icon(
          Icons.add,
          size: 32,
          color: Colors.white,
        ),
      ),

      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  Widget _goalButton() {
    return GestureDetector(
      onTap: _showGoalDialog, // 🔥 important
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
        ),
        child: const Text("Add Your Goal"),
      ),
    );
  }
  // ================= HEADER =================

  Future<void> _loadTodayWater() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString("userId");

    if (userId == null) return;

    final data = await WaterService.loadWater(userId: userId);

    setState(() {
      currentWater = data["totalWaterMl"] ?? 0;
      targetWater = data["goalMl"] ?? 2000;
      glasses = data["glasses"] ?? 0;
    });
  }

  @override
  void initState() {
    super.initState();
    _loadTodayWater();
    _loadWeeklyWater();

    waveController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    waveAnimation = Tween<double>(begin: 3, end: -3).animate(
      CurvedAnimation(parent: waveController!, curve: Curves.easeInOut),
    );
  }

  Future<void> _saveWater() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString("userId");

    if (userId == null) return;

    final today = DateTime.now().toString().split(' ')[0];

    await WaterService.saveWater(
      userId: userId,
      totalWaterMl: currentWater,
      glasses: glasses,
      goalMl: targetWater,
      date: today,
    );
  }
  Future<void> _loadWeeklyWater() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString("userId");

    if (userId == null) return;

    final data = await WaterService.loadWeeklyWater(userId: userId);

    setState(() {
      weeklyWater = data;
    });
  }
  @override
  void dispose() {
    waveController?.dispose();
    super.dispose();
  }

  Widget _header() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 45),
      decoration: BoxDecoration(
        color: const Color(0xFFA7D7B5),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(80),
          bottomRight: Radius.circular(80),
        ),
        boxShadow: [
          BoxShadow(
            blurRadius: 15,
            color: Colors.black.withOpacity(0.25),
            offset: const Offset(0, 8),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context, currentWater),
            child: const Icon(Icons.arrow_back, size: 24),
          ),
          const SizedBox(height: 15),
          const Text(
            "Water Tracker",
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              fontFamily: "serif",
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            "Daily hydration",
            style: TextStyle(
              color: Color(0xFF1B5E20),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  // ================= TIME CARD =================

  Widget _timeCard() {
    return Center(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: MediaQuery.of(context).size.width * 0.9,
          height: 160, // 👈 match Figma height
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [
                Color(0xFFFFFFFF),
                Color(0xFFFFFFFF),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                blurRadius: 12,
                color: Colors.black.withOpacity(0.25),
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Stack(
            children: [

              // LIGHT WAVE PNG
              Positioned(
                bottom: -30,
                left: 0,
                right: -50,
                child: Image.asset(
                  "assets/images/light_wave.png",
                  fit: BoxFit.cover,
                ),
              ),

              // DARK WAVE PNG
              Positioned(
                bottom: 0,
                left: 0,
                right: -10,
                child: Image.asset(
                  "assets/images/dark_wave.png",
                  fit: BoxFit.cover,
                ),
              ),

              // MAIN CONTENT
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                child: Row(
                  children: [

                    // LEFT TEXT
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            "11:00 AM",
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                          SizedBox(height: 6),
                          Text(
                            "200ml water(2 Glass)",
                            style: TextStyle(
                              color: Colors.black54,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // RIGHT WATER DROPS
                    SizedBox(
                      width: 150,
                      height: 120,
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [

                          // BIG DROP
                          Positioned(
                            right: -10,
                            top: -20,
                            child: Image.asset(
                              "assets/images/water_drop.png",
                              width: 210, // bigger drop
                            ),
                          ),

                          // SMALL DROP
                          Positioned(
                            right: -40,
                            bottom: -50,
                            child: Image.asset(
                              "assets/images/small_water_drop.png",
                              width: 200, // bigger small drop
                            ),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),

              // BUTTON POSITIONED LOWER
              Positioned(
                left: 16,
                bottom: 25, // adjust this to move button up/down
                child: _goalButton(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ================= PROGRESS SECTION =================

  Widget _progressSection() {

    double lightWaveBottom = -120 + (156 * progress);
    double darkWaveBottom  = -120 + (120 * progress);

    bool isEmpty = progress <= 0;
    bool isFull = progress >= 1;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Stack(
        children: [
          Row(
            children: [

              // WATER PROGRESS CIRCLE
              SizedBox(
                width: 156,
                height: 156,
                child: Stack(
                  alignment: Alignment.center,
                  children: [

                    // BACKGROUND + BORDER + SHADOW
                    Container(
                      width: 156,
                      height: 156,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                        border: Border.all(
                          color: const Color(0xFFADE5FC),
                          width: 8,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.25),
                            offset: const Offset(-5, 5),
                            blurRadius: 5,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                    ),

                    ClipOval(
                      child: SizedBox(
                        width: 156,
                        height: 156,
                        child: isFull
                            ? Container(
                          color: const Color(0xFF59B8E8),
                        )
                            : isEmpty
                            ? Container(
                          color: Colors.transparent,
                        )
                            : AnimatedBuilder(
                          animation: waveAnimation ?? const AlwaysStoppedAnimation(0),
                          builder: (context, child) {
                            return Stack(
                              children: [

                                // LIGHT WAVE
                                Positioned(
                                  bottom: lightWaveBottom,
                                  left: 0,
                                  child: Transform.translate(
                                    offset: Offset(-(waveAnimation?.value ?? 0), 0),
                                    child: Image.asset(
                                      "assets/images/vector1.png",
                                      width: 156,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),

                                // DARK WAVE
                                Positioned(
                                  bottom: darkWaveBottom,
                                  left: 0,
                                  child: Transform.translate(
                                    offset: Offset(waveAnimation?.value ?? 0, 0),
                                    child: Image.asset(
                                      "assets/images/vector2.png",
                                      width: 156,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                    ),

                    // CENTER TEXT
                    Text(
                      "${currentWater}ml",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: progress > 0.6 ? Colors.white : Colors.black,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 25),

              // TARGET BOX
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: const Color(0xFFF2F2F2),
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      blurRadius: 8,
                      color: Colors.black.withOpacity(0.08),
                    )
                  ],
                ),
                child: Column(
                  children: [
                    const Text("Target"),
                    const SizedBox(height: 6),
                    Text(
                      "$targetWater ml",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    )
                  ],
                ),
              )
            ],
          ),

          // FLOATING MINI LOG CARD
          Positioned(
            top: 10,
            left: 120,
            child: Container(
              width: 160,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue.shade200),
                boxShadow: [
                  BoxShadow(
                    blurRadius: 6,
                    color: Colors.black.withOpacity(0.08),
                  )
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("9:30 AM", style: TextStyle(fontSize: 12)),
                  const SizedBox(height: 5),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      Text("100ml"),
                      Text("10%"),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Container(
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.blue.shade100,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: FractionallySizedBox(
                      widthFactor: 0.1,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.blue,
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ================= BUTTON =================

  void _addWater() async {
    setState(() {
      currentWater += 250;
      glasses += 1;
    });

    await _saveWater();
    await _loadTodayWater();
    await _loadWeeklyWater();

  }

  void _removeWater() async {
    if (currentWater <= 0) return;

    setState(() {
      currentWater -= 250;
      glasses -= 1;
    });

    await _saveWater();
    await _loadTodayWater();
  }

  void _showAddWaterDialog() {
    final controller = TextEditingController();
    String selectedUnit = "ML";

    showDialog(
      context: context,
      builder: (_) {
        return StatefulBuilder(
          builder: (context, setDialogState) {

            double enteredValue =
                double.tryParse(controller.text) ?? 0;

            double previewMl =
            selectedUnit == "ML"
                ? enteredValue
                : enteredValue * 1000;

            int previewGlasses =
            (previewMl ~/ 250).toInt();

            return Dialog(
              insetPadding: const EdgeInsets.symmetric(horizontal: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Container(
                width: MediaQuery.of(context).size.width * 0.9,
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [

                    // TITLE
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "Add Water Intake",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                    ),

                    const SizedBox(height: 18),

                    // INPUT FIELD
                    TextField(
                      controller: controller,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        hintText: "Enter amount",
                        filled: true,
                        fillColor: Colors.grey.shade200,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      onChanged: (_) {
                        setDialogState(() {});
                      },
                    ),

                    const SizedBox(height: 14),

                    // UNIT SELECTOR
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _unitChip(
                          label: "ML",
                          selected: selectedUnit == "ML",
                          onTap: () {
                            setDialogState(() {
                              selectedUnit = "ML";
                            });
                          },
                        ),
                        const SizedBox(width: 10),
                        _unitChip(
                          label: "Litre",
                          selected: selectedUnit == "Litre",
                          onTap: () {
                            setDialogState(() {
                              selectedUnit = "Litre";
                            });
                          },
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // PREVIEW
                    if (enteredValue > 0)
                      Text(
                        "≈ $previewGlasses glass(es)",
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Colors.blue,
                        ),
                      ),

                    const SizedBox(height: 22),

                    // BUTTON ROW
                    Row(
                      children: [

                        // CANCEL
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text(
                            "Cancel",
                            style: TextStyle(color: Colors.grey[800]),
                          ),
                        ),

                        const Spacer(),

                        // REMOVE
                        SizedBox(
                          width: 120,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFF44336),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                vertical: 12,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),

                                side: const BorderSide(
                                  color: Colors.black,
                                  width: 1,
                                ),
                              ),
                            ),
                            onPressed: () async {

                              final value = double.tryParse(controller.text);

                              if (value != null && value > 0) {

                                double ml =
                                selectedUnit == "ML"
                                    ? value
                                    : value * 1000;

                                setState(() {

                                  currentWater -= ml.toInt();

                                  if (currentWater < 0) {
                                    currentWater = 0;
                                  }

                                  glasses = (currentWater ~/ 250);
                                });

                                await _saveWater();
                                await _loadTodayWater();
                              }

                              Navigator.pop(context);
                            },
                            child: const Text("Remove"),
                          ),
                        ),

                        const SizedBox(width: 10),

                        // ADD WATER
                        SizedBox(
                          width: 120,
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [
                                  Color(0xFF7CEAA4),
                                  Color(0xFF49D57C),
                                  Color(0xFF21C55D),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(12),

                              // 👇 ADD THIS
                              border: Border.all(
                                color: Colors.black,
                                width: 1.5,
                              ),
                            ),
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                shadowColor: Colors.transparent,
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              onPressed: ()async {

                                final value = double.tryParse(controller.text);

                                if (value != null && value > 0) {

                                  double ml =
                                  selectedUnit == "ML"
                                      ? value
                                      : value * 1000;

                                  setState(() {
                                    currentWater += ml.toInt();
                                    glasses = (currentWater ~/ 250);
                                  });


                                  await _saveWater();
                                  await _loadTodayWater();
                                }

                                Navigator.pop(context);
                              },
                              child: const Text(
                                "Add Water",
                                style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        )
                      ],
                    )
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
  void _showGoalDialog() {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text("Set Daily Water Goal"),
          content: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              hintText: "Enter goal in ml",
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),

            ElevatedButton(
              onPressed: () async {
                final value = int.tryParse(controller.text);

                if (value != null && value > 0) {

                  setState(() {
                    targetWater = value; // 🔥 update UI
                  });

                  await _saveWater();       // 🔥 save in backend
                  await _loadTodayWater(); // 🔥 reload UI

                  Navigator.pop(context);
                }
              },
              child: const Text("Save"),
            ),
          ],
        );
      },
    );
  }
  Widget _unitChip({
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 8,
        ),
        decoration: BoxDecoration(
          color: selected
              ? const Color(0xFF22C55E)
              : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : Colors.black,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _dashboardButton() {
    return Column(
      children: [

        Container(
          width: MediaQuery.of(context).size.width * 0.6,
          // Figma width
          height: 61,
          // Figma height
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            gradient: const LinearGradient(
              colors: [
                Color(0xFF7CEAA4),
                Color(0xFF49D57C),
                Color(0xFF21C55D),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            border: Border.all(
              color: Colors.black,
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.25),
                offset: const Offset(-5, 5),
                blurRadius: 5,
                spreadRadius: 2,
              ),
            ],
          ),
          alignment: Alignment.center,
          child: const Text(
            "Go To Dashboard",
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
        ),

        const SizedBox(height: 12),

        SizedBox(
          width: 214,
          child: Text(
            "${(progress * 100).toInt()}% of today's goal",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              color: Color(0xFF2E7D32),
            ),
          ),
        ),
      ],
    );
  }
  Widget _weeklySummary() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Weekly Summary",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),

          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  blurRadius: 6,
                  color: Colors.black.withOpacity(0.08),
                )
              ],
            ),
            child: Column(
              children: weeklyWater.entries.map((e) {

                String value = e.value >= 1000
                    ? "${(e.value / 1000).toStringAsFixed(1)} L"
                    : "${e.value} ml";

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(e.key),
                      Text(value),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

