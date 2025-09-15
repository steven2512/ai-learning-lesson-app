// ✅ LessonThree with conditional continue button for StepFive & StepSeven

import 'package:flame/components.dart' show Vector2;
import 'package:flutter/material.dart';
import 'package:running_robot/core/app_router.dart';
import 'package:running_robot/z_pages/assets/lessonAssets/continueButton.dart';
import 'package:running_robot/z_pages/assets/lessonAssets/icon_button.dart';
import 'package:running_robot/z_pages/assets/lessonAssets/progress_bar.dart'
    as flutter_ui_bar;
import 'package:running_robot/game/decorations/progress_bar.dart'
    show LessonProgressBar;
import 'package:running_robot/game/events/event_type.dart'
    show EventProgressBar;
import 'package:running_robot/z_pages/lessons/qual-quan/s01_recap_1.dart';
import 'package:running_robot/z_pages/lessons/qual-quan/s10_not_qual.dart';
import 'package:running_robot/z_pages/lessons/qual-quan/s02_recap_2.dart';
import 'package:running_robot/z_pages/lessons/qual-quan/s03_meaning.dart';
import 'package:running_robot/z_pages/lessons/qual-quan/s04_num_cate.dart';
import 'package:running_robot/z_pages/lessons/qual-quan/s05_quan_intro.dart';
import 'package:running_robot/z_pages/lessons/qual-quan/s06_quan_eg.dart';
import 'package:running_robot/z_pages/lessons/qual-quan/s07_not_quan.dart';
import 'package:running_robot/z_pages/lessons/qual-quan/s08_qual_intro.dart';
import 'package:running_robot/z_pages/lessons/qual-quan/s09_qual_eg.dart';

class LessonThree extends StatefulWidget {
  final AppNavigate onNavigate;
  const LessonThree({super.key, required this.onNavigate});

  @override
  State<LessonThree> createState() => _LessonThreeState();
}

class _LessonThreeState extends State<LessonThree> {
  int currentStep = 0;

  final Map<int, double> topOffsets = const {
    0: 160,
    1: 270,
    2: 180,
    3: 200,
    4: 180,
    5: 220,
    6: 120,
    7: 150,
    8: 200,
    9: 120,
  };

  int get totalStages => 10;
  bool _lessonCompleted = false;
  bool _stepSixAnswered = false;
  bool _stepNineAnswered = false;

  late IconButtonWidget<void> returnButton;

  @override
  void initState() {
    super.initState();
    returnButton = IconButtonWidget<void>(
      iconPath: 'assets/images/x_icon.png',
      tint: Colors.black87,
      size: 22,
      onPressed: (_) => widget.onNavigate(const RouteMainMenu(tab: 0)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double topOffset = topOffsets[currentStep] ?? 120;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // ✅ Progress bar
          Positioned(
            top: 70,
            left: MediaQuery.of(context).size.width / 2 - (279 / 2),
            child: flutter_ui_bar.LessonProgressBar(
              totalStages: totalStages,
              currentStage: _lessonCompleted ? totalStages : currentStep,
            ),
          ),

          // ✅ Close button
          Positioned(top: 69, left: 30, child: returnButton),

          // ✅ Active step
          Positioned.fill(
            top: topOffset,
            bottom: 100,
            child: _buildCurrentStep(),
          ),

          // ✅ Continue button
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Center(
              child: _lessonCompleted
                  ? const SizedBox.shrink()
                  : _buildContinueButton(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContinueButton() {
    // Step 5 → only show after correct answer
    if (currentStep == 6 && !_stepSixAnswered) {
      return const SizedBox.shrink();
    }

    // Step 7 → only show after correct answer
    if (currentStep == 9 && !_stepNineAnswered) {
      return const SizedBox.shrink();
    }

    return ContinueButton(
      onPressed: () {
        if (currentStep < totalStages - 1) {
          setState(() {
            currentStep++;
          });
        } else {
          setState(() => _lessonCompleted = true);

          final endBar = LessonProgressBar(
            position: Vector2.zero(),
            stages: totalStages,
          );
          for (int i = 0; i < totalStages; i++) {
            endBar.switchPhase(EventProgressBar.proceed);
          }

          widget.onNavigate(
            RouteEndLesson(
              xp: 50,
              streak: 1,
              progressBar: endBar,
              chapterProgress: 3,
              totalChapterLessons: 10,
              topText: "Lesson 3 complete! 🎉",
              repeatLesson: const RouteLesson(3),
              nextLesson: const RouteLesson(4), // placeholder
              illustrationPath: null,
            ),
          );
        }
      },
    );
  }

  Widget _buildCurrentStep() {
    switch (currentStep) {
      case 0:
        return const LessonStepZero();
      case 1:
        return const LessonStepOne();
      case 2:
        return const LessonStepTwo();
      case 3:
        return const LessonStepThree();
      case 4:
        return const LessonStepFour();
      case 5:
        return const LessonStepFive();
      case 6:
        return LessonStepSix(
          onStepCompleted: () => setState(() => _stepSixAnswered = true),
        );
      case 7:
        return const LessonStepSeven();
      case 8:
        return const LessonStepEight();
      case 9:
        return LessonStepNine(
          onStepCompleted: () => setState(() => _stepNineAnswered = true),
        );
    }
    return const SizedBox.shrink();
  }
}
