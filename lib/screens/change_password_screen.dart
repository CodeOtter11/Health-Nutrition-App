import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../core/api_config.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() =>
      _ChangePasswordScreenState();
}

class _ChangePasswordScreenState
    extends State<ChangePasswordScreen> {

  final oldPasswordController = TextEditingController();
  final newPasswordController = TextEditingController();
  final confirmPasswordController = TextEditingController();


  Future<void> changePassword() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("auth_token");

      if (token == null) return;

      final baseUrl = await ApiConfig.getBaseUrl();

      final response = await http.put(
        Uri.parse("$baseUrl/auth/change-password"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode({
          "oldPassword": oldPasswordController.text,
          "newPassword": newPasswordController.text,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data["message"])),
        );

        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data["message"])),
        );
      }

    } catch (e) {
      print("Change password error: $e");
    }
  }
  @override
  Widget build(BuildContext context) {
    final isDark =
        Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
      isDark ? const Color(0xFF0E1117) : const Color(0xFFF2F2F2),
      body: Stack(
        children: [

          /// ===== EXACT SAME CURVES =====
          Positioned(
            top: -180,
            left: -40,
            right: -50,
            child: Container(
              height: 500,
              decoration: const BoxDecoration(
                color: Color(0xFF77C192),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(300),
                  bottomRight: Radius.circular(520),
                ),
              ),
            ),
          ),

          Positioned(
            top: -100,
            left: -20,
            right: -100,
            child: Container(
              height: 380,
              decoration: const BoxDecoration(
                color: Color(0xFF56B278),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(1000),
                  bottomRight: Radius.circular(1300),
                ),
              ),
            ),
          ),

          /// ===== CONTENT =====
          SafeArea(
            child: SingleChildScrollView(
              child: Column(
                children: [

                  const SizedBox(height: 20),

                  /// HEADER
                  Padding(
                    padding:
                    const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        IconButton(
                          icon: Icon(
                            Icons.arrow_back,
                            color: isDark
                                ? Colors.white
                                : Colors.black,
                          ),
                          onPressed: () =>
                              Navigator.pop(context),
                        ),
                        const SizedBox(width: 6),
                        const Text(
                          "Change Password",
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),

                  /// 🔥 PROPER SPACING AFTER CURVES
                  const SizedBox(height: 250),

                  /// FORM STARTS HERE
                  Padding(
                    padding:
                    const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      children: [

                        buildPasswordField(
                            "Old Password",
                            oldPasswordController,
                            isDark),
                        const SizedBox(height: 20),

                        buildPasswordField(
                            "New Password",
                            newPasswordController,
                            isDark),
                        const SizedBox(height: 20),

                        buildPasswordField(
                            "Confirm Password",
                            confirmPasswordController,
                            isDark),
                        const SizedBox(height: 40),

                        ElevatedButton(
                          onPressed: () {

                            if (oldPasswordController.text.isEmpty ||
                                newPasswordController.text.isEmpty ||
                                confirmPasswordController.text.isEmpty) {

                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text("All fields are required")),
                              );
                              return;
                            }

                            if (newPasswordController.text != confirmPasswordController.text) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text("Passwords do not match")),
                              );
                              return;
                            }

                            changePassword();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                            const Color(0xFF22C55E),
                            padding:
                            const EdgeInsets.symmetric(
                                horizontal: 50,
                                vertical: 15),
                            shape: RoundedRectangleBorder(
                              borderRadius:
                              BorderRadius.circular(30),
                            ),
                            elevation: isDark ? 8 : 4,
                            shadowColor:
                            const Color(0xFF22C55E),
                          ),
                          child: const Text(
                            "Update Password",
                            style: TextStyle(
                                color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    oldPasswordController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  Widget buildPasswordField(
      String label,
      TextEditingController controller,
      bool isDark) {
    return TextField(
      controller: controller,
      obscureText: true,
      style: TextStyle(
          color: isDark ? Colors.white : Colors.black),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          color: isDark
              ? Colors.grey.shade300
              : Colors.black,
        ),

        filled: true,
        fillColor:
        isDark ? const Color(0xFF161B22) : Colors.white,

        // Normal border
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: Color(0xFF22C55E),
            width: 1.5,
          ),
        ),

        // When user clicks input field
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: Color(0xFF22C55E),
            width: 2,
          ),
        ),

        // fallback border
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}