import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

class EmailSupportScreen extends StatefulWidget {
  const EmailSupportScreen({super.key});

  @override
  State<EmailSupportScreen> createState() => _EmailSupportScreenState();
}

class _EmailSupportScreenState extends State<EmailSupportScreen> {
  final _formKey = GlobalKey<FormState>();

  String selectedSubject = "Bug Report";

  final List<String> subjects = [
    "Bug Report",
    "Payment Issue",
    "Account Problem",
    "Feature Request",
    "Other",
  ];

  static const Color _green = Color(0xFF22C55E);
  static const Color _darkHeader = Color(0xFF1F3D2B);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bool isDark = theme.brightness == Brightness.dark;

    final Color lightCurve =
    isDark ? _darkHeader.withOpacity(0.7) : const Color(0xFF77C192);

    final Color darkCurve =
    isDark ? _darkHeader : const Color(0xFF56B278);

    return Scaffold(
      backgroundColor: isDark ? Colors.black : const Color(0xFFF3EDF7),
      body: Stack(
        children: [

          /// ================= CURVE =================
          Container(
            height: 200,
            child: Stack(
              children: [

                Positioned(
                  top: -100,
                  left: -40,
                  right: -30,
                  child: Container(
                    height: 301,
                    decoration: BoxDecoration(
                      color: lightCurve,
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(600),
                        bottomRight: Radius.circular(520),
                      ),
                    ),
                  ),
                ),

                Positioned(
                  top: -160,
                  left: -20,
                  right: 10,
                  child: Container(
                    height: 320,
                    decoration: BoxDecoration(
                      color: darkCurve,
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(1000),
                        bottomRight: Radius.circular(1300),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          /// ================= CONTENT =================
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  /// HEADER
                  Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: Icon(
                          Icons.arrow_back,
                          color: isDark ? Colors.white : Colors.black,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        "Email Support",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color:
                          isDark ? Colors.white : Colors.black,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  Text(
                    "We're here to help you",
                    style: TextStyle(
                      fontSize: 17,
                      color: isDark
                          ? Colors.white70
                          : Colors.black,
                    ),
                  ),

                  const SizedBox(height: 120),

                  /// ================= FORM CARD =================
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: isDark
                          ? const Color(0xFF1E1E1E)
                          : Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(
                              isDark ? 0.4 : 0.12),
                          blurRadius: 15,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [

                          _buildField("Full Name", LucideIcons.user, isDark),
                          const SizedBox(height: 16),

                          _buildField("Enter your email", LucideIcons.mail, isDark),
                          const SizedBox(height: 16),

                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              "Subject",
                              style: TextStyle(
                                fontSize: 12,
                                color: isDark
                                    ? Colors.white70
                                    : Colors.black,
                              ),
                            ),
                          ),

                          const SizedBox(height: 6),

                          DropdownButtonFormField<String>(
                            value: selectedSubject,
                            dropdownColor:
                            isDark ? Colors.grey[900] : Colors.white,
                            decoration: _inputDecoration(
                                "Select subject",
                                LucideIcons.alertTriangle,
                                isDark),
                            items: subjects
                                .map((e) => DropdownMenuItem(
                              value: e,
                              child: Text(
                                e,
                                style: TextStyle(
                                  color: isDark
                                      ? Colors.white
                                      : Colors.black,
                                ),
                              ),
                            ))
                                .toList(),
                            onChanged: (val) {
                              setState(() {
                                selectedSubject = val!;
                              });
                            },
                          ),

                          const SizedBox(height: 16),

                          /// MESSAGE FIELD (LOGIC SAME)
                          TextFormField(
                            minLines: 1,
                            maxLines: null,
                            cursorColor: isDark ? Colors.white : Colors.black,
                            style: TextStyle(
                              color: isDark
                                  ? Colors.white
                                  : Colors.black,
                            ),
                            keyboardType: TextInputType.multiline,
                            decoration: _messageDecoration(isDark),
                          ),

                          const SizedBox(height: 14),

                          Align(
                            alignment: Alignment.centerLeft,
                            child: TextButton.icon(
                              onPressed: () {},
                              icon: const Icon(
                                LucideIcons.paperclip,
                                size: 18,
                                color: _green,
                              ),
                              label: const Text(
                                "Attach Screenshot",
                                style: TextStyle(
                                  color: _green,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 20),

                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () {},
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _green,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              child: const Text(
                                "Send Message",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 22),

                  Center(
                    child: Text(
                      "We usually respond within 24 hours.",
                      style: TextStyle(
                        color: _green,
                        fontSize: 15,
                      ),
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

  InputDecoration _inputDecoration(
      String hint, IconData icon, bool isDark) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(
        color: isDark ? Colors.white60 : Colors.black54,
      ),
      prefixIcon: Icon(
        icon,
        size: 18,
        color: _green,
      ),
      filled: true,
      fillColor:
      isDark ? const Color(0xFF2A2A2A) : Colors.white,
      contentPadding:
      const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(
          color: isDark
              ? Colors.white24
              : const Color(0xFFE5E5E5),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(
          color: _green,
          width: 1.6,
        ),
      ),
    );
  }

  InputDecoration _messageDecoration(bool isDark) {
    return InputDecoration(
      labelText: "Additional details",
      labelStyle: TextStyle(
        color: isDark ? Colors.white70 : Colors.black,
      ),
      floatingLabelStyle: TextStyle(
        color: isDark ? Colors.white : Colors.black,
      ),
      prefixIcon: Icon(
        LucideIcons.messageSquare,
        size: 20,
        color: isDark ? Colors.white70 : Colors.black,
      ),
      filled: true,
      fillColor:
      isDark ? const Color(0xFF2A2A2A) : Colors.white,
      contentPadding:
      const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(
          color: isDark
              ? Colors.white24
              : const Color(0xFFD6D6D6),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(
          color: _green,
          width: 1.5,
        ),
      ),
    );
  }

  Widget _buildField(String hint, IconData icon, bool isDark) {
    return TextFormField(
      cursorColor: isDark ? Colors.white : Colors.black,
      style: TextStyle(
        color: isDark ? Colors.white : Colors.black,
      ),
      decoration: _inputDecoration(hint, icon, isDark),
    );
  }
}