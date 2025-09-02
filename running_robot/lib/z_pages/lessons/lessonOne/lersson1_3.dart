import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

const Color mainConceptColor =
    Color.fromARGB(255, 255, 109, 12); // Classification color
const Color binaryConceptColor =
    Color.fromARGB(255, 12, 109, 255); // Binary Classification color
const double maxTextWidth = 350;
const double secondLineSize = 20.5;
const FontWeight secondLineWeight = FontWeight.w800;

class LessonStepTwo extends StatelessWidget {
  final VoidCallback onContinue;

  const LessonStepTwo({super.key, required this.onContinue});

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
              margin: const EdgeInsets.only(bottom: 5, top: 5),
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
                    _word("only", Colors.black87,
                        fontSize: secondLineSize, fontWeight: secondLineWeight),
                    _word("2", Colors.black87,
                        fontSize: secondLineSize, fontWeight: secondLineWeight),
                    _word("labels,", Colors.black87,
                        fontSize: secondLineSize, fontWeight: secondLineWeight),
                    _word("it's", Colors.black87,
                        fontSize: secondLineSize, fontWeight: secondLineWeight),
                    _word("called", Colors.black87,
                        fontSize: secondLineSize, fontWeight: secondLineWeight),
                    _word("Binary Classification", binaryConceptColor,
                        fontSize: secondLineSize, fontWeight: FontWeight.w800),
                  ]),
                ],
              ),
            ),
            SizedBox(height: 10),
            // Second Box (Binary Classification examples)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 15),
              margin: const EdgeInsets.only(bottom: 20),
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
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Intro text (line 1)
                  _buildSentence([
                    _word("Binary Classification", binaryConceptColor,
                        fontWeight: FontWeight.w800, fontSize: secondLineSize),
                    _word("can go from", Colors.black87,
                        fontSize: secondLineSize, fontWeight: secondLineWeight),
                  ], alignment: WrapAlignment.center, constrainWidth: false),

                  // Intro text (line 2) — centered Banana/Apple
                  _buildSentence(
                    [
                      _word("Banana", Colors.black87,
                          fontSize: secondLineSize,
                          fontWeight: secondLineWeight,
                          italic: true),
                      _word("or", Colors.black87,
                          fontSize: secondLineSize,
                          fontWeight: secondLineWeight),
                      _word("Apple? (simple)", Colors.black87,
                          fontSize: secondLineSize,
                          fontWeight: secondLineWeight,
                          italic: true),
                    ],
                    alignment: WrapAlignment.center,
                    constrainWidth: false,
                  ),
                  const SizedBox(height: 16),

                  // ✅ Big Banana Image (centered)
                  _singleImageBox('assets/images/apple.jpg'),

                  const SizedBox(height: 20),

                  // Difficult Problem text (centered)
                  _buildSentence(
                    [
                      _word("to", Colors.black87,
                          fontSize: secondLineSize,
                          fontWeight: secondLineWeight),
                      _word("Cancer or Not Cancer? (complex)", Colors.black87,
                          fontSize: secondLineSize,
                          fontWeight: secondLineWeight,
                          italic: true),
                    ],
                    alignment: WrapAlignment.center,
                    constrainWidth: false,
                  ),
                  const SizedBox(height: 16),

                  // ✅ Big Complex Example Image (centered)
                  _singleImageBox('assets/images/brain_mri4.png'),
                ],
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  style: ButtonStyle(
                    backgroundColor:
                        MaterialStateProperty.all<Color>(Colors.teal),
                    padding: MaterialStateProperty.all<EdgeInsets>(
                      const EdgeInsets.symmetric(horizontal: 38, vertical: 14),
                    ),
                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                  ),
                  onPressed: onContinue,
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

  // ✅ Single Image Box (centered full width with padding)
  static Widget _singleImageBox(String assetPath) {
    return Container(
      width: double.infinity,
      height: 180,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black26, width: 1),
      ),
      clipBehavior: Clip.hardEdge,
      child: Image.asset(assetPath, fit: BoxFit.cover),
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
