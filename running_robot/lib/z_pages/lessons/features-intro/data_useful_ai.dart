// FILE: lib/z_pages/lessons/features-intro/data_useful_ai.dart
import 'package:flutter/material.dart';
import 'package:running_robot/z_pages/assets/lessonAssets/dialouge.dart';
import 'package:running_robot/z_pages/assets/lessonAssets/helpful_tools.dart'; // ✅ LessonText API
import 'package:running_robot/z_pages/assets/lessonAssets/mascot_dialouge.dart'; // ✅ MascotDialogue

const Color dataOrange = Color(0xFFFF6D00); // 🔸 Bright Orange
const Color aiPink = Color(0xFFE91E63); // 🔹 Accent for AI text
const double dialogueSize = 24; // consistent with previous lessons

/// ✅ Slide 1 — "Not all data is useful"
/// Uses same layout/flow as DataAiIntro so parent brain auto callback works seamlessly.
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
                    // Page 1
                    // ──────────────────────────────
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        LessonText.sentence([
                          LessonText.word("As", Colors.black87,
                              fontSize: dialogueSize),
                          LessonText.word("you", Colors.black87,
                              fontSize: dialogueSize),
                          LessonText.word("know,", Colors.black87,
                              fontSize: dialogueSize),
                          LessonText.word("AI", aiPink,
                              fontSize: dialogueSize,
                              fontWeight: FontWeight.w900),
                          LessonText.word("needs", Colors.black87,
                              fontSize: dialogueSize),
                          LessonText.word("data", dataOrange,
                              fontSize: dialogueSize,
                              fontWeight: FontWeight.w900),
                          LessonText.word("to", Colors.black87,
                              fontSize: dialogueSize),
                          LessonText.word("do", Colors.black87,
                              fontSize: dialogueSize),
                          LessonText.word("meaningful", Colors.black87,
                              fontSize: dialogueSize),
                          LessonText.word("things", Colors.black87,
                              fontSize: dialogueSize),
                          LessonText.word("for", Colors.black87,
                              fontSize: dialogueSize),
                          LessonText.word("humans.", Colors.black87,
                              fontSize: dialogueSize),
                        ]),
                      ],
                    ),

                    // ──────────────────────────────
                    // Page 2
                    // ──────────────────────────────
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        LessonText.sentence([
                          LessonText.word("However,", Colors.black87,
                              fontSize: dialogueSize),
                          LessonText.word("not", Colors.black87,
                              fontSize: dialogueSize),
                          LessonText.word("everything", Colors.black87,
                              fontSize: dialogueSize),
                          LessonText.word("about", Colors.black87,
                              fontSize: dialogueSize),
                          LessonText.word("that", Colors.black87,
                              fontSize: dialogueSize),
                          LessonText.word("data", dataOrange,
                              fontSize: dialogueSize,
                              fontWeight: FontWeight.w900),
                          LessonText.word("will", Colors.black87,
                              fontSize: dialogueSize),
                          LessonText.word("be", Colors.black87,
                              fontSize: dialogueSize),
                          LessonText.word("useful", aiPink,
                              fontSize: dialogueSize,
                              fontWeight: FontWeight.w900),
                          LessonText.word("for", Colors.black87,
                              fontSize: dialogueSize),
                          LessonText.word("the", Colors.black87,
                              fontSize: dialogueSize),
                          LessonText.word("AI.", aiPink,
                              fontSize: dialogueSize,
                              fontWeight: FontWeight.w900),
                        ]),
                      ],
                    ),

                    // ──────────────────────────────
                    // Page 3
                    // ──────────────────────────────
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        LessonText.sentence([
                          LessonText.word("So", Colors.black87,
                              fontSize: dialogueSize),
                          LessonText.word("we", Colors.black87,
                              fontSize: dialogueSize),
                          LessonText.word("have", Colors.black87,
                              fontSize: dialogueSize),
                          LessonText.word("to", Colors.black87,
                              fontSize: dialogueSize),
                          LessonText.word("choose", aiPink,
                              fontSize: dialogueSize,
                              fontWeight: FontWeight.w900),
                          LessonText.word("smartly", aiPink,
                              fontSize: dialogueSize,
                              fontWeight: FontWeight.w900),
                          LessonText.word("to", Colors.black87,
                              fontSize: dialogueSize),
                          LessonText.word("help", Colors.black87,
                              fontSize: dialogueSize),
                          LessonText.word("AI", aiPink,
                              fontSize: dialogueSize,
                              fontWeight: FontWeight.w900),
                          LessonText.word("learn", Colors.black87,
                              fontSize: dialogueSize),
                          LessonText.word("better!", Colors.black87,
                              fontSize: dialogueSize),
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
