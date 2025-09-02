import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:running_robot/z_pages/assets/lessonN/mcq_box.dart';

const Color mainConceptColor = Color.fromARGB(255, 255, 109, 12);
const FontWeight secondLineWeight = FontWeight.w800;
const double secondLineSize = 20.5;
const double maxTextWidth = 350;

class LessonStepZero extends StatefulWidget {
  final VoidCallback onContinue;

  const LessonStepZero({super.key, required this.onContinue});

  @override
  State<LessonStepZero> createState() => _LessonStepZeroState();
}

class _LessonStepZeroState extends State<LessonStepZero> {
  bool _answered = false;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title + Definition
            Container(
              padding: const EdgeInsets.only(
                left: 13,
                right: 13,
                top: 15,
                bottom: 15,
              ),
              margin: const EdgeInsets.only(bottom: 30),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.black26, width: 1),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 6,
                    offset: Offset(0, 3),
                  )
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSentence([
                    _word("What", Colors.black87, fontSize: 30),
                    _word("is", Colors.black87, fontSize: 30),
                    _word("classification?", mainConceptColor, fontSize: 30),
                  ]),
                  const SizedBox(height: 12),
                  _buildSentence([
                    const Padding(
                      padding: EdgeInsets.only(top: 3, right: 1),
                      child: Icon(Icons.arrow_forward_rounded,
                          size: 26, color: Colors.black54),
                    ),
                    _word("Classification", mainConceptColor,
                        fontSize: secondLineSize, fontWeight: FontWeight.w800),
                    _word("is", Colors.black87,
                        fontSize: secondLineSize, fontWeight: secondLineWeight),
                    _word("deciding", Colors.black87,
                        fontSize: secondLineSize, fontWeight: secondLineWeight),
                    _word("which", Colors.black87,
                        fontSize: secondLineSize, fontWeight: secondLineWeight),
                    _word("group", Colors.black87,
                        fontSize: secondLineSize, fontWeight: secondLineWeight),
                    _word("something", Colors.black87,
                        fontSize: secondLineSize,
                        fontWeight: secondLineWeight,
                        italic: true),
                    _word("belongs", Colors.black87,
                        fontSize: secondLineSize, fontWeight: secondLineWeight),
                    _word("to.", Colors.black87,
                        fontSize: secondLineSize, fontWeight: secondLineWeight),
                  ]),
                ],
              ),
            ),

            // Dog vs Cat row
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 170,
                  height: 250,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.black26, width: 1),
                    ),
                    clipBehavior: Clip.hardEdge,
                    child:
                        Image.asset('assets/images/dog.png', fit: BoxFit.cover),
                  ),
                ),
                const SizedBox(width: 15),
                SizedBox(
                  width: 165,
                  height: 250,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.black26, width: 1),
                    ),
                    clipBehavior: Clip.hardEdge,
                    child:
                        Image.asset('assets/images/cat.jpg', fit: BoxFit.cover),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 15),

            // MCQ
            MCQBox(
              question: _buildSentence([
                _word("Which", Colors.black87, fontSize: 24),
                _word("one", Colors.black87, fontSize: 24),
                _word("is", Colors.black87, fontSize: 24),
                _word("a", Colors.black87, fontSize: 24),
                _word("dog?", Colors.green,
                    fontWeight: FontWeight.w600, fontSize: 24),
              ], alignment: WrapAlignment.center, constrainWidth: false),
              answers: ["Picture 1", "Picture 2"],
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
                }
              },
            ),
            const SizedBox(height: 20),

            // Continue button (only after answer chosen)
            if (_answered)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    style: ButtonStyle(
                      backgroundColor:
                          MaterialStateProperty.all<Color>(Colors.teal),
                      padding: MaterialStateProperty.all<EdgeInsets>(
                        const EdgeInsets.symmetric(
                            horizontal: 38, vertical: 14),
                      ),
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                    ),
                    onPressed: widget.onContinue,
                    child: Text(
                      'Continue',
                      style: GoogleFonts.lato(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
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
