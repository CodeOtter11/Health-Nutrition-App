import 'package:flutter/material.dart';
import 'enter_otp_screen.dart';

class ForgotPasswordScreen extends StatelessWidget {
  ForgotPasswordScreen({super.key});

  final TextEditingController emailController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7F5),
      body: SafeArea(
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: BackButton(),
                  ),

                  const SizedBox(height: 20),

                  Image.asset(
                    "assets/images/forgot.png",
                    height: 280,
                  ),

                  const SizedBox(height: 20),

                  const Text(
                    "Forgot Password?",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 6),

                  const Text(
                    "Don’t worry, it happens! please enter registered email.",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.green),
                  ),

                  const SizedBox(height: 30),

                  // const Align(
                  //   alignment: Alignment.centerLeft,
                  //   child: Text("Enter Email Or Phone No"
                  //   ),
                  // ),

                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Enter Registered Email id Or Phone No",
                      style: TextStyle(
                        fontSize: 16,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),

                  TextField(
                    controller: emailController,
                    style: TextStyle(
                      fontSize: 13
                    ),
                    decoration: InputDecoration(
                      hintText: "Enter email or phone no",
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),

                  SizedBox(
                    width: 200,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF63C784),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const EnterOtpScreen(),
                          ),
                        );
                      },
                      child: const Text("Send code"),
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
}
