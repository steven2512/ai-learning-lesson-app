import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:running_robot/z_pages/assets/lessonAssets/helpful_tools.dart';

const Color mainConceptColor = Color.fromARGB(255, 255, 109, 12);
const Color keyConceptGreen = Color.fromARGB(255, 0, 163, 54);

/// 🔹 Global font sizes
const double globalFontSize = 20;
const double noteTextSize = 20;

class HelloInUnicode extends StatelessWidget {
  const HelloInUnicode({super.key});

  void _showUnicodeOverlay(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black54, // ✅ semi-translucent background
      builder: (context) {
        return Center(
          child: Container(
            width: 320,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 10,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("How Unicode Works",
                      style: GoogleFonts.lato(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        color: mainConceptColor,
                      )),
                  const SizedBox(height: 16),

                  // ✅ Steps (split into mini boxes)
                  LessonText.box(
                    child: LessonText.sentence([
                      LessonText.word("1.", Colors.black87, fontSize: 16),
                      LessonText.word("You type", Colors.black87, fontSize: 16),
                      LessonText.word("'A'", mainConceptColor,
                          fontSize: 16, fontWeight: FontWeight.w900),
                      LessonText.word("on the keyboard.", Colors.black87,
                          fontSize: 16),
                    ]),
                  ),
                  LessonText.box(
                    child: LessonText.sentence([
                      LessonText.word("2.", Colors.black87, fontSize: 16),
                      LessonText.word("OS maps it to a", Colors.black87,
                          fontSize: 16),
                      LessonText.word("Unicode code point", keyConceptGreen,
                          fontSize: 16, fontWeight: FontWeight.w800),
                      LessonText.word("(U+0041).", Colors.black87,
                          fontSize: 16),
                    ]),
                  ),
                  LessonText.box(
                    child: LessonText.sentence([
                      LessonText.word("3.", Colors.black87, fontSize: 16),
                      LessonText.word("Then encoded as", Colors.black87,
                          fontSize: 16),
                      LessonText.word("UTF-8 bytes", mainConceptColor,
                          fontSize: 16, fontWeight: FontWeight.w800),
                      LessonText.word("(01000001).", Colors.black87,
                          fontSize: 16),
                    ]),
                  ),
                  LessonText.box(
                    child: LessonText.sentence([
                      LessonText.word("4.", Colors.black87, fontSize: 16),
                      LessonText.word(
                          "Stored in memory & read by", Colors.black87,
                          fontSize: 16),
                      LessonText.word("programs.", keyConceptGreen,
                          fontSize: 16, fontWeight: FontWeight.w800),
                    ]),
                  ),

                  const SizedBox(height: 20),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text("Got it"),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

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

            // ✅ Binary string box
            Container(
              margin: const EdgeInsets.only(bottom: 20),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(14),
              ),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 37, 35, 35),
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

            // ✅ Small note with clickable word
            Padding(
              padding: const EdgeInsets.only(top: 4, right: 5),
              child: Center(
                child: Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    LessonText.word("Note:", Colors.black54,
                        fontSize: 14, italic: true),
                    LessonText.word(" this is done via", Colors.black54,
                        fontSize: 14, italic: true),
                    GestureDetector(
                      onTap: () => _showUnicodeOverlay(context),
                      child: LessonText.word(
                        "Unicode encoding standard",
                        Colors.black87,
                        fontSize: 14,
                        italic: true,
                        underline: true,
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
}
