import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:running_robot/z_pages/assets/lessonAssets/helpful_tools.dart';

const Color mainConceptColor = Color.fromARGB(255, 255, 109, 12);
const Color keyConceptGreen = Color.fromARGB(255, 0, 163, 54);
const double secondLineSize = 20.5;
const FontWeight secondLineWeight = FontWeight.w800;

class LessonStepZero extends StatefulWidget {
  const LessonStepZero({super.key});

  @override
  State<LessonStepZero> createState() => _LessonStepZeroState();
}

class _LessonStepZeroState extends State<LessonStepZero>
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
            // ✅ First big box
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 13),
              margin: const EdgeInsets.only(top: 10, bottom: 7),
              decoration: _boxDecoration(),
              child: LessonText.sentence([
                LessonText.word("For", Colors.black87, fontSize: 22),
                LessonText.word("humans,", Colors.black87, fontSize: 22),
                LessonText.word("when", Colors.black87, fontSize: 22),
                LessonText.word("we", Colors.black87, fontSize: 22),
                LessonText.word("look", Colors.black87, fontSize: 22),
                LessonText.word("at", Colors.black87, fontSize: 22),
                LessonText.word("a", Colors.black87, fontSize: 22),
                LessonText.word("photo,", mainConceptColor, fontSize: 22),
                LessonText.word("we", Colors.black87, fontSize: 22),
                LessonText.word("think", Colors.black87, fontSize: 22),
                LessonText.word("'That's", keyConceptGreen,
                    fontSize: 22, fontWeight: FontWeight.w800),
                LessonText.word("a", keyConceptGreen, fontSize: 22),
                LessonText.word("photo'.", keyConceptGreen,
                    fontSize: 22, fontWeight: FontWeight.w800),
              ]),
            ),

            // ✅ Small one-line box
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
              margin: const EdgeInsets.only(bottom: 0),
              decoration: _boxDecoration(),
              child: Text(
                "Obvious, right?",
                style: GoogleFonts.lato(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ),

            // ✅ Cameraman + Dialogue in one Stack
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: Center(
                child: SizedBox(
                  width: 400,
                  height: 400,
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      // Cameraman (base layer)
                      Positioned(
                        bottom: 20,
                        left: 20,
                        child: Image.asset(
                          "assets/images/cameraman.png",
                          width: 380,
                          height: 300,
                          fit: BoxFit.contain,
                        ),
                      ),

                      // Dialogue box (above, pointing to cameraman's head on right)
                      Positioned(
                        top: 40,
                        right: -50,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Image.asset(
                              "assets/images/dialogue_box.png",
                              width: 240,
                              height: 100,
                              fit: BoxFit.contain,
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.only(bottom: 20, left: 3),
                              child: Text(
                                """That's a \nnice photo!""",
                                textAlign: TextAlign.center,
                                style: GoogleFonts.lato(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black87,
                                    height: 1.1),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
