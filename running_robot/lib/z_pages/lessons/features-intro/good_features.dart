// FILE: lib/z_pages/lessons/features-intro/good_features.dart
// ✅ Slide 4 — “Good Features Example”
// Displays goal first, then labeled house illustration below.

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:running_robot/z_pages/assets/lessonAssets/helpful_tools.dart';

const Color goodGreen = Color(0xFF00A336); // green for "Good"
const Color mainConceptColor = Color(0xFFE91E63); // pink for "Features Example"
const Color accentColor = Color(0xFFFF6D00); // data orange
const Color goalBlue = Color(0xFF1565C0); // blue for "Goal"
const double featureFontSize = 20;

class GoodFeaturesExample extends StatelessWidget {
  const GoodFeaturesExample({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ========== Box 1 — Goal ==========
          LessonText.box(
            child: LessonText.sentence([
              LessonText.word("Goal:", goalBlue,
                  fontSize: featureFontSize + 2, fontWeight: FontWeight.w800),
              LessonText.word("Predict", Colors.black87,
                  fontSize: featureFontSize),
              LessonText.word("house's", accentColor,
                  fontSize: featureFontSize, fontWeight: FontWeight.w900),
              LessonText.word("price.", accentColor,
                  fontSize: featureFontSize, fontWeight: FontWeight.w900),
            ]),
          ),

          const SizedBox(height: 16),

          // ========== Box 2 — Label + Image ==========
          LessonText.box(
            child: Column(
              children: [
                // ✅ “Good” green, “Features Example” pink
                LessonText.sentence([
                  LessonText.word("Good", mainConceptColor,
                      fontSize: featureFontSize + 2,
                      fontWeight: FontWeight.w800),
                  LessonText.word("Features ✅", mainConceptColor,
                      fontSize: featureFontSize + 2,
                      fontWeight: FontWeight.w700),
                ]),
                const SizedBox(height: 12),
                Center(
                  child: Image.asset(
                    "assets/images/house_factors.png",
                    fit: BoxFit.contain,
                    height: 240,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
