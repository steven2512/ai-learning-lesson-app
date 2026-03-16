// FILE: lib/z_pages/lessons/lesson1/lesson1_1.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:running_robot/core/widgets.dart';
import 'package:running_robot/z_pages/assets/lessonAssets/helpful_tools.dart';
import 'package:running_robot/z_pages/lessons/unknown/bin_classf.dart'; // LessonText

const Color _mainConceptColor = Color.fromARGB(255, 255, 109, 12);
const Color _keyConceptGreen = Color.fromARGB(255, 0, 163, 54);
final screenW = ScreenSize.width;
final screenH = ScreenSize.height;

/// Instead of hardcoding, we define a function that scales slowly
double _scaledFontSize(BuildContext context, double baseSize) {
  // Example: Pixel 9 ≈ 1080px (logical width ~411dp)
  // Use width/411 as scaling, but dampen with 0.15 to make it "slow"
  final scale = 1 + ((screenW / 411) - 1) * 0.15;

  return baseSize * scale;
}

class DataTypes extends StatelessWidget {
  const DataTypes({super.key});

  @override
  Widget build(BuildContext context) {
    final introSize = _scaledFontSize(context, 21); // base = 21
    final secondLineSize = introSize - 1.5;

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// ───────────────────────────────────────────
            /// BOX 1
            /// ───────────────────────────────────────────
            LessonText.box(
              margin: const EdgeInsets.only(bottom: 10, top: 60),
              child: LessonText.sentence([
                LessonText.word("There", Colors.black87, fontSize: introSize),
                LessonText.word("are", Colors.black87, fontSize: introSize),
                LessonText.word("many", _mainConceptColor, fontSize: introSize),
                LessonText.word("types", _mainConceptColor,
                    fontSize: introSize, fontWeight: FontWeight.w800),
                LessonText.word("of", Colors.black87, fontSize: introSize),
                LessonText.word("data", _keyConceptGreen,
                    fontSize: introSize, fontWeight: FontWeight.w800),
                LessonText.word("📊", _keyConceptGreen,
                    fontSize: introSize, fontWeight: FontWeight.w800),
              ]),
            ),

            /// ───────────────────────────────────────────
            /// BOX 2
            /// ───────────────────────────────────────────
            LessonText.box(
              margin: const EdgeInsets.only(bottom: 0),
              child: LessonText.sentence([
                LessonText.word("You", Colors.black87,
                    fontSize: secondLineSize, fontWeight: FontWeight.w800),
                LessonText.word("might even", Colors.black87,
                    fontSize: secondLineSize, fontWeight: FontWeight.w800),
                LessonText.word("work", Colors.black87,
                    fontSize: secondLineSize, fontWeight: FontWeight.w800),
                LessonText.word("with", Colors.black87,
                    fontSize: secondLineSize, fontWeight: FontWeight.w800),
                LessonText.word("them", Colors.black,
                    fontSize: secondLineSize, fontWeight: FontWeight.w800),
                LessonText.word("every day", _mainConceptColor,
                    fontSize: secondLineSize, fontWeight: FontWeight.w800),
                LessonText.word("without knowing 😉", Colors.black87,
                    fontSize: secondLineSize, fontWeight: FontWeight.w800),
              ]),
            ),

            const SizedBox(height: 20),

            /// ───────────────────────────────────────────
            /// CHARACTER + DIALOGUE
            /// ───────────────────────────────────────────
            Center(
              child: SizedBox(
                width: 400,
                height: 320,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
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
