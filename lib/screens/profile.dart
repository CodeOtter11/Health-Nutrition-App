import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../core/theme_controller.dart';
import '../models/user_profile_data.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'edit_profile_screen.dart';
import 'change_password_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  UserProfileData? profile;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadProfile();
  }

  Future<void> loadProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final name = prefs.getString('username');
    final email = prefs.getString('email');

    setState(() {
      profile = UserProfileData(
        name: name,
        email: email,
        createdAt: DateTime.now(),
      );
      isLoading = false;
    });
  }

  Future<void> _logout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await ThemeController.resetToLight();
    await prefs.clear();

    Navigator.pushNamedAndRemoveUntil(
      context,
      '/signin',
          (route) => false,
      arguments: {'loggedOut': true},
    );
  }

  Widget settingsCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    VoidCallback? onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF161B22) : Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isDark
                ? const Color(0xFF22C55E).withOpacity(0.6)
                : const Color(0xFF22C55E),
            width: 1.2,
          ),
          boxShadow: isDark
              ? [
            BoxShadow(
              color: const Color(0xFF22C55E).withOpacity(0.15),
              blurRadius: 12,
              spreadRadius: 1,
            )
          ]
              : [],
        ),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: const Color(0xFF22C55E).withOpacity(0.15),
              child: Icon(icon, color: const Color(0xFF22C55E)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  color: isDark ? Colors.white : Colors.black,
                ),
              ),
            ),
            const Icon(Icons.chevron_right),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (profile == null) {
      return const Scaffold(
        body: Center(child: Text("Setting up profile...")),
      );
    }

    return Scaffold(
      backgroundColor:
      isDark ? const Color(0xFF0E1117) : const Color(0xFFF2F2F2),
      body: Stack(
        children: [

          /// TOP CURVES
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

          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 40),
              child: Column(
                children: [

                  const SizedBox(height: 10),

                  /// HEADER
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        // IconButton(
                        //   icon: const Icon(Icons.arrow_back),
                        //   onPressed: () => Navigator.pop(context),
                        // ),
                        const SizedBox(width: 6),
                        const Text(
                          "Profile",
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 10),

                  /// PROFILE CARD
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 35),
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: isDark
                            ? const Color(0xFF161B22)
                            : Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: const Color(0xFF22C55E),
                          width: 1.5,
                        ),
                      ),
                      child: Stack(
                        children: [

                          Column(
                            children: [
                              const Icon(Icons.account_circle,
                                  size: 80, color: Colors.grey),
                              const SizedBox(height: 10),
                              Text(
                                profile!.name ?? "",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: isDark
                                      ? Colors.white
                                      : Colors.black,
                                ),
                              ),
                              Text(
                                profile!.email ?? "",
                                style: TextStyle(
                                  color: isDark
                                      ? Colors.grey.shade400
                                      : Colors.grey,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Row(
                                children: [
                                  Expanded(child: _smallBox(isDark)),
                                  const SizedBox(width: 10),
                                  Expanded(child: _smallBox(isDark)),
                                  const SizedBox(width: 10),
                                  Expanded(child: _smallBox(isDark)),
                                ],
                              )
                            ],
                          ),

                          /// PEN DROPDOWN
                          Positioned(
                            top: 0,
                            right: 0,
                            child: PopupMenuButton<String>(
                              icon: const Icon(Icons.edit,
                                  color: Color(0xFF22C55E)),
                              onSelected: (value) {
                                if (value == "edit") {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                      const EditProfileScreen(),
                                    ),
                                  );
                                } else if (value == "password") {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                      const ChangePasswordScreen(),
                                    ),
                                  );
                                }
                              },
                              itemBuilder: (context) => const [
                                PopupMenuItem(
                                  value: "edit",
                                  child: Row(
                                    children: [
                                      Icon(Icons.person),
                                      SizedBox(width: 10),
                                      Text("Edit Profile"),
                                    ],
                                  ),
                                ),
                                PopupMenuItem(
                                  value: "password",
                                  child: Row(
                                    children: [
                                      Icon(Icons.lock),
                                      SizedBox(width: 10),
                                      Text("Change Password"),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  /// WHITE / DARK SECTION
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: isDark
                          ? const Color(0xFF0E1117)
                          : Colors.white,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(30),
                        topRight: Radius.circular(30),
                      ),
                    ),
                    child: Column(
                      children: [

                        const SizedBox(height: 20),

                        /// PREFERENCES
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 20),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              "Preferences",
                              style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600),
                            ),
                          ),
                        ),

                        const SizedBox(height: 10),

                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: const Color(0xFF22C55E),
                                width: 1.5,
                              ),
                            ),
                            child: Row(
                              children: [
                                const CircleAvatar(
                                  backgroundColor: Color(0xFFEFFAF2),
                                  child: Icon(LucideIcons.moon,
                                      color: Color(0xFF22C55E)),
                                ),
                                const SizedBox(width: 12),
                                const Expanded(child: Text("Dark mode")),
                                Switch(
                                  value: ThemeController.isDark,
                                  activeColor: Colors.white,
                                  activeTrackColor:
                                  const Color(0xFF22C55E),
                                  onChanged: (value) async {
                                    await ThemeController
                                        .toggleTheme(value);
                                    setState(() {});
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 20),

                        /// SETTINGS
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 10),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              "Settings",
                              style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600),
                            ),
                          ),
                        ),

                        const SizedBox(height: 10),

                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Column(
                            children: [
                              settingsCard(
                                context: context,
                                icon: LucideIcons.target,
                                title: "Goals & Targets",
                                onTap: () {
                                  Navigator.pushNamed(context, '/goals-targets');
                                },
                              ),

                              settingsCard(
                                context: context,
                                icon: LucideIcons.fileText,
                                title: "Medical Reports",
                                onTap: () {
                                  Navigator.pushNamed(context, '/medical-reports');
                                },
                              ),

                              settingsCard(
                                context: context,
                                icon: LucideIcons.helpCircle,
                                title: "Help & Support",
                                onTap: () {
                                  Navigator.pushNamed(context, '/help-support');
                                },
                              ),

                              settingsCard(
                                context: context,
                                icon: LucideIcons.bell,
                                title: "Reminders",
                                onTap: () {
                                  Navigator.pushNamed(context, '/reminders');
                                },
                              ),

                              settingsCard(
                                context: context,
                                icon: LucideIcons.bellRing,
                                title: "Notifications",
                                onTap: () {
                                  Navigator.pushNamed(context, '/notifications');
                                },
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 30),

                        Center(
                          child: SizedBox(
                            width: 250,
                            child: ElevatedButton.icon(
                              onPressed: () => _logout(context),
                              icon: const Icon(Icons.logout),
                              label: const Text(
                                "Logout",
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                const Color(0xFF22C55E),
                                foregroundColor: Colors.white,
                                elevation: isDark ? 8 : 6,
                                shadowColor:
                                const Color(0xFF22C55E),
                                padding: const EdgeInsets.symmetric(
                                    vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius:
                                  BorderRadius.circular(14),
                                ),
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 40),
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

  Widget _smallBox(bool isDark) {
    return Container(
      height: 60,
      decoration: BoxDecoration(
        color: isDark
            ? const Color(0xFF1A1F24)
            : const Color(0xFFF8F8F8),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFF22C55E),
          width: 1.5,
        ),
      ),
    );
  }
}