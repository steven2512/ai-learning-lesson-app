import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:running_robot/z_pages/assets/lessonN/mcq_box.dart';

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
  final ValueNotifier<bool>? answeredNotifier;
  final VoidCallback? onRoundComplete;

  const LessonStepOne({
    super.key,
    this.answeredNotifier,
    this.onRoundComplete,
  });

  @override
  LessonStepOneState createState() => LessonStepOneState();
}

class LessonStepOneState extends State<LessonStepOne> {
  int currentRound = 0;
  bool _answeredCorrect = false;
  bool _triedWrong = false;

  final List<_QuizItem> quizItems = const [
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

  void _handleAnswerTap(int selectedIndex) {
    final current = quizItems[currentRound];
    if (selectedIndex == current.correctIndex) {
      setState(() {
        _answeredCorrect = true;
        _triedWrong = false;
      });
      widget.answeredNotifier?.value = true;
    } else {
      if (!_answeredCorrect) {
        setState(() => _triedWrong = true);
      }
      widget.answeredNotifier?.value = false;
    }
  }

  /// Called by LessonOne on "Continue"
  void nextRound() {
    if (_answeredCorrect && currentRound < quizItems.length - 1) {
      setState(() {
        currentRound++;
        _answeredCorrect = false;
        _triedWrong = false;
      });
      widget.answeredNotifier?.value = false;
    } else if (currentRound == quizItems.length - 1) {
      widget.onRoundComplete?.call(); // finished quiz
    }
  }

  bool get isLastRound => currentRound == quizItems.length - 1;

  @override
  Widget build(BuildContext context) {
    final current = quizItems[currentRound];

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
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
                child: Image.asset(
                  current.image,
                  fit: BoxFit.contain,
                ),
              ),
            ),

            // ✅ MCQ
            MCQBox(
              key: ValueKey(
                  currentRound), // 👈 this forces Flutter to rebuild fresh each round
              question: _buildSentence([
                _word(current.question, Colors.black87, fontSize: 22),
              ], alignment: WrapAlignment.center, constrainWidth: false),
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

            // ✅ Try Again
            if (_triedWrong && !_answeredCorrect)
              _feedbackBox(
                "Try Again!",
                Colors.red.shade50,
                Colors.red.shade700,
              ),

            // ✅ Correct
            if (_answeredCorrect)
              _feedbackBox(
                isLastRound
                    ? "🎉 Great job! You finished the quiz."
                    : "Correct ✅ Tap Continue to move on",
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

  static Widget _word(String text, Color color,
      {FontWeight? fontWeight, double? fontSize}) {
    return Text(
      "$text ",
      style: GoogleFonts.lato(
        fontSize: fontSize ?? 20,
        fontWeight: fontWeight ?? FontWeight.w800,
        color: color,
      ),
    );
  }

  static Widget _buildSentence(List<Widget> words,
      {WrapAlignment alignment = WrapAlignment.start,
      bool constrainWidth = true}) {
    final content = Wrap(alignment: alignment, children: words);
    return constrainWidth
        ? ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: maxTextWidth),
            child: content,
          )
        : Center(child: content);
  }
}
