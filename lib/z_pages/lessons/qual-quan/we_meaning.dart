// ✅ LessonStepTwo — Slide 3 (ease-in question)
// Image box styled as a modern photo frame (soft white border + shadow)

import 'package:flutter/material.dart';
import 'package:running_robot/z_pages/assets/lessonAssets/helpful_tools.dart';

const double lesson3FontSize = 20;

class HumanLookForMeaning extends StatelessWidget {
  const HumanLookForMeaning({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 14),

            // 🟦 Box 1
            LessonText.box(
              margin: const EdgeInsets.only(top: 4, bottom: 10),
              child: LessonText.sentence([
                LessonText.word("But when humans analyze", Colors.black87,
                    fontSize: lesson3FontSize),
                LessonText.word("data", const Color.fromARGB(255, 255, 109, 12),
                    fontSize: lesson3FontSize, fontWeight: FontWeight.w800),
                LessonText.word(",", Colors.black87, fontSize: lesson3FontSize),
                LessonText.word("whether", Colors.black87,
                    fontSize: lesson3FontSize),
                LessonText.word(
                    "images,", const Color.fromARGB(255, 0, 150, 25),
                    fontSize: lesson3FontSize, fontWeight: FontWeight.w800),
                LessonText.word(
                    "sound, etc", const Color.fromARGB(255, 204, 109, 0),
                    fontSize: lesson3FontSize, fontWeight: FontWeight.w800),
              ]),
            ),

            // 🟦 Box 2
            LessonText.box(
              margin: const EdgeInsets.only(bottom: 10),
              child: LessonText.sentence([
                LessonText.word("We don’t see just", Colors.black87,
                    fontSize: lesson3FontSize),
                LessonText.word("0s", const Color.fromARGB(255, 0, 113, 206),
                    fontSize: lesson3FontSize, fontWeight: FontWeight.w800),
                LessonText.word("and", Colors.black87,
                    fontSize: lesson3FontSize),
                LessonText.word("1s", const Color.fromARGB(255, 102, 1, 218),
                    fontSize: lesson3FontSize, fontWeight: FontWeight.w800),
                LessonText.word(".", Colors.black87, fontSize: lesson3FontSize),
              ]),
            ),

            // 🟦 Box 3
            LessonText.box(
              margin: const EdgeInsets.only(bottom: 6),
              child: LessonText.sentence([
                LessonText.word("We look for", Colors.black87,
                    fontSize: lesson3FontSize),
                LessonText.word(
                    "a meaning 🌟", const Color.fromARGB(255, 255, 115, 0),
                    fontSize: lesson3FontSize, fontWeight: FontWeight.w800),
                LessonText.word(".", Colors.black87, fontSize: lesson3FontSize),
              ]),
            ),

            // 🟦 Box 4 (Modern photo frame style)
            Container(
              margin: const EdgeInsets.only(top: 12, bottom: 12),
              decoration: BoxDecoration(
                color: Colors.white, // soft gallery white frame
                border: Border.all(
                  color: const Color.fromARGB(
                      255, 235, 175, 175), // same as background, elegant frame
                  width: 9,
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: const Color.fromARGB(255, 148, 109, 109)
                        .withOpacity(0.3),
                    blurRadius: 12,
                    spreadRadius: 2,
                    offset: const Offset(4, 6),
                  ),
                ],
              ),
              child: ClipRRect(
                child: Image.asset(
                  "assets/images/happy_life.jpg",
                  width: 400,
                  height: 220,
                  fit: BoxFit.cover,
                ),
              ),
            ),

            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}
