import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:running_robot/z_pages/assets/lessonAssets/helpful_tools.dart';

const Color mainConceptColor = Color.fromARGB(255, 255, 109, 12);
const Color keyConceptGreen = Color.fromARGB(255, 0, 163, 54);

class LessonStepOne extends StatefulWidget {
  const LessonStepOne({super.key});

  @override
  State<LessonStepOne> createState() => _LessonStepOneState();
}

class _LessonStepOneState extends State<LessonStepOne>
    with TickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ✅ Definition box (using LessonText.box)
            LessonText.box(
              margin: const EdgeInsets.only(bottom: 7),
              child: LessonText.sentence([
                LessonText.word("And when", Colors.black87, fontSize: 22),
                LessonText.word("we", Colors.black87, fontSize: 22),
                LessonText.word("listen", Colors.black87, fontSize: 22),
                LessonText.word("to", Colors.black87, fontSize: 22),
                LessonText.word("music,", mainConceptColor, fontSize: 22),
                LessonText.word("we", Colors.black87, fontSize: 22),
                LessonText.word("think", Colors.black87, fontSize: 22),
                LessonText.word("'That's", keyConceptGreen,
                    fontSize: 22, fontWeight: FontWeight.w800),
                LessonText.word("a", keyConceptGreen, fontSize: 22),
                LessonText.word("song'.", keyConceptGreen,
                    fontSize: 22, fontWeight: FontWeight.w800),
              ]),
            ),

            // ✅ Small one-liner box
            LessonText.box(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
              margin: const EdgeInsets.only(bottom: 20),
              child: Text(
                "Again, no surprise here.",
                style: GoogleFonts.lato(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ),

            // ✅ Musician with dialogue ABOVE
            Center(
              child: SizedBox(
                width: 400,
                height: 350, // enough to hold both image + bubble
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    // 🎵 Musician image
                    Positioned(
                      bottom: -40,
                      left: 0,
                      right: 0,
                      child: Image.asset(
                        "assets/images/music_listening.png",
                        width: 400,
                        height: 290,
                        fit: BoxFit.contain,
                      ),
                    ),

                    // 💬 Dialogue bubble overlay
                    Positioned(
                      top: 5, // smaller value = higher up
                      right: 40,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Image.asset(
                            "assets/images/dialogue_box.png",
                            width: 240,
                            height: 115,
                            fit: BoxFit.contain,
                          ),
                          Padding(
                            padding: const EdgeInsets.only(
                                bottom: 30, left: 5), // only for text
                            child: Text(
                              "This is an\namazing song!",
                              textAlign: TextAlign.center,
                              style: GoogleFonts.lato(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                                height: 1.1,
                              ),
                            ),
                          ),
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
}
