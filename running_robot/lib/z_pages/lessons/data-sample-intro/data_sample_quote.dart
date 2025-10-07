// FILE: lib/z_pages/lessons/data-sample-intro/data_sample_quote.dart
// ✅ Slide 1 — Quote (manual). Italic quote, author colored using LessonText.sentence + word.

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:running_robot/z_pages/assets/lessonAssets/helpful_tools.dart';

const Color authorAccent = Color(0xFF6A1B9A); // nice deep purple

class DataSampleQuote extends StatelessWidget {
  const DataSampleQuote({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LessonText.box(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "“We learn from example and direct experience; the rest is just noise”",
                  style: GoogleFonts.lato(
                    fontSize: 24,
                    fontStyle: FontStyle.italic,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                // Author line using LessonText.sentence + LessonText.word
                LessonText.sentence([
                  LessonText.word("—", Colors.black54,
                      fontSize: 18, fontWeight: FontWeight.w700),
                  LessonText.word("Malcolm", authorAccent,
                      fontSize: 18, fontWeight: FontWeight.w800, italic: true),
                  LessonText.word("Gladwell", authorAccent,
                      fontSize: 18, fontWeight: FontWeight.w800, italic: true),
                ]),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
