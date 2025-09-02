import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

const Color mainConceptColor = Color.fromARGB(255, 255, 109, 12);
const Color labelColor = Color.fromARGB(255, 12, 109, 255);
const double maxTextWidth = 350;
const double secondLineSize = 20.5;
const FontWeight secondLineWeight = FontWeight.w800;

class LessonStepTwo extends StatelessWidget {
  const LessonStepTwo({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title box
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              margin: const EdgeInsets.only(bottom: 20, top: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.black26, width: 1),
                boxShadow: const [
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
                    _word("Each", Colors.black87,
                        fontSize: secondLineSize, fontWeight: secondLineWeight),
                    _word("data", mainConceptColor,
                        fontSize: secondLineSize, fontWeight: FontWeight.w800),
                    _word("has a", Colors.black87,
                        fontSize: secondLineSize, fontWeight: secondLineWeight),
                    _word("label", labelColor,
                        fontSize: secondLineSize, fontWeight: FontWeight.w800),
                  ]),
                ],
              ),
            ),

            // Explanation box
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.black26, width: 1),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 6,
                    offset: Offset(0, 3),
                  )
                ],
              ),
              child: IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Data column
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Wrap(
                            crossAxisAlignment: WrapCrossAlignment.center,
                            spacing: 4,
                            children: [
                              _word("Data", mainConceptColor,
                                  fontSize: 16, fontWeight: FontWeight.w800),
                              Icon(Icons.storage,
                                  color: mainConceptColor, size: 18),
                            ],
                          ),
                          _buildSentence([
                            _word("the", Colors.black87,
                                fontSize: 16, fontWeight: secondLineWeight),
                            _word(
                                "input", const Color.fromARGB(255, 0, 163, 54),
                                fontSize: 16, fontWeight: FontWeight.w800),
                            _word("we give the computer", Colors.black87,
                                fontSize: 16, fontWeight: secondLineWeight),
                          ]),
                        ],
                      ),
                    ),

                    // Divider
                    Container(
                      width: 1,
                      color: Colors.black12,
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                    ),

                    // Label column
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Wrap(
                            crossAxisAlignment: WrapCrossAlignment.center,
                            spacing: 4,
                            children: [
                              _word("Label", labelColor,
                                  fontSize: 16, fontWeight: FontWeight.w800),
                              Icon(Icons.flag, color: labelColor, size: 18),
                            ],
                          ),
                          _buildSentence([
                            _word("the", Colors.black87,
                                fontSize: 16, fontWeight: secondLineWeight),
                            _word("correct",
                                const Color.fromARGB(255, 0, 163, 54),
                                fontSize: 16, fontWeight: FontWeight.w800),
                            _word("answer for the data", Colors.black87,
                                fontSize: 16, fontWeight: secondLineWeight),
                          ]),
                        ],
                      ),
                    ),
                  ],
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
        : content;
  }
}
