import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:meal_plan/features/auth/signup.dart';
import 'package:meal_plan/services/auth_service.dart';
import 'package:meal_plan/screens/main_shell.dart';
import 'package:meal_plan/features/auth/forgot_password.dart';
import '../../main.dart'; // 👈 for setupFCM()
import 'package:meal_plan/services/notification_service.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  bool _obscurePassword = true;
  bool _logoutMessageShown = false;

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final FocusNode _emailFocus = FocusNode();
  final FocusNode _passwordFocus = FocusNode();

  final AuthService _authService = AuthService();

  Future<void> _handleGoogleLogin() async {
    final success = await _authService.signInWithGoogle();
    if (!mounted) return;

    if (!success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Google sign-in failed")),
      );
      return;
    }

    await Future.delayed(const Duration(milliseconds: 300));
    await setupFCM();

    print("🚀 Triggering notification scheduling...");

    // ✅ TEST INSTANT NOTIFICATION FIRST
      await NotificationService.showNotification(
      "TEST NOW 🔥",
      "If you see this → notification works",
    );

    await NotificationService.scheduleNotification(
      id: 1,
      title: "Test Reminder 🚀",
      body: "Local notification working!",
      scheduledTime: DateTime.now().add(Duration(seconds: 10)),
    );

    // ⏳ IMPORTANT DELAY
    await Future.delayed(Duration(seconds: 2));

    if (!mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const MainShell()),
          (route) => false,
    );
  }

  Future<void> _handleLogin() async {
    if (emailController.text.isEmpty || passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("All fields are required")),
      );
      return;
    }

    final success = await _authService.login(
      emailController.text.trim(),
      passwordController.text.trim(),
    );

    if (!mounted) return;

    if (!success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Invalid email or password")),
      );
      return;
    }

    await Future.delayed(const Duration(milliseconds: 300));
    await setupFCM();

    print("🚀 Triggering notification scheduling...");

    // ✅ TEST INSTANT NOTIFICATION FIRST
    await NotificationService.showNotification(
      "TEST NOW 🔥",
      "If you see this → notification works",
    );

    await NotificationService.scheduleNotification(
      id: 1,
      title: "Test Reminder 🚀",
      body: "Local notification working!",
      scheduledTime: DateTime.now().add(Duration(seconds: 10)),
    );

