import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

const Color mainConceptColor = Color.fromARGB(255, 255, 109, 12);
const Color binaryConceptColor = Color.fromARGB(255, 12, 109, 255);
const double maxTextWidth = 350;
const double secondLineSize = 20.5;
const FontWeight secondLineWeight = FontWeight.w800;

class LessonStepFour extends StatelessWidget {
  const LessonStepFour({super.key});

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
              width: 420,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              margin: const EdgeInsets.only(bottom: 20, top: 10),
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
              child: _buildSentence([
                _word("If", Colors.black87,
                    fontSize: secondLineSize, fontWeight: secondLineWeight),
                _word("a", Colors.black87,
                    fontSize: secondLineSize, fontWeight: secondLineWeight),
                _word("classification", mainConceptColor,
                    fontSize: secondLineSize, fontWeight: FontWeight.w800),
                _word("task", Colors.black87,
                    fontSize: secondLineSize, fontWeight: secondLineWeight),
                _word("involves", Colors.black87,
                    fontSize: secondLineSize, fontWeight: secondLineWeight),
                _word("only 2 labels,", Colors.black87,
                    fontSize: secondLineSize, fontWeight: secondLineWeight),
                _word("it's called", Colors.black87,
                    fontSize: secondLineSize, fontWeight: secondLineWeight),
                _word("Binary Classification", binaryConceptColor,
                    fontSize: secondLineSize, fontWeight: FontWeight.w800),
              ]),
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
