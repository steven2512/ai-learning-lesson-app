// ✅ Slide 1 — Quote (manual)
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:running_robot/z_pages/assets/lessonAssets/helpful_tools.dart';

class LabelQuote extends StatelessWidget {
  const LabelQuote({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 8),
      child: LessonText.box(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "“Without a goal, life is motion without meaning.”",
              style: GoogleFonts.lato(
                fontSize: 24,
                fontStyle: FontStyle.italic,
                fontWeight: FontWeight.w700,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            LessonText.sentence([
              LessonText.word("—", Colors.black54,
                  fontSize: 18, fontWeight: FontWeight.w700),
              LessonText.word("Rick", const Color(0xFF6A1B9A),
                  fontSize: 18, fontWeight: FontWeight.w800, italic: true),
              LessonText.word("Warren", const Color(0xFF6A1B9A),
                  fontSize: 18, fontWeight: FontWeight.w800, italic: true),
            ]),
          ],
        ),
      ),
    );
  }
}
