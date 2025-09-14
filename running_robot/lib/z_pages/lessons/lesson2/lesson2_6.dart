import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:running_robot/z_pages/assets/lessonAssets/helpful_tools.dart';

const Color mainConceptColor = Color.fromARGB(255, 255, 109, 12);
const Color keyConceptGreen = Color.fromARGB(255, 0, 163, 54);

/// 🔹 Global font sizes
const double globalFontSize = 20;
const double noteTextSize = 20;

class LessonStepFive extends StatelessWidget {
  const LessonStepFive({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ✅ Intro box
            LessonText.box(
              margin: const EdgeInsets.only(top: 10, bottom: 20),
              child: LessonText.sentence([
                LessonText.word("Let's", Colors.black87,
                    fontSize: globalFontSize + 2),
                LessonText.word("look", Colors.black87,
                    fontSize: globalFontSize + 2),
                LessonText.word("at", Colors.black87,
                    fontSize: globalFontSize + 2),
                LessonText.word("this", Colors.black87,
                    fontSize: globalFontSize + 2),
                LessonText.word("sequence", mainConceptColor,
                    fontSize: globalFontSize + 2, fontWeight: FontWeight.w800),
              ]),
            ),

            // ✅ Binary string box (softer black + surrounding container)
            Container(
              margin: const EdgeInsets.only(bottom: 20),
              padding: const EdgeInsets.all(8), // outer padding
              decoration: BoxDecoration(
                color: Colors.grey[200], // light surround
                borderRadius: BorderRadius.circular(14),
              ),
              child: Container(
                width: double.infinity, // ✅ stretch to align with other boxes
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color:
                      const Color.fromARGB(255, 37, 35, 35), // toned-down black
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      "01001000 01100101",
                      style: GoogleFonts.robotoMono(
                        fontSize: 18,
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "01101100 01101100 01101111",
                      style: GoogleFonts.robotoMono(
                        fontSize: 18,
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ✅ Explanation box
            LessonText.box(
              margin: const EdgeInsets.only(bottom: 10),
              child: LessonText.sentence([
                LessonText.word("Believe", const Color.fromARGB(255, 0, 0, 0),
                    fontSize: noteTextSize, fontWeight: FontWeight.w800),
                LessonText.word("it", Colors.black87, fontSize: noteTextSize),
                LessonText.word("or", Colors.black87, fontSize: noteTextSize),
                LessonText.word("not,", Colors.black87, fontSize: noteTextSize),
                LessonText.word("this", Colors.black87, fontSize: noteTextSize),
                LessonText.word("is", Colors.black87, fontSize: noteTextSize),
                LessonText.word("how", Colors.black87, fontSize: noteTextSize),
                LessonText.word("computers", keyConceptGreen,
                    fontSize: noteTextSize, fontWeight: FontWeight.w800),
                LessonText.word("see the word", Colors.black87,
                    fontSize: noteTextSize, italic: true),
                LessonText.word("'Hello'!", mainConceptColor,
                    fontSize: noteTextSize, fontWeight: FontWeight.w800),
              ]),
            ),

            // ✅ Small italic note underneath
            Padding(
              padding: const EdgeInsets.only(top: 4, right: 5),
              child: LessonText.sentence(
                [
                  LessonText.word("Note:", Colors.black54,
                      fontSize: 14, italic: true),
                  LessonText.word(" this is done via", Colors.black54,
                      fontSize: 14, italic: true),
                  LessonText.word("Unicode encoding standard", Colors.black87,
                      fontSize: 14,
                      italic: true,
                      underline: true), // 👈 underline supported now
                ],
                constrainWidth: false,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
