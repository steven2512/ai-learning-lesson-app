// lib/z_pages/lessons/data-ai-relevance/wrap_up_dialogue.dart
// ✅ Wrap-up with mascot wrapper (formula aligned with lesson_step_zero.dart).
// ✅ Legacy untouched, only wrapped in MascotDialogue.

import 'package:flutter/material.dart';
import 'package:running_robot/z_pages/assets/lessonAssets/helpful_tools.dart';
import 'package:running_robot/z_pages/assets/lessonAssets/dialouge.dart';
import 'package:running_robot/z_pages/assets/lessonAssets/mascot_dialouge.dart'; // 👈 added

const Color _dataOrange = Color.fromARGB(255, 255, 109, 12);
const Color _aiPink = Color(0xFFE91E63);
const Color _learnBlue = Color(0xFF1E88E5);

const double _dialougeSize = 24;
const double _firstPageSize =
    20; // ↓ smaller so “classic examples” stays on one line

class WrapUpDialogue extends StatelessWidget {
  final VoidCallback? onFinished; // shows "Finish" on last page if provided
  final VoidCallback? onRequestNext; // ✅ optional skip (like lesson_step_zero)

  const WrapUpDialogue({super.key, this.onFinished, this.onRequestNext});

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
              child: MascotDialogue(
                mascotAsset: 'assets/images/mascot_pointing_up.png',
                mascotHeight: 256,
                gapBelowBubble: -22,
                horizontalOffset: -20,
                anchor: MascotAnchor.left,
                dialogue: DialogueBox(
                  width: 320,
                  finishButton: onFinished != null,
                  finishCallback: () {
                    if (onRequestNext != null) {
                      onRequestNext!();
                    } else if (onFinished != null) {
                      onFinished!();
                    }
                  },
                  content: [
                    // Page 1 — keep sentence; italicize “classic examples”; smaller font
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        LessonText.sentence([
                          LessonText.word("Those", Colors.black87,
                              fontSize: _firstPageSize),
                          LessonText.word("are", Colors.black87,
                              fontSize: _firstPageSize),
                          LessonText.word("2", Colors.black87,
                              fontSize: _firstPageSize),
                          LessonText.word("classic", Colors.black87,
                              fontSize: _firstPageSize, italic: true),
                          LessonText.word("examples", Colors.black87,
                              fontSize: _firstPageSize, italic: true),
                          LessonText.word("of", Colors.black87,
                              fontSize: _firstPageSize),
                          LessonText.word("how", Colors.black87,
                              fontSize: _firstPageSize),
                          LessonText.word("AI", _aiPink,
                              fontSize: _firstPageSize,
                              fontWeight: FontWeight.w900),
                          LessonText.word("works", Colors.black87,
                              fontSize: _firstPageSize),
                          LessonText.word("with", Colors.black87,
                              fontSize: _firstPageSize),
                          LessonText.word("data", _dataOrange,
                              fontSize: _firstPageSize,
                              fontWeight: FontWeight.w900),
                        ]),
                      ],
                    ),

                    // Page 2 — “In reality...” (light color accents; don’t overdo)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        LessonText.sentence([
                          LessonText.word("In", Colors.black87,
                              fontSize: _dialougeSize - 2),
                          LessonText.word("reality,", Colors.black87,
                              fontSize: _dialougeSize - 2),
                          LessonText.word("there", Colors.black87,
                              fontSize: _dialougeSize - 2),
                          LessonText.word("are", Colors.black87,
                              fontSize: _dialougeSize - 2),
                          LessonText.word("far", Colors.black87,
                              fontSize: _dialougeSize - 2),
                          LessonText.word("more", Colors.black87,
                              fontSize: _dialougeSize - 2),
                          LessonText.word("complex", Colors.black87,
                              fontSize: _dialougeSize - 2),
                          LessonText.word("uses", Colors.black87,
                              fontSize: _dialougeSize - 2),
                          LessonText.word("of", Colors.black87,
                              fontSize: _dialougeSize - 2),
                          LessonText.word("AI", _aiPink,
                              fontSize: _dialougeSize - 2,
                              fontWeight: FontWeight.w900),
                          LessonText.word("!", _aiPink,
                              fontSize: _dialougeSize - 2),
                        ]),
                      ],
                    ),

                    // Page 3 — “Rest assured...” + italic colored “later lessons” + cute emoji
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        LessonText.sentence([
                          LessonText.word("Rest", _learnBlue,
                              fontSize: _dialougeSize - 2,
                              fontWeight: FontWeight.w900),
                          LessonText.word("assured", _learnBlue,
                              fontSize: _dialougeSize - 2,
                              fontWeight: FontWeight.w900),
                          LessonText.word("—", Colors.black87,
                              fontSize: _dialougeSize - 2),
                          LessonText.word("we", Colors.black87,
                              fontSize: _dialougeSize - 2),
                          LessonText.word("will", Colors.black87,
                              fontSize: _dialougeSize - 2),
                          LessonText.word("learn", Colors.black87,
                              fontSize: _dialougeSize - 2),
                          LessonText.word("all", Colors.black87,
                              fontSize: _dialougeSize - 2),
                          LessonText.word("about", Colors.black87,
                              fontSize: _dialougeSize - 2),
                          LessonText.word("those", Colors.black87,
                              fontSize: _dialougeSize - 2),
                          LessonText.word("in", Colors.black87,
                              fontSize: _dialougeSize - 2),
                          LessonText.word("later", _learnBlue,
                              fontSize: _dialougeSize - 2,
                              italic: true,
                              fontWeight: FontWeight.w900),
                          LessonText.word("lessons", _learnBlue,
                              fontSize: _dialougeSize - 2,
                              italic: true,
                              fontWeight: FontWeight.w900),
                          LessonText.word("✨", _learnBlue,
                              fontSize: _dialougeSize - 2),
                          LessonText.word(".", Colors.black87,
                              fontSize: _dialougeSize - 2),
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
