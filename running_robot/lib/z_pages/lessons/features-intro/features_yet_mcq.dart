// FILE: lib/z_pages/lessons/features-intro/feature_yet_mcq.dart
// ✅ LessonStep — “Pick the Best Goal” (Student Study App)
// ✔ Feature pills now have solid colors + white font
// ✔ Text no longer bolded inside capsules
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
          // 🟧 Main Question Box
          LessonText.box(
            margin: const EdgeInsets.only(bottom: 18),
            padding: const EdgeInsets.all(14),
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
                const SizedBox(height: 12),

                // 🟦 Feature Capsules Grid
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  alignment: WrapAlignment.center,
                  children: [
                    _featurePill(
                        "Study hours", const Color(0xFF1976D2)), // blue
                    _featurePill(
                        "Sleep hours", const Color(0xFF178C48)), // green
                    _featurePill("Quiz scores", const Color(0xFFE65100),
                        fullWidth: true), // orange
                  ],
                ),

                const SizedBox(height: 16),

                // 🟪 Final question
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

          // 🟩 MCQ Box
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

  // 🔹 Capsule Builder Helper (solid color + white text)
  Widget _featurePill(String label, Color fillColor, {bool fullWidth = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
      constraints:
          fullWidth ? const BoxConstraints(minWidth: double.infinity) : null,
      decoration: BoxDecoration(
        color: fillColor, // solid fill
        borderRadius: BorderRadius.circular(50),
        boxShadow: [
          BoxShadow(
            color: fillColor.withOpacity(0.25),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Center(
        child: Text(
          label,
          style: GoogleFonts.lato(
            color: Colors.white, // white font
            fontSize: lessonFontSize,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
