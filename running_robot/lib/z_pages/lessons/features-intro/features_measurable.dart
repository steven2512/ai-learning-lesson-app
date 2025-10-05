// FILE: lib/z_pages/lessons/features-intro/feature_measurable.dart
// ✅ Slide 3 — “A feature must be measurable”
// Two definition boxes: main rule + clarification with recap mention.

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:running_robot/z_pages/assets/lessonAssets/helpful_tools.dart';

const Color featurePink = Color(0xFFE91E63); // AI highlight
const Color dataOrange = Color(0xFFFF6D00); // Data highlight
const double featureFontSize = 20;

class FeatureMeasurable extends StatelessWidget {
  const FeatureMeasurable({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ========== Box 1 — Rule ==========
          LessonText.box(
            child: LessonText.sentence([
              LessonText.word("A", Colors.black87, fontSize: 26),
              LessonText.word("feature", featurePink,
                  fontSize: 26, fontWeight: FontWeight.w900),
              LessonText.word("must", Colors.black87, fontSize: 26),
              LessonText.word("be", Colors.black87, fontSize: 26),
              LessonText.word("measurable.", dataOrange,
                  fontSize: 26, fontWeight: FontWeight.w900),
            ]),
          ),

          const SizedBox(height: 16),

          // ========== Box 2 — Clarification ==========
          LessonText.box(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                LessonText.sentence([
                  LessonText.word("Measurable", featurePink,
                      fontSize: featureFontSize + 1,
                      fontWeight: FontWeight.w800),
                  LessonText.word("means", Colors.black87,
                      fontSize: featureFontSize),
                  LessonText.word("something", Colors.black87,
                      fontSize: featureFontSize),
                  LessonText.word("either", Colors.black87,
                      fontSize: featureFontSize),
                  LessonText.word("numeric", dataOrange,
                      fontSize: featureFontSize, fontWeight: FontWeight.w900),
                  LessonText.word("(quantitative)", Colors.black54,
                      fontSize: featureFontSize, italic: true),
                  LessonText.word("or", Colors.black87,
                      fontSize: featureFontSize),
                  LessonText.word("categorical", dataOrange,
                      fontSize: featureFontSize, fontWeight: FontWeight.w900),
                  LessonText.word("(qualitative).", Colors.black54,
                      fontSize: featureFontSize, italic: true),
                ]),
                const SizedBox(height: 6),
                LessonText.sentence([
                  LessonText.word("(Recap", const Color.fromARGB(255, 0, 0, 0),
                      fontSize: featureFontSize - 1),
                  LessonText.word("Lesson", Colors.black54,
                      fontSize: featureFontSize - 1),
                  LessonText.word("4)", Colors.black54,
                      fontSize: featureFontSize - 1),
                ]),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
