// FILE: lib/z_pages/lessons/lesson4/lesson4.dart
import 'package:flutter/material.dart';
import 'package:running_robot/core/app_router.dart';
import 'package:running_robot/core/base_lesson_brain.dart';

// ⬇️ Your game widget
import 'package:running_robot/z_pages/lessons/qual-game/catch_qual_game.dart';

class QualGameBrain extends BaseLessonBrain {
  const QualGameBrain({super.key, required AppNavigate onNavigate})
      : super(onNavigate: onNavigate);

  @override
  String get lessonId => "qual-game";

  @override
  State<QualGameBrain> createState() => _QualGameBrainState();
}

class _QualGameBrainState extends BaseLessonBrainState<QualGameBrain> {
  @override
  List<SubLesson> buildSubLessons() => [
        SubLesson(
          topOffset: 50,
          mechanic: LessonMechanic.emit,
          build: (done, reset) => CatchQualGame(
            onStepCompleted: done,
            onReset: reset, // 👈 now connected
          ),
        ),
      ];
}
