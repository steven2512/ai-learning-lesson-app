import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:running_robot/z_pages/assets/lessonN/mcq_box.dart';

const double maxTextWidth = 350;

class LessonStepOne extends StatefulWidget {
  final ValueNotifier<bool>?
      answeredNotifier; // ✅ For LessonOne to track answered state

  const LessonStepOne({super.key, this.answeredNotifier});

  @override
  State<LessonStepOne> createState() => _LessonStepOneState();
}

class _LessonStepOneState extends State<LessonStepOne> {
  bool _answered = false;

  bool get answered => _answered;

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
              onAnswerTap: (_, __) {
                if (!_answered) {
                  setState(() => _answered = true);
                  widget.answeredNotifier?.value = true; // ✅ update LessonOne
                }
              },
            ),
            const SizedBox(height: 20),
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
