// FILE: lib/z_pages/lessons/lesson1/lesson_step_three.dart
// ✅ Dialogue-only (like LessonStepZero)
// ✅ Two ways to notify parent: unlock Continue OR skip straight.

import 'package:flutter/material.dart';
import 'package:running_robot/z_pages/assets/lessonAssets/dialouge.dart';
import 'package:running_robot/z_pages/assets/lessonAssets/helpful_tools.dart'; // LessonText helper

const Color mainConceptColor = Color.fromARGB(255, 255, 109, 12);
const Color keyConceptGreen = Color.fromARGB(255, 0, 163, 54);
const double globalFontSize = 22;

class LessonStepThree extends StatelessWidget {
  final VoidCallback onFinished; // ✅ legacy: unlock Continue button
  final VoidCallback? onRequestNext; // ✅ optional: skip Continue and auto next

  const LessonStepThree({
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
            Padding(
              padding: const EdgeInsets.only(left: 15),
              child: DialogueBox(
                finishButton: true,
                finishCallback: () {
                  if (onRequestNext != null) {
                    onRequestNext!(); // ✅ skip continue
                  } else {
                    onFinished(); // ✅ legacy behavior
                  }
                },
                width: 320,
                content: [
                  // First line: define binary numbers
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      LessonText.sentence([
                        LessonText.word("Those", Colors.black87,
                            fontSize: globalFontSize),
                        LessonText.word("0's", keyConceptGreen,
                            fontSize: globalFontSize,
                            fontWeight: FontWeight.w800),
                        LessonText.word("and", Colors.black87,
                            fontSize: globalFontSize),
                        LessonText.word("1's", keyConceptGreen,
                            fontSize: globalFontSize,
                            fontWeight: FontWeight.w800),
                        LessonText.word("are", Colors.black87,
                            fontSize: globalFontSize),
                        LessonText.word("called", Colors.black87,
                            fontSize: globalFontSize),
                        LessonText.word("binary", mainConceptColor,
                            fontSize: globalFontSize + 2,
                            fontWeight: FontWeight.w800),
                        LessonText.word("numbers.", mainConceptColor,
                            fontSize: globalFontSize),
                      ]),
                    ],
                  ),

                  // Second line: binary means 2 values
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      LessonText.sentence([
                        LessonText.word("Binary", mainConceptColor,
                            fontSize: globalFontSize,
                            fontWeight: FontWeight.w800),
                        LessonText.word("means", Colors.black87,
                            fontSize: globalFontSize),
                        LessonText.word("we", Colors.black87,
                            fontSize: globalFontSize),
                        LessonText.word("only", Colors.black87,
                            fontSize: globalFontSize),
                        LessonText.word("use", Colors.black87,
                            fontSize: globalFontSize),
                        LessonText.word("two values", keyConceptGreen,
                            fontSize: globalFontSize,
                            fontWeight: FontWeight.w800),
                      ]),
                    ],
                  ),

                  // Third line: analogy with pairs (0/1, yes/no, blue/red)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      LessonText.sentence([
                        LessonText.word("Like", Colors.black87,
                            fontSize: globalFontSize),
                        LessonText.word("0", Colors.blue,
                            fontSize: globalFontSize,
                            fontWeight: FontWeight.w800),
                        LessonText.word("and", Colors.black87,
                            fontSize: globalFontSize),
                        LessonText.word("1,", Colors.red,
                            fontSize: globalFontSize,
                            fontWeight: FontWeight.w800),
                        LessonText.word("yes", Colors.blue,
                            fontSize: globalFontSize,
                            fontWeight: FontWeight.w800),
                        LessonText.word("and", Colors.black87,
                            fontSize: globalFontSize),
                        LessonText.word("no,", Colors.red,
                            fontSize: globalFontSize,
                            fontWeight: FontWeight.w800),
                        LessonText.word("blue", Colors.blue,
                            fontSize: globalFontSize,
                            fontWeight: FontWeight.w800),
                        LessonText.word("and", Colors.black87,
                            fontSize: globalFontSize),
                        LessonText.word("red,", Colors.red,
                            fontSize: globalFontSize,
                            fontWeight: FontWeight.w800),
                        LessonText.word("etc.", Colors.black87,
                            fontSize: globalFontSize),
                      ]),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
