import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:running_robot/z_pages/assets/lessonN/mcq_box.dart';

const double maxTextWidth = 350;

class LessonStepOne extends StatefulWidget {
  final ValueNotifier<bool>? answeredNotifier;

  const LessonStepOne({super.key, this.answeredNotifier});

  @override
  State<LessonStepOne> createState() => _LessonStepOneState();
}

class _LessonStepOneState extends State<LessonStepOne> {
  bool _answeredCorrect = false;
  bool _triedWrong = false;

  void _handleAnswerTap(int selectedIndex) {
    if (selectedIndex == 0) {
      // Dog = correct
      setState(() {
        _answeredCorrect = true;
        _triedWrong = false;
      });
      widget.answeredNotifier?.value = true;
    } else {
      // Cat = wrong
      if (!_answeredCorrect) {
        setState(() {
          _triedWrong = true;
        });
        widget.answeredNotifier?.value = false;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ✅ Dog Image
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
                  'assets/images/dog_horizontal.png',
                  fit: BoxFit.cover,
                ),
              ),
            ),

            // ✅ MCQ
            MCQBox(
              question: _buildSentence([
                _word("Is this", Colors.black87, fontSize: 24),
                _word("a dog", const Color.fromARGB(255, 78, 212, 83),
                    fontWeight: FontWeight.w600, fontSize: 24),
                _word("or", Colors.black87, fontSize: 24),
                _word("a cat?", const Color.fromARGB(221, 255, 51, 0),
                    fontSize: 24),
              ], alignment: WrapAlignment.center, constrainWidth: false),
              answers: ["Dog", "Cat"],
              correctAnswer: 0,
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
              lockCorrectAnswer: true, // assumes your MCQBox supports this
              onAnswerTap: (index, _) => _handleAnswerTap(index),
            ),

            const SizedBox(height: 20),

            // ✅ Try Again message
            if (_triedWrong && !_answeredCorrect)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.red.shade200, width: 1),
                ),
                child: Text(
                  "Try Again!",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.lato(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.red.shade700,
                  ),
                ),
              ),

            // ✅ Congrats message
            if (_answeredCorrect)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.green.shade200, width: 1),
                ),
                child: Text(
                  "Congrats 🎉 You just finished your first classification task!",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.lato(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.green.shade700,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // helpers
  static Widget _word(String text, Color color,
      {FontWeight? fontWeight, bool italic = false, double? fontSize}) {
    return Text(
      "$text ",
      style: GoogleFonts.lato(
        fontSize: fontSize ?? 22,
        fontWeight: fontWeight ?? FontWeight.w800,
        fontStyle: italic ? FontStyle.italic : FontStyle.normal,
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
