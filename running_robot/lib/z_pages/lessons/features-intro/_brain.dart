// FILE: lib/z_pages/lessons/binary-intro/_brain.dart
import 'package:flutter/material.dart';
import 'package:running_robot/core/app_router.dart';
import 'package:running_robot/core/base_lesson_brain.dart';
import 'package:running_robot/core/widgets.dart';
import 'package:running_robot/z_pages/lessons/features-intro/data_useful_ai.dart';
import 'package:running_robot/z_pages/lessons/features-intro/features_intro.dart';
import 'package:running_robot/z_pages/lessons/features-intro/features_measurable.dart';
import 'package:running_robot/z_pages/lessons/features-intro/features_yet_mcq.dart';
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
  // 🔹 NEW: Precache all lesson-specific images when lesson starts
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      final ctx = context;

      // 🧠 DataUsefulAI
      precacheImage(
          const AssetImage("assets/images/mascot_pointing_up.png"), ctx);

      // 🏎️ FeatureDefinition
      precacheImage(const AssetImage("assets/images/car_model.png"), ctx);

      // 📏 FeatureMeasurable — (no image)

      // 🏠 Good & Bad Features
      precacheImage(const AssetImage("assets/images/house_factors.png"), ctx);
      precacheImage(const AssetImage("assets/images/bad_example.png"), ctx);

      // 🎬 MovieFeaturesQuiz
      precacheImage(const AssetImage("assets/images/movie_rating.png"), ctx);
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
          mechanic: LessonMechanic.emit,
          build: (done, reset) =>
              GoodFeaturesExample(onStepCompleted: () => done()),
        ),
        // SubLesson(
        //   topOffset: screenH * 0.34,
        //   mechanic: LessonMechanic.manual,
        //   build: (_, __) => const BadFeaturesExample(),
        // ),
        SubLesson(
            topOffset: screenH * 0.12,
            mechanic: LessonMechanic.emit,
            build: (done, reset) => MovieFeaturesQuiz(
                  onStepCompleted: () => done(),
                )),
        SubLesson(
            topOffset: screenH * 0.12,
            mechanic: LessonMechanic.emit,
            build: (done, reset) => FeatureYetMCQ(
                  onStepCompleted: () => done(),
                )),
      ];
}
