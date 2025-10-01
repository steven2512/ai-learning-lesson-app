import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:running_robot/core/widgets.dart';
import 'package:running_robot/z_pages/assets/lessonAssets/helpful_tools.dart'; // ✅ LessonText helpers
import 'package:running_robot/z_pages/assets/lessonAssets/mcq_box.dart';
import 'package:running_robot/z_pages/lessons/data-intro/data_intro.dart'; // ✅ Your MCQBox with style: 1 support

const Color _mainConceptColor =
    Color.fromARGB(255, 255, 109, 12); // 🔸 Numbers stay orange
const Color _aiConceptColor = Colors.green; // ✅ AI/predict emphasis = green
final double _correctTextSize = ScreenSize.category == ScreenCategory.medium
    ? 17
    : ScreenSize.category == ScreenCategory.small
        ? 14
        : 18;
final double screenH = ScreenSize.height;
final double screenW = ScreenSize.width;

/// ✅ PredictionExercise
class PredictionExercise extends StatefulWidget {
  final VoidCallback? onCompleted; // optional callback when correct

  const PredictionExercise({super.key, this.onCompleted});

  @override
  State<PredictionExercise> createState() => _PredictionExerciseState();
}

class _PredictionExerciseState extends State<PredictionExercise> {
  bool _answeredCorrect = false;
  bool _triedWrong = false;

  void _handleAnswerTap(int selectedIndex) {
    // Options: ["38", "20", "22", "4"] => correct index = 2
    final isCorrect = selectedIndex == 2;
    if (isCorrect) {
      setState(() {
        _answeredCorrect = true;
        _triedWrong = false;
      });
      widget.onCompleted?.call();
    } else {
      if (!_answeredCorrect) {
        setState(() => _triedWrong = true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> successMsg = [
      // 🔹 First line — Rule
      LessonText.sentence([
        LessonText.word("Rule:", Colors.black87,
            fontWeight: FontWeight.w900, fontSize: _correctTextSize),
        LessonText.word("add", Colors.black87, fontSize: _correctTextSize),
        LessonText.word("7", _mainConceptColor,
            fontSize: _correctTextSize, fontWeight: FontWeight.w700),
        LessonText.word("each step → next is", Colors.black87,
            fontSize: _correctTextSize),
        LessonText.word("22", _mainConceptColor,
            fontSize: _correctTextSize, fontWeight: FontWeight.w700),
      ]),

      const SizedBox(height: 6),

      // 🔹 Second line — AI link
      LessonText.sentence([
        LessonText.word("With", Colors.black87, fontSize: _correctTextSize),
        LessonText.word("enough", Colors.black87, fontSize: _correctTextSize),
        LessonText.word("data,", Colors.black87, fontSize: _correctTextSize),
        LessonText.word("AI", _aiConceptColor,
            fontSize: _correctTextSize,
            italic: true,
            fontWeight: FontWeight.bold),
        LessonText.word("can", Colors.black87, fontSize: _correctTextSize),
        LessonText.word("also", Colors.black87, fontSize: _correctTextSize),
        LessonText.word("predict", _aiConceptColor,
            fontSize: _correctTextSize, italic: true),
        LessonText.word("the", Colors.black87, fontSize: _correctTextSize),
        LessonText.word("next", dataOrange,
            fontSize: _correctTextSize,
            fontWeight: FontWeight.bold), // stays black
        LessonText.word("number", dataOrange,
            fontSize: _correctTextSize, fontWeight: FontWeight.w900),
        LessonText.word("like", Colors.black87, fontSize: _correctTextSize),
        LessonText.word("you", Colors.black87,
            fontWeight: FontWeight.w900, fontSize: _correctTextSize),
        LessonText.word("did!", Colors.black87,
            fontWeight: FontWeight.w900, fontSize: _correctTextSize),
      ]),
    ];

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30),
        child: Column(
          children: [
            // ✅ Heading box
            LessonText.box(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(12),
              child: Center(
                child: LessonText.sentence([
                  LessonText.word("What", Colors.black87, fontSize: 22),
                  LessonText.word("number", _mainConceptColor,
                      fontSize: 22, fontWeight: FontWeight.w800),
                  LessonText.word("comes", Colors.black87, fontSize: 22),
                  LessonText.word("next", Colors.black87,
                      fontSize: 22), // stays black
                  LessonText.word("?", Colors.black87, fontSize: 22),
                ], alignment: WrapAlignment.center),
              ),
            ),

            // ✅ Picture box (placeholder image)
            LessonText.box(
              margin: const EdgeInsets.only(bottom: 15),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.black26, width: 1),
              ),
              child: SizedBox(
                width: double.infinity,
                height: screenH * 0.25,
                child: ClipRRect(
                  borderRadius: const BorderRadius.all(Radius.circular(12)),
                  child: Image.asset(
                    'assets/images/15913.png', // <-- placeholder
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),

            // ✅ MCQ — style: 1 (2×2 grid)
            MCQBox(
              answers: const ["38", "20", "22", "4"],
              correctAnswer: 2, // index of "22"
              width: double.infinity,
              height: screenH * 0.3,
              padding: const [16, 15, 10, 16, 16, 16],
              colorFill: Colors.white,
              borderRadius: 12,
              fontSize: 20,
              textColor: Colors.black,
              answerFill: Colors.white,
              answerFontWeight: FontWeight.w500,
              answerFontSize: _correctTextSize,
              defaultAnimation: true,
              lockCorrectAnswer: true,
              style: 1,
              onAnswerTap: (index, _) => _handleAnswerTap(index),
            ),

            const SizedBox(height: 10),

            if (_triedWrong && !_answeredCorrect)
              _feedbackBoxText(
                "Try Again!",
                Colors.red.shade50,
                Colors.red.shade700,
              ),

            if (_answeredCorrect)
              _feedbackBoxWidgets(
                successMsg,
                Colors.green.shade50,
                Colors.green.shade700,
              ),
          ],
        ),
      ),
    );
  }

  // ✅ Feedback helpers
  Widget _feedbackBoxText(String msg, Color bg, Color borderColor) {
    return LessonText.box(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor.withOpacity(0.4), width: 1),
      ),
      child: Text(
        msg,
        textAlign: TextAlign.start,
        style: GoogleFonts.lato(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: borderColor,
        ),
      ),
    );
  }

  Widget _feedbackBoxWidgets(
    List<Widget> msgs,
    Color bg,
    Color borderColor,
  ) {
    return LessonText.box(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor.withOpacity(0.4), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: msgs,
      ),
    );
  }
}
