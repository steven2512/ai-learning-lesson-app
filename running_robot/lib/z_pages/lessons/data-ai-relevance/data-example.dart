// FILE: lib/z_pages/lessons/data-ai-relevance/data_example.dart
import 'package:flutter/material.dart';
import 'package:running_robot/z_pages/assets/lessonAssets/dialouge.dart';
import 'package:running_robot/z_pages/assets/lessonAssets/helpful_tools.dart';

const Color dataOrange = Color.fromARGB(255, 255, 109, 12); // Data
const Color aiPink = Color(0xFFE91E63); // AI
const Color exampleBlue = Color.fromARGB(255, 0, 123, 255); // Examples
const double globalFontSize = 21;

class DataExample extends StatelessWidget {
  final VoidCallback onFinished;

  const DataExample({super.key, required this.onFinished});

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
                finishCallback: onFinished,
                width: 320,
                content: [
                  // Page 1 — First sentence
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      LessonText.sentence([
                        LessonText.word("Data", dataOrange,
                            fontSize: globalFontSize,
                            fontWeight: FontWeight.w900),
                        LessonText.word("is", Colors.black87,
                            fontSize: globalFontSize),
                        LessonText.word("basically", Colors.black87,
                            fontSize: globalFontSize),
                        LessonText.word("the", Colors.black87,
                            fontSize: globalFontSize),
                        LessonText.word("examples", exampleBlue,
                            fontSize: globalFontSize,
                            fontWeight: FontWeight.w700,
                            italic: true),
                        LessonText.word("that", Colors.black87,
                            fontSize: globalFontSize),
                        LessonText.word("AI", aiPink,
                            fontSize: globalFontSize,
                            fontWeight: FontWeight.w900),
                        LessonText.word("learns", Colors.black87,
                            fontSize: globalFontSize),
                        LessonText.word("from.", Colors.black87,
                            fontSize: globalFontSize),
                      ]),
                    ],
                  ),

                  // Page 2 — Second sentence
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      LessonText.sentence([
                        LessonText.word("With", Colors.black87,
                            fontSize: globalFontSize - 1),
                        LessonText.word("data", dataOrange,
                            fontSize: globalFontSize - 1,
                            fontWeight: FontWeight.w900),
                        LessonText.word(",", Colors.black87,
                            fontSize: globalFontSize - 1),
                        LessonText.word("AI", aiPink,
                            fontSize: globalFontSize - 1,
                            fontWeight: FontWeight.w900),
                        LessonText.word("can", Colors.black87,
                            fontSize: globalFontSize - 1),
                        LessonText.word("do", Colors.black87,
                            fontSize: globalFontSize - 1),
                        LessonText.word("powerful", Colors.black,
                            fontSize: globalFontSize - 1,
                            fontWeight: FontWeight.w900,
                            italic: true),
                        LessonText.word("and", Colors.black87,
                            fontSize: globalFontSize - 1),
                        LessonText.word("useful", Colors.black,
                            fontSize: globalFontSize - 1,
                            fontWeight: FontWeight.w900,
                            italic: true),
                        LessonText.word("things", Colors.black,
                            fontSize: globalFontSize - 1,
                            fontWeight: FontWeight.w900,
                            italic: true),
                        LessonText.word("for", Colors.black87,
                            fontSize: globalFontSize - 1),
                        LessonText.word("humans.", Colors.black87,
                            fontSize: globalFontSize - 1),
                      ]),
                    ],
                  ),

                  // Page 3 — Transition sentence
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      LessonText.sentence([
                        LessonText.word("Let's", Colors.black87,
                            fontSize: globalFontSize),
                        LessonText.word("see", Colors.black87,
                            fontSize: globalFontSize),
                        LessonText.word("what", Colors.black87,
                            fontSize: globalFontSize),
                        LessonText.word("AI", aiPink,
                            fontSize: globalFontSize,
                            fontWeight: FontWeight.w900),
                        LessonText.word("can really", Colors.black87,
                            fontSize: globalFontSize),
                        LessonText.word("do", Colors.black87,
                            fontSize: globalFontSize),
                        LessonText.word("with", Colors.black87,
                            fontSize: globalFontSize),
                        LessonText.word("data!", dataOrange,
                            fontSize: globalFontSize,
                            fontWeight: FontWeight.w900),
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
