import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:running_robot/z_pages/assets/lessonAssets/helpful_tools.dart';

const Color mainConceptColor = Color.fromARGB(255, 255, 109, 12);
const Color keyConceptGreen = Color.fromARGB(255, 0, 163, 54);

/// 🔹 Global font sizes
const double globalFontSize = 22;
const double noteTextSize = 20.3;

class LessonStepThree extends StatelessWidget {
  const LessonStepThree({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ✅ First box: define binary numbers
            LessonText.box(
              margin: const EdgeInsets.only(top: 10, bottom: 15),
              child: LessonText.sentence([
                LessonText.word("Those", Colors.black87,
                    fontSize: globalFontSize),
                LessonText.word("0's", keyConceptGreen,
                    fontSize: globalFontSize, fontWeight: FontWeight.w800),
                LessonText.word("and", Colors.black87,
                    fontSize: globalFontSize),
                LessonText.word("1's", keyConceptGreen,
                    fontSize: globalFontSize, fontWeight: FontWeight.w800),
                LessonText.word("are", Colors.black87,
                    fontSize: globalFontSize),
                LessonText.word("called", Colors.black87,
                    fontSize: globalFontSize),
                LessonText.word("binary", mainConceptColor,
                    fontSize: globalFontSize + 2, fontWeight: FontWeight.w800),
                LessonText.word("numbers.", mainConceptColor,
                    fontSize: globalFontSize),
              ]),
            ),

            // ✅ Second box: binary means 2 values
            LessonText.box(
              margin: const EdgeInsets.only(bottom: 15),
              child: LessonText.sentence([
                LessonText.word("Binary", mainConceptColor,
                    fontSize: globalFontSize, fontWeight: FontWeight.w800),
                LessonText.word("means", Colors.black87,
                    fontSize: globalFontSize),
                LessonText.word("we", Colors.black87, fontSize: globalFontSize),
                LessonText.word("only", Colors.black87,
                    fontSize: globalFontSize),
                LessonText.word("use", Colors.black87,
                    fontSize: globalFontSize),
                LessonText.word("two values", keyConceptGreen,
                    fontSize: globalFontSize, fontWeight: FontWeight.w800),
              ]),
            ),

            // ✅ Third box: examples with Apple/Banana and Yes/No on new lines
            LessonText.box(
              margin: const EdgeInsets.only(bottom: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  LessonText.sentence([
                    LessonText.word("Here", Colors.black87,
                        fontSize: globalFontSize),
                    LessonText.word("it", Colors.black87,
                        fontSize: globalFontSize),
                    LessonText.word("is", Colors.black87,
                        fontSize: globalFontSize),
                    LessonText.word("'0'", keyConceptGreen,
                        fontSize: globalFontSize, fontWeight: FontWeight.w800),
                    LessonText.word("and", Colors.black87,
                        fontSize: globalFontSize),
                    LessonText.word("'1',", keyConceptGreen,
                        fontSize: globalFontSize, fontWeight: FontWeight.w800),
                    LessonText.word("but", Colors.black87,
                        fontSize: globalFontSize),
                    LessonText.word("it", Colors.black87,
                        fontSize: globalFontSize),
                    LessonText.word("could", Colors.black87,
                        fontSize: globalFontSize),
                    LessonText.word("be", Colors.black87,
                        fontSize: globalFontSize),
                    LessonText.word("[Apple", mainConceptColor,
                        fontSize: globalFontSize, italic: true),
                    LessonText.word("and", Colors.black87,
                        fontSize: globalFontSize),
                    LessonText.word("Banana].", mainConceptColor,
                        fontSize: globalFontSize, italic: true),
                  ]),
                  const SizedBox(height: 6), // spacing between lines
                  LessonText.sentence([
                    LessonText.word("Or", Colors.black87,
                        fontSize: globalFontSize),
                    LessonText.word("[Yes", keyConceptGreen,
                        fontSize: globalFontSize, italic: true),
                    LessonText.word("and", Colors.black87,
                        fontSize: globalFontSize),
                    LessonText.word("No].", keyConceptGreen,
                        fontSize: globalFontSize, italic: true),
                  ]),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
