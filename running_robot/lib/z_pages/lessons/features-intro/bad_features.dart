// FILE: lib/z_pages/lessons/features-intro/bad_features.dart
// ✅ Slide 5 — “Bad Features Example”
// Displays goal first, then labeled placeholder image below.

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:running_robot/z_pages/assets/lessonAssets/helpful_tools.dart';

const Color badPink = Color(0xFFE91E63); // pink for "Bad"
const Color accentColor = Color(0xFFFF6D00); // data orange
const Color goalBlue = Color(0xFF1565C0); // blue for "Goal"
const double featureFontSize = 20;

class BadFeaturesExample extends StatelessWidget {
  const BadFeaturesExample({super.key});

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

          // ========== Box 2 — Label + Placeholder Image ==========
          LessonText.box(
            child: Column(
              children: [
                // ✅ “Bad Features” label (pink)
                LessonText.sentence([
                  LessonText.word("Bad Features ❌", badPink,
                      fontSize: featureFontSize + 2,
                      fontWeight: FontWeight.w800),
                ]),
                const SizedBox(height: 12),
                Center(
                  child: Image.asset(
                    "assets/images/bad_example.png", // 🔹 Placeholder image
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
