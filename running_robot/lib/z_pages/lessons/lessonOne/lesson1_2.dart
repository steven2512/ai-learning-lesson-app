import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class LessonStepOne extends StatelessWidget {
  final VoidCallback onContinue;

  const LessonStepOne({super.key, required this.onContinue});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "Lesson 1.2: Data and Label",
            style: GoogleFonts.lato(
              fontSize: 24,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: onContinue,
            child: Text("Continue"),
          ),
        ],
      ),
    );
  }
}
