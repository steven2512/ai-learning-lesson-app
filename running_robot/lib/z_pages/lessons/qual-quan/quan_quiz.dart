// lib/z_pages/lessons/LessonTzhee/lesson3_5_mcq.dart
// ✅ LessonStepFive — Tricky MCQ with illustration + tinted feedback box

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:running_robot/core/widgets.dart';
import 'package:running_robot/z_pages/assets/lessonAssets/helpful_tools.dart';
import 'package:running_robot/z_pages/assets/lessonAssets/mcq_box.dart';

const double lesson3FontSize = 20;
const double feedbackFontSize = 16; // ✅ global font size for feedback
const Color mainConceptColor = Color.fromARGB(255, 255, 109, 12);
final double screenH = ScreenSize.height;

class QuanQuiz extends StatefulWidget {
  final VoidCallback? onStepCompleted; // ✅ notify parent when correct

  const QuanQuiz({super.key, this.onStepCompleted});

  @override
  State<QuanQuiz> createState() => _QuanQuizState();
}

class _QuanQuizState extends State<QuanQuiz> {
  String? feedbackMessage;
  bool? isCorrectAnswer;

  void _showFeedback(int index, bool isCorrect) {
    setState(() {
      isCorrectAnswer = isCorrect;
      if (isCorrect) {
        feedbackMessage =
            "Correct ✅ There is no real meaning to calculate or measure phone numbers";
        widget.onStepCompleted?.call(); // ✅ trigger completion event
      } else if (index == 0) {
        feedbackMessage = "Incorrect ❌ You can measure and calculate with age.";
      } else if (index == 1) {
        feedbackMessage =
            "Incorrect ❌ You can measure and calculate with height.";
      } else if (index == 3) {
        feedbackMessage =
            "Incorrect ❌ You can measure and calculate with weight.";
      } else {
        feedbackMessage = "Incorrect ❌ This can be measured.";
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 🟦 Question box
          LessonText.box(
            margin: const EdgeInsets.only(bottom: 18),
            child: LessonText.sentence([
              LessonText.word("Which", Colors.black87,
                  fontSize: lesson3FontSize),
              LessonText.word("one", Colors.black87, fontSize: lesson3FontSize),
              LessonText.word("is", Colors.black87, fontSize: lesson3FontSize),
              LessonText.word("NOT", Colors.red,
                  fontSize: lesson3FontSize,
                  fontWeight: FontWeight.w900,
                  italic: true),
              LessonText.word("quantitative", mainConceptColor,
                  fontSize: lesson3FontSize, fontWeight: FontWeight.w900),
              LessonText.word("data?", Colors.black87,
                  fontSize: lesson3FontSize),
            ]),
          ),

          // 🟦 Illustration box
          LessonText.box(
            margin: const EdgeInsets.only(bottom: 10),
            child: Center(
              child: Image.asset(
                "assets/images/quantitative_not.png",
                height: screenH * 0.18,
                fit: BoxFit.contain,
              ),
            ),
          ),

          // 🟦 MCQ Box
          MCQBox(
            style: 1,
            correctAnswer: 2, // Phone number ❌
            answers: [
              "Age",
              "Height",
              "Phone number",
              "Weight",
            ],
            lockCorrectAnswer: true,
            answerFill: Colors.white,
            onAnswerTap: _showFeedback,
          ),

          // 🟦 Feedback box (tinted)
          if (feedbackMessage != null)
            LessonText.box(
              margin: const EdgeInsets.only(top: 10),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: isCorrectAnswer == true
                    ? Colors.green.shade50
                    : Colors.red.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: (isCorrectAnswer == true ? Colors.green : Colors.red)
                      .withOpacity(0.4),
                  width: 1,
                ),
              ),
              child: Text(
                feedbackMessage!,
                style: GoogleFonts.lato(
                  fontSize: feedbackFontSize,
                  fontWeight: FontWeight.w600,
                  color: isCorrectAnswer == true
                      ? Colors.green.shade700
                      : Colors.red.shade700,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
