// FILE: lib/z_pages/lessons/features-intro/feature_yet_mcq.dart
// ✅ LessonStep — “Pick the Best Goal” (Student Study App)
// ✔ Harder MCQ with subtle distractors
// ✔ Distinct colors for features and goal
// ✔ Uses style 0 (classic vertical)

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:running_robot/core/widgets.dart';
import 'package:running_robot/z_pages/assets/lessonAssets/helpful_tools.dart';
import 'package:running_robot/z_pages/assets/lessonAssets/mcq_box.dart';

const double lessonFontSize = 20;
const double feedbackFontSize = 16;
const Color mainConceptColor = Color(0xFFFF6D00); // orange for “features”
const Color goalColor = Color(0xFF8B5CF6); // purple for “goal”
final double screenH = ScreenSize.height;

class FeatureYetMCQ extends StatefulWidget {
  final VoidCallback? onStepCompleted;

  const FeatureYetMCQ({super.key, this.onStepCompleted});

  @override
  State<FeatureYetMCQ> createState() => _FeatureYetMCQState();
}

class _FeatureYetMCQState extends State<FeatureYetMCQ> {
  String? feedbackMessage;
  bool? isCorrectAnswer;

  void _handleAnswerTap(int index, bool isCorrect) {
    setState(() {
      isCorrectAnswer = isCorrect;
      if (isCorrect) {
        feedbackMessage =
            "✅ Correct! These measurable features best help predict a student’s exam performance.";
        widget.onStepCompleted?.call();
      } else {
        feedbackMessage =
            "❌ Not quite. Think about what kind of prediction these features can directly support.";
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 🟧 Question Box
          LessonText.box(
            margin: const EdgeInsets.only(bottom: 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                LessonText.sentence([
                  LessonText.word("If", Colors.black87,
                      fontSize: lessonFontSize),
                  LessonText.word("we", Colors.black87,
                      fontSize: lessonFontSize),
                  LessonText.word("have", Colors.black87,
                      fontSize: lessonFontSize),
                  LessonText.word("these", Colors.black87,
                      fontSize: lessonFontSize),
                  LessonText.word("features:", mainConceptColor,
                      fontSize: lessonFontSize, fontWeight: FontWeight.w900),
                ]),
                const SizedBox(height: 8),
                LessonText.sentence([
                  LessonText.word("study", const Color(0xFF2196F3), // blue
                      fontSize: lessonFontSize,
                      fontWeight: FontWeight.w900),
                  LessonText.word("hours,", const Color(0xFF2196F3),
                      fontSize: lessonFontSize),
                  LessonText.word("sleep", const Color(0xFF22C55E), // green
                      fontSize: lessonFontSize,
                      fontWeight: FontWeight.w900),
                  LessonText.word("hours,", const Color(0xFF22C55E),
                      fontSize: lessonFontSize),
                  LessonText.word("and", Colors.black87,
                      fontSize: lessonFontSize),
                  LessonText.word("quiz", const Color(0xFFFF9800), // orange
                      fontSize: lessonFontSize,
                      fontWeight: FontWeight.w900),
                  LessonText.word("scores", const Color(0xFFFF9800),
                      fontSize: lessonFontSize),
                ]),
                const SizedBox(height: 8),
                LessonText.sentence([
                  LessonText.word("Which", Colors.black87,
                      fontSize: lessonFontSize),
                  LessonText.word("goal", goalColor,
                      fontSize: lessonFontSize, fontWeight: FontWeight.w900),
                  LessonText.word("are", Colors.black87,
                      fontSize: lessonFontSize),
                  LessonText.word("these", Colors.black87,
                      fontSize: lessonFontSize),
                  LessonText.word("features", mainConceptColor,
                      fontSize: lessonFontSize, fontWeight: FontWeight.w900),
                  LessonText.word("most", Colors.black87,
                      fontSize: lessonFontSize),
                  LessonText.word("useful", Colors.black87,
                      fontSize: lessonFontSize),
                  LessonText.word("for?", Colors.black87,
                      fontSize: lessonFontSize),
                ]),
              ],
            ),
          ),

          // 🟩 MCQ Box (harder options)
          MCQBox(
            question: false,
            lockCorrectAnswer: true,
            answers: const [
              "Predict how many hours the student will sleep next week",
              "Predict the student’s exam performance",
              "Predict the student’s favorite study subject",
              "Predict how consistent the student’s study routine is",
            ],
            correctAnswer: 1,
            onAnswerTap: _handleAnswerTap,
            style: 0,
          ),

          // 🟨 Feedback Box
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
