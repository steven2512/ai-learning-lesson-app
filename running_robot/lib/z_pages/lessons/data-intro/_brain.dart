// FILE: lib/z_pages/lessons/lesson1/lesson1.dart
import 'package:flutter/material.dart';
import 'package:running_robot/core/app_router.dart';
import 'package:running_robot/core/base_lesson_brain.dart';

// legacy lesson steps
import 'package:running_robot/z_pages/lessons/data-intro/data_intro.dart'; // StepZero + StepOne
import 'package:running_robot/z_pages/lessons/data-intro/comp_data.dart';
import 'package:running_robot/z_pages/lessons/data-intro/data_types.dart';
import 'package:running_robot/z_pages/lessons/data-intro/data_quiz.dart';

class DataIntroBrain extends BaseLessonBrain {
  const DataIntroBrain({super.key, required AppNavigate onNavigate})
      : super(onNavigate: onNavigate);

  @override
  String get lessonId => "data-intro";

  @override
  State<DataIntroBrain> createState() => _DataIntroBrainState();
}

class _DataIntroBrainState extends BaseLessonBrainState<DataIntroBrain> {
  @override
  List<SubLesson> buildSubLessons() => [
        // Step 0 → Intro with conditional continue
        SubLesson(
          topOffset: 200,
          mechanic: LessonMechanic.auto, // ✅ auto, not manual
          build: (done, reset) => DataIntroLesson(
            onFinished: () => done(), // fallback if needed
            onRequestNext: () => goNext(), // skip Continue if triggered
          ),
        ),

        // Step 1 → Computer to Data
        SubLesson(
          topOffset: 220,
          mechanic: LessonMechanic.emit,
          build: (done, reset) => ComputerToData(
            onCompleted: done,
          ),
        ),

        // Step 2 → Data Types
        SubLesson(
          topOffset: 150,
          mechanic: LessonMechanic.manual,
          build: (_, __) => const DataTypes(),
        ),

        // Steps 3+ → Dynamic quiz pages
        for (int i = 0; i < DataTypeQuiz.quizCount; i++)
          SubLesson(
            topOffset: 160,
            mechanic: LessonMechanic.emit,
            build: (done, reset) => DataTypeQuiz(
              key: ValueKey('quiz-$i'),
              quizIndex: i,
              onQuizCompleted: (_) => done(),
            ),
          ),
      ];
}
