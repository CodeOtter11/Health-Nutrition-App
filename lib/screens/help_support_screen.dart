import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

  static const Color _green = Color(0xFF22C55E);
  static const Color _lightHeader = Color(0xFFB9F2C8);
  static const Color _darkHeader = Color(0xFF1F3D2B);
  static const Color _bgLight = Color(0xFFF3F4F6);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bool isDark = theme.brightness == Brightness.dark;

    final Color lightCurve =
    isDark ? _darkHeader.withOpacity(0.7) : const Color(0xFF77C192);

    final Color darkCurve =
    isDark ? _darkHeader : const Color(0xFF56B278);

    return Scaffold(
      backgroundColor: isDark ? Colors.black : _bgLight,
      body: Stack(
        children: [

          /// ================= CURVE =================
          Container(
            height: 200, // smaller header
            child: Stack(
              children: [

                /// LIGHT CURVE
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

                /// DARK CURVE
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
              child: Padding(
                padding:
                const EdgeInsets.fromLTRB(16, 40, 16, 24),
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [

                    /// HEADER TEXT
                    Row(
                      children: [
                        IconButton(
                          padding: EdgeInsets.zero,
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
                        Text(
                          "Help & Support",
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: isDark
                                ? Colors.white
                                : Colors.black,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 100),

                    /// CONTACT US
                    Text(
                      "CONTACT US",
                      style: theme.textTheme.labelMedium?.copyWith(
                        letterSpacing: 0.8,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,

                      ),
                    ),
                    const SizedBox(height: 14),

                    _contactTile(
                      context: context,
                      icon: LucideIcons.messageCircle,
                      title: "Live Chat",
                      subtitle: "Chat with our support team",
                      onTap: () {
                        Navigator.pushNamed(
                            context, '/help-chat');
                      },
                    ),
                    _contactTile(
                      context: context,
                      icon: LucideIcons.mail,
                      title: "Email Support",
                      subtitle: "support@example.com",
                      onTap: () {
                        Navigator.pushNamed(context, '/email-support');
                      },
                    ),
                    _contactTile(
                      context: context,
                      icon: LucideIcons.fileText,
                      title: "Documentation",
                      subtitle: "Browse help articles",
                      onTap: () {},
                    ),

                    const SizedBox(height: 28),

                    /// FAQ
                    Text(
                      "FREQUENTLY ASKED QUESTIONS",
                      style: theme.textTheme.labelMedium?.copyWith(
                        letterSpacing: 0.8,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 14),

                    Container(
                      decoration: BoxDecoration(
                        color: theme.cardColor,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ExpansionPanelList.radio(
                        elevation: 0,
                        expandedHeaderPadding: EdgeInsets.zero,
                        animationDuration: const Duration(milliseconds: 300),
                        children: [

                          _faqPanel(
                            "1",
                            "How do I reset my password?",
                            "Go to Profile → Change Password and follow the instructions.",
                          ),

                          _faqPanel(
                            "2",
                            "How do I track my daily goals?",
                            "Open the dashboard to monitor and update your daily goals.",
                          ),

                          _faqPanel(
                            "3",
                            "Can I sync data across devices?",
                            "Yes. Login with the same account on different devices.",
                          ),

                          _faqPanel(
                            "4",
                            "How do I delete my account?",
                            "Please contact support to permanently delete your account.",
                          ),

                          _faqPanel(
                            "5",
                            "Can I track my progress on different devices?",
                            "Yes. Your progress will automatically sync when logged in.",
                          ),

                        ],
                      ),
                    ),

                    const SizedBox(height: 32),

                    Center(
                      child: Text(
                        "App Version 1.0.0",
                        style:
                        theme.textTheme.bodySmall,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ---------- CONTACT TILE ----------
  Widget _contactTile({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: theme.dividerColor.withOpacity(0.15),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ListTile(
        onTap: onTap,
        contentPadding:
        const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        leading: Container(
          height: 44,
          width: 44,
          decoration: BoxDecoration(
            color: _green.withOpacity(0.14),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(icon, color: _green),
        ),
        title: Text(
          title,
          style: theme.textTheme.titleSmall?.copyWith(
              fontSize: 15,
              fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          subtitle,
          style: theme.textTheme.bodySmall?.copyWith(
            fontSize: 14, // ← increase here
          ),
        ),
        trailing: Icon(
          Icons.chevron_right,
          color:
          theme.iconTheme.color?.withOpacity(0.6),
        ),
      ),
    );
  }

  // ---------- FAQ TILE ----------
  Widget _faqTile(BuildContext context,
      String question,
      String answer,) {
    final theme = Theme.of(context);

    return ExpansionTile(
      leading: const Icon(
        LucideIcons.helpCircle,
        size: 18,
        color: _green,
      ),
      title: Text(
        question,
        style: theme.textTheme.bodyMedium?.copyWith(
          fontSize: 15,
          fontWeight: FontWeight.w500,
        ),
      ),
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          child: Text(
            answer,
            style: theme.textTheme.bodySmall,
          ),
        ),
      ],
    );
  }
  ExpansionPanelRadio _faqPanel(
      String value,
      String question,
      String answer,
      ) {
    return ExpansionPanelRadio(
      value: value,
      headerBuilder: (context, isExpanded) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: ListTile(
            leading: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: const Color(0xFF22C55E).withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                LucideIcons.helpCircle,
                size: 22,
                color: Color(0xFF22C55E),
              ),
            ),
            title: Text(
              question,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        );
      },
      body: Padding(
        padding: const EdgeInsets.fromLTRB(72, 0, 20, 18),
        child: Text(
          answer,
          style: const TextStyle(
            fontSize: 15,
            height: 1.5,
            color: Colors.black87,
          ),
        ),
      ),
    );
  }
}