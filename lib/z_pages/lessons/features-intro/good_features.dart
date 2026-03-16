// FILE: lib/z_pages/lessons/features-intro/good_features.dart
// ✅ Slide 4 — “Good Features Example” (refactored)
// • Goal box stays on top (unchanged)
// • Below it: NEW ImageSlider (smooth left/right) with tags on TOP
// • Images: assets/images/house_factors.png, assets/images/bad_examples.png
// • Tags: ["Good Features ✅", "Bad Features ❌"]
// • Slider height = MediaQuery.of(context).size.height * 0.25
// • Slider width = full LessonText.box width (accounts for inner padding)

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:running_robot/z_pages/assets/lessonAssets/helpful_tools.dart';
// NEW: import the slider widget
import 'package:running_robot/z_pages/assets/lessonAssets/image_slider.dart';

const Color goodGreen = Color(0xFF00A336); // green for "Good"
const Color mainConceptColor = Color(0xFFE91E63); // pink for "Features Example"
const Color accentColor = Color(0xFFFF6D00); // data orange
const Color goalBlue = Color(0xFF1565C0); // blue for "Goal"
const double featureFontSize = 20;

class GoodFeaturesExample extends StatelessWidget {
  final VoidCallback? onStepCompleted;

  const GoodFeaturesExample({super.key, this.onStepCompleted});

  @override
  Widget build(BuildContext context) {
    // We'll use LayoutBuilder to capture the available width for the slider
    // and subtract the default LessonText.box horizontal padding (13 * 2).
    // NOTE: LessonText.box default padding = EdgeInsets.symmetric(v:15, h:13)
    const double defaultLessonBoxHPad = 10.0;
    const double defaultLessonBoxVPad = 10.0;

    final screenH = MediaQuery.of(context).size.height;
    final sliderHeight = screenH * 0.28;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ========== Box 1 — Goal (UNCHANGED) ==========
          LessonText.box(
            child: LessonText.sentence([
              LessonText.word("Goal:", goalBlue,
                  fontSize: featureFontSize + 2, fontWeight: FontWeight.w800),
              LessonText.word("Predict", Colors.black87,
                  fontSize: featureFontSize),
              LessonText.word("house's", accentColor,
                  fontSize: featureFontSize, fontWeight: FontWeight.w900),
              LessonText.word("price 💰.", accentColor,
                  fontSize: featureFontSize, fontWeight: FontWeight.w900),
            ]),
          ),

          const SizedBox(height: 16),

          // ========== Box 2 — NEW: ImageSlider inside its own LessonText.box ==========
          // The ImageSlider itself is wrapped in LessonText.box (internally).
          // We compute width so the inner SizedBox doesn't overflow padding.
          LayoutBuilder(
            builder: (context, constraints) {
              final fullBoxWidth = constraints.maxWidth;
              final sliderWidth = fullBoxWidth -
                  (defaultLessonBoxHPad * 2); // account for inner padding

              return ImageSlider(
                imagePaths: const [
                  "assets/images/house_factors.png",
                  "assets/images/bad_example.png",
                ],
                width: sliderWidth,
                height: sliderHeight,
                // Ensure the internal LessonText.box uses the default paddings we subtracted above
                paddings: const [
                  defaultLessonBoxVPad, // top
                  defaultLessonBoxHPad, // right
                  defaultLessonBoxVPad, // bottom
                  defaultLessonBoxHPad, // left
                ],
                tagBox: false,
                tagTextColor: Colors.black,
                imageTag: true,
                imageTags: const ["Good Features ✅", "Bad Features ❌"],
                imageTagTop: true, // FIX: true actually puts tags on top
                onFinished: () {
                  // FIX: StatelessWidget -> no `widget`, call the field directly
                  onStepCompleted?.call();
                },
              );
            },
          ),
        ],
      ),
    );
  }
}
