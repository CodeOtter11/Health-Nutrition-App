import 'package:flutter/material.dart';

// pages
import '../dashboard_page.dart';
import 'upgrade_pro.dart';
import 'meal_plan.dart';
import 'progress.dart';
import 'profile.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'profiles_screen.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../core/api_config.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;

  bool? isProUser;
  bool isLoadingPro = true;

  @override
  void initState() {
    super.initState();
    loadProStatus();
  }

  Future<void> loadProStatus() async {
    final prefs = await SharedPreferences.getInstance();

    String? token = prefs.getString("auth_token");

    if (token == null) {
      setState(() {
        isProUser = false;
        isLoadingPro = false;
      });
      return;
    }

    try {
      final baseUrl = await ApiConfig.getBaseUrl();

      final response = await http.get(
        Uri.parse("$baseUrl/auth/user/profile"),
        headers: {
          "Authorization": "Bearer $token",
        },
      );

      final data = jsonDecode(response.body);

      print("PRO STATUS RESPONSE: $data");

      setState(() {
        isProUser = data["isProUser"] ?? false;
        isLoadingPro = false;
      });

    } catch (e) {
      print("Pro status error: $e");

      setState(() {
        isProUser = false;
        isLoadingPro = false;
      });
    }
  }

  Future<bool> checkProStatus() async {
    final prefs = await SharedPreferences.getInstance();

    String? token = prefs.getString("auth_token");

    if (token == null) {
      return false;
    }

    try {
      final baseUrl = await ApiConfig.getBaseUrl();

      final response = await http.get(
        Uri.parse("$baseUrl/auth/user/profile"),
        headers: {
          "Authorization": "Bearer $token",
        },
      );

      final data = jsonDecode(response.body);

      print("PRO STATUS RESPONSE: $data");

      return data["isProUser"] ?? false;

    } catch (e) {
      print("Pro status error: $e");
      return false;
    }
  }

  List<Widget> get _pages => [
    const DashboardPage(),

    isLoadingPro
        ? const Center(
      child: CircularProgressIndicator(),
    )
        : isProUser == true
        ? const ProfilesScreen(
      wantsDoctor: false,
    )
        : const UpgradeProScreen(),

    const MealPlanScreen(),

    ProgressScreen(
      key: ValueKey(_currentIndex),
    ),

    const ProfileScreen(),
  ];

  final List<IconData> _icons = [
    Icons.home,
    Icons.diamond_outlined,
    Icons.restaurant,
    Icons.pie_chart_outline,
    Icons.person_outline,
  ];

  Widget _navbar() {
    final width = MediaQuery.of(context).size.width;
    final itemWidth = width / _icons.length;

    // Center position of selected tab
    double centerX = itemWidth * _currentIndex + itemWidth / 2;

    final fabSize = width * 0.15;
    final edgeSafe = fabSize * 0.9;
    final navHeight = width * 0.17;

    centerX = centerX.clamp(edgeSafe, width - edgeSafe);

    return SizedBox(
      height: navHeight,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [

          // Base background to prevent dip transparency
          Container(
            height: navHeight * 0.75,
            width: double.infinity,
            color: Colors.grey.shade200,
          ),

          // Green Navbar Shape
          ClipPath(
            clipper: NavBarClipper(
              centerX: centerX,
              total: _icons.length,
            ),
            child: Container(
              height: navHeight * 0.78,
              width: double.infinity,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF39A84A), Color(0xFF2E9B3F)],
                ),
              ),
            ),
          ),

          // Floating active icon
          AnimatedPositioned(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOut,
            bottom: navHeight * 0.12,
            left: centerX - fabSize / 2,
            child: Container(
              height: fabSize,
              width: fabSize,
              decoration: BoxDecoration(
                color: const Color(0xFF8FEA70),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.25),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(
                _icons[_currentIndex],
                color: Colors.black,
                size: fabSize * 0.45,
              ),
            ),
          ),

          // Icon row
          Positioned.fill(
            child: Row(
              children: List.generate(_icons.length, (index) {
                return Expanded(
                  child: InkWell(
                    splashColor: Colors.transparent,
                    highlightColor: Colors.transparent,
                    onTap: () {
                      setState(() => _currentIndex = index);
                    },
                    child: Padding(
                      padding: EdgeInsets.only(top: navHeight * 0.12),
                      child: Center(
                        child: Icon(
                          _icons[index],
                          size: 22,
                          color: _currentIndex == index
                              ? Colors.transparent
                              : Colors.white.withOpacity(0.9),
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade200,
      body: Stack(
        children: [
          IndexedStack(
            index: _currentIndex,
            children: _pages,
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: _navbar(),
          ),
        ],
      ),
    );
  }
}

class NavBarClipper extends CustomClipper<Path> {
  final double centerX;
  final int total;

  NavBarClipper({
    required this.centerX,
    required this.total,
  });

  @override
  Path getClip(Size size) {
    final path = Path();

    double slotWidth = size.width / total;

    // Wider pocket like your design
    double dipWidth = slotWidth * 1.40;

    // Balanced depth
    double dipDepth = size.height * 0.95;

    double curveRadius = dipWidth * 0.35;

    path.lineTo(centerX - dipWidth / 2, 0);

    // Smooth left curve
    path.cubicTo(
      centerX - curveRadius, 0,
      centerX - curveRadius, dipDepth,
      centerX, dipDepth,
    );

    // Smooth right curve
    path.cubicTo(
      centerX + curveRadius, dipDepth,
      centerX + curveRadius, 0,
      centerX + dipWidth / 2, 0,
    );

    path.lineTo(size.width, 0);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => true;
}