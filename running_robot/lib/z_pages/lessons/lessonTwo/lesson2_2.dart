import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:running_robot/z_pages/assets/lessonAssets/helpful_tools.dart';

const Color mainConceptColor = Color.fromARGB(255, 255, 109, 12);
const Color keyConceptGreen = Color.fromARGB(255, 0, 163, 54);
const double secondLineSize = 20.5;
const FontWeight secondLineWeight = FontWeight.w800;

class LessonStepOne extends StatefulWidget {
  const LessonStepOne({super.key});

  @override
  State<LessonStepOne> createState() => _LessonStepOneState();
}

class _LessonStepOneState extends State<LessonStepOne>
    with TickerProviderStateMixin {
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

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ✅ Definition box
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 13),
              margin: const EdgeInsets.only(bottom: 20),
              decoration: _boxDecoration(),
              child: LessonText.sentence([
                LessonText.word("When", Colors.black87, fontSize: 22),
                LessonText.word("we", Colors.black87, fontSize: 22),
                LessonText.word("listen", Colors.black87, fontSize: 22),
                LessonText.word("to", Colors.black87, fontSize: 22),
                LessonText.word("music,", mainConceptColor, fontSize: 22),
                LessonText.word("we", Colors.black87, fontSize: 22),
                LessonText.word("say", Colors.black87, fontSize: 22),
                LessonText.word("'That's", keyConceptGreen,
                    fontSize: 22, fontWeight: FontWeight.w800),
                LessonText.word("a", keyConceptGreen, fontSize: 22),
                LessonText.word("song'.", keyConceptGreen,
                    fontSize: 22, fontWeight: FontWeight.w800),
              ]),
            ),

            // ✅ Musician with dialogue ABOVE
            Center(
              child: Column(
                children: [
                  // Dialogue bubble ABOVE
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      Image.asset(
                        "assets/images/dialogue_box.png",
                        width: 280,
                        height: 150,
                        fit: BoxFit.contain,
                      ),
                      Container(
                        padding: const EdgeInsets.only(bottom: 25),
                        child: Text(
                          "That's a beautiful song!",
                          textAlign: TextAlign.center,
                          style: GoogleFonts.lato(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                    ],
                  ),
                  // 🎵 Musician image (placeholder asset — replace if you have a specific one)
                  Image.asset(
                    "assets/images/musician.png",
                    width: 380,
                    height: 260,
                    fit: BoxFit.contain,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
