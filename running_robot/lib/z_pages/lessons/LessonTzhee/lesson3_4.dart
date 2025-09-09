// ✅ LessonStepThree — Slide 4 (Quantitative data question)
// Simple structure with LessonText.word, LessonText.sentence, LessonText.box
// Animation placeholder can be added later.

import 'package:flutter/material.dart';
import 'package:running_robot/z_pages/assets/lessonAssets/helpful_tools.dart';

const double lesson3FontSize = 20;

class LessonStepThree extends StatelessWidget {
  const LessonStepThree({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 18),

            // 🟦 Big Question Box
            LessonText.box(
              margin: const EdgeInsets.only(bottom: 14),
              child: LessonText.sentence([
                LessonText.word(
                  "That's why the",
                  Colors.black87,
                  fontSize: lesson3FontSize,
                ),
                LessonText.word(
                  "first thing",
                  const Color.fromARGB(255, 255, 109, 12),
                  fontSize: lesson3FontSize,
                ),
                LessonText.word(
                  "we ask is:",
                  const Color.fromARGB(221, 0, 0, 0),
                  fontSize: lesson3FontSize,
                ),
              ]),
            ),

            // 🟦 Key Question Box (numbers or categories)
            LessonText.box(
              margin: const EdgeInsets.only(bottom: 14),
              child: LessonText.sentence([
                LessonText.word(
                  "Is this data",
                  Colors.black87,
                  fontSize: lesson3FontSize,
                ),
                LessonText.word(
                  "numbers",
                  const Color.fromARGB(255, 0, 113, 206), // blue highlight
                  fontSize: lesson3FontSize,
                  fontWeight: FontWeight.w800,
                ),
                LessonText.word(
                  "or",
                  Colors.black87,
                  fontSize: lesson3FontSize,
                ),
                LessonText.word(
                  "categories?",
                  const Color.fromARGB(255, 200, 0, 0), // red highlight
                  fontSize: lesson3FontSize,
                  fontWeight: FontWeight.w800,
                ),
              ]),
            ),

            // 🟦 Placeholder for animation box
            LessonText.box(
              margin: const EdgeInsets.only(bottom: 14),
              child: Center(
                child: Text(
                  "🔄 (Animation coming soon)",
                  style: const TextStyle(
                    fontSize: 16,
                    fontStyle: FontStyle.italic,
                    color: Colors.black54,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}
