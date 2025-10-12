// FILE: lib/z_pages/lessons/labels-intro/label_quiz.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:running_robot/core/widgets.dart';
import 'package:running_robot/z_pages/assets/lessonAssets/helpful_tools.dart';
import 'package:running_robot/z_pages/assets/lessonAssets/mcq_box.dart';

const Color _mainConceptColor =
    Color.fromARGB(255, 255, 109, 12); // 🟧 Orange for main term
const Color _labelColor = Color(0xFF2E7D32); // 🟩 Green for “label”
const Color _emphRed = Color(
    0xFFD32F2F); // 🔴 Emphasis red for “the column” & (cat, bird, or fish)

final double _textSize = ScreenSize.category == ScreenCategory.medium
    ? 17
    : ScreenSize.category == ScreenCategory.small
        ? 14
        : 18;
final double screenH = ScreenSize.height;
final double screenW = ScreenSize.width;

/// 🧩 LabelQuiz — “What is the label?” question
class LabelQuiz extends StatefulWidget {
  final VoidCallback? onCompleted;

  const LabelQuiz({super.key, this.onCompleted});

  @override
  State<LabelQuiz> createState() => _LabelQuizState();
}

class _LabelQuizState extends State<LabelQuiz> {
  bool _answeredCorrect = false;
  bool _triedWrong = false;

