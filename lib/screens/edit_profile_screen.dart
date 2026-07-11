import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../core/api_config.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {

  final TextEditingController usernameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController cityController = TextEditingController();
  bool isGoogleUser = false;

  Future<void> loadProfile() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("auth_token");
      print("TOKEN = $token");
      if (token == null) return;

      final baseUrl = await ApiConfig.getBaseUrl();

      final response = await http.get(
        Uri.parse("$baseUrl/auth/user/profile"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
      );

      print("PROFILE RESPONSE = ${response.body}");

      if (response.statusCode == 200) {
        print(response.body);
        final data = jsonDecode(response.body);

        setState(() {
          usernameController.text = data["name"] ?? "";
          emailController.text = data["email"] ?? "";
          phoneController.text = data["phone"] ?? "";
          cityController.text = data["city"] ?? "";

          // Google email lock logic
          isGoogleUser = data["authProvider"] == "google";
        });
      }
    } catch (e) {
      print("Load profile error: $e");
    }
  }

  @override
  void initState() {
    super.initState();
    loadProfile();
  }
  Future<void> updateProfile() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("auth_token");
      if (token == null) return;

      final baseUrl = await ApiConfig.getBaseUrl();

      final response = await http.put(
        Uri.parse("$baseUrl/auth/user/profile"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode({
          "name": usernameController.text,
          "email": emailController.text,
          "phone": phoneController.text,
          "city": cityController.text,
        }),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Profile updated successfully")),
        );
      } else {
        print("Update failed: ${response.body}");
      }
    } catch (e) {
      print("Update profile error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
      isDark ? const Color(0xFF0E1117) : const Color(0xFFEAEAEA),
      body: Stack(
        children: [

          /// TOP CURVES (SAME AS PROFILE)
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

          /// CONTENT
          SafeArea(
            child: SingleChildScrollView(
              child: Column(
                children: [

                  const SizedBox(height: 20),

                  /// HEADER ROW
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        IconButton(
                          icon: Icon(Icons.arrow_back,
                              color: isDark
                                  ? Colors.white
                                  : Colors.black),
                          onPressed: () => Navigator.pop(context),
                        ),
                        const SizedBox(width: 6),
                        const Text(
                          "Edit Profile",
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 40),

                  /// PROFILE ICON CARD
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isDark
                          ? const Color(0xFF161B22)
                          : Colors.white,
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          color: isDark
                              ? Colors.black.withOpacity(0.4)
                              : Colors.black26,
                          blurRadius: 10,
                        )
                      ],
                    ),
                    child: Column(
                      children: [
                        const Icon(Icons.account_circle,
                            size: 80, color: Colors.grey),
                        const SizedBox(height: 5),
                        Text(
                          "Edit picture",
                          style: TextStyle(
                            color: isDark
                                ? Colors.white
                                : Colors.black,
                          ),
                        )
                      ],
                    ),
                  ),

                  const SizedBox(height: 40),

                  /// FORM
                  Padding(
                    padding:
                    const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment:
                      CrossAxisAlignment.start,
                      children: [

                        Text("Username",
                            style: TextStyle(
                                color: isDark
                                    ? Colors.white
                                    : Colors.black)),
                        const SizedBox(height: 8),
                        buildTextField(
                            usernameController, isDark),

                        const SizedBox(height: 20),

                        Text("Email ID",
                            style: TextStyle(
                                color: isDark
                                    ? Colors.white
                                    : Colors.black)),
                        const SizedBox(height: 8),
                        buildTextField(
                          emailController,
                          isDark,
                          readOnly: isGoogleUser,
                        ),

                        const SizedBox(height: 20),

                        Text("Phone",
                            style: TextStyle(
                                color: isDark ? Colors.white : Colors.black)),
                        const SizedBox(height: 8),
                        buildTextField(phoneController, isDark),

                        const SizedBox(height: 20),

                        Text("City",
                            style: TextStyle(
                                color: isDark ? Colors.white : Colors.black)),
                        const SizedBox(height: 8),
                        buildTextField(cityController, isDark),

                        const SizedBox(height: 40),

                        Center(
                          child: ElevatedButton(
                            onPressed: updateProfile,
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                              const Color(0xFF22C55E),
                              padding:
                              const EdgeInsets.symmetric(
                                  horizontal: 60,
                                  vertical: 15),
                              shape: RoundedRectangleBorder(
                                borderRadius:
                                BorderRadius.circular(10),
                              ),
                              elevation: isDark ? 8 : 4,
                              shadowColor:
                              const Color(0xFF22C55E),
                            ),
                            child: const Text(
                              "Update",
                              style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.white),
                            ),
                          ),
                        ),
                      ],
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
  @override
  void dispose() {
    usernameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    cityController.dispose();
    super.dispose();
  }

  Widget buildTextField(
      TextEditingController controller,
      bool isDark, {
        bool readOnly = false,
      }) {
    return TextField(
      controller: controller,
      readOnly: readOnly,
      style: TextStyle(
        color: isDark ? Colors.white : Colors.black,
      ),
      decoration: InputDecoration(
        suffixIcon: readOnly
            ? const Icon(Icons.lock, color: Colors.grey)
            : const Icon(Icons.edit, color: Color(0xFF22C55E)),
        filled: true,
        fillColor: isDark ? const Color(0xFF161B22) : Colors.white,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFF22C55E)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFF22C55E), width: 2),
        ),
      ),
    );
  }
}