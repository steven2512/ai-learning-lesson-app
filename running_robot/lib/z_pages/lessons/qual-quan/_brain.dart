// FILE: lib/z_pages/lessons/lesson3/lesson3.dart
import 'package:flutter/material.dart';
import 'package:running_robot/core/app_router.dart';
import 'package:running_robot/core/base_lesson_brain.dart';
import 'package:running_robot/core/widgets.dart';

// lesson steps
import 'package:running_robot/z_pages/lessons/qual-quan/recap_data.dart';
import 'package:running_robot/z_pages/lessons/qual-quan/qual_quiz.dart';
import 'package:running_robot/z_pages/lessons/qual-quan/recap_binary.dart';
import 'package:running_robot/z_pages/lessons/qual-quan/we_meaning.dart';
import 'package:running_robot/z_pages/lessons/qual-quan/num_cate.dart';
import 'package:running_robot/z_pages/lessons/qual-quan/quan_intro.dart';
import 'package:running_robot/z_pages/lessons/qual-quan/quan_eg.dart';
import 'package:running_robot/z_pages/lessons/qual-quan/quan_quiz.dart';
import 'package:running_robot/z_pages/lessons/qual-quan/qual_intro.dart';
import 'package:running_robot/z_pages/lessons/qual-quan/qual_eg.dart';

final screenH = ScreenSize.height;
final screenW = ScreenSize.width;

class QualQuanBrain extends BaseLessonBrain {
  const QualQuanBrain({super.key, required AppNavigate onNavigate})
      : super(onNavigate: onNavigate);

  @override
  String get lessonId => "qual-quan";

  @override
  State<QualQuanBrain> createState() => _QualQuanBrainState();
}

class _QualQuanBrainState extends BaseLessonBrainState<QualQuanBrain> {
  // 🔹 NEW: Precache lesson-specific images when lesson starts
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      final ctx = context;
      precacheImage(const AssetImage("assets/images/data_chart.png"), ctx);
      precacheImage(const AssetImage("assets/images/quantitative.png"), ctx);
      precacheImage(const AssetImage("assets/images/qualitative.png"), ctx);
      precacheImage(
          const AssetImage("assets/images/quantitative_not.png"), ctx);
      precacheImage(const AssetImage("assets/images/happy_life.jpg"), ctx);
    });
  }
  // 🔹 END NEW

  @override
  List<SubLesson> buildSubLessons() => [
        SubLesson(
          topOffset: screenH * 0.19,
          mechanic: LessonMechanic.manual,
          build: (_, __) => const RecapData(),
        ),
        SubLesson(
          topOffset: screenH * 0.3,
          mechanic: LessonMechanic.manual,
          build: (_, __) => const RecapBinary(),
        ),
        SubLesson(
          topOffset: screenH * 0.2,
          mechanic: LessonMechanic.manual,
          build: (_, __) => const HumanLookForMeaning(),
        ),
        SubLesson(
          topOffset: screenH * 0.22,
          mechanic: LessonMechanic.emit,
          build: (done, _) => NumberAndCategoryIntro(onCompleted: done),
        ),
        SubLesson(
          topOffset: screenH * 0.21,
          mechanic: LessonMechanic.manual,
          build: (_, __) => const QuanIntro(),
        ),
        SubLesson(
          topOffset: screenH * 0.23,
          mechanic: LessonMechanic.manual,
          build: (_, __) => const QuanExample(),
        ),
        // Step 6 → QuanQuiz, emit only when completed
        SubLesson(
          topOffset: screenH * 0.15,
          mechanic: LessonMechanic.emit,
          build: (done, reset) => QuanQuiz(
            onStepCompleted: () => done(),
          ),
        ),
        SubLesson(
          topOffset: screenH * 0.21,
          mechanic: LessonMechanic.manual,
          build: (_, __) => const QualIntro(),
        ),
        SubLesson(
          topOffset: screenH * 0.23,
          mechanic: LessonMechanic.manual,
          build: (_, __) => const QualExample(),
        ),
        // Step 9 → QualQuiz, emit only when completed
        SubLesson(
          topOffset: screenH * 0.15,
          mechanic: LessonMechanic.emit,
          build: (done, reset) => QualQuiz(
            onStepCompleted: () => done(),
          ),
        ),
      ];
}
