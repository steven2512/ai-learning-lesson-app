// FILE: lib/z_pages/lessons/data-sample-intro/data_set_def.dart
// ✅ Slide 6 — Dataset definition (exact QualIntro style)

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:running_robot/z_pages/assets/lessonAssets/helpful_tools.dart';

const Color mainConceptColor = Color.fromARGB(255, 255, 109, 12); // 🔸 orange
const Color keyConceptPurple = Color.fromARGB(255, 130, 59, 207);
const double lesson3FontSize = 20;

class DataSetDefinition extends StatelessWidget {
  const DataSetDefinition({super.key});

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
                  LessonText.word("a", Colors.black87, fontSize: 30),
                  LessonText.word("Dataset", mainConceptColor, fontSize: 30),
                  LessonText.word("?", Colors.black87, fontSize: 30),
                ]),
                const SizedBox(height: 12),
                // Definition sentence (exact wording)
                LessonText.sentence([
                  LessonText.word("A", Colors.black87,
                      fontSize: lesson3FontSize),
                  LessonText.word("Dataset", mainConceptColor,
                      fontSize: lesson3FontSize + 1),
                  LessonText.word("is", Colors.black87,
                      fontSize: lesson3FontSize),
                  LessonText.word("a", Colors.black87,
                      fontSize: lesson3FontSize),
                  LessonText.word("collection", keyConceptPurple,
                      fontSize: lesson3FontSize, italic: true),
                  LessonText.word("of", Colors.black87,
                      fontSize: lesson3FontSize),
                  LessonText.word("many", Colors.black87,
                      fontSize: lesson3FontSize),
                  LessonText.word(
                    "Data",
                    const Color.fromARGB(221, 0, 102, 255),
                    fontSize: lesson3FontSize,
                    fontWeight: FontWeight.w900,
                  ),
                  LessonText.word(
                    "Samples",
                    const Color.fromARGB(221, 0, 102, 255),
                    fontSize: lesson3FontSize,
                    fontWeight: FontWeight.w900,
                  ),
                ]),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // ========== Image (copy style) ==========
          Center(
            child: Image.asset(
              "assets/images/data_set.png",
              fit: BoxFit.contain,
            ),
          ),
        ],
      ),
    );
  }
}
