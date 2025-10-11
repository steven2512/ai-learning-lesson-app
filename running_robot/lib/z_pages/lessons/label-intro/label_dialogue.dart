// ✅ Slide 2 — Robot Dialogue (auto), exactly like your OneAtATimeDialogue style.
import 'package:flutter/material.dart';
import 'package:running_robot/z_pages/assets/lessonAssets/dialouge.dart';
import 'package:running_robot/z_pages/assets/lessonAssets/helpful_tools.dart';
import 'package:running_robot/z_pages/assets/lessonAssets/mascot_dialouge.dart';

const Color dataOrange = Color(0xFFFF6D00);
const Color aiPink = Color(0xFFE91E63);
const Color goalBlue = Color(0xFF1565C0);

class LabelDialogue extends StatelessWidget {
  final VoidCallback onFinished; // unlock continue
  final VoidCallback? onRequestNext; // optional auto-next

  const LabelDialogue({
    super.key,
    required this.onFinished,
    this.onRequestNext,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 30),
      child: Center(
        child: MascotDialogue(
          mascotAsset: 'assets/images/mascot_pointing_up.png',
          mascotHeight: 256,
          gapBelowBubble: -22,
          horizontalOffset: -15,
          anchor: MascotAnchor.left,
          dialogue: DialogueBox(
            width: 320,
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
                    LessonText.word("Now", Colors.black87, fontSize: 22),
                    LessonText.word("you", Colors.black87, fontSize: 22),
                    LessonText.word("know", Colors.black87, fontSize: 22),
                    LessonText.word("what", Colors.black87, fontSize: 22),
                    LessonText.word("a Feature", aiPink,
                        fontSize: 22, fontWeight: FontWeight.w900),
                    LessonText.word("is", Colors.black87, fontSize: 22),
                  ]),
                ],
              ),
              // Page 2
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  LessonText.sentence([
                    LessonText.word("However,", Colors.black87, fontSize: 22),
                    LessonText.word("Features", aiPink,
                        fontSize: 22, fontWeight: FontWeight.w900),
                    LessonText.word("don't", Colors.black87, fontSize: 22),
                    LessonText.word("mean", Colors.black87, fontSize: 22),
                    LessonText.word("anything", Colors.black87, fontSize: 22),
                    LessonText.word("without", Colors.black87, fontSize: 22),
                    LessonText.word("a", Colors.black87, fontSize: 22),
                    LessonText.word("Goal", goalBlue,
                        fontSize: 22, fontWeight: FontWeight.w900),
                    LessonText.word("to", Colors.black87, fontSize: 22),
                    LessonText.word("aim", Colors.black87, fontSize: 22),
                    LessonText.word("at!", Colors.black87, fontSize: 22),
                  ]),
                ],
              ),
              // Page 3
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  LessonText.sentence([
                    LessonText.word("That", Colors.black87, fontSize: 22),
                    LessonText.word("goal", goalBlue,
                        fontSize: 22, fontWeight: FontWeight.w900),
                    LessonText.word("usually", Colors.black87, fontSize: 22),
                    LessonText.word("is", Colors.black87, fontSize: 22),
                    LessonText.word("some", Colors.black87, fontSize: 22),
                    LessonText.word("decision", Colors.black87, fontSize: 22),
                    LessonText.word("or", Colors.black87, fontSize: 22),
                    LessonText.word("prediction", Colors.black87, fontSize: 22),
                    LessonText.word("humans", Colors.black87, fontSize: 22),
                    LessonText.word("need", Colors.black87, fontSize: 22),
                    LessonText.word("AI", aiPink,
                        fontSize: 22, fontWeight: FontWeight.w900),
                    LessonText.word("to", Colors.black87, fontSize: 22),
                    LessonText.word("make!", Colors.black87, fontSize: 22),
                  ]),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
