import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

const Color binaryConceptColor = Color.fromARGB(255, 12, 109, 255);
const double maxTextWidth = 350;
const double secondLineSize = 20.5;
const FontWeight secondLineWeight = FontWeight.w800;

class LessonStepFive extends StatelessWidget {
  const LessonStepFive({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
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
                children: [
                  // Intro line
                  _buildSentence([
                    _word("Binary Classification", binaryConceptColor,
                        fontWeight: FontWeight.w800, fontSize: secondLineSize),
                    _word("can go from", Colors.black87,
                        fontSize: secondLineSize, fontWeight: secondLineWeight),
                  ], alignment: WrapAlignment.center, constrainWidth: false),

                  // Simple example
                  _buildSentence([
                    _word("Banana", Colors.black87,
                        fontSize: secondLineSize,
                        fontWeight: secondLineWeight,
                        italic: true),
                    _word("or", Colors.black87,
                        fontSize: secondLineSize, fontWeight: secondLineWeight),
                    _word("Apple? (simple)", Colors.black87,
                        fontSize: secondLineSize,
                        fontWeight: secondLineWeight,
                        italic: true),
                  ], alignment: WrapAlignment.center, constrainWidth: false),
                  const SizedBox(height: 16),
                  _singleImageBox('assets/images/apple.jpg'),

                  const SizedBox(height: 20),

                  // Complex example
                  _buildSentence([
                    _word("to", Colors.black87,
                        fontSize: secondLineSize, fontWeight: secondLineWeight),
                    _word("Cancer or Not Cancer? (complex)", Colors.black87,
                        fontSize: secondLineSize,
                        fontWeight: secondLineWeight,
                        italic: true),
                  ], alignment: WrapAlignment.center, constrainWidth: false),
                  const SizedBox(height: 16),
                  _singleImageBox('assets/images/brain_mri4.png'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ✅ Image helper
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
