// FILE: lib/z_pages/lessons/lesson1/lesson1_1.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:running_robot/z_pages/assets/lessonAssets/helpful_tools.dart';
import 'package:running_robot/z_pages/lessons/unknown/bin_classf.dart'; // LessonText

// ====== EXISTING: LessonStepZero remains in this file, unchanged ======
// (Not repeated here; keep your current implementation.)

// ====== NEW: LessonStepOne (intro) ======
const Color _mainConceptColor = Color.fromARGB(255, 255, 109, 12);
const Color _keyConceptGreen = Color.fromARGB(255, 0, 163, 54);
const double _maxTextWidth = 350;

// ✅ Global font-size flag (controls both lines)
const double kIntroFontSize = 21.0;
const double kSecondLineSize = kIntroFontSize - 1.5;

class LessonStepTwo extends StatelessWidget {
  const LessonStepTwo({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// ─────────────────────────────────────────────────────────
            /// BOX 1: "There are many types of data 📊"
            /// ─────────────────────────────────────────────────────────
            LessonText.box(
              margin: const EdgeInsets.only(bottom: 10, top: 60),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  LessonText.sentence([
                    LessonText.word("There", Colors.black87,
                        fontSize: kIntroFontSize),
                    LessonText.word("are", Colors.black87,
                        fontSize: kIntroFontSize),
                    LessonText.word("many", _mainConceptColor,
                        fontSize: kIntroFontSize),
                    LessonText.word("types", _mainConceptColor,
                        fontSize: kIntroFontSize, fontWeight: FontWeight.w800),
                    LessonText.word("of", Colors.black87,
                        fontSize: kIntroFontSize),
                    LessonText.word("data", _keyConceptGreen,
                        fontSize: kIntroFontSize, fontWeight: FontWeight.w800),
                    LessonText.word("📊", _keyConceptGreen,
                        fontSize: kIntroFontSize, fontWeight: FontWeight.w800),
                  ]),
                ],
              ),
            ),

            /// ─────────────────────────────────────────────────────────
            /// BOX 2: "Most of which you actually use on a daily basis 😉"
            /// ─────────────────────────────────────────────────────────
            LessonText.box(
              margin: const EdgeInsets.only(bottom: 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  LessonText.sentence([
                    LessonText.word("You", Colors.black87,
                        fontSize: kSecondLineSize, fontWeight: FontWeight.w800),
                    LessonText.word("might even", Colors.black87,
                        fontSize: kSecondLineSize, fontWeight: FontWeight.w800),
                    LessonText.word("work", Colors.black87,
                        fontSize: kSecondLineSize, fontWeight: FontWeight.w800),
                    LessonText.word("with", Colors.black87,
                        fontSize: kSecondLineSize, fontWeight: FontWeight.w800),
                    LessonText.word("them", const Color.fromARGB(255, 0, 0, 0),
                        fontSize: kSecondLineSize, fontWeight: FontWeight.w800),
                    LessonText.word("every day", _mainConceptColor,
                        fontSize: kSecondLineSize, fontWeight: FontWeight.w800),
                    LessonText.word("without knowing 😉", Colors.black87,
                        fontSize: kSecondLineSize, fontWeight: FontWeight.w800),
                  ]),
                ],
              ),
            ),

            const SizedBox(height: 20),

            /// ─────────────────────────────────────────────────────────
            /// CHARACTER + DIALOGUE STACK
            /// ─────────────────────────────────────────────────────────
            Center(
              child: SizedBox(
                width: 400,
                height: 320,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    // Character (base layer)
                    Positioned(
                      bottom: 0,
                      left: 10,
                      child: Image.asset(
                        "assets/images/data_analyst.png",
                        width: 280,
                        height: 280,
                        fit: BoxFit.contain,
                      ),
                    ),

                    // Dialogue box (top-right of character)
                    Positioned(
                      top: 40,
                      right: 60,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Image.asset(
                            "assets/images/dialogue_box.png",
                            width: 230,
                            height: 90,
                            fit: BoxFit.contain,
                          ),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 18, left: 2),
                            child: Text(
                              "Data is \neverywhere",
                              textAlign: TextAlign.center,
                              style: GoogleFonts.lato(
                                fontSize: 16,
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
