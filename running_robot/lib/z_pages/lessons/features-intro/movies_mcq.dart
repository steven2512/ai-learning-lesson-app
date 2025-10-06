// FILE: lib/z_pages/lessons/features-intro/movie_features_quiz.dart
// ✅ LessonStepSix — Movie Features MCQ (multi-select)
// ✔ Layout: Question box → Image box → MCQBox → Feedback box
// ✔ Uses mechanic: emit → triggers onStepCompleted when all correct

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:running_robot/core/widgets.dart';
import 'package:running_robot/z_pages/assets/lessonAssets/helpful_tools.dart';
// import 'package:running_robot/z_pages/assets/lessonAssets/multiple_mcq_box.dart'; // CHANGED: remove old ManyMCQBox
import 'package:running_robot/z_pages/assets/lessonAssets/mcq_box.dart'; // NEW: MCQBox with multipleOption support

const double lessonFontSize = 20;
const double feedbackFontSize = 16;
const Color mainConceptColor = Color(0xFFFF6D00);
final double screenH = ScreenSize.height;

class MovieFeaturesQuiz extends StatefulWidget {
  final VoidCallback? onStepCompleted;

  const MovieFeaturesQuiz({super.key, this.onStepCompleted});

  @override
  State<MovieFeaturesQuiz> createState() => _MovieFeaturesQuizState();
}

class _MovieFeaturesQuizState extends State<MovieFeaturesQuiz> {
  String? feedbackMessage;
  bool? isCorrectAnswer;

  void _handleSubmit(List<int> selectedIndices, bool allCorrect) {
    setState(() {
      isCorrectAnswer = allCorrect;
      if (allCorrect) {
        feedbackMessage =
            // CHANGED: shorter, 2-line success message
            "✅ Correct!\nGenre, Main Actors & Director are strong features.";
        widget.onStepCompleted?.call(); // ✅ emit done
      } else {
        feedbackMessage =
            "❌ Not quite. Think about which features truly describe the movie, not its price or filming place.";
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
          // 🟦 Question box
          // 🟦 Question box
          LessonText.box(
            margin: const EdgeInsets.only(bottom: 18),
            child: LessonText.sentence([
              LessonText.word("Choose", Colors.black87,
                  fontSize: lessonFontSize),
              LessonText.word("3", mainConceptColor,
                  fontSize: lessonFontSize, fontWeight: FontWeight.w900),
              LessonText.word("features", mainConceptColor,
                  fontSize: lessonFontSize),
              LessonText.word("that", Colors.black87, fontSize: lessonFontSize),
              LessonText.word("are", Colors.black87, fontSize: lessonFontSize),
              LessonText.word("most", Colors.black87, fontSize: lessonFontSize),
              LessonText.word("useful", Colors.black87,
                  fontSize: lessonFontSize),
              LessonText.word("for", Colors.black87, fontSize: lessonFontSize),
              LessonText.word("the", Colors.black87, fontSize: lessonFontSize),
              LessonText.word("AI.", Colors.black87, fontSize: lessonFontSize),
            ]),
          ),

          // 🟦 Image box (placeholder)
          LessonText.box(
            margin: const EdgeInsets.only(bottom: 10),
            child: Center(
              child: Image.asset(
                "assets/images/new_movie_rating_transparent.png",
                height: screenH * 0.2,
                fit: BoxFit.contain,
              ),
            ),
          ),

          // 🟦 MCQ box (multi-select) — CHANGED: uses MCQBox
          MCQBox(
            multipleOption: true, // NEW: multi-select on
            answers: const [
              "Movie Genre",
              "Ticket Price",
              "Main Actors",
              "Director",
              "Total Cameras",
              "Total Actors"
            ],
            correctAnswers: const [0, 2, 3], // NEW: multi-correct
            correctAnswer:
                0, // legacy param kept (ignored in multi mode, still validated in-range)
            style: 1, // 2×N grid (even count OK)
            submitLabel: "Submit", // NEW: button label
            onSubmitAnswers: (selected, allCorrect) {
              // NEW: submit callback
              // (kept the prints you had)
              // ignore: avoid_print
              print("Selected: $selected");
              // ignore: avoid_print
              print(allCorrect ? "✅ Correct!" : "❌ Try again");
              _handleSubmit(selected, allCorrect); // feed into feedback/emit
            },
            // You can keep other legacy visuals/locks via MCQBox defaults
            // lockCorrectAnswer: true, // optional: lock after perfect submit
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
