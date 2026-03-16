// FILE: lib/z_pages/lessons/lesson4/lesson4.dart
import 'package:flutter/material.dart';
import 'package:running_robot/core/app_router.dart';
import 'package:running_robot/core/base_lesson_brain.dart';
import 'package:running_robot/core/widgets.dart';

// ⬇️ Your game widget
import 'package:running_robot/z_pages/lessons/qual-game/catch_qual_game.dart';

double screenH = ScreenSize.height;

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
          topOffset: screenH * 0.05,
          mechanic: LessonMechanic.emit,
          build: (done, _remountingReset /* not used here */) => CatchQualGame(
            onStepCompleted: done,
            // 👇 Use a NON-remounting reset so Start Game won't dispose itself mid-callback.
            onReset: () {
              // just hide the Continue button; do NOT bump _restartNonce
              if (mounted) {
                setState(() {
                  answered = false;
                });
              }
            },
          ),
        ),
      ];
}
