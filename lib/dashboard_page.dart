import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:meal_plan/explore_page.dart';
import 'package:meal_plan/features/trackers/sleep_tracker_page.dart';
import '../core/app_style.dart';
import '../core/app_colors.dart';
import 'package:intl/intl.dart';
import '../services/daily_tip_service.dart';
import '../screens/log_workout.dart';
import '../screens/log_weight.dart';
import '../screens/meal_plan.dart';
import '../screens/ask_coach_screen.dart';
import '../services/water_service.dart';
import 'package:meal_plan/features/trackers/water_tracker_page.dart';
import 'package:meal_plan/services/animated_water_glass.dart'; // 👈 add this

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {

  bool _showHabitTracker = false;
  List<String> _selectedHabits = [];

  String _userName = '';


  String _dailyTip = '';
  bool _loadingTip = true;
  double _sleepHours = 0;

  // ---------------- WATER ----------------
  int waterGlasses = 0;     // for glass UI
  int totalWaterMl = 0;    // 👈 ADD THIS LINE (actual intake)

  int waterGoalMl = 2000;  // user daily goal
  final int mlPerGlass = 250;

  // auto calculated glass count
  final int maxGlasses = 8;

  // ---------------- ALCOHOL ----------------
  int _alcoholCount = 0;
  final int _alcoholDailyLimit = 5;

  // ---------------- SMOKING ----------------
  int _smokingCount = 0;
  final int _smokingDailyLimit = 20;

  HabitInfo? _alcoholHabit;

  HabitInfo? _smokingHabit;

  String getGreeting() {
    final hour = DateTime.now().hour;

    if (hour < 12) return "Good Morning";
    if (hour < 17) return "Good Afternoon";
    if (hour < 21) return "Good Evening";
    return "Good Night";
  }

  Future<void> _loadHabitDetails() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList('habitDetails') ?? [];

    for (final item in raw) {
      if (item.startsWith('Alcohol')) {
        _alcoholHabit = HabitInfo.fromStorage(item);
      }
      if (item.startsWith('Smoking')) {
        _smokingHabit = HabitInfo.fromStorage(item);
      }
    }
  }

  Future<void> _loadSleepData() async {
    final prefs = await SharedPreferences.getInstance();

    setState(() {
      _sleepHours = prefs.getDouble('sleepHours') ?? 0;
    });
  }

  void _removeWater() async{
    setState(() {
      totalWaterMl -= mlPerGlass;

      if (totalWaterMl < 0) {
        totalWaterMl = 0;
      }

      waterGlasses =
          waterGlasses = (totalWaterMl ~/ mlPerGlass);
    });

    await _saveWaterData();
    await _loadWaterData();
  }

  Future<void> _refreshDashboard() async {
    await _loadDailyTip();
    await _loadWaterData();
    await _loadSleepData();
    await _loadHabitTracker();
    await _loadHabitDetails();
  }

  @override
  void initState() {
    super.initState();
    _loadHabitTracker();
    _loadHabitDetails();
    _loadDailyTip();
    _loadWaterData();
    _loadUserName();
    _loadSleepData();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refreshDashboard();
    });

  }

  Future<void> _loadUserName() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _userName = prefs.getString('username') ?? 'User';
    });
  }


  Future<void> _loadWaterData() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString("userId");

    if (userId == null) return;

    final data = await WaterService.loadWater(userId: userId);

    setState(() {
      totalWaterMl = data["totalWaterMl"] ?? 0;
      waterGoalMl = data["goalMl"] ?? 2000;
      waterGlasses = data["glasses"] ?? (totalWaterMl ~/ mlPerGlass);
    });
  }
  Widget _progressSummaryCard() {
    final double waterL = totalWaterMl / 1000;

    return _dashboardCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          const Text(
            "Today's Progress",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 12),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _progressItem("💧", "Water", "${waterL.toStringAsFixed(1)}L"),
              _progressItem("😴", "Sleep", "${_sleepHours.toStringAsFixed(1)}h"),
              _progressItem("🔥", "Habits", "${_selectedHabits.length}"),
            ],
          ),
        ],
      ),
    );
  }

  Widget _progressItem(String emoji, String title, String value) {
    return Column(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 20)),
        const SizedBox(height: 4),
        Text(
          title,
          style: const TextStyle(fontSize: 11),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Future<void> _saveWaterData() async {

    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString("userId");

    if (userId == null) return;

    final today = DateTime.now().toString().split(' ')[0];

    await WaterService.saveWater(
      userId: userId,
      totalWaterMl: totalWaterMl,
      glasses: waterGlasses,
      goalMl: waterGoalMl,
      date: today,
    );
  }
  void _showAddWaterDialog() async {
    final controller = TextEditingController();
    String selectedUnit = "ML";

    showDialog(
      context: context,
      builder: (_) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            double enteredValue =
                double.tryParse(controller.text) ?? 0;

            double previewMl = selectedUnit == "ML"
                ? enteredValue
                : enteredValue * 1000;

            int previewGlasses =
            (previewMl ~/ mlPerGlass).toInt();

            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              title: const Text(
                "Add Water Intake",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [

                  // INPUT FIELD
                  TextField(
                    controller: controller,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      hintText: "Enter amount",
                      filled: true,
                      fillColor: Colors.grey.shade100,
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

                  // GLASS PREVIEW
                  if (enteredValue > 0)
                    Text(
                      "≈ $previewGlasses glass(es)",
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Colors.blue,
                      ),
                    ),
                ],
              ),

              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Cancel"),
                ),

                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF22C55E),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () async {
                    final value =
                    double.tryParse(controller.text);

                    if (value != null && value > 0) {

                      double ml = selectedUnit == "ML"
                          ? value
                          : value * 1000;

                      setState(() {
                        totalWaterMl += ml.toInt();
                        waterGlasses =
                            waterGlasses = (totalWaterMl ~/ mlPerGlass);
                      });

                      await _saveWaterData();
                      await _loadWaterData();
                      setState(() {});
                    }

                    Navigator.pop(context, true);
                  },
                  child: const Text(
                    "Add Water",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _setWaterGoalDialog() {
    final controller =
    TextEditingController(text: waterGoalMl.toString());

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Set Daily Water Goal (ml)'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
        ),
        actions: [
          TextButton(
            onPressed: () async {
              final value = int.tryParse(controller.text);
              if (value != null && value >= 500) {
                final prefs = await SharedPreferences.getInstance();
                await prefs.setInt('waterGoalMl', value);

                setState(() {
                  waterGoalMl = value;
                  waterGlasses = (totalWaterMl ~/ mlPerGlass);
                });

                // ⭐ Send updated goal to backend
                await _saveWaterData();
              }
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Future<void> _loadDailyTip() async {
    try {
      final tip = await DailyTipService.getDailyTip();
      if (!mounted) return;

      setState(() {
        _dailyTip = tip;
        _loadingTip = false;
      });
    } catch (e) {
      setState(() {
        _dailyTip = 'Stay consistent. Small habits lead to big results.';
        _loadingTip = false;
      });
    }
  }

  Future<void> _loadHabitTracker() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _showHabitTracker = prefs.getBool('hasHabitTracker') ?? false;
      _selectedHabits = prefs.getStringList('selectedHabits') ?? [];

      _alcoholCount = prefs.getInt('alcoholTodayCount') ?? 0;
      _smokingCount = prefs.getInt('smokingTodayCount') ?? 0;
    });
  }

  // ---------------- UPDATE ALCOHOL ----------------
  Future<void> _updateAlcohol(int value) async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _alcoholCount = value.clamp(0, _alcoholDailyLimit);
    });
    await prefs.setInt('alcoholTodayCount', _alcoholCount);
  }

  // ---------------- UPDATE SMOKING ----------------
  Future<void> _updateSmoking(int value) async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _smokingCount = value.clamp(0, _smokingDailyLimit);
    });
    await prefs.setInt('smokingTodayCount', _smokingCount);
  }

  // ---------------- UI ----------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        top: false,
        child: RefreshIndicator(
          onRefresh: _refreshDashboard,
          child: SingleChildScrollView(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: Stack(
                  children: [

                    // 🌿 GREEN BACKGROUND CIRCLE
                    Positioned.fill(
                      top: 850,
                      left: -30,
                      right: -30,
                      child: Align(
                        alignment: Alignment.topCenter,
                        child: Container(
                          width: MediaQuery.of(context).size.width * 1.10,
                          height: MediaQuery.of(context).size.width * 1.10,
                          decoration: BoxDecoration(
                            color: const Color(0xFFA5D6B3),
                            borderRadius: BorderRadius.circular(500),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.25),
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    // 🔹 MAIN CONTENT
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [

                        // 🔹 TOP SECTION
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 8),
                              _header(),
                              const SizedBox(height: 20),
                              _progressSummaryCard(),
                              const SizedBox(height: 20),
                              _mealPlanCard(),
                              const SizedBox(height: 20),
                              _workoutCard(),
                            ],
                          ),
                        ),

                        // 🔹 WATER SECTION
                        _waterTrackerCard(),

                        // 🔹 LOWER SECTION
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 24, 16, 60),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [

                              const SizedBox(height: 40),

                              _sleepTrackerCard(),
                              _exploreMoreTrackersCard(),

                              if (_selectedHabits.contains('Alcohol'))
                                _alcoholTrackerCard(),

                              if (_selectedHabits.contains('Smoking'))
                                _smokingTrackerCard(),

                              if (_showHabitTracker)
                                _habitTrackerCard(),

                              _dailyUsageCard(context),
                            ],
                          ),
                        ),
                      ],
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

  // ---------------- COMMON CARD ----------------
  Widget _dashboardCard({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: AppStyles.cardPadding,
      margin: const EdgeInsets.only(bottom: 16),
      decoration: AppStyles.card(context),
      child: child,
    );
  }

  // ---------------- HEADER ----------------
  Widget _header() {
    final isDark =
        Theme.of(context).brightness == Brightness.dark;

    return Stack(
      children: [

        // ===== MAIN HEADER CONTAINER (UNCHANGED) =====
        Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
          decoration: BoxDecoration(
            color: isDark
                ? const Color(0xFF1F3D2B)
                : const Color(0xFFB9F2C8),
            borderRadius: const BorderRadius.vertical(
              bottom: Radius.circular(32),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                getGreeting(),
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  color: isDark ? Colors.white : Colors.black,
                ),
              ),

              const SizedBox(height: 6),

              Row(
                children: [
                  Icon(
                    Icons.calendar_today_outlined,
                    size: 14,
                    color: isDark
                        ? const Color(0xFF7EDC9D)
                        : const Color(0xFF2E7D32),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    DateFormat('EEEE, MMM d')
                        .format(DateTime.now()),
                    style: TextStyle(
                      fontSize: 13,
                      color: isDark
                          ? const Color(0xFF7EDC9D)
                          : const Color(0xFF2E7D32),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              Text(
                'Hello, $_userName',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: isDark ? Colors.white : Colors.black,
                ),
              ),

              const SizedBox(height: 6),

              Text(
                'Ready for a healthier you?\n'
                    'Build healthy habits and track your progress.',
                style: TextStyle(
                  fontSize: 12,
                  height: 1.35,
                  color: isDark
                      ? const Color(0xFFB7F5C8)
                      : const Color(0xFF1B5E20),
                ),
              ),

              const SizedBox(height: 14),

              ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: SizedBox(
                  width: double.infinity,
                  height: 150,
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: Image.asset(
                          'assets/images/hero-food.jpg',
                          fit: BoxFit.cover,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),

        // ===== SUN IMAGE (TOP RIGHT CORNER) =====
        Positioned(
          top: -10,
          right: -10,
          child: Image.asset(
            'assets/images/sun.png',
            width: 120,
            height: 120,
            fit: BoxFit.contain,
          ),
        ),
      ],
    );
  }

  // ---------------- MEAL PLAN ----------------
  Widget _mealPlanCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.black, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(4, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _mealRow('Breakfast', [
            'Oats with milk',
            '1 Banana',
            'Boiled Eggs',
          ]),
          const SizedBox(height: 8),

          _mealRow('Lunch', [
            '2 Roti',
            'Paneer Bhurji',
            'Salad',
          ]),
          const SizedBox(height: 10),

          _mealRow('Dinner', [
            'Rice',
            'Dal',
            'Vegetable Sabzi',
          ]),
        ],
      ),
    );
  }


  Widget _mealRow(
      String title,
      List<String> meals,
      ) {
    List<Color> gradient;

    switch (title) {
      case 'Breakfast':
        gradient = [Color(0xFF0FA958), Color(0xFF0A8E47)];
        break;
      case 'Lunch':
        gradient = [Color(0xFF39C16C), Color(0xFF2EA85C)];
        break;
      case 'Dinner':
        gradient = [Color(0xFF6FD49A), Color(0xFF4FAE73)];
        break;
      default:
        gradient = [Color(0xFF49B86C), Color(0xFF2E8B57)];
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradient,
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(18),

        // Black outline like screenshot
        border: Border.all(color: Colors.black, width: 2),

        // Soft shadow
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.25),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Theme(
        data: Theme.of(context).copyWith(
          dividerColor: Colors.transparent,
        ),
        child: ExpansionTile(
          tilePadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 3),
          childrenPadding:
          const EdgeInsets.symmetric(horizontal: 20, vertical: 6),

          iconColor: Colors.black,
          collapsedIconColor: Colors.black,

          leading: const Icon(
            Icons.restaurant,
            color: Colors.black,
          ),

          title: Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 17,
              fontWeight: FontWeight.w600,
            ),
          ),

          children: meals
              .map(
                (meal) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                children: [
                  const Icon(Icons.circle,
                      size: 6, color: Colors.white),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      meal,
                      style: const TextStyle(
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          )
              .toList(),
        ),
      ),
    );
  }

  // ---------------- WORKOUT ----------------
  Widget _workoutCard() {
    return Center(
      child: FractionallySizedBox(
        widthFactor: 0.88, // smaller width than meal cards
        child: Container(
          margin: const EdgeInsets.only(top: 10),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [
                Color(0xFF7ED39A),
                Color(0xFF4FBF78),
                Color(0xFF4FBF78),
              ],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: Colors.black, width: 2),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.25),
                blurRadius: 6,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Text(
                      'Today’s Workout',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Time duration · Calories · Exercises',
                      style: TextStyle(
                        color: Colors.black87,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_forward,
                color: Colors.black,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ---------------- WATER TRACKER ----------------
  Widget _waterTrackerCard() {
    final double totalLiters = waterGoalMl / 1000;
    final double consumedMl = totalWaterMl.toDouble();
    final double progress =
    waterGoalMl == 0 ? 0 : (consumedMl / waterGoalMl).clamp(0.0, 1.0);

    return GestureDetector(
      onTap: () async {
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const WaterTrackerPage(),
          ),
        );

// 🔥 ONLY THIS LINE
        await _loadWaterData();
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 20),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              // 🔹 DAILY TIP
              Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: const BoxDecoration(
                      color: Color(0xFFC6F6D5),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.lightbulb,
                      color: Color(0xFFFACC15),
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    "Daily Health Tip",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),

              Padding(
                padding: const EdgeInsets.only(left: 46),
                child: Text(
                  _loadingTip
                      ? "Fetching today’s health tip..."
                      : _dailyTip,
                  style: const TextStyle(fontSize: 15),
                ),
              ),

              const SizedBox(height: 18),

              // 🔹 WATER HEADER
              Row(
                children: [
                  Container(
                    width: 34,
                    height: 34,
                    decoration: const BoxDecoration(
                      color: Color(0xFFC6F6D5),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.water_drop,
                      color: Color(0xFF0EA5E9),
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    "Water Intake",
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600),
                  ),
                  const Spacer(),

                  IconButton(
                    onPressed: _removeWater,
                    icon: const Icon(Icons.remove),
                  ),

                  IconButton(
                    onPressed: _showAddWaterDialog,
                    icon: const Icon(Icons.add),
                  ),

                  IconButton(
                    onPressed: _setWaterGoalDialog,
                    icon: const Icon(Icons.flag),
                  ),
                ],
              ),

              const SizedBox(height: 14),

              // 🔹 PROGRESS BAR
              LinearProgressIndicator(
                value: progress,
                minHeight: 8,
                backgroundColor: Colors.white,
                color: progress >= 1 ? Colors.green : Colors.blue,
              ),

              const SizedBox(height: 16),

              // 🔹 TEXT
              Row(
                children: [
                  Text(
                    (consumedMl / 1000).toStringAsFixed(1),
                    style: const TextStyle(
                        fontSize: 29,
                        fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(width: 4),
                  const Text("L"),
                  const Spacer(),
                  Text("/ ${totalLiters.toStringAsFixed(0)} L"),
                ],
              ),

              const SizedBox(height: 20),

              // 🔹 GLASSES
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(
                  maxGlasses,
                      (index) => AnimatedWaterGlass(
                    filled: index < waterGlasses,
                  ),
                ),
              ),

              const SizedBox(height: 50),

              // 🔹 MESSAGE
              Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      consumedMl >= waterGoalMl
                          ? "🎉 You reached today's water goal!"
                          : "Let’s go crush your goal",
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      width: 28,
                      height: 28,
                      decoration: const BoxDecoration(
                        color: Color(0xFFC6F6D5),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.local_drink,
                        color: Color(0xFF0EA5E9),
                        size: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  Widget _narrowCard({required Widget child}) {
    return Center(
      child: FractionallySizedBox(
        widthFactor: 0.88,
        child: child,
      ),
    );
  }

  Widget _exploreMoreTrackersCard() {
    return _narrowCard(
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const AllTrackersPage(),
            ),
          );
        },
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF4FBF78), Color(0xFF3AAE66)],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: Colors.black, width: 2),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.25),
                blurRadius: 6,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            children: [
              const Icon(Icons.explore, color: Colors.black),
              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'Find More to Track',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'BMI, Heart, Steps & more',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),

              const Icon(Icons.arrow_forward, color: Colors.black),
            ],
          ),
        ),
      ),
    );
  }

  // ---------------- ALCOHOL TRACKER ----------------
  Widget _alcoholTrackerCard() {
    if (_alcoholHabit == null) return const SizedBox();

    final consumed = _alcoholCount;
    final limit = _alcoholHabit!.limit;
    final unit = _alcoholHabit!.unit;
    final freq = _alcoholHabit!.frequency.toLowerCase();

    final progress =
    limit == 0 ? 0.0 : (consumed / limit).clamp(0.0, 1.0);

    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: AppStyles.card(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.local_bar, color: AppColors.accent),
              SizedBox(width: 8),
              Text('Alcohol', style: AppStyles.title(context))
            ],
          ),

          const SizedBox(height: 6),
          Text(
            '${_alcoholHabit!.frequency} limit: $limit $unit',
            style: AppStyles.subText(context),
          ),

          const SizedBox(height: 12),
          Text('Consumed this $freq'),

          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: progress,
            minHeight: 8,
            backgroundColor: Theme.of(context).dividerColor,
            color: progress > 0.9
                ? AppColors.error
                : progress > 0.7
                ? AppColors.warning
                : AppColors.accent,
            borderRadius: BorderRadius.circular(10),
          ),

          const SizedBox(height: 8),
          Text('${(progress * 100).toInt()}%'),

          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () async {
                final qty = await _showLogSheet(habit: 'Alcohol');
                if (qty != null) {
                  _updateAlcohol(_alcoholCount + qty);
                }
              },

              icon: const Icon(Icons.add),
              label: const Text('Log Drink'),

            ),
          ),
        ],
      ),
    );
  }

  Widget _smokingTrackerCard() {
    if (_smokingHabit == null) return const SizedBox();

    final consumed = _smokingCount;
    final limit = _smokingHabit!.limit;
    final freq = _smokingHabit!.frequency.toLowerCase();

    final progress =
    limit == 0 ? 0.0 : (consumed / limit).clamp(0.0, 1.0);

    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: AppStyles.card(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.smoking_rooms, color: AppColors.accent),
              SizedBox(width: 8),
              Text('Smoking', style: AppStyles.title(context))
            ],
          ),

          const SizedBox(height: 6),
          Text(
            '${_smokingHabit!.frequency} limit: $limit cigarettes',
            style: AppStyles.subText(context),
          ),

          const SizedBox(height: 12),
          Text('Consumed this $freq'),

          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: progress,
            minHeight: 8,
            backgroundColor: Theme.of(context).dividerColor,
            color: progress > 0.9
                ? AppColors.error
                : progress > 0.7
                ? AppColors.warning
                : AppColors.accent,

          ),

          const SizedBox(height: 8),
          Text('${(progress * 100).toInt()}%'),

          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              icon: const Icon(Icons.add),
              label: const Text('Log Cigarette'),

              onPressed: () async {
                final qty = await _showLogSheet(habit: 'Smoking');
                if (qty != null) {
                  _updateSmoking(_smokingCount + qty);
                }
              },
            ),
          ),
        ],
      ),
    );
  }


  // ---------------- SHARED COUNTER CARD ----------------
  Widget _habitCounterCard({
    required IconData icon,
    required String title,
    required int value,
    required int limit,
    required VoidCallback onAdd,
    required VoidCallback onRemove,
  }) {
    return Container(
      padding: AppStyles.cardPadding,
      margin: const EdgeInsets.only(bottom: 16),
      decoration: AppStyles.card(context),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: AppColors.accent,
            child: Icon(icon, color: Colors.white),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text('$value / $limit'),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.remove),
            onPressed: value > 0 ? onRemove : null,
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: value < limit ? onAdd : null,
          ),
        ],
      ),
    );
  }

  // ---------------- SLEEP TRACKER ----------------
  Widget _sleepTrackerCard() {
    return _narrowCard(
      child: GestureDetector(
        onTap: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const SleepTrackerPage(),
            ),
          );

          await _refreshDashboard();
        },
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF55C27B), Color(0xFF3BAE66)],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: Colors.black, width: 2),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.25),
                blurRadius: 6,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            children: [
              const Icon(Icons.bedtime, color: Colors.black, size: 24),
              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Sleep',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      _sleepHours > 0
                          ? '${_sleepHours.toStringAsFixed(1)}h slept today'
                          : 'Track your sleep duration',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),

              const Icon(Icons.arrow_forward, color: Colors.black),
            ],
          ),
        ),
      ),
    );
  }


  // ---------------- HABIT CHIPS ----------------
  Widget _habitTrackerCard() {
    return _dashboardCard(
      child: Wrap(
        spacing: 10,
        runSpacing: 10,
        children: _selectedHabits
            .map((habit) => Chip(
          label: Text(habit),
          backgroundColor: Theme.of(context).cardColor,
          labelStyle: const TextStyle(
            color: AppColors.primary,
          ),
        ))
            .toList(),
      ),
    );
  }

  // ---------------- DAILY USAGE ----------------
  Widget _dailyUsageCard(BuildContext context) {
    return _narrowCard(
      child: GridView.count(
        crossAxisCount: 2,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: MediaQuery.of(context).size.width < 360 ? 1.5 : 1.9,
        children: [
          _UsageTile(
            title: 'Add Meal',
            icon: Icons.restaurant,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const MealPlanScreen(),
                ),
              );
            },
          ),

          _UsageTile(
            title: 'Add Workout',
            icon: Icons.fitness_center,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const LogWorkoutScreen(),
                ),
              );
            },
          ),

          _UsageTile(
            title: 'Add Weight',
            icon: Icons.monitor_weight,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const LogWeightScreen(),
                ),
              );
            },
          ),

          _UsageTile(
            title: 'Ask Coach',
            icon: Icons.psychology,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const AskCoachScreen(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }


  Future<int?> _showLogSheet({required String habit}) {
    int quantity = 1;
    String unit = 'glass';

    return showModalBottomSheet<int>(
      context: context,
      backgroundColor: Theme.of(context).cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModal) {
            return Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    habit == 'Alcohol' ? 'Log Drink' : 'Log Cigarette',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),

                  if (habit == 'Alcohol') ...[
                    TextFormField(
                      keyboardType: TextInputType.number,
                      initialValue: '1',
                      decoration: const InputDecoration(
                        labelText: 'Quantity',
                      ),
                      onChanged: (v) =>
                      quantity = int.tryParse(v) ?? 1,
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: unit,
                      items: const [
                        DropdownMenuItem(value: 'glass', child: Text('Glass')),
                        DropdownMenuItem(value: 'ml', child: Text('ml')),
                        DropdownMenuItem(value: 'peg', child: Text('Peg')),
                      ],
                      onChanged: (v) => setModal(() => unit = v!),
                    ),
                  ] else ...[
                    TextFormField(
                      keyboardType: TextInputType.number,
                      initialValue: '1',
                      decoration: const InputDecoration(
                        labelText: 'Cigarettes',
                      ),
                      onChanged: (v) =>
                      quantity = int.tryParse(v) ?? 1,
                    ),
                  ],

                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () =>
                          Navigator.pop(context, quantity),
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

}

// ---------------- USAGE TILE ----------------
class _UsageTile extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback onTap;

  const _UsageTile({
    required this.title,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF4FBF78), Color(0xFF3AAE66)],
          ),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.black, width: 2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.25),
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [

            Icon(icon, color: Colors.white, size: 26),

            const SizedBox(height: 6),

            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 15,
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------- WATER GLASS ----------------
// class AnimatedWaterGlass extends StatelessWidget {
//   final bool filled;
//
//   const AnimatedWaterGlass({
//     super.key,
//     required this.filled,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     final width = MediaQuery.of(context).size.width * 0.06;
//
//     return SizedBox(
//       width: width,
//       height: width * 1.5,
//       child: Stack(
//         alignment: Alignment.bottomCenter,
//         children: [
//           // 💧 WATER FILL
//           AnimatedContainer(
//             duration: const Duration(milliseconds: 500),
//             width: 18,
//             height: filled ? 28 : 0,
//             decoration: BoxDecoration(
//               color: const Color(0xFF3BA4F6).withOpacity(0.65),
//               borderRadius: const BorderRadius.vertical(
//                 bottom: Radius.circular(5),
//               ),
//             ),
//           ),
//
//           // 🥛 GLASS OUTLINE
//           Container(
//             width: 18,
//             height: 34,
//             decoration: BoxDecoration(
//               border: Border.all(
//                 color: Theme.of(context).dividerColor,
//                 width: 1.5,
//               ),
//               borderRadius: const BorderRadius.vertical(
//                 top: Radius.circular(5),
//                 bottom: Radius.circular(7),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }


class HabitInfo {
  final String frequency;
  final int limit;
  final String unit;

  HabitInfo({
    required this.frequency,
    required this.limit,
    required this.unit,
  });

  factory HabitInfo.fromStorage(String raw) {
    // Alcohol|Weekly|250ml|Weekly|100ml
    final parts = raw.split('|');
    final limitPart = parts[4];

    final limit =
    int.parse(limitPart.replaceAll(RegExp(r'[^0-9]'), ''));
    final unit =
    limitPart.replaceAll(RegExp(r'[0-9]'), '');

    return HabitInfo(
      frequency: parts[3],
      limit: limit,
      unit: unit,
    );
  }
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