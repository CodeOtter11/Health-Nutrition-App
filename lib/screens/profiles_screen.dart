import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:meal_plan/dashboard_page.dart';
import 'diet_plan_view_screen.dart';
import 'chat_screen.dart';

class ProfilesScreen extends StatefulWidget {
  final bool wantsDoctor;
  final String? doctorSlot;
  final String? dietitianSlot;
  final String? coachSlot;

  const ProfilesScreen({
    super.key,
    required this.wantsDoctor,
    this.doctorSlot,
    this.dietitianSlot,
    this.coachSlot,
  });

  @override
  State<ProfilesScreen> createState() => _ProfilesScreenState();
}

class _ProfilesScreenState extends State<ProfilesScreen> {
  List consultations = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadExperts();
  }

  Future<void> loadExperts() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString("auth_token");

      print("TOKEN FROM PREFS: $token");

      final res = await http.get(
        Uri.parse("http://192.168.1.6:5000/api/auth/user/experts"),
        headers: {
          "Authorization": "Bearer $token",
        },
      );

      print("STATUS CODE: ${res.statusCode}");
      print("BODY: ${res.body}");

      final data = jsonDecode(res.body);

      setState(() {
        consultations = data["consultations"] ?? [];
        isLoading = false;
      });

    } catch (e) {
      print("Error loading experts: $e");

      setState(() {
        isLoading = false;
      });
    }
  }

  Widget buildCard(dynamic expert, BuildContext context) {
    final user = expert["userId"];

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.green.withOpacity(0.1),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          // 🔹 LEFT SIDE (PROFILE)
          CircleAvatar(
            backgroundColor: Colors.green.shade300,
            child: const Icon(Icons.person, color: Colors.white),
          ),

          const SizedBox(width: 12),

          // 🔹 CENTER TEXT
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user["name"] ?? "Unknown",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(expert["role"] ?? "No role"),
                Text("Slot: ${expert["slot"] ?? "Not assigned"}"),
              ],
            ),
          ),

          // 🔹 RIGHT SIDE BUTTONS
          Column(
            children: [
              // CHAT BUTTON
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  minimumSize: const Size(70, 30),
                  padding: EdgeInsets.zero,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: const Text("Chat", style: TextStyle(fontSize: 12)),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ChatScreen(
                        expertId: expert["userId"]["id"], // ✅ FIXED ID
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(height: 6),

              // PLAN BUTTON
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  minimumSize: const Size(70, 30),
                  padding: EdgeInsets.zero,
                  side: const BorderSide(color: Colors.green),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: const Text(
                  "Plan",
                  style: TextStyle(
                    color: Colors.green,
                    fontSize: 12,
                  ),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const DietPlanViewScreen(),
                    ),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green.shade50,

      appBar: AppBar(
        backgroundColor: Colors.green,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => DashboardPage(),
              ),
            ); // 🔥 BACK BUTTON
          },
        ),
        title: const Text("Your Experts"),
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: isLoading
            ? const Center(
          child: CircularProgressIndicator(
            color: Colors.green,
          ),
        )
            : consultations.isEmpty
            ? const Center(
          child: Text("No experts assigned yet"),
        )
            : ListView.builder(
          itemCount: consultations.length,
          itemBuilder: (context, index) {
            return buildCard(
              consultations[index],
              context,
            );
          },
        ),
      ),
    );
  }
}