// FILE: label_recap_complete_sample.dart
// Slide — Recap: simplified animation inside LessonText.box (box height = 38%)

import 'package:flutter/material.dart';
import 'package:running_robot/z_pages/assets/lessonAssets/helpful_tools.dart';
import 'package:running_robot/z_pages/lessons/label-intro/plane_tag.dart';

const Color aiPink = Color(0xFFE91E63);
const Color goalBlue = Color(0xFF1565C0);
const Color dataOrange = Color(0xFFFF6D00);

class LabelRecapCompleteSample extends StatelessWidget {
  final VoidCallback? onStepCompleted;
  const LabelRecapCompleteSample({super.key, this.onStepCompleted});

  @override
  Widget build(BuildContext context) {
    final h = MediaQuery.of(context).size.height;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LessonText.box(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                LessonText.sentence([
                  LessonText.word("Combining", Colors.black87,
                      fontSize: 22, fontWeight: FontWeight.w800),
                  LessonText.word("Features", aiPink,
                      fontSize: 22, fontWeight: FontWeight.w900),
                  LessonText.word("and", Colors.black87, fontSize: 22),
                  LessonText.word("Label", goalBlue,
                      fontSize: 22, fontWeight: FontWeight.w900),
                  LessonText.word("gives", Colors.black87, fontSize: 22),
                  LessonText.word("a", Colors.black87, fontSize: 22),
                  LessonText.word("complete", Colors.black87,
                      fontSize: 22, fontWeight: FontWeight.w800),
                  LessonText.word("Data", dataOrange,
                      fontSize: 22, fontWeight: FontWeight.w900),
                  LessonText.word("Sample.", dataOrange,
                      fontSize: 22, fontWeight: FontWeight.w900),
                ]),
                const SizedBox(height: 8),
                LessonText.sentence([
                  LessonText.word("(recap", Colors.black54, fontSize: 16),
                  LessonText.word("lesson", Colors.black54, fontSize: 16),
                  LessonText.word("6)", Colors.black54, fontSize: 16),
                ]),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Hard cap the animation box to 38% of screen height
          LessonText.box(
            child: SizedBox(
              height: h * 0.38,
              child: PlaneTagsPriceAnimation(
                planeAsset: 'assets/images/airplane.png',
                onCompleted: (_) => onStepCompleted?.call(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
