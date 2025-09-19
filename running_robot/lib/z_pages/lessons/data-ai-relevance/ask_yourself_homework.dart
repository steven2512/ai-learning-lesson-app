// FILE: lib/z_pages/lessons/data-ai-relevance/student_homework.dart
import 'package:flutter/material.dart';
import 'package:running_robot/z_pages/assets/lessonAssets/helpful_tools.dart';

const Color dataOrange = Color.fromARGB(255, 255, 109, 12); // homework
const Color aiPink = Color(0xFFE91E63); // student
const Color practiceGreen = Color.fromARGB(255, 0, 163, 54); // practice/improve
const double globalFontSize = 22;

class AskYourselfHomework extends StatelessWidget {
  const AskYourselfHomework({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🟦 Box 1 — "Ask Yourself" + question (same box)
            LessonText.box(
              margin: const EdgeInsets.only(bottom: 15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  LessonText.sentence([
                    LessonText.word("Ask", dataOrange,
                        fontSize: 30, fontWeight: FontWeight.w900),
                    LessonText.word("Yourself", dataOrange,
                        fontSize: 30, fontWeight: FontWeight.w900),
                  ]),
                  const SizedBox(height: 14),

                  // Question
                  LessonText.sentence([
                    LessonText.word("Without the", Colors.black87,
                        fontSize: globalFontSize),
                    LessonText.word("homework (data)", dataOrange,
                        fontSize: globalFontSize, fontWeight: FontWeight.w900),
                    LessonText.word(",", Colors.black87,
                        fontSize: globalFontSize),
                    LessonText.word("can the", Colors.black87,
                        fontSize: globalFontSize),
                    LessonText.word("student (AI)", aiPink,
                        fontSize: globalFontSize, fontWeight: FontWeight.w900),
                    LessonText.word(
                        "improve?", const Color.fromARGB(255, 0, 0, 0),
                        fontSize: globalFontSize, fontWeight: FontWeight.w900),
                  ]),
                ],
              ),
            ),

            LessonText.box(
              padding: EdgeInsetsGeometry.all(8),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.asset(
                  "assets/images/ask_yourself.png",
                  width: 400,
                  height: 220,
                  fit: BoxFit.cover,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
