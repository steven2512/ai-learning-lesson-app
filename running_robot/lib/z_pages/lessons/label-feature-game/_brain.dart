import 'package:flutter/material.dart';
import 'package:running_robot/core/app_router.dart';
import 'package:running_robot/core/base_lesson_brain.dart';
import 'package:running_robot/core/widgets.dart';

import 'label_feature_game.dart';

double screenH = ScreenSize.height;

class LabelFeatureGameBrain extends BaseLessonBrain {
  const LabelFeatureGameBrain({super.key, required AppNavigate onNavigate})
      : super(onNavigate: onNavigate);

  @override
  String get lessonId => "label-feature-game";

  @override
  State<LabelFeatureGameBrain> createState() => _LabelFeatureGameBrainState();
}

class _LabelFeatureGameBrainState
    extends BaseLessonBrainState<LabelFeatureGameBrain> {
  @override
  List<SubLesson> buildSubLessons() => [
        for (int i = 0; i < 3; i++)
          SubLesson(
            topOffset: screenH * 0.15, // 👈 per your spec
            mechanic: LessonMechanic.emit,
            build: (done, _remountingReset) => LabelFeatureGame(
              slideIndex: i,
              onCompleted: done,
              onReset: () {
                if (mounted) {
                  setState(() {
                    answered = false; // hide Continue
                  });
                }
              },
            ),
          ),
      ];
}