  void _handleAnswerTap(int selectedIndex) {
    // Answers: ["Feature", "Label", "Data sample", "Dataset"] → correct = 1
    final bool isCorrect = selectedIndex == 1;
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
    // ✂️ Shortened success message to 2 lines max
    final List<Widget> successMsg = [
      LessonText.sentence([
        LessonText.word("Correct!", Colors.black87,
            fontWeight: FontWeight.w900, fontSize: _textSize),
        LessonText.word("The", Colors.black87, fontSize: _textSize),
        LessonText.word("label", _labelColor,
            fontSize: _textSize, fontWeight: FontWeight.w800),
        LessonText.word("names", Colors.black87, fontSize: _textSize),
        LessonText.word("what", Colors.black87, fontSize: _textSize),
        LessonText.word("it", Colors.black87, fontSize: _textSize),
        LessonText.word("is.", Colors.black87, fontSize: _textSize),
      ]),
      const SizedBox(height: 6),
      LessonText.sentence([
        LessonText.word("Features", _mainConceptColor,
            fontSize: _textSize, fontWeight: FontWeight.w800),
        LessonText.word("describe", Colors.black87, fontSize: _textSize),
        LessonText.word("the", Colors.black87, fontSize: _textSize),
        LessonText.word("sample", Colors.black87, fontSize: _textSize),
        LessonText.word("(e.g.,", Colors.black87, fontSize: _textSize),
        LessonText.word("legs,", Colors.black87, fontSize: _textSize),
        LessonText.word("fur).", Colors.black87, fontSize: _textSize),
      ]),
    ];

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30),
        child: Column(
          children: [
            // ------------------------------------------------------------
            // ✅ BIG BOX — Details first (features + pills)
            // ------------------------------------------------------------
            LessonText.box(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.black26, width: 1),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  LessonText.sentence([
                    LessonText.word("Each", Colors.black87,
                        fontSize: _textSize),
                    LessonText.word("row", Colors.black87,
                        fontSize: _textSize, fontWeight: FontWeight.w700),
                    LessonText.word("includes", Colors.black87,
                        fontSize: _textSize),
                    LessonText.word("features", _mainConceptColor,
                        fontSize: _textSize, fontWeight: FontWeight.w800),
                    LessonText.word("such", Colors.black87,
                        fontSize: _textSize),
                    LessonText.word("as:", Colors.black87, fontSize: _textSize),
                  ]),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _featurePill("Number of legs", Colors.indigo),
                      _featurePill("Has fur (Yes/No)", Colors.teal),
                      _featurePill("Lays eggs (Yes/No)", Colors.deepOrange),
                    ],
                  ),
                ],
              ),
            ),

            // ------------------------------------------------------------
            // 🧠 SMALL BOX — Simplified question, split per word
            // “What do you call the column that tells what kind it is (cat, bird or fish)?”
            // “the” + “column” red; “(cat, bird or fish)” blue (as in your current version)
            // ------------------------------------------------------------
            LessonText.box(
              margin: const EdgeInsets.only(bottom: 15),
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border:
                    Border.all(color: _labelColor.withOpacity(0.4), width: 1),
              ),
              child: Center(
                child: LessonText.sentence(
                  [
                    LessonText.word("What", Colors.black87, fontSize: 20),
                    LessonText.word("do", Colors.black87, fontSize: 20),
                    LessonText.word("you", Colors.black87, fontSize: 20),
                    LessonText.word("call", Colors.black87, fontSize: 20),
                    LessonText.word("the", _emphRed,
                        fontSize: 20, fontWeight: FontWeight.w900),
                    LessonText.word("column", _emphRed,
                        fontSize: 20, fontWeight: FontWeight.w900),
                    LessonText.word("that", Colors.black87, fontSize: 20),
                    LessonText.word("tells", Colors.black87, fontSize: 20),
                    LessonText.word("what", Colors.black87, fontSize: 20),
                    LessonText.word("kind", Colors.black87, fontSize: 20),
                    LessonText.word("it", Colors.black87, fontSize: 20),
                    LessonText.word("is", Colors.black87, fontSize: 20),
                    LessonText.word("(cat,", Color.fromARGB(255, 13, 108, 233),
                        fontSize: 20, fontWeight: FontWeight.w900),
                    LessonText.word("bird", Color.fromARGB(255, 13, 108, 233),
                        fontSize: 20, fontWeight: FontWeight.w900),
                    LessonText.word("or", Color.fromARGB(255, 13, 108, 233),
                        fontSize: 20, fontWeight: FontWeight.w900),
                    LessonText.word("fish)?", Color.fromARGB(255, 13, 108, 233),
                        fontSize: 20, fontWeight: FontWeight.w900),
                  ],
                  alignment: WrapAlignment.center,
                ),
              ),
            ),

            // ------------------------------------------------------------
            // 🟩 MCQ Box (unchanged)
            // ------------------------------------------------------------
            MCQBox(
              answers: const [
                "Feature",
                "Label",
                "Data sample",
                "Dataset",
              ],
              correctAnswer: 1,
              width: double.infinity,
              height: screenH * 0.3,
              padding: const [16, 15, 10, 16, 16, 16],
              colorFill: Colors.white,
              borderRadius: 12,
              fontSize: 20,
              textColor: Colors.black,
              answerFill: Colors.white,
              answerFontWeight: FontWeight.w500,
              answerFontSize: _textSize,
              defaultAnimation: true,
              lockCorrectAnswer: true,
              style: 1,
              onAnswerTap: (index, _) => _handleAnswerTap(index),
            ),

            const SizedBox(height: 10),

            if (_triedWrong && !_answeredCorrect)
              _feedbackBoxText(
                "❌ Try Again! Think about what describes what the animal *is*.",
                Colors.red.shade50,
                Colors.red.shade700,
              ),

            if (_answeredCorrect)
              _feedbackBoxWidgets(
                  successMsg, Colors.green.shade50, Colors.green.shade700),
          ],
        ),
      ),
    );
  }

  // ✅ Pill helper — bright background, white Lato text
  Widget _featurePill(String text, Color bg) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        text,
        style: GoogleFonts.lato(
          color: Colors.white,
          fontSize: _textSize,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }

  // (Bullet helper kept for future use; not used now)
  Widget _bullet(String text) {
    return Row(
      children: [
        const Text("• ", style: TextStyle(fontSize: 18, color: Colors.black87)),
        Expanded(
          child: Text(
            text,
            style: GoogleFonts.lato(
              fontSize: _textSize,
              color: Colors.black87,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
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
