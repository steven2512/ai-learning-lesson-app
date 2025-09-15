// FILE: lib/z_pages/lessons/lesson1/lesson_step_zero.dart
// ✅ Dialogue-only. Animation removed.
// ✅ Two ways to notify parent: unlock Continue OR skip straight.

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:running_robot/z_pages/assets/lessonAssets/dialouge.dart';
import 'package:running_robot/z_pages/assets/lessonAssets/helpful_tools.dart'; // LessonText helper

const Color lessonOneColor = Color(0xFF00897B); // Teal
const Color conceptColor = Color(0xFF6A1B9A); // Deep Purple
const Color aiColor = Color(0xFFE91E63); // Pink accent
const Color dataOrange = Color(0xFFFF6D00); // Bright Orange

const double secondLineSize = 20.5;
const FontWeight secondLineWeight = FontWeight.w800;

class DataIntroLesson extends StatelessWidget {
  final VoidCallback onFinished; // ✅ legacy: unlock Continue button
  final VoidCallback? onRequestNext; // ✅ optional: skip Continue and auto next

  const DataIntroLesson({
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
                  // Welcome
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      LessonText.sentence([
                        LessonText.word("Welcome", Colors.black87,
                            fontSize: 28),
                        LessonText.word("to", Colors.black87, fontSize: 28),
                        LessonText.word("Lesson 1!", dataOrange,
                            fontSize: 28, fontWeight: FontWeight.w900),
                      ]),
                    ],
                  ),

                  // Foundational Concept in AI
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      LessonText.sentence([
                        LessonText.word("We", Colors.black87, fontSize: 22),
                        LessonText.word("will", Colors.black87, fontSize: 22),
                        LessonText.word("now", Colors.black87, fontSize: 22),
                        LessonText.word("learn", Colors.black87, fontSize: 22),
                        LessonText.word("the", Colors.black87, fontSize: 22),
                        LessonText.word("most", Colors.black87, fontSize: 22),
                        LessonText.word("foundational",
                            const Color.fromARGB(255, 0, 14, 211),
                            fontSize: 22, fontWeight: FontWeight.w900),
                        LessonText.word(
                            "concept", Color.fromARGB(255, 0, 14, 211),
                            fontSize: 22, fontWeight: FontWeight.w900),
                        LessonText.word("in", Colors.black87, fontSize: 22),
                        LessonText.word(
                            "AI", const Color.fromARGB(255, 233, 0, 0),
                            fontSize: 22, fontWeight: FontWeight.w900),
                      ]),
                    ],
                  ),

                  // The Concept of Data ⚡
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      LessonText.sentence([
                        LessonText.word("The", Colors.black87, fontSize: 26),
                        LessonText.word("concept", Colors.black87,
                            fontSize: 26),
                        LessonText.word("of", Colors.black87, fontSize: 26),
                        LessonText.word("Data ⚡", dataOrange,
                            fontSize: 26, fontWeight: FontWeight.w900),
                      ]),
                    ],
                  ),

                  // What is Data?
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      LessonText.sentence([
                        LessonText.word("So", Colors.black87, fontSize: 30),
                        LessonText.word("what", Colors.black87, fontSize: 30),
                        LessonText.word("is", Colors.black87, fontSize: 30),
                        LessonText.word("Data?", dataOrange,
                            fontSize: 30, fontWeight: FontWeight.w900),
                      ]),
                      const SizedBox(height: 12),
                      LessonText.sentence([
                        const Padding(
                          padding: EdgeInsets.only(top: 3, right: 1),
                          child: Icon(Icons.arrow_forward_rounded,
                              size: 26, color: Colors.black54),
                        ),
                        LessonText.word("Data", dataOrange,
                            fontSize: secondLineSize,
                            fontWeight: FontWeight.w800),
                        LessonText.word("is", Colors.black87,
                            fontSize: secondLineSize,
                            fontWeight: secondLineWeight),
                        LessonText.word("the", Colors.black87,
                            fontSize: secondLineSize,
                            fontWeight: secondLineWeight),
                        LessonText.word("information", lessonOneColor,
                            fontSize: secondLineSize,
                            fontWeight: FontWeight.w800),
                        LessonText.word("we", Colors.black87,
                            fontSize: secondLineSize,
                            fontWeight: secondLineWeight),
                        LessonText.word("feed", Colors.black87,
                            fontSize: secondLineSize,
                            fontWeight: secondLineWeight),
                        LessonText.word("into", Colors.black87,
                            fontSize: secondLineSize,
                            fontWeight: secondLineWeight),
                        LessonText.word("a", Colors.black87,
                            fontSize: secondLineSize,
                            fontWeight: secondLineWeight),
                        LessonText.word("computer.", Colors.black87,
                            fontSize: secondLineSize,
                            fontWeight: secondLineWeight),
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
