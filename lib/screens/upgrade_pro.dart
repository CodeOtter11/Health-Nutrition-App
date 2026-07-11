import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../core/app_colors.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'consultation_flow_screen.dart';
import '../core/api_config.dart';

// ✅ NEW IMPORTS
import 'dart:convert';
import 'package:http/http.dart' as http;

class UpgradeProScreen extends StatefulWidget {
  const UpgradeProScreen({super.key});

  @override
  State<UpgradeProScreen> createState() => _UpgradeProScreenState();
}

class _UpgradeProScreenState extends State<UpgradeProScreen> {
  String? selectedPlan;

  // ✅ NEW FUNCTION (REPLACES RAZORPAY)
  Future<void> upgradeToPro() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      String? userId = prefs.getString("userId");
      String? token = prefs.getString("auth_token");

      if (userId == null || token == null) {
        print("❌ userId/token missing");
        return;
      }

      // get dynamic base URL
      final baseUrl = await ApiConfig.getBaseUrl();

      final response = await http.post(
        Uri.parse("$baseUrl/subscription/activate-pro"),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
        body: jsonEncode({
          "plan": selectedPlan
        }),
      );

      print("SUBSCRIPTION RESPONSE: ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // Optional local caching for faster UI load
        await prefs.setBool(
          "isProUser",
          data["user"]["isProUser"],
        );

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("🎉 Pro Activated Successfully"),
          ),
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => const ConsultationFlowScreen(),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Failed: ${response.body}"),
          ),
        );
      }

    } catch (e) {
      print("🔥 ERROR: $e");

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error: $e"),
        ),
      );
    }
  }

  // ---------------- FEATURE CARD ----------------
  Widget featureCard(
      BuildContext context, IconData icon, String title, String subtitle) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF121212) : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF22C55E)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 6,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: const Color(0xFF22C55E).withOpacity(0.15),
            child: Icon(icon, color: const Color(0xFF22C55E)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(fontWeight: FontWeight.w600)),
                Text(subtitle,
                    style: const TextStyle(fontSize: 12, color: Colors.black)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ---------------- PLAN CARD ----------------
  Widget planCard({
    required BuildContext context,
    required String planKey,
    required String title,
    required String price,
    required String period,
    String? saveText,
  }) {
    final bool selected = selectedPlan == planKey;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedPlan = planKey;
        });
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: selected
              ? (isDark
              ? const Color(0xFF1F3D2B)
              : const Color(0xFFEFFAF2))
              : (isDark ? const Color(0xFF121212) : Colors.white),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected
                ? const Color(0xFF22C55E)
                : Colors.grey.shade400,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 6,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 6),
                Text(title,
                    style: const TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 6),
                Text(price,
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                Text(
                  period,
                  style: TextStyle(
                    fontSize: 18,
                    color: isDark ? Colors.white70 : Colors.black,
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  height: 22,
                  child: saveText != null
                      ? Text(
                    saveText,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Color(0xFF22C55E),
                    ),
                  )
                      : const SizedBox(),
                ),
              ],
            ),
            if (planKey == 'yearly')
              Positioned(
                top: -25,
                right: 2,
                child: Container(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFF22C55E),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text(
                    "BEST VALUE",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // ---------------- UI ----------------
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor:
      isDark ? const Color(0xFF000000) : const Color(0xFFF2F2F2),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
              child: Column(
                children: [

                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      ),
                    ],
                  ),

                  const Icon(Icons.diamond,
                      size: 44, color: Color(0xFF22C55E)),
                  const SizedBox(height: 10),

                  const Text(
                    "Unlock Pro Features",
                    style:
                    TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 4),

                  const Text(
                    "Unlock your full potential with premium features",
                    style: TextStyle(
                        fontSize: 14, color: Color(0xFF22C55E)),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 20),

                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Premium Features",
                      style:
                      TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ),

                  const SizedBox(height: 10),

                  featureCard(context, LucideIcons.user,
                      "Personal Dietitian",
                      "Get customized meal plans and nutrition advice"),

                  featureCard(context, LucideIcons.dumbbell,
                      "Fitness Coach",
                      "Personalized workout routines for your goals"),

                  featureCard(context, LucideIcons.messageCircle,
                      "24/7 Chat Support",
                      "Direct access to your coaches anytime"),

                  featureCard(context, LucideIcons.bookOpen,
                      "Premium Recipes",
                      "Exclusive healthy recipes library"),

                  const SizedBox(height: 20),

                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Choose Your Plan",
                      style:
                      TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ),

                  const SizedBox(height: 10),

                  Row(
                    children: [
                      Expanded(
                        child: planCard(
                          context: context,
                          planKey: 'monthly',
                          title: "Monthly",
                          price: "₹499",
                          period: "/month",
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: planCard(
                          context: context,
                          planKey: 'yearly',
                          title: "Yearly",
                          price: "₹3,999",
                          period: "/year",
                          saveText: "Save ₹1,799",
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  Padding(
                    padding: EdgeInsets.symmetric(
                        horizontal: screenWidth * 0.18),
                    child: GestureDetector(
                      onTap: () {
                        if (selectedPlan == null) return;

                        // ✅ NEW FUNCTION CALL
                        upgradeToPro();
                      },
                      child: Container(
                        height: 44,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [
                              Color(0xFF7EDC9D),
                              Color(0xFF22C55E),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Center(
                          child: Text(
                            "Start Free Trial",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),

                  Padding(
                    padding: EdgeInsets.symmetric(
                        horizontal: screenWidth * 0.18),
                    child: Row(
                      mainAxisAlignment:
                      MainAxisAlignment.spaceBetween,
                      children: const [
                        Column(
                          children: [
                            Text("7 Day",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15)),
                            SizedBox(height: 2),
                            Text("free trial",
                                style: TextStyle(fontSize: 13)),
                          ],
                        ),
                        Column(
                          children: [
                            Text("No",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15)),
                            SizedBox(height: 2),
                            Text("commitment",
                                style: TextStyle(fontSize: 13)),
                          ],
                        ),
                        Column(
                          children: [
                            Text("Full",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15)),
                            SizedBox(height: 2),
                            Text("access",
                                style: TextStyle(fontSize: 13)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}