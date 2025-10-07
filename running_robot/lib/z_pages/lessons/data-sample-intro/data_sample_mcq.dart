// FILE: lib/z_pages/lessons/data-sample-intro/data_sample_mcq.dart
// ✅ Slide 5 — MCQ (emit). Top instruction box, middle image box,
// bottom MCQBox (style: 1) with WHITE tiles, no question.

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:running_robot/core/widgets.dart';
import 'package:running_robot/z_pages/assets/lessonAssets/helpful_tools.dart';
import 'package:running_robot/z_pages/assets/lessonAssets/mcq_box.dart';

const double lessonFontSize = 20;
final double screenH = ScreenSize.height;
const Color mainConceptColor = Color.fromARGB(255, 255, 109, 12); // 🔸 orange

class DataSampleMCQ extends StatefulWidget {
  final VoidCallback? onStepCompleted;
  const DataSampleMCQ({super.key, this.onStepCompleted});

  @override
  State<DataSampleMCQ> createState() => _DataSampleMCQState();
}

class _DataSampleMCQState extends State<DataSampleMCQ> {
  String? feedbackMessage;
  bool? isCorrect;

  void _handleTap(int index, bool correct) {
    setState(() {
      isCorrect = correct;
      feedbackMessage = correct
          ? "✅ Correct. Data Sample is always singular."
          : "❌ Not quite. Data Sample is just one example.";
    });
    if (correct) widget.onStepCompleted?.call();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Instruction (short, with ? and Data Sample in orange)
          LessonText.box(
            margin: const EdgeInsets.only(bottom: 12),
            child: LessonText.sentence([
              LessonText.word("Choose", Colors.black87,
                  fontSize: 22, fontWeight: FontWeight.w800),
              LessonText.word("the", Colors.black87,
                  fontSize: 22, fontWeight: FontWeight.w800),
              LessonText.word("Data", mainConceptColor,
                  fontSize: 22, fontWeight: FontWeight.w900),
              LessonText.word("Sample", mainConceptColor,
                  fontSize: 22, fontWeight: FontWeight.w900),
            ]),
          ),

          // Image in a box (use your MCQ image asset)
          LessonText.box(
            padding: EdgeInsetsGeometry.symmetric(vertical: 5, horizontal: 0),
            margin: const EdgeInsets.only(bottom: 12),
            child: Center(
              child: Image.asset(
                "assets/images/data_sample_mcq.png", // <- use your exported image
                height: screenH * 0.22,
                fit: BoxFit.contain,
              ),
            ),
          ),

          // MCQ — style 1 grid, white tiles, no question string
          MCQBox(
            answers: const [
              "A. 1 apple", // ✅ correct (singular)
              "B. 3 patient records",
              "C. 3 cars",
              "D. 3 houses",
            ],
            correctAnswer: 0, // "1 apple"
            style: 1, // 2×N grid
            answerFill: Colors.white, // keep options white
            lockCorrectAnswer: true,
            onAnswerTap: _handleTap,
          ),

          if (feedbackMessage != null)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: LessonText.box(
                child: Text(
                  feedbackMessage!,
                  style: GoogleFonts.lato(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: (isCorrect ?? false)
                        ? Colors.green.shade700
                        : Colors.red.shade700,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
