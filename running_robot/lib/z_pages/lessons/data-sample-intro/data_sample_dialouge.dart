// FILE: lib/z_pages/lessons/data-sample-intro/one_at_a_time.dart
// ✅ Slide 2 — Dialogue (auto). EXACT mascot + bubble sizing like your example.
// Uses DialogueBox + MascotDialogue with width: 320, mascotHeight: 256,
// gapBelowBubble: -22, horizontalOffset: -15.

import 'package:flutter/material.dart';
import 'package:running_robot/z_pages/assets/lessonAssets/dialouge.dart';
import 'package:running_robot/z_pages/assets/lessonAssets/helpful_tools.dart';
import 'package:running_robot/z_pages/assets/lessonAssets/mascot_dialouge.dart';

const Color dataOrange = Color(0xFFFF6D00);
const Color aiPink = Color(0xFFE91E63);

class OneAtATimeDialogue extends StatelessWidget {
  final VoidCallback onFinished; // unlock continue (legacy)
  final VoidCallback? onRequestNext; // optional: skip continue, go next

  const OneAtATimeDialogue({
    super.key,
    required this.onFinished,
    this.onRequestNext,
  });

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
                mascotHeight: 256, // EXACT
                gapBelowBubble: -22, // EXACT
                horizontalOffset: -15, // EXACT
                anchor: MascotAnchor.left,
                dialogue: DialogueBox(
                  width: 320, // EXACT
                  finishButton: true,
                  finishCallback: () {
                    if (onRequestNext != null) {
                      onRequestNext!(); // auto-next
                    } else {
                      onFinished(); // legacy unlock
                    }
                  },
                  content: [
                    // Page 1
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        LessonText.sentence([
                          LessonText.word("We’ve", Colors.black87,
                              fontSize: 22),
                          LessonText.word("seen", Colors.black87, fontSize: 22),
                          LessonText.word("what", Colors.black87, fontSize: 22),
                          LessonText.word("data", dataOrange,
                              fontSize: 22, fontWeight: FontWeight.w900),
                          LessonText.word("is", Colors.black87, fontSize: 22),
                          LessonText.word("and", Colors.black87, fontSize: 22),
                          LessonText.word("why", Colors.black87, fontSize: 22),
                          LessonText.word("it", Colors.black87, fontSize: 22),
                          LessonText.word("matters!", Colors.black87,
                              fontSize: 22),
                        ]),
                      ],
                    ),
                    // Page 2
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        LessonText.sentence([
                          LessonText.word("But", Colors.black87, fontSize: 22),
                          LessonText.word("AI", aiPink,
                              fontSize: 22, fontWeight: FontWeight.w900),
                          LessonText.word("doesn’t", Colors.black87,
                              fontSize: 22),
                          LessonText.word("learn", Colors.black87,
                              fontSize: 22),
                          LessonText.word("from", Colors.black87, fontSize: 22),
                          LessonText.word("all", Colors.black87, fontSize: 22),
                          LessonText.word("data", dataOrange,
                              fontSize: 22, fontWeight: FontWeight.w900),
                          LessonText.word("at", Colors.black87, fontSize: 22),
                          LessonText.word("once…", Colors.black87,
                              fontSize: 22),
                        ]),
                      ],
                    ),
                    // Page 3
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        LessonText.sentence([
                          LessonText.word("It", Colors.black87, fontSize: 22),
                          LessonText.word("learns", Colors.black87,
                              fontSize: 22),
                          LessonText.word("step", Colors.black87, fontSize: 22),
                          LessonText.word("by", Colors.black87, fontSize: 22),
                          LessonText.word("step", Colors.black87, fontSize: 22),
                          LessonText.word("—", Colors.black87, fontSize: 22),
                          LessonText.word("from", Colors.black87, fontSize: 22),
                          LessonText.word("each", Colors.black87, fontSize: 22),
                          LessonText.word("data", dataOrange,
                              fontSize: 22, fontWeight: FontWeight.w900),
                          LessonText.word("sample!", dataOrange,
                              fontSize: 22, fontWeight: FontWeight.w900),
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
