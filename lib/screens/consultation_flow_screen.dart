import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'slot_screen.dart';
import 'profiles_screen.dart';

class ConsultationFlowScreen extends StatefulWidget {
  const ConsultationFlowScreen({super.key});

  @override
  State<ConsultationFlowScreen> createState() =>
      _ConsultationFlowScreenState();
}

class _ConsultationFlowScreenState extends State<ConsultationFlowScreen> {
  int currentStep = 0;

  bool wantsDoctor = false;

  String? doctorSlot;
  String? dietitianSlot;
  String? coachSlot;

  // ================= ASSIGN PROFESSIONALS =================
  Future<void> assignProfessionals() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString("auth_token");

      if (token == null) {
        print("❌ Token not found");
        return;
      }

      // ---------------- DOCTOR ----------------
      if (wantsDoctor && doctorSlot != null) {
        final doctorRes = await http.post(
          Uri.parse("http://192.168.1.6:5000/api/auth/assign"),
          headers: {
            "Content-Type": "application/json",
            "Authorization": "Bearer $token",
          },
          body: jsonEncode({
            "role": "doctor",
            "slot": doctorSlot,
          }),
        );

        print("Doctor Assignment: ${doctorRes.body}");
      }

      // ---------------- DIETITIAN ----------------
      if (dietitianSlot != null) {
        final dietitianRes = await http.post(
          Uri.parse("http://192.168.1.6:5000/api/auth/assign"),
          headers: {
            "Content-Type": "application/json",
            "Authorization": "Bearer $token",
          },
          body: jsonEncode({
            "role": "dietitian",
            "slot": dietitianSlot,
          }),
        );

        print("Dietitian Assignment: ${dietitianRes.body}");
      }

      // ---------------- COACH ----------------
      if (coachSlot != null) {
        final coachRes = await http.post(
          Uri.parse("http://192.168.1.6:5000/api/auth/assign"),
          headers: {
            "Content-Type": "application/json",
            "Authorization": "Bearer $token",
          },
          body: jsonEncode({
            "role": "coach",
            "slot": coachSlot,
          }),
        );

        print("Coach Assignment: ${coachRes.body}");
      }

      print("✅ All professionals assigned successfully");
    } catch (e) {
      print("❌ Assignment Error: $e");

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Assignment Failed: $e"),
        ),
      );
    }
  }

  // ================= FLOW =================
  void nextStep() async {
    if (currentStep == 0) {
      // Ask doctor
      final result = await showDialog<bool>(
        context: context,
        builder: (_) =>
            AlertDialog(
              title: const Text("Consult a Doctor?"),
              content: const Text("Do you want to consult a doctor?"),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text("No"),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: const Text("Yes"),
                ),
              ],
            ),
      );

      wantsDoctor = result ?? false;

      if (wantsDoctor) {
        doctorSlot = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) =>
            const SlotScreen(
              title: "Doctor Slot",
            ),
          ),
        );
      }

      setState(() {
        currentStep = 1;
      });

      nextStep();
    }

    else if (currentStep == 1) {
      dietitianSlot = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) =>
          const SlotScreen(
            title: "Dietitian Slot",
          ),
        ),
      );

      setState(() {
        currentStep = 2;
      });

      nextStep();
    }

    else if (currentStep == 2) {
      coachSlot = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) =>
          const SlotScreen(
            title: "Coach Slot",
          ),
        ),
      );

      // 🔥 BACKEND ASSIGNMENT
      await assignProfessionals();

      // FINAL SCREEN
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) =>
              ProfilesScreen(
                wantsDoctor: wantsDoctor,
                doctorSlot: doctorSlot,
                dietitianSlot: dietitianSlot,
                coachSlot: coachSlot,
              ),
        ),
      );
    }
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      nextStep();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,

      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [

            // 🔥 LOADER (same everywhere in your app)
            const CircularProgressIndicator(
              color: Color(0xff4CAF50),
            ),

            const SizedBox(height: 20),

            // 🔥 TEXT (theme-based)
            Text(
              "Setting up your consultation...",
              style: theme.textTheme.bodyLarge?.copyWith(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}