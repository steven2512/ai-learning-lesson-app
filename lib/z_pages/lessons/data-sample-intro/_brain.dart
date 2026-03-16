// FILE: lib/z_pages/lessons/data-sample-intro/_brain.dart
import 'package:flutter/material.dart';
import 'package:running_robot/core/app_router.dart';
import 'package:running_robot/core/base_lesson_brain.dart';
import 'package:running_robot/core/widgets.dart';

// Steps
import 'package:running_robot/z_pages/lessons/data-sample-intro/data_sample_quote.dart';
import 'package:running_robot/z_pages/lessons/data-sample-intro/data_sample_dialouge.dart';
import 'package:running_robot/z_pages/lessons/data-sample-intro/data_sample_def.dart';
import 'package:running_robot/z_pages/lessons/data-sample-intro/data_sample_char.dart';
import 'package:running_robot/z_pages/lessons/data-sample-intro/data_sample_mcq.dart';
import 'package:running_robot/z_pages/lessons/data-sample-intro/data_sample_set_game.dart';
import 'package:running_robot/z_pages/lessons/data-sample-intro/data_set_def.dart';

final double screenW = ScreenSize.width;
final double screenH = ScreenSize.height;

class DataSampleIntroBrain extends BaseLessonBrain {
  const DataSampleIntroBrain({super.key, required AppNavigate onNavigate})
      : super(onNavigate: onNavigate);

  @override
  String get lessonId => "data-sample-intro";

  @override
  State<DataSampleIntroBrain> createState() => _DataSampleIntroBrainState();
}

class _DataSampleIntroBrainState
    extends BaseLessonBrainState<DataSampleIntroBrain> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      final ctx = context;
      precacheImage(
          const AssetImage("assets/images/mascot_pointing_up.png"), ctx);
      precacheImage(const AssetImage("assets/images/placeholder.png"), ctx);
    });
  }

  @override
  List<SubLesson> buildSubLessons() => [
        // Slide 1 — Quote (manual)
        SubLesson(
          topOffset: screenH * 0.33, // centered feel
          mechanic: LessonMechanic.manual,
          build: (_, __) => const DataSampleQuote(),
        ),

        // Slide 2 — Dialogue (auto) — EXACT sizing like your example
        SubLesson(
          topOffset: screenH * 0.20,
          mechanic: LessonMechanic.auto,
          build: (done, __) => OneAtATimeDialogue(
            onFinished: done, // legacy: unlock Continue
            onRequestNext: () => goNext(), // skip continue → next
          ),
        ),

        // Slide 3 — Definition (manual)
        SubLesson(
          topOffset: screenH * 0.22,
          mechanic: LessonMechanic.manual,
          build: (_, __) => const DataSampleDefinition(),
        ),

        // Slide 4 — Characteristic (manual)
        SubLesson(
          topOffset: screenH * 0.22,
          mechanic: LessonMechanic.manual,
          build: (_, __) => const DataSampleCharacteristic(),
        ),

        // Slide 5 — MCQ (emit)
        SubLesson(
          topOffset: screenH * 0.18,
          mechanic: LessonMechanic.emit,
          build: (done, __) => DataSampleMCQ(onStepCompleted: done),
        ),

        // Slide 6 — Dataset Definition (manual)
        SubLesson(
          topOffset: screenH * 0.22,
          mechanic: LessonMechanic.manual,
          build: (_, __) => const DataSetDefinition(),
        ),

        SubLesson(
          topOffset: screenH * 0.15,
          mechanic: LessonMechanic.emit,
          build: (done, _remountingReset /* not used */) => DataSampleSetGame(
            onStepCompleted: done,
            onReset: () {
              if (mounted) {
                setState(() {
                  answered = false; // hides Continue after Try Again / Reset
                });
              }
            },
          ),
        ),
      ];
}
