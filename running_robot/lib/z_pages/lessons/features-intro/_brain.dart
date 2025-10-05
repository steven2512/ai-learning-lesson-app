// FILE: lib/z_pages/lessons/binary-intro/_brain.dart
import 'package:flutter/material.dart';
import 'package:running_robot/core/app_router.dart';
import 'package:running_robot/core/base_lesson_brain.dart';
import 'package:running_robot/core/widgets.dart';
import 'package:running_robot/z_pages/lessons/features-intro/bad_features.dart';
import 'package:running_robot/z_pages/lessons/features-intro/data_useful_ai.dart';
import 'package:running_robot/z_pages/lessons/features-intro/features_intro.dart';
import 'package:running_robot/z_pages/lessons/features-intro/features_measurable.dart';
import 'package:running_robot/z_pages/lessons/features-intro/good_features.dart';
import 'package:running_robot/z_pages/lessons/features-intro/movies_mcq.dart';

final screenH = ScreenSize.height;
final screenW = ScreenSize.width;

class FeaturesIntroBrain extends BaseLessonBrain {
  const FeaturesIntroBrain({super.key, required AppNavigate onNavigate})
      : super(onNavigate: onNavigate);

  @override
  String get lessonId => "features-intro";

  @override
  State<FeaturesIntroBrain> createState() => _FeatureIntroBrainState();
}

class _FeatureIntroBrainState extends BaseLessonBrainState<FeaturesIntroBrain> {
  // 🔹 NEW: Precache lesson-specific images when lesson starts
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      // final ctx = context;
      // precacheImage(const AssetImage("assets/images/monitor.png"), ctx);
      // precacheImage(const AssetImage("assets/images/cameraman.png"), ctx);
      // precacheImage(const AssetImage("assets/images/dialogue_box.png"), ctx);
      // precacheImage(const AssetImage("assets/images/music_listening.png"), ctx);
      // // 👆 covers all Image.asset calls used inside HumanSeePhoto, HumanHearMusic,
      // // ComputerSeeZeroOne, and dialogue overlays.
    });
  }
  // 🔹 END NEW

  @override
  List<SubLesson> buildSubLessons() => [
        SubLesson(
          topOffset: screenH * 0.20,
          mechanic: LessonMechanic.auto,
          build: (done, __) => DataUsefulAI(onFinished: done),
        ),
        SubLesson(
          topOffset: screenH * 0.22,
          mechanic: LessonMechanic.manual,
          build: (_, __) => const FeatureDefinition(),
        ),
        SubLesson(
          topOffset: screenH * 0.25,
          mechanic: LessonMechanic.manual,
          build: (_, __) => const FeatureMeasurable(),
        ),
        SubLesson(
          topOffset: screenH * 0.25,
          mechanic: LessonMechanic.manual,
          build: (_, __) => const GoodFeaturesExample(),
        ),
        SubLesson(
          topOffset: screenH * 0.25,
          mechanic: LessonMechanic.manual,
          build: (_, __) => const BadFeaturesExample(),
        ),
        // ),
        SubLesson(
            topOffset: screenH * 0.15,
            mechanic: LessonMechanic.emit,
            build: (done, reset) => MovieFeaturesQuiz(
                  onStepCompleted: () => done(),
                )),
        // ),
        // SubLesson(
        //   topOffset: screenH * 0.1,
        //   mechanic: LessonMechanic.emit,
        //   build: (done, reset) => BinaryDragDropGame(
        //     onCompleted: done,
        //     onRestartRequested: reset, // ✅ uses the parent resetAnswer
        //   ),
        // ),
      ];
}
