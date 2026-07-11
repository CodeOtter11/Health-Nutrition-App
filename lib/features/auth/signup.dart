import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:meal_plan/features/auth/signin.dart';
import 'package:meal_plan/features/onboarding/basic_details.dart';
import 'package:meal_plan/models/user_profile_data.dart';
import 'package:meal_plan/services/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  bool _googleLoading = false;
  bool _obscurePassword = true;

  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  final FocusNode _emailFocus = FocusNode();
  final FocusNode _nameFocus = FocusNode();
  final FocusNode _phoneFocus = FocusNode();
  final FocusNode _passwordFocus = FocusNode();

  final AuthService _authService = AuthService();
  final Color primaryGreen = const Color(0xFF22C35D);

  Future<void> _handleGoogleSignup() async {
    if (_googleLoading) return;

    setState(() => _googleLoading = true);

    final success = await _authService.signInWithGoogle();

    if (!mounted) return;
    setState(() => _googleLoading = false);

    if (!success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Google sign-in failed")),
      );
      return;
    }

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final profile = UserProfileData(
      name: user.displayName ?? "",
      email: user.email ?? "",
      phone: user.phoneNumber ?? "",
    );

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => BasicDetailsScreen(profile: profile),
      ),
    );
  }

  Future<void> _handleSignup() async {
    if (nameController.text.isEmpty ||
        emailController.text.isEmpty ||
        phoneController.text.isEmpty ||
        passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("All fields are required")),
      );
      return;
    }

    final error = await _authService.register(
      nameController.text.trim(),
      emailController.text.trim(),
      phoneController.text.trim(),
      passwordController.text.trim(),
    );

    if (!mounted) return;

    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error)),
      );
      return;
    }

    final profile = UserProfileData(
      name: nameController.text.trim(),
      email: emailController.text.trim(),
      phone: phoneController.text.trim(),
    );

    print("Navigating to BasicDetailsScreen");

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => BasicDetailsScreen(profile: profile),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SizedBox.expand(
        child: Stack(
          children: [

            /// LIGHT CURVE
            Positioned(
              bottom: -120,
              left: -25,
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
              bottom: -270,
              left: -50,
              right: -20,
              child: Container(
                height: 460,
                decoration: const BoxDecoration(
                  color: Color(0xFF56B278),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(2000),
                    topRight: Radius.circular(2600),
                  ),
                ),
              ),
            ),

            /// MAIN CONTENT
            SafeArea(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: constraints.maxHeight,
                      ),
                      child: Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 420),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            child: Column(
                              children: [

                                Transform.translate(
                                  offset: const Offset(0, -35),
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
                                        'Sign up',
                                        style: TextStyle(
                                          fontFamily: 'RobotoSlab',
                                          fontSize: 28,
                                          fontWeight: FontWeight.w700,
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

                                      _label('Email address'),
                                      _inputField(
                                        hint: 'Enter your email',
                                        icon: LucideIcons.mail,
                                        controller: emailController,
                                        focusNode: _emailFocus,
                                        textInputAction: TextInputAction.next,
                                        onSubmitted: (_) =>
                                            FocusScope.of(context).requestFocus(_nameFocus),
                                      ),

                                      const SizedBox(height: 16),

                                      _label('User name'),
                                      _inputField(
                                        hint: 'Choose a username',
                                        icon: LucideIcons.user,
                                        controller: nameController,
                                        focusNode: _nameFocus,
                                        textInputAction: TextInputAction.next,
                                        onSubmitted: (_) =>
                                            FocusScope.of(context).requestFocus(_phoneFocus),
                                      ),

                                      const SizedBox(height: 16),

                                      _label('Contact number'),
                                      _inputField(
                                        hint: 'Enter your phone number',
                                        icon: LucideIcons.phone,
                                        controller: phoneController,
                                        focusNode: _phoneFocus,
                                        textInputAction: TextInputAction.next,
                                        onSubmitted: (_) =>
                                            FocusScope.of(context).requestFocus(_passwordFocus),
                                      ),

                                      const SizedBox(height: 16),

                                      _label('Password'),
                                      _inputField(
                                        hint: 'Create a password',
                                        icon: LucideIcons.lock,
                                        controller: passwordController,
                                        obscure: _obscurePassword,
                                        focusNode: _passwordFocus,
                                        textInputAction: TextInputAction.done,
                                        onSubmitted: (_) => _handleSignup(),
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
                                    ],
                                  ),
                                ),

                                const SizedBox(height: 40),

                                Column(
                                  children: [

                                    Transform.translate(
                                      offset: const Offset(0, -27),
                                      child: _signUpButton(),
                                    ),

                                    Transform.translate(
                                      offset: const Offset(0, -25),
                                      child: Column(
                                        children: [
                                          const SizedBox(height: 14),
                                          _orDivider(),
                                          const SizedBox(height: 14),
                                          _googleButton(),
                                          const SizedBox(height: 16),
                                          _signInLink(),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 30),

                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _signUpButton() {
    return Container(
      height: 56,   // match figma height
      width: 184,   // match figma width
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
            color: Colors.black.withOpacity(0.15),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextButton(
        onPressed: _handleSignup,
        style: TextButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(13),
          ),
        ),
        child: const Text(
          'Sign up',
          style: TextStyle(
            fontFamily: 'RobotoSlab',
            color: Colors.black,
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
      ),
    );
  }

  Widget _orDivider() {
    return SizedBox(
      width: 180,
      child: Row(
        children: const [
          Expanded(child: Divider(thickness: 1.0, color: Colors.black)),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              "or",
              style: TextStyle(fontFamily: 'RobotoSlab'),
            ),
          ),
          Expanded(child: Divider(thickness: 1.0, color: Colors.black)),
        ],
      ),
    );
  }

  Widget _googleButton() {
    return Container(
      width: 210,
      height: 48,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.5), // transparent background
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
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
          style: TextStyle(color: Colors.black87),
        ),
        onPressed: _handleGoogleSignup,
      ),
    );
  }

  Widget _signInLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          "Already have an account? ",
          style: TextStyle(fontFamily: 'RobotoSlab'),
        ),
        GestureDetector(
          onTap: () {
            print("Tapped Sign In");
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const SignInScreen()),
            );
          },
          child: const Text(
            'Sign in',
            style: TextStyle(
              fontFamily: 'RobotoSlab',
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _label(String text) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        text,
        style: const TextStyle(
          fontFamily: 'RobotoSlab',
          fontSize: 20,
          color: Colors.black87,
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
    return TextField(
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
        hintStyle: const TextStyle(
          fontFamily: 'RobotoSlab',
          fontSize: 18,
          fontWeight: FontWeight.w400,
          color: Color(0x63000000), // 39% black opacity
        ),
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

        // Default border (without focus)
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: primaryGreen, width: 1.4),
        ),

        // Focused border (when typing)
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: primaryGreen, width: 2),
        ),

        // Hover border (desktop/web)
        hoverColor: primaryGreen.withOpacity(0.08),

        // Error border (optional good practice)
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.red, width: 1.5),
        ),
      ),
    );
  }
}