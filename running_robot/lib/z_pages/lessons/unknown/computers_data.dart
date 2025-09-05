import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

const Color mainConceptColor =
    Color.fromARGB(255, 255, 109, 12); // Highlight Data
const Color keyConceptGreen =
    Color.fromARGB(255, 0, 163, 54); // Highlight key words
const double maxTextWidth = 350;
const double secondLineSize = 21.5;
const FontWeight secondLineWeight = FontWeight.w800;

/// ✅ Global font size for special highlighted words
const double definitionSize = 22.0;

/// ✅ Colors for the 4 key actions
const Color storeColor = Color.fromARGB(255, 119, 0, 115); // Blue
const Color processColor = Color.fromARGB(255, 0, 180, 177); // Orange
const Color patternsColor = Color.fromARGB(255, 0, 98, 196); // Purple
const Color decisionsColor = Color.fromARGB(255, 255, 0, 0); // Green

class LessonStepTwoTwo extends StatelessWidget {
  const LessonStepTwoTwo({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ✅ Box: What computers do with data
            Container(
              width: double.infinity,
              padding: const EdgeInsets.only(
                left: 13,
                right: 13,
                top: 15,
                bottom: 15,
              ),
              margin: const EdgeInsets.only(bottom: 30),
              decoration: _boxDecoration(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Question
                  _buildSentence([
                    _word("What", Colors.black87, fontSize: 30),
                    _word("can", Colors.black87, fontSize: 30),
                    _word("computers", const Color.fromARGB(255, 0, 187, 50),
                        fontSize: 30),
                    _word("do", Colors.black87, fontSize: 30),
                    _word("with", Colors.black87, fontSize: 30),
                    _word("data?", mainConceptColor, fontSize: 30),
                  ]),
                  const SizedBox(height: 15),
                  // Answer (pipeline with arrows)
                  _buildSentence([
                    const Padding(
                      padding: EdgeInsets.only(top: 3, right: 1),
                      child: Icon(Icons.arrow_forward_rounded,
                          size: 26, color: Colors.black54),
                    ),
                    _word("They", const Color.fromARGB(255, 0, 0, 0),
                        fontSize: secondLineSize, fontWeight: secondLineWeight),
                    _word("can", Colors.black,
                        fontSize: secondLineSize, fontWeight: secondLineWeight),

                    // Store
                    _word("store data,", storeColor,
                        fontSize: definitionSize,
                        fontWeight: FontWeight.w800,
                        italic: true),
                    _word("process", processColor,
                        fontSize: definitionSize,
                        fontWeight: FontWeight.w800,
                        italic: true),
                    // Process
                    _word("data,", processColor,
                        fontSize: definitionSize,
                        fontWeight: FontWeight.w800,
                        italic: true),

                    _word("then", Colors.black87,
                        fontSize: secondLineSize, fontWeight: secondLineWeight),

                    // Find patterns
                    _word("find patterns", patternsColor,
                        fontSize: definitionSize,
                        fontWeight: FontWeight.w800,
                        italic: true),

                    _word("and", Colors.black87,
                        fontSize: secondLineSize, fontWeight: secondLineWeight),

                    // Make decisions
                    _word("make decisions.", decisionsColor,
                        fontSize: definitionSize,
                        fontWeight: FontWeight.w800,
                        italic: true),
                  ]),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ✅ Shared box decoration
  BoxDecoration _boxDecoration() {
    return BoxDecoration(
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
    );
  }

  // helpers
  static Widget _word(String text, Color color,
      {FontWeight? fontWeight, bool italic = false, double? fontSize}) {
    return Text(
      "$text ",
      style: GoogleFonts.lato(
        fontSize: fontSize ?? secondLineSize,
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
