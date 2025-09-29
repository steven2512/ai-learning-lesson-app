// FILE: lib/z_pages/lessons/data-ai-relevance/_brain.dart
import 'package:flutter/material.dart';
import 'package:running_robot/core/app_router.dart';
import 'package:running_robot/core/base_lesson_brain.dart';

// lesson steps
import 'package:running_robot/z_pages/lessons/data-ai-relevance/ai-predict-quiz.dart';
import 'package:running_robot/z_pages/lessons/data-ai-relevance/ai-predict.dart';
import 'package:running_robot/z_pages/lessons/data-ai-relevance/ask_yourself_homework.dart';
import 'package:running_robot/z_pages/lessons/data-ai-relevance/data-example.dart';
import 'package:running_robot/z_pages/lessons/data-ai-relevance/data_ai_intro.dart';
import 'package:running_robot/z_pages/lessons/data-ai-relevance/sort-group-quiz.dart';
import 'package:running_robot/z_pages/lessons/data-ai-relevance/sort-group.dart';
import 'package:running_robot/z_pages/lessons/data-ai-relevance/student_homework.dart';
import 'package:running_robot/z_pages/lessons/data-ai-relevance/wrap-up.dart';

class DataAiRelevance extends BaseLessonBrain {
  const DataAiRelevance({super.key, required AppNavigate onNavigate})
      : super(onNavigate: onNavigate);

  @override
  String get lessonId => "data-ai-relevance";

  @override
  State<DataAiRelevance> createState() => _DataAIRelevanceState();
}

class _DataAIRelevanceState extends BaseLessonBrainState<DataAiRelevance> {
  @override
  void initState() {
    super.initState();
    // ✅ NEW: Precache lesson assets once at Brain level
    Future.microtask(() {
      final ctx = context;
      precacheImage(
          const AssetImage("assets/images/data-ai-student-homework.png"), ctx);
      precacheImage(const AssetImage("assets/images/ask_yourself.png"), ctx);
      precacheImage(const AssetImage("assets/images/15913.png"), ctx);
      precacheImage(const AssetImage("assets/images/house1.png"), ctx);
      precacheImage(const AssetImage("assets/images/house2.png"), ctx);
      precacheImage(const AssetImage("assets/images/house3.png"), ctx);
      precacheImage(const AssetImage("assets/images/house4.png"), ctx);
      precacheImage(
          const AssetImage("assets/images/mascot_pointing_up.png"), ctx);
    });
  }

  @override
  List<SubLesson> buildSubLessons() => [
        // Dialogue: “Why do we care about data?”
        SubLesson(
          topOffset: 200,
          mechanic: LessonMechanic.auto,
          build: (done, __) => DataAiIntro(onFinished: done),
        ),

        // Analogy: Student & Homework
        SubLesson(
          topOffset: 230,
          mechanic: LessonMechanic.manual,
          build: (_, __) => const StudentHomework(),
        ),
        SubLesson(
          topOffset: 230,
          mechanic: LessonMechanic.manual,
          build: (_, __) => const AskYourselfHomework(),
        ),

        // Data as examples
        SubLesson(
          topOffset: 200,
          mechanic: LessonMechanic.auto,
          build: (done, __) => DataExample(onFinished: done),
        ),

        // Prediction explained
        SubLesson(
          topOffset: 200,
          mechanic: LessonMechanic.emit,
          build: (done, __) => AIPredict(onCompleted: done),
        ),

        // Prediction exercise (MCQ sequence)
        SubLesson(
          topOffset: 160,
          mechanic: LessonMechanic.emit,
          build: (done, reset) => PredictionExercise(onCompleted: done),
        ),

        // Classification explained
        SubLesson(
          topOffset: 200,
          mechanic: LessonMechanic.emit,
          build: (done, __) => SortGroup(onCompleted: done),
        ),

        // Classification drag-and-drop game
        SubLesson(
          topOffset: 120,
          mechanic: LessonMechanic.emit,
          build: (done, reset) => SortGroupQuiz(
            onCompleted: done,
            onRestartRequested: reset,
          ),
        ),

        // Wrap-up dialogue
        SubLesson(
          topOffset: 200,
          mechanic: LessonMechanic.auto,
          build: (done, __) => WrapUpDialogue(onFinished: done),
        )
      ];
}
