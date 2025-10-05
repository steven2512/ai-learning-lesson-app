// FILE: lib/z_pages/lessons/features-intro/feature_definition.dart
// ✅ Slide 2 — Definition: “What is a Feature?”
// Same format as QualIntro — definition box + optional image zone.

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:running_robot/z_pages/assets/lessonAssets/helpful_tools.dart';

const Color mainConceptColor = Color(0xFFE91E63); // 🔹 AI Pink
const Color keyConceptOrange = Color(0xFFFF6D00); // 🔸 Data Orange
const double featureFontSize = 20;

class FeatureDefinition extends StatelessWidget {
  const FeatureDefinition({super.key});

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
                  LessonText.word("a", Colors.black87, fontSize: 30),
                  LessonText.word("Feature?", mainConceptColor,
                      fontSize: 30, fontWeight: FontWeight.w900),
                ]),
                const SizedBox(height: 12),
                LessonText.sentence([
                  LessonText.word("A", Colors.black87,
                      fontSize: featureFontSize),
                  LessonText.word("feature", mainConceptColor,
                      fontSize: featureFontSize, fontWeight: FontWeight.w800),
                  LessonText.word("is", Colors.black87,
                      fontSize: featureFontSize),
                  LessonText.word("an", Colors.black87,
                      fontSize: featureFontSize),
                  LessonText.word("attribute", keyConceptOrange,
                      fontSize: featureFontSize,
                      fontWeight: FontWeight.w900,
                      italic: true),
                  LessonText.word("of", Colors.black87,
                      fontSize: featureFontSize),
                  LessonText.word("the", Colors.black87,
                      fontSize: featureFontSize),
                  LessonText.word("data", keyConceptOrange,
                      fontSize: featureFontSize, fontWeight: FontWeight.w900),
                  LessonText.word("that", Colors.black87,
                      fontSize: featureFontSize),
                  LessonText.word("helps", Colors.black87,
                      fontSize: featureFontSize),
                  LessonText.word("AI", mainConceptColor,
                      fontSize: featureFontSize, fontWeight: FontWeight.w900),
                  LessonText.word("make", Colors.black87,
                      fontSize: featureFontSize),
                  LessonText.word("a", Colors.black87,
                      fontSize: featureFontSize),
                  LessonText.word("decision", Colors.black87,
                      fontSize: featureFontSize, italic: true),
                  LessonText.word("or", Colors.black87,
                      fontSize: featureFontSize),
                  LessonText.word("prediction.", Colors.black87,
                      fontSize: featureFontSize,
                      fontWeight: FontWeight.w800,
                      italic: true),
                ]),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // ========== Placeholder / Animation Area ==========
          LessonText.box(
            child: Center(
              child: Image.asset(
                height: 200,
                "assets/images/car_model.png", // 🖼️ replace with animation later
                fit: BoxFit.contain,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