// ⏳ IMPORTANT DELAY
    await Future.delayed(Duration(seconds: 2));

    if (!mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const MainShell()),
          (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final args =
    ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (args?['loggedOut'] == true && !_logoutMessageShown) {
        _logoutMessageShown = true;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Logout successful'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    });

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [

          /// LIGHT CURVE (background)
          Positioned(
            bottom: -70,
            left: -75,
            right: -70,
            child: Container(
              height: 400,
              decoration: const BoxDecoration(
                color: Color(0xFF77C192),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(600),
                  topRight: Radius.circular(520),
                ),
              ),
            ),
          ),
          /// DARK CURVE
          Positioned(
            bottom: -175,   // raises arc upward
            left: -200,     // wider arc like Figma
            right: -100,
            child: Container(
              height: 420,  // taller so curve is visible
              decoration: const BoxDecoration(
                color: Color(0xFF56B278),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(1000),
                  topRight: Radius.circular(1300),
                ),
              ),
            ),
          ),

          /// MAIN CONTENT
          SafeArea(
            child: Align(
              alignment: Alignment.topCenter,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: SingleChildScrollView(
                    keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                    child: Column(
                      children: [

                      Transform.translate(
                        offset: const Offset(0, -30), // adjust value (-20 to -40 as needed)
                        child: Column(
                          children: [

                            const SizedBox(height: 40),

                            CircleAvatar(
                              radius: 30,
                              backgroundColor: const Color(0xFF63C784),
                              child: const Icon(
                                LucideIcons.leaf,
                                color: Colors.white,
                                size: 28,
                              ),
                            ),

                            const SizedBox(height: 14),

                            const Text(
                              'Sign in',
                              style: TextStyle(
                                fontFamily: 'RobotoSlab',
                                fontSize: 28,
                                fontWeight: FontWeight.w500,
                              ),
                            ),

                            const SizedBox(height: 6),

                            const Text(
                              'Welcome to Nutrition App',
                              style: TextStyle(
                                fontFamily: 'RobotoSlab',
                                color: Color(0xFF078E39),
                                fontSize: 15,
                              ),
                            ),

                            const SizedBox(height: 26),

                            _label('Mobile no. or email address'),
                            const SizedBox(height: 8),
                            _inputField(
                              hint: 'Enter your email or mobile',
                              icon: LucideIcons.mail,
                              controller: emailController,
                              focusNode: _emailFocus,
                              textInputAction: TextInputAction.next,
                              onSubmitted: (_) =>
                                  FocusScope.of(context).requestFocus(_passwordFocus),
                            ),

                            const SizedBox(height: 20),

                            _label('Password'),
                            const SizedBox(height: 8),
                            _inputField(
                              hint: 'Enter your password',
                              icon: LucideIcons.lock,
                              controller: passwordController,
                              obscure: _obscurePassword,
                              focusNode: _passwordFocus,
                              textInputAction: TextInputAction.done,
                              onSubmitted: (_) => _handleLogin(),
                              suffix: IconButton(
                                icon: Icon(
                                  _obscurePassword
                                      ? LucideIcons.eye
                                      : LucideIcons.eyeOff,
                                  size: 18,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _obscurePassword = !_obscurePassword;
                                  });
                                },
                              ),
                            ),

                            const SizedBox(height: 4),

                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => ForgotPasswordScreen(),
                                      ),
                                    );
                                  },
                                child: const Text(
                                  'Forgot password?',
                                  style: TextStyle(
                                    fontFamily: 'RobotoSlab',
                                    color: Color(0xFF49B86C),
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ),

                          ],
                        ),
                      ),
                      // rest of UI (button, divider, google, signup link) stays same


                      const SizedBox(height: 0),

                      /// SIGN IN BUTTON
                      Container(
                        height: 48,
                        width: 200,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [
                              Color(0xFF7FD8A3),
                              Color(0xFF4FC37A),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(13), // figma radius

                          border: Border.all(
                            color: const Color(0xFF000000), // figma border color
                            width: 2,                       // figma border width
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.25),
                              blurRadius: 10,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: TextButton(
                          onPressed: _handleLogin,
                          child: const Text(
                            'Sign in',
                            style: TextStyle(
                              fontFamily: 'RobotoSlab',
                              color: Colors.black,
                              fontWeight: FontWeight.w400,
                              fontSize: 18,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 10),

                      SizedBox(
                        width: 200,
                        child: Row(
                          children: [
                            Expanded(
                              child: Divider(
                                thickness: 1.0,
                                color: Colors.black,   // changed here
                              ),
                            ),
                            const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 8),
                              child: Text(
                                "or",
                                style: TextStyle(fontFamily: 'RobotoSlab'),
                              ),
                            ),
                            Expanded(
                              child: Divider(
                                thickness: 1.0,
                                color: Colors.black,   // changed here
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 14),

                      Transform.translate(
                        offset: const Offset(0, 6),
                        child: Container(
                          width: 210,
                          height: 48,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.5), // transparent background
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.18),
                                blurRadius: 10,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              backgroundColor: Colors.transparent, // important
                              side: BorderSide.none,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            icon: Image.asset(
                              'assets/images/google_logo.png',
                              height: 18,
                            ),
                            label: const Text(
                              'Sign in with Google',
                              style: TextStyle(
                                color: Colors.black87,
                              ),
                            ),
                            onPressed: _handleGoogleLogin,
                          ),
                        ),
                      ),

                      const SizedBox(height: 14),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            "Don't have an account? ",
                            style: TextStyle(fontFamily: 'RobotoSlab'),
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const SignUpScreen(),
                                ),
                              );
                            },
                            child: const Text(
                              'Sign up',
                              style: TextStyle(
                                fontFamily: 'RobotoSlab',
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                              ),
                            ),

                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    ),
  );
}

  Widget _label(String text) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        text,
        style: const TextStyle(
          fontFamily: 'RobotoSlab',
          fontWeight: FontWeight.w400, // Regular
          fontSize: 20,                // Match Figma
          height: 1.0,                 // Line height 100%
          letterSpacing: 0,            // Figma 0%
          color: Colors.black,         // #000000
        ),
      ),
    );
  }

  Widget _inputField({
    required String hint,
    required IconData icon,
    required TextEditingController controller,
    FocusNode? focusNode,
    TextInputAction? textInputAction,
    ValueChanged<String>? onSubmitted,
    bool obscure = false,
    Widget? suffix,
  }) {
    return AnimatedBuilder(
      animation: focusNode ?? FocusNode(),
      builder: (context, _) {
        final isFocused = focusNode?.hasFocus ?? false;

        return Container(

          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              if (isFocused)
                BoxShadow(
                  color: const Color(0xFF6FD08C).withOpacity(0.35),
                  blurRadius: 10,
                  spreadRadius: 0.5,
                )
            ],
          ),
          child: TextField(
            controller: controller,
            focusNode: focusNode,
            obscureText: obscure,
            textInputAction: textInputAction,
            onSubmitted: onSubmitted,

            style: const TextStyle(   // ADD THIS
              fontFamily: 'RobotoSlab',
              fontSize: 18,
              color: Colors.black,
            ),

            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(
                fontFamily: 'RobotoSlab',
                color: Colors.grey.shade500,
                fontSize: 18,
              ),
              contentPadding:
              const EdgeInsets.symmetric(vertical: 16),

              prefixIcon: Padding(
                padding: const EdgeInsets.all(6),
                child: Container(
                  width: 34,
                  height: 34,
                  decoration: const BoxDecoration(
                    color: Color(0x63078E39), // your hex background
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Icon(
                      icon,
                      size: 18,
                      color: Color(0xFF078E39), // strong green icon
                    ),
                  ),
                ),
              ),

              suffixIcon: suffix,
              filled: true,
              fillColor: Colors.white,

              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(
                  color: Color(0xFF7BCF97),
                  width: 1.2,
                ),
              ),

              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(
                  color: Color(0xFF49B86C),
                  width: 2,
                ),
              ),

              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
        );
      },
    );
  }
}