// ✅ LessonStepSeven — Tricky MCQ for Qualitative data with illustration + tinted feedback box
//
// ✔ Layout preserved exactly (question box → image box → MCQ box → feedback box)
// ✔ New question: “Which one is qualitative data?”
// ✔ Answers short; A/B/C quantitative, D qualitative (correctAnswer = 3)

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:running_robot/z_pages/assets/lessonAssets/helpful_tools.dart';
import 'package:running_robot/z_pages/assets/lessonAssets/mcq_box.dart';

const double lesson3FontSize = 20;
const double feedbackFontSize = 16; // ✅ global font size for feedback
const Color mainConceptColor = Color.fromARGB(255, 255, 109, 12);

class QualQuiz extends StatefulWidget {
  final VoidCallback? onStepCompleted; // ✅ notify parent when correct

  const QualQuiz({super.key, this.onStepCompleted});

  @override
  State<QualQuiz> createState() => _QualQuizState();
}

class _QualQuizState extends State<QualQuiz> {
  String? feedbackMessage;
  bool? isCorrectAnswer;

  void _showFeedback(int index, bool isCorrect) {
    setState(() {
      isCorrectAnswer = isCorrect;
      if (isCorrect) {
        feedbackMessage =
            "Correct ✅ Postcode is a label/identifier — a category, not a measurement.";
        widget.onStepCompleted?.call(); // ✅ trigger completion event
      } else if (index == 0) {
        feedbackMessage =
            "Incorrect ❌ Height is measured in cm — quantitative.";
      } else if (index == 1) {
        feedbackMessage =
            "Incorrect ❌ Test score (/100) is numeric — quantitative.";
      } else if (index == 2) {
        feedbackMessage =
            "Incorrect ❌ Temperature (°C) is measured — quantitative.";
      } else {
        feedbackMessage = "Incorrect ❌ That option isn’t qualitative.";
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
              LessonText.word("Qualitative", mainConceptColor,
                  fontSize: lesson3FontSize, fontWeight: FontWeight.w900),
              LessonText.word("Data?", mainConceptColor,
                  fontSize: lesson3FontSize, fontWeight: FontWeight.w900),
            ]),
          ),

          // 🟦 Illustration box (kept as-is for layout parity)
          LessonText.box(
            margin: const EdgeInsets.only(bottom: 18),
            child: Center(
              child: Image.asset(
                "assets/images/qualitative_not.png", // kept to avoid asset changes
                height: 180,
                fit: BoxFit.contain,
              ),
            ),
          ),

          // 🟦 MCQ Box
          MCQBox(
            correctAnswer: 3, // ✅ D is qualitative
            answers: const [
              "Height (cm)",
              "Test score (/100)",
              "Temperature (°C)",
              "Postcode",
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
