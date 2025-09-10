// lib/z_pages/lessons/LessonTzhee/lesson3_5_mcq.dart
// ✅ LessonStepFive — Tricky MCQ with illustration

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:running_robot/z_pages/assets/lessonAssets/helpful_tools.dart';
import 'package:running_robot/z_pages/assets/lessonAssets/mcq_box.dart';

const double lesson3FontSize = 20;
const Color mainConceptColor = Color.fromARGB(255, 255, 109, 12);

class LessonStepFive extends StatelessWidget {
  const LessonStepFive({super.key});

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
            margin: const EdgeInsets.only(bottom: 18),
            child: Center(
              child: Image.asset(
                "assets/images/quantitative.png",
                height: 180,
                fit: BoxFit.contain,
              ),
            ),
          ),

          // 🟦 MCQ Box (answers white fill)
          MCQBox(
            correctAnswer: 0, // Phone number ❌
            answers: [
              "Phone number",
              "Age (years)",
              "Height (cm)",
              "Weight (kg)",
            ],
            lockCorrectAnswer: true,
            answerFill: Colors.white, // ✅ blend with background
            onAnswerTap: (index, isCorrect) {
              debugPrint(
                  "Selected $index → ${isCorrect ? "Correct" : "Incorrect"}");
            },
          ),
        ],
      ),
    );
  }
}
