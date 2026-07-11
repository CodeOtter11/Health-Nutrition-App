import 'package:flutter/material.dart';

class PrimaryNextButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String text;

  const PrimaryNextButton({
    super.key,
    required this.onPressed,
    this.text = "Next",
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 184,
      height: 56,
      child: GestureDetector(
        onTap: onPressed,
        child: Container(
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(13),

            gradient: const LinearGradient(
              colors: [
                Color(0xFF7FD8A3),
                Color(0xFF4FC37A),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),

            border: Border.all(
              color: Colors.black,
              width: 2,
            ),

            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                offset: const Offset(-5, 5),
                blurRadius: 8,
              ),
            ],
          ),
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              fontFamily: 'RobotoSlab',
              color: Colors.black,
            ),
          ),
        ),
      ),
    );
  }
}