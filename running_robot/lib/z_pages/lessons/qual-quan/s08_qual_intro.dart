// lib/z_pages/lessons/LessonTzhee/lesson3_7_qualitative.dart
// ✅ LessonStepSeven — Qualitative definition only + image

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:running_robot/z_pages/assets/lessonAssets/helpful_tools.dart';

const Color mainConceptColor = Color.fromARGB(255, 255, 109, 12);
const Color keyConceptPurple = Color.fromARGB(255, 130, 59, 207);
const double lesson3FontSize = 20;

class LessonStepSeven extends StatelessWidget {
  const LessonStepSeven({super.key});

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
                LessonText.sentence([
                  LessonText.word("What", Colors.black87, fontSize: 30),
                  LessonText.word("is", Colors.black87, fontSize: 30),
                  LessonText.word("Qualitative", mainConceptColor,
                      fontSize: 30),
                  LessonText.word("Data?", Colors.black87, fontSize: 30),
                ]),
                const SizedBox(height: 12),
                LessonText.sentence([
                  LessonText.word("Qualitative", mainConceptColor,
                      fontSize: lesson3FontSize + 1),
                  LessonText.word("data", Colors.black87,
                      fontSize: lesson3FontSize),
                  LessonText.word("is", Colors.black87,
                      fontSize: lesson3FontSize),
                  LessonText.word("information", keyConceptPurple,
                      fontSize: lesson3FontSize, italic: true),
                  LessonText.word("that", Colors.black87,
                      fontSize: lesson3FontSize),
                  LessonText.word("describes", Colors.black87,
                      fontSize: lesson3FontSize),
                  LessonText.word(
                      "categories.", const Color.fromARGB(221, 0, 102, 255),
                      fontSize: lesson3FontSize),
                ]),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // ========== Qualitative Image ==========
          LessonText.box(
            child: Center(
              child: Image.asset(
                "assets/images/qualitative.png",
                fit: BoxFit.contain,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
