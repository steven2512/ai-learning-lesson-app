// FILE: lib/z_pages/lessons/lesson3/lesson3.dart
import 'package:flutter/material.dart';
import 'package:running_robot/core/app_router.dart';
import 'package:running_robot/core/base_lesson_brain.dart';

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

class QualQuanBrain extends BaseLessonBrain {
  const QualQuanBrain({super.key, required AppNavigate onNavigate})
      : super(onNavigate: onNavigate);

  @override
  String get lessonId => "qual-quan";

  @override
  State<QualQuanBrain> createState() => _QualQuanBrainState();
}

class _QualQuanBrainState extends BaseLessonBrainState<QualQuanBrain> {
  @override
  List<SubLesson> buildSubLessons() => [
        SubLesson(
          topOffset: 160,
          mechanic: LessonMechanic.manual,
          build: (_, __) => const RecapData(),
        ),
        SubLesson(
          topOffset: 270,
          mechanic: LessonMechanic.manual,
          build: (_, __) => const RecapBinary(),
        ),
        SubLesson(
          topOffset: 180,
          mechanic: LessonMechanic.manual,
          build: (_, __) => const HumanLookForMeaning(),
        ),
        SubLesson(
          topOffset: 230,
          mechanic: LessonMechanic.emit,
          build: (done, _) => NumberAndCategoryIntro(onCompleted: done),
        ),
        SubLesson(
          topOffset: 180,
          mechanic: LessonMechanic.manual,
          build: (_, __) => const QuanIntro(),
        ),
        SubLesson(
          topOffset: 220,
          mechanic: LessonMechanic.manual,
          build: (_, __) => const QuanExample(),
        ),
        // Step 6 → QuanQuiz, emit only when completed
        SubLesson(
          topOffset: 120,
          mechanic: LessonMechanic.emit,
          build: (done, reset) => QuanQuiz(
            onStepCompleted: () => done(),
          ),
        ),
        SubLesson(
          topOffset: 150,
          mechanic: LessonMechanic.manual,
          build: (_, __) => const QualIntro(),
        ),
        SubLesson(
          topOffset: 200,
          mechanic: LessonMechanic.manual,
          build: (_, __) => const QualExample(),
        ),
        // Step 9 → QualQuiz, emit only when completed
        SubLesson(
          topOffset: 120,
          mechanic: LessonMechanic.emit,
          build: (done, reset) => QualQuiz(
            onStepCompleted: () => done(),
          ),
        ),
      ];
}
