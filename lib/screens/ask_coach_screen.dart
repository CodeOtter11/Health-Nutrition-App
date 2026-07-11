import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../core/app_style.dart';
import 'upgrade_pro.dart';

class AskCoachScreen extends StatelessWidget {
  const AskCoachScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
      isDark ? const Color(0xFF000000) : const Color(0xFFF2F2F2),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ---------- CURVED HEADER ----------
                  Container(
                    width: double.infinity,
                    height: 150,
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                    decoration: BoxDecoration(
                      color: isDark
                          ? const Color(0xFF1F3D2B)
                          : const Color(0xFF9ED4A8),
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(40),
                        bottomRight: Radius.circular(40),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.15),
                          blurRadius: 12,
                          offset: const Offset(0, 6),
                        )
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        IconButton(
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          icon: Icon(
                            Icons.arrow_back,
                            color:
                            isDark ? Colors.white : Colors.black,
                          ),
                          onPressed: () => Navigator.pop(context),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          "Ask Coach",
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color:
                            isDark ? Colors.white : Colors.black,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "Get expert guidance",
                          style: TextStyle(
                            fontSize: 14,
                            color: isDark
                                ? const Color(0xFF7EDC9D)
                                : const Color(0xFF0F7A39),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // ---------- CONTENT ----------
                  Padding(
                    padding:
                    const EdgeInsets.fromLTRB(20, 20, 20, 30),
                    child: Column(
                      crossAxisAlignment:
                      CrossAxisAlignment.center,
                      children: [
                        // PRO BADGE
                        Container(
                          padding:
                          const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 6),
                          decoration: BoxDecoration(
                            color:
                            const Color(0xFF22C55E).withOpacity(0.2),
                            borderRadius:
                            BorderRadius.circular(999),
                          ),
                          child: const Text(
                            "Pro Feature",
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF1B8A43),
                            ),
                          ),
                        ),

                        const SizedBox(height: 20),

                        // MAIN CARD
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(22),
                          decoration: BoxDecoration(
                            color: isDark
                                ? const Color(0xFF121212)
                                : const Color(0xFFEFEFEF),
                            borderRadius:
                            BorderRadius.circular(16),
                            border: Border.all(
                                color:
                                const Color(0xFF22C55E)),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black
                                    .withOpacity(0.15),
                                blurRadius: 8,
                                offset:
                                const Offset(0, 4),
                              )
                            ],
                          ),
                          child: Column(
                            children: [
                              // ICON
                              Container(
                                height: 64,
                                width: 64,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: const Color(0xFF22C55E)
                                      .withOpacity(0.15),
                                ),
                                child: const Icon(
                                  LucideIcons.messageCircle,
                                  size: 30,
                                  color: Color(0xFF22C55E),
                                ),
                              ),

                              const SizedBox(height: 16),

                              const Text(
                                "Chat with a personal coach",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                ),
                                textAlign: TextAlign.center,
                              ),

                              const SizedBox(height: 8),

                              Text(
                                "Get personalized advice for diet, workout and lifestyle from certified fitness coaches.",
                                style: AppStyles.subText(
                                    context),
                                textAlign: TextAlign.center,
                              ),

                              const SizedBox(height: 20),

                              // FEATURES
                              _featureRow(
                                  "1-on-1 coach guidance"),
                              _featureRow(
                                  "Custom diet & workout"),
                              _featureRow(
                                  "Daily question support"),
                              _featureRow(
                                  "Progress-based suggestions"),

                              const SizedBox(height: 20),

                              // LOCKED BAR
                              Container(
                                padding:
                                const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: isDark
                                      ? Colors.white10
                                      : Colors.black12,
                                  borderRadius:
                                  BorderRadius.circular(
                                      10),
                                  border: Border.all(
                                      color:
                                      Colors.black26),
                                ),
                                child: Row(
                                  children: const [
                                    Icon(Icons.lock,
                                        size: 18),
                                    SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        "This feature is available for pro users only.",
                                        style: TextStyle(
                                            fontSize: 13),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 26),

                        // UPGRADE BUTTON
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                const UpgradeProScreen(),
                              ),
                            );
                          },
                          child: Container(
                            height: 52,
                            width: 240,
                            decoration: BoxDecoration(
                              gradient:
                              const LinearGradient(
                                colors: [
                                  Color(0xFF7EDC9D),
                                  Color(0xFF22C55E),
                                ],
                              ),
                              borderRadius:
                              BorderRadius.circular(14),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black
                                      .withOpacity(0.2),
                                  blurRadius: 8,
                                  offset:
                                  const Offset(0, 4),
                                )
                              ],
                            ),
                            child: const Center(
                              child: Text(
                                "Upgrade to pro",
                                style: TextStyle(
                                  fontWeight:
                                  FontWeight.w700,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 10),

                        Text(
                          "Cancel anytime • Secure payments",
                          style: AppStyles.subText(context),
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

  // FEATURE ROW
  Widget _featureRow(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          const Icon(
            LucideIcons.checkCircle,
            color: Color(0xFF22C55E),
            size: 18,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}
