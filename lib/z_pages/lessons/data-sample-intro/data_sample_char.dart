// FILE: lib/z_pages/lessons/data-sample-intro/data_sample_char.dart
// ✅ Slide 4 — Single sentence box + animation box (no extra explanation)

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:running_robot/core/widgets.dart';
import 'package:running_robot/z_pages/assets/lessonAssets/helpful_tools.dart';

final double screenH = ScreenSize.height;

const Color mainConceptColor = Color.fromARGB(255, 255, 109, 12); // 🔸 orange

class DataSampleCharacteristic extends StatelessWidget {
  const DataSampleCharacteristic({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ========== Single sentence only ==========
          LessonText.box(
            child: LessonText.sentence([
              LessonText.word("A", Colors.black87, fontSize: 26),
              LessonText.word("Data", mainConceptColor,
                  fontSize: 26, fontWeight: FontWeight.w900),
              LessonText.word("Sample", mainConceptColor,
                  fontSize: 26, fontWeight: FontWeight.w900),
              LessonText.word("is", Colors.black87, fontSize: 26),
              LessonText.word("always", Colors.black87, fontSize: 26),
              LessonText.word("singular.", Colors.black87, fontSize: 26),
            ]),
          ),

          const SizedBox(height: 16),

          // ========== Animation placeholder ==========
          Center(
            child: Image.asset(
              "assets/images/always_singular.png",
              fit: BoxFit.contain,
              height: screenH * 0.35,
            ),
          ),
        ],
      ),
    );
  }
}
