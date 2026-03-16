// ✅ Slide 3 — What is a Label? (manual)
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:running_robot/z_pages/assets/lessonAssets/helpful_tools.dart';

const Color goalBlue = Color(0xFF1565C0);
const double defFontSize = 20;

class LabelDefinition extends StatelessWidget {
  const LabelDefinition({super.key});

  @override
  Widget build(BuildContext context) {
    final screenH = MediaQuery.of(context).size.height;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LessonText.box(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title
                LessonText.sentence([
                  LessonText.word("What", Colors.black87, fontSize: 30),
                  LessonText.word("is", Colors.black87, fontSize: 30),
                  LessonText.word("a", Colors.black87, fontSize: 30),
                  LessonText.word("Label", goalBlue, fontSize: 30),
                  LessonText.word("?", Colors.black87, fontSize: 30),
                ]),
                const SizedBox(height: 12),
                // Definition
                LessonText.sentence([
                  LessonText.word("A", Colors.black87, fontSize: defFontSize),
                  LessonText.word("label", goalBlue,
                      fontSize: defFontSize + 1, fontWeight: FontWeight.w900),
                  LessonText.word("is", Colors.black87, fontSize: defFontSize),
                  LessonText.word("the", Colors.black87, fontSize: defFontSize),
                  LessonText.word("correct", Colors.black87,
                      fontSize: defFontSize),
                  LessonText.word("answer", Colors.black87,
                      fontSize: defFontSize),
                  LessonText.word("or", Colors.black87, fontSize: defFontSize),
                  LessonText.word("goal", goalBlue,
                      fontSize: defFontSize, fontWeight: FontWeight.w900),
                  LessonText.word("we", Colors.black87, fontSize: defFontSize),
                  LessonText.word("want", Colors.black87,
                      fontSize: defFontSize),
                  LessonText.word("the", Colors.black87, fontSize: defFontSize),
                  LessonText.word("AI", const Color(0xFFE91E63),
                      fontSize: defFontSize, fontWeight: FontWeight.w900),
                  LessonText.word("to", Colors.black87, fontSize: defFontSize),
                  LessonText.word("guess!", Colors.black87,
                      fontSize: defFontSize),
                ]),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // ========== Placeholder / Animation Area ==========
          LessonText.box(
            child: Center(
              child: Image.asset(
                height: screenH * 0.25,
                "assets/images/label_def.png", // 🖼️ replace with animation later
                fit: BoxFit.contain,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
