import 'dart:async';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

class HelpChatScreen extends StatefulWidget {
  const HelpChatScreen({super.key});

  @override
  State<HelpChatScreen> createState() => _HelpChatScreenState();
}

class _HelpChatScreenState extends State<HelpChatScreen> {
  static const Color green = Color(0xFF22C55E);

  String? selectedCategory;
  final List<_ChatMessage> messages = [];

  final Map<String, Map<String, String>> helpData = {
    "Account": {
      "Reset password":
      "No worries 😊\n\n1️⃣ Open Login screen\n2️⃣ Tap Forgot Password\n3️⃣ Enter email\n4️⃣ Check email\n5️⃣ Create new password",
      "Update profile info":
      "Open Profile → Tap Edit → Update → Save",
      "Delete account":
      "Profile → Settings → Delete Account → Confirm\n\n⚠️ This action is permanent.",
    },
    "Meals": {
      "How to log a meal":
      "Tap Add Meal → Search food → Enter quantity → Save",
      "Edit a logged meal":
      "Open Meal History → Select → Edit → Save",
      "Meal not in database":
      "Use Custom Food option to manually add meals.",
    },
    "Progress": {
      "View my statistics":
      "Open Progress tab to view calories, weight & goals.",
      "Export my data":
      "Profile → Export Data → Download PDF or CSV.",
      "Data not syncing":
      "Check internet, relogin, and update app.",
    },
    "Reminders": {
      "Reminder didn't ring":
      "Check notification permission & battery optimization.",
      "Edit reminder":
      "Open Reminders → Select → Edit → Save.",
      "Delete reminder":
      "Swipe reminder left or tap delete icon.",
    },
    "App Issues": {
      "App keeps crashing":
      "Restart app, update it, and clear cache.",
      "App is running slow":
      "Close background apps and restart device.",
      "Feature not working":
      "Update app and check internet connection.",
    },
  };

  @override
  void initState() {
    super.initState();
    _botType("Hi 👋 How can I help you today?");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F2),
      body: SafeArea(
        child: Column(
          children: [
            _header(),
            Expanded(child: _chatContainer()),
          ],
        ),
      ),
    );
  }

  // ================= HEADER =================
  Widget _header() {
    final theme = Theme.of(context);
    final bool isDark = theme.brightness == Brightness.dark;

    const Color lightHeader = Color(0xFFB9F2C8);
    const Color darkHeader = Color(0xFF1F3D2B);

    final Color lightCurve =
    isDark ? darkHeader.withOpacity(0.7) : const Color(0xFF77C192);

    final Color darkCurve =
    isDark ? darkHeader : const Color(0xFF56B278);

    return Stack(
      children: [

        /// SAME CURVE VALUES
        Container(
          height: 200,
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

        /// HEADER CONTENT
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 25, 20, 0),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () {
                    if (selectedCategory != null) {
                      setState(() {
                        selectedCategory = null;
                        messages.clear();
                      });
                      _botType("Hi 👋 How can I help you today?");
                    } else {
                      Navigator.pop(context);
                    }
                  },
                  child: Icon(
                    Icons.arrow_back,
                    size: 22,
                    color: isDark ? Colors.white : Colors.black,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  "Help chat",
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    color: isDark ? Colors.white : Colors.black,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ================= CHAT CONTAINER =================
  Widget _chatContainer() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFDFF0E4),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.black12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ListView(
        children: [
          ...messages.map(_chatBubble),
          const SizedBox(height: 16),
          if (selectedCategory == null)
            _mainOptions()
          else
            _questionOptions(),
        ],
      ),
    );
  }

  // ================= CHAT BUBBLE =================
  Widget _chatBubble(_ChatMessage msg) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        mainAxisAlignment:
        msg.isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!msg.isUser)
            Container(
              height: 32,
              width: 32,
              decoration: BoxDecoration(
                color: green.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                LucideIcons.messageCircle,
                size: 16,
                color: green,
              ),
            ),
          if (!msg.isUser) const SizedBox(width: 8),
          Flexible(
            child: Container(
              padding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: msg.isUser ? green : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.black26),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Text(
                msg.text,
                style: TextStyle(
                  color: msg.isUser ? Colors.white : Colors.black87,
                  fontSize: 14,
                  height: 1.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ================= MAIN OPTIONS =================
  Widget _mainOptions() {
    return Column(
      children: [
        _optionGrid(),
      ],
    );
  }

  Widget _optionGrid() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.black26),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          const Align(
              alignment: Alignment.centerLeft,
              child: Text("You can ask:",
                  style: TextStyle(fontWeight: FontWeight.w600))),
          const SizedBox(height: 14),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: helpData.keys.map((category) {
              return GestureDetector(
                onTap: () {
                  setState(() {
                    selectedCategory = category;
                  });
                  _botType(
                      "Sure 👍 What would you like to know about $category?");
                },
                child: Container(
                  width: 140,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: green),
                    boxShadow: [
                      BoxShadow(
                        color: green.withOpacity(0.3),
                        blurRadius: 6,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Center(
                      child: Text(category,
                          style: const TextStyle(
                              fontWeight: FontWeight.w600))),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  // ================= QUESTIONS =================
  Widget _questionOptions() {
    final questions = helpData[selectedCategory!]!.keys.toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("You can ask:",
            style: TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 10),
        ...questions.map(
              (q) => GestureDetector(
            onTap: () {
              messages.add(_ChatMessage(q, true));
              _botType(helpData[selectedCategory!]![q]!);
              setState(() {});
            },
            child: Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: green),
              ),
              child: Text(q),
            ),
          ),
        ),
      ],
    );
  }

  // ================= BOT TYPING =================
  void _botType(String text) {
    messages.add(_ChatMessage("", false));
    final index = messages.length - 1;

    int i = 0;
    Timer.periodic(const Duration(milliseconds: 18), (timer) {
      if (i < text.length) {
        setState(() {
          messages[index].text += text[i];
        });
        i++;
      } else {
        timer.cancel();
      }
    });
  }
}

class _ChatMessage {
  String text;
  final bool isUser;
  _ChatMessage(this.text, this.isUser);
}
