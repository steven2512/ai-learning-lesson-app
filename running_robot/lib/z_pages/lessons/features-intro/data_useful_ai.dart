// FILE: lib/z_pages/lessons/features-intro/data_useful_ai.dart
// ✅ Simplified to 2 dialogues: about Data Sample → Features.

import 'package:flutter/material.dart';
import 'package:running_robot/z_pages/assets/lessonAssets/dialouge.dart';
import 'package:running_robot/z_pages/assets/lessonAssets/helpful_tools.dart'; // ✅ LessonText API
import 'package:running_robot/z_pages/assets/lessonAssets/mascot_dialouge.dart'; // ✅ MascotDialogue

const Color dataOrange = Color(0xFFFF6D00); // 🔸 Bright Orange
const Color aiPink = Color(0xFFE91E63); // 🔹 Accent for AI text
const double dialogueSize = 24; // consistent with previous lessons

/// ✅ Slide — "Data Sample → Features"
class DataUsefulAI extends StatelessWidget {
  final VoidCallback onFinished;
  const DataUsefulAI({super.key, required this.onFinished});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            Center(
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
                    // ──────────────────────────────
                    // Dialogue 1
                    // ──────────────────────────────
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        LessonText.sentence([
                          LessonText.word("Last", Colors.black87,
                              fontSize: dialogueSize),
                          LessonText.word("lesson,", Colors.black87,
                              fontSize: dialogueSize),
                          LessonText.word("we", Colors.black87,
                              fontSize: dialogueSize),
                          LessonText.word("learnt", dataOrange,
                              fontSize: dialogueSize,
                              fontWeight: FontWeight.w800),
                          LessonText.word("about", Colors.black87,
                              fontSize: dialogueSize),
                          LessonText.word("Data", aiPink,
                              fontSize: dialogueSize,
                              fontWeight: FontWeight.w800),
                          LessonText.word("Sample.", aiPink,
                              fontSize: dialogueSize,
                              fontWeight: FontWeight.w900),
                        ]),
                      ],
                    ),

                    // ──────────────────────────────
                    // Dialogue 2
                    // ──────────────────────────────
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        LessonText.sentence([
                          LessonText.word("Each", Colors.black87,
                              fontSize: dialogueSize),
                          LessonText.word("of", Colors.black87,
                              fontSize: dialogueSize),
                          LessonText.word("those", Colors.black87,
                              fontSize: dialogueSize),
                          LessonText.word("data samples", aiPink,
                              fontSize: dialogueSize,
                              fontWeight: FontWeight.w800),
                          LessonText.word("actually have", Colors.black87,
                              fontSize: dialogueSize),
                          LessonText.word("things", Colors.black87,
                              fontSize: dialogueSize),
                          LessonText.word("called", Colors.black87,
                              fontSize: dialogueSize),
                          LessonText.word("Features.", dataOrange,
                              fontSize: dialogueSize,
                              fontWeight: FontWeight.w900,
                              italic: true),
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
