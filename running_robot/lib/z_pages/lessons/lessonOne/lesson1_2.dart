import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:running_robot/z_pages/assets/lessonAssets/mcq_box.dart';

const double maxTextWidth = 350;

/// Quiz item model
class _QuizItem {
  final String image;
  final String question;
  final List<String> answers;
  final int correctIndex;

  const _QuizItem({
    required this.image,
    required this.question,
    required this.answers,
    required this.correctIndex,
  });
}

class LessonStepOne extends StatefulWidget {
  final int quizIndex;
  final void Function(int quizIndex) onQuizCompleted;

  const LessonStepOne({
    super.key,
    required this.quizIndex,
    required this.onQuizCompleted,
  });

  static int get quizCount => _quizItems.length;

  // 🔧 This stays your source of truth for quizzes
  static const List<_QuizItem> _quizItems = [
    _QuizItem(
      image: "assets/images/notebook.png",
      question: "What is this data?",
      answers: ["Text", "Audio"],
      correctIndex: 0,
    ),
    _QuizItem(
      image: "assets/images/cat1.jpg",
      question: "What is this data?",
      answers: ["Picture", "Video"],
      correctIndex: 0,
    ),
    _QuizItem(
      image: "assets/images/car.jpg",
      question: "What is this data?",
      answers: ["Audio", "Text"],
      correctIndex: 0,
    ),
    _QuizItem(
      image: "assets/images/recording.png",
      question: "What is this data?",
      answers: ["Video", "Picture"],
      correctIndex: 0,
    ),
  ];

  // 🔧 FIX #1: Per-quiz success messages (index-aligned with quizzes)
  static const List<String> successMessages = [
    "Nice start — it's TEXT. Tap Continue.",
    "Yep — that's a PICTURE. Tap Continue.",
    "Correct — this one's AUDIO. Tap Continue.",
    "🎉 All correct — it's a VIDEO. Tap Continue to finish.",
  ];

  @override
  State<LessonStepOne> createState() => LessonStepOneState();
}

class LessonStepOneState extends State<LessonStepOne> {
  bool _answeredCorrect = false;
  bool _triedWrong = false;

  _QuizItem get current => LessonStepOne._quizItems[widget.quizIndex];
  bool get isLastRound => widget.quizIndex == LessonStepOne.quizCount - 1;

  void _handleAnswerTap(int selectedIndex) {
    if (selectedIndex == current.correctIndex) {
      setState(() {
        _answeredCorrect = true;
        _triedWrong = false;
      });
      widget.onQuizCompleted(widget.quizIndex);
    } else {
      if (!_answeredCorrect) {
        setState(() => _triedWrong = true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Resolve per-quiz success message with safe fallback
    final String successMsg =
        (widget.quizIndex < LessonStepOne.successMessages.length)
            ? LessonStepOne.successMessages[widget.quizIndex]
            : "Correct ✅ Tap Continue to move on";

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30),
        child: Column(
          children: [
            // ✅ Heading
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.black26, width: 1),
              ),
              child: Center(
                child: Text(
                  "What is this data?",
                  style: GoogleFonts.lato(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                ),
              ),
            ),

            // ✅ Image
            Container(
              width: double.infinity,
              height: 250,
              margin: const EdgeInsets.only(bottom: 15),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.black26, width: 1),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.asset(current.image, fit: BoxFit.contain),
              ),
            ),

            // ✅ MCQ
            MCQBox(
              key: ValueKey(widget.quizIndex),
              question:
                  Text(current.question, style: GoogleFonts.lato(fontSize: 22)),
              answers: current.answers,
              correctAnswer: current.correctIndex,
              width: double.infinity,
              height: 250,
              padding: [16, 15, 10, 16, 16, 16],
              colorFill: Colors.white,
              borderRadius: 12,
              fontSize: 20,
              textColor: Colors.black,
              answerFill: Colors.white,
              answerFontWeight: FontWeight.w500,
              answerFontSize: 18,
              defaultAnimation: true,
              lockCorrectAnswer: true,
              onAnswerTap: (index, _) => _handleAnswerTap(index),
            ),

            const SizedBox(height: 20),

            if (_triedWrong && !_answeredCorrect)
              _feedbackBox(
                  "Try Again!", Colors.red.shade50, Colors.red.shade700),

            if (_answeredCorrect)
              _feedbackBox(
                successMsg, // 🔧 FIX #1: per-quiz custom text
                Colors.green.shade50,
                Colors.green.shade700,
              ),
          ],
        ),
      ),
    );
  }

  Widget _feedbackBox(String msg, Color bg, Color text) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: text.withOpacity(0.4), width: 1),
      ),
      child: Text(
        msg,
        textAlign: TextAlign.center,
        style: GoogleFonts.lato(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: text,
        ),
      ),
    );
  }
}
