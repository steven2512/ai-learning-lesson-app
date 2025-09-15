import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:running_robot/z_pages/assets/lessonAssets/helpful_tools.dart';

const Color mainConceptColor = Color.fromARGB(255, 0, 113, 206); // blue
const Color keyConceptGreen = Color.fromARGB(255, 0, 163, 54);

/// 🔹 Global font size for Lesson 3
const double lesson3FontSize = 20;

/// 🔹 Shared Recap Word Style
Widget recapWord(String label) {
  return LessonText.word(
    "$label Recap🔥",
    const Color.fromARGB(255, 255, 109, 12), // highlight orange
    fontSize: lesson3FontSize + 2,
    fontWeight: FontWeight.w900,
    italic: true,
  );
}

/// ------------------------------------------------------------------------
/// PART 2 WIDGET: Second recap box + dark “binary photo” container box
/// Class name is LessonStepOne (your requested name for the 2nd file)
/// ------------------------------------------------------------------------
class RecapBinary extends StatelessWidget {
  const RecapBinary({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20),

            // 🔹 Recap Box: Lesson 2
            LessonText.recapBox(
              child: LessonText.sentence([
                recapWord("Lesson 2"),
                LessonText.word("Then we know that Computers",
                    const Color.fromARGB(255, 0, 0, 0),
                    fontSize: lesson3FontSize, fontWeight: FontWeight.w800),
                LessonText.word("turn all", Colors.black87,
                    fontSize: lesson3FontSize),
                LessonText.word("data", mainConceptColor,
                    fontSize: lesson3FontSize, fontWeight: FontWeight.w800),
                LessonText.word("into", Colors.black87,
                    fontSize: lesson3FontSize),
                LessonText.word("0s", const Color.fromARGB(255, 255, 81, 0),
                    fontSize: lesson3FontSize, fontWeight: FontWeight.w800),
                LessonText.word("and", Colors.black87,
                    fontSize: lesson3FontSize),
                LessonText.word("1s", const Color.fromARGB(255, 102, 1, 218),
                    fontSize: lesson3FontSize, fontWeight: FontWeight.w800),
                Padding(
                  padding: const EdgeInsets.only(top: 2.2),
                  child: LessonText.word(
                    "(binary)",
                    const Color.fromARGB(255, 2, 151, 119),
                    fontSize: lesson3FontSize - 3,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ]),
            ),

            const SizedBox(height: 5),

            // 🔹 Dark box with 0s and 1s (2 top, 3 bottom)
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
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.greenAccent, width: 1.2),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Top row (2 side by side)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Text(
                          "01001000",
                          style: GoogleFonts.robotoMono(
                            fontSize: 18,
                            color: Colors.greenAccent,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          "01100101",
                          style: GoogleFonts.robotoMono(
                            fontSize: 18,
                            color: Colors.greenAccent,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    // Bottom row (3 side by side)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Text(
                          "01101100",
                          style: GoogleFonts.robotoMono(
                            fontSize: 18,
                            color: Colors.greenAccent,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          "01101100",
                          style: GoogleFonts.robotoMono(
                            fontSize: 18,
                            color: Colors.greenAccent,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          "01101111",
                          style: GoogleFonts.robotoMono(
                            fontSize: 18,
                            color: Colors.greenAccent,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
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
