import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:running_robot/z_pages/assets/lessonAssets/helpful_tools.dart'; // ✅ LessonText helpers
import 'package:running_robot/z_pages/assets/lessonAssets/mcq_box.dart'; // ✅ Your MCQBox with style: 1 support

const Color _mainConceptColor = Color.fromARGB(255, 255, 109, 12);
const double _correctTextSize = 20;

/// ✅ PredictionExercise
/// Top box: "Guess what number comes next?"
/// Middle box: placeholder image (replace later)
/// Bottom: MCQBox style: 1 with options [3, 5, 13, 17], correct is 17.
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
    // Options in order: [3, 5, 13, 17] => correct index = 3
    final isCorrect = selectedIndex == 3;
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
      LessonText.sentence([
        LessonText.word("Correct", Colors.green.shade800,
            fontSize: _correctTextSize, fontWeight: FontWeight.w700),
        LessonText.word("🎉", Colors.green.shade800,
            fontSize: _correctTextSize),
      ]),
      const SizedBox(height: 6),
      LessonText.sentence([
        LessonText.word("Rule:", Colors.black87,
            fontWeight: FontWeight.bold, fontSize: 18),
        LessonText.word(" add", Colors.black87, fontSize: 18),
        LessonText.word(" 4", Colors.green.shade800,
            fontSize: 18, fontWeight: FontWeight.w700),
        LessonText.word(" each step → next is", Colors.black87, fontSize: 18),
        LessonText.word(" 17", Colors.green.shade800,
            fontSize: 18, fontWeight: FontWeight.w700),
        LessonText.word(".", Colors.black87, fontSize: 18),
      ]),
    ];

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30),
        child: Column(
          children: [
            // ✅ Heading box
            LessonText.box(
              margin: const EdgeInsets.only(bottom: 20),
              padding: const EdgeInsets.all(14),
              child: Center(
                child: LessonText.sentence([
                  LessonText.word("What", Colors.black87, fontSize: 22),
                  LessonText.word("number", _mainConceptColor, fontSize: 22),
                  LessonText.word("comes", Colors.black87, fontSize: 22),
                  LessonText.word("next", _mainConceptColor, fontSize: 22),
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
                height: 220,
                child: ClipRRect(
                  borderRadius: const BorderRadius.all(Radius.circular(12)),
                  // ⬇️ Replace with your actual placeholder asset path
                  child: Image.asset(
                    'assets/images/placeholder.png', // <-- placeholder
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),

            // ✅ MCQ — question omitted (like "question: false"), style: 1 (2×2 grid)
            MCQBox(
              // question: null, // (omitted on purpose)
              answers: const ["3", "5", "13", "17"],
              correctAnswer: 3, // index of "17"
              width: double.infinity,
              height: 250,
              padding: const [16, 15, 10, 16, 16, 16],
              colorFill: Colors.white,
              borderRadius: 12,
              fontSize: 20,
              textColor: Colors.black,
              answerFill: Colors.white,
              answerFontWeight: FontWeight.w500,
              answerFontSize: 18,
              defaultAnimation: true,
              lockCorrectAnswer: true,
              style: 1, // 🔥 2×2 layout (TL, TR, BL, BR)
              onAnswerTap: (index, _) => _handleAnswerTap(index),
            ),

            const SizedBox(height: 20),

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

  // ✅ Same feedback helpers as your DataTypeQuiz pattern
  Widget _feedbackBoxText(String msg, Color bg, Color borderColor) {
    return LessonText.box(
      padding: const EdgeInsets.all(14),
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
