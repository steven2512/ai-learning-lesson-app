// FILE: lib/z_pages/lessons/data-ai-relevance/student_homework.dart
import 'package:flutter/material.dart';
import 'package:running_robot/z_pages/assets/lessonAssets/helpful_tools.dart';

const Color dataOrange = Color.fromARGB(255, 255, 109, 12);
const Color aiPink = Color(0xFFE91E63);
const double globalFontSize = 22;

class StudentHomework extends StatelessWidget {
  const StudentHomework({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🟦 Box 1 — Header + Text
            LessonText.box(
              margin: const EdgeInsets.only(bottom: 15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Content
                  LessonText.sentence([
                    LessonText.word("Think of", Colors.black87,
                        fontSize: globalFontSize),
                    LessonText.word("AI", aiPink,
                        fontSize: globalFontSize, fontWeight: FontWeight.w900),
                    LessonText.word("as the", Colors.black87,
                        fontSize: globalFontSize),
                    LessonText.word("student", aiPink,
                        fontSize: globalFontSize, fontWeight: FontWeight.w900),
                    LessonText.word("and", Colors.black87,
                        fontSize: globalFontSize),
                    LessonText.word("data", dataOrange,
                        fontSize: globalFontSize, fontWeight: FontWeight.w900),
                    LessonText.word("as the", Colors.black87,
                        fontSize: globalFontSize),
                    LessonText.word("homework.", dataOrange,
                        fontSize: globalFontSize, fontWeight: FontWeight.w900),
                  ]),
                ],
              ),
            ),

            // 🟦 Box 2 — Placeholder image
            LessonText.box(
              margin: const EdgeInsets.only(bottom: 15),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.asset(
                  "assets/images/placeholder.png",
                  width: double.infinity,
                  height: 200,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
