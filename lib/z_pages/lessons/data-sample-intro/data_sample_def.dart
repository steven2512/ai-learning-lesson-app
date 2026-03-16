// FILE: lib/z_pages/lessons/data-sample-intro/data_sample_def.dart
// ✅ Slide 3 — Definition (exact QualIntro style, Data Sample in orange)

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:running_robot/core/widgets.dart';
import 'package:running_robot/z_pages/assets/lessonAssets/helpful_tools.dart';

const Color mainConceptColor = Color.fromARGB(255, 255, 109, 12); // 🔸 orange
const Color keyConceptPurple = Color.fromARGB(255, 130, 59, 207);
const double lesson3FontSize = 20;
final double screenH = ScreenSize.height;

class DataSampleDefinition extends StatelessWidget {
  const DataSampleDefinition({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ========== Definition ==========
          LessonText.box(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title line (copy style)
                LessonText.sentence([
                  LessonText.word("What", Colors.black87, fontSize: 30),
                  LessonText.word("is", Colors.black87, fontSize: 30),
                  LessonText.word("Data", mainConceptColor, fontSize: 30),
                  LessonText.word("Sample?", mainConceptColor, fontSize: 30),
                ]),
                const SizedBox(height: 12),
                // Definition sentence (copy style)
                LessonText.sentence([
                  LessonText.word("A", Colors.black87,
                      fontSize: lesson3FontSize),
                  LessonText.word("data", mainConceptColor,
                      fontSize: lesson3FontSize + 1),
                  LessonText.word("sample", mainConceptColor,
                      fontSize: lesson3FontSize + 1),
                  LessonText.word("is", Colors.black87,
                      fontSize: lesson3FontSize),
                  LessonText.word("one", Colors.black87,
                      fontSize: lesson3FontSize),
                  LessonText.word("small", Colors.black87,
                      fontSize: lesson3FontSize),
                  LessonText.word("example", keyConceptPurple,
                      fontSize: lesson3FontSize, italic: true),
                  LessonText.word("of", Colors.black87,
                      fontSize: lesson3FontSize),
                  LessonText.word("data", Colors.black87,
                      fontSize: lesson3FontSize),
                  LessonText.word("that", Colors.black87,
                      fontSize: lesson3FontSize),
                  LessonText.word("helps", Colors.black87,
                      fontSize: lesson3FontSize),
                  LessonText.word(
                    "AI",
                    const Color.fromARGB(221, 0, 102, 255),
                    fontSize: lesson3FontSize,
                    fontWeight: FontWeight.w900,
                  ),
                  LessonText.word("learn.", Colors.black87,
                      fontSize: lesson3FontSize),
                ]),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // ========== Image (copy style) ==========

          Center(
            child: Image.asset(
              "assets/images/data_sample.png",
              height: screenH * 0.3,
              fit: BoxFit.contain,
            ),
          ),
        ],
      ),
    );
  }
}
