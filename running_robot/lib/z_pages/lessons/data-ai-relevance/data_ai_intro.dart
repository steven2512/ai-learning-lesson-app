// FILE: lib/z_pages/lessons/data-ai-relevance/data_ai_intro.dart
// ✅ Dialogue-only with mascot wrapper.
// ✅ Same formula as lesson_step_zero.dart.

import 'package:flutter/material.dart';
import 'package:running_robot/z_pages/assets/lessonAssets/dialouge.dart';
import 'package:running_robot/z_pages/assets/lessonAssets/helpful_tools.dart'; // LessonText helper
import 'package:running_robot/z_pages/assets/lessonAssets/mascot_dialouge.dart'; // 👈 added

const Color dataOrange = Color(0xFFFF6D00); // 🔸 Bright Orange
const Color aiPink = Color(0xFFE91E63);
const double dialougeSize = 24; // 🔹 Accent for AI

class DataAiIntro extends StatelessWidget {
  final VoidCallback onFinished;

  const DataAiIntro({super.key, required this.onFinished});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.only(left: 15),
              // 👇 Wrap DialogueBox in MascotDialogue (same pattern as lesson_step_zero.dart)
              child: MascotDialogue(
                mascotAsset: 'assets/images/mascot_pointing_up.png',
                mascotHeight: 256,
                gapBelowBubble: -22,
                horizontalOffset: -15,
                anchor: MascotAnchor.left,
                dialogue: DialogueBox(
                  finishButton: true,
                  finishCallback: onFinished,
                  width: 320,
                  content: [
                    // Page 1
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        LessonText.sentence([
                          LessonText.word("Now", Colors.black87,
                              fontSize: dialougeSize),
                          LessonText.word("you", Colors.black87,
                              fontSize: dialougeSize),
                          LessonText.word("know", Colors.black87,
                              fontSize: dialougeSize),
                          LessonText.word("what", Colors.black87,
                              fontSize: dialougeSize),
                          LessonText.word("data", dataOrange,
                              fontSize: dialougeSize,
                              fontWeight: FontWeight.w900),
                          LessonText.word("is", Colors.black87,
                              fontSize: dialougeSize),
                          LessonText.word("🔥", Colors.black87,
                              fontSize: dialougeSize),
                        ]),
                      ],
                    ),

                    // Page 2
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        LessonText.sentence([
                          LessonText.word("You may wonder", Colors.black87,
                              fontSize: dialougeSize),
                          LessonText.word('"Why', Colors.black87,
                              fontSize: dialougeSize),
                          LessonText.word("do", Colors.black87,
                              fontSize: dialougeSize),
                          LessonText.word("we", Colors.black87,
                              fontSize: dialougeSize),
                          LessonText.word("care", Colors.black87,
                              fontSize: dialougeSize),
                          LessonText.word("about", Colors.black87,
                              fontSize: dialougeSize),
                          LessonText.word('Data?"', dataOrange,
                              fontSize: dialougeSize,
                              fontWeight: FontWeight.w900),
                        ]),
                      ],
                    ),

                    // Page 3
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        LessonText.sentence([
                          LessonText.word("How", Colors.black87,
                              fontSize: dialougeSize),
                          LessonText.word("is", Colors.black87,
                              fontSize: dialougeSize),
                          LessonText.word("data", dataOrange,
                              fontSize: dialougeSize,
                              fontWeight: FontWeight.w900),
                          LessonText.word("really", Colors.black87,
                              fontSize: dialougeSize),
                          LessonText.word("related", Colors.black87,
                              fontSize: dialougeSize),
                          LessonText.word("to", Colors.black87,
                              fontSize: dialougeSize),
                          LessonText.word("AI?", aiPink,
                              fontSize: dialougeSize,
                              fontWeight: FontWeight.w900),
                        ]),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
