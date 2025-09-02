import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

const Color mainConceptColor = Color.fromARGB(255, 255, 109, 12);
const FontWeight secondLineWeight = FontWeight.w800;
const double secondLineSize = 20.5;
const double maxTextWidth = 350;

class LessonStepZero extends StatelessWidget {
  const LessonStepZero({super.key});

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
