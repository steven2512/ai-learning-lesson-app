// FILE: lib/z_pages/lessons/lesson1/lesson1.dart
// ✅ Minimal changes: StepZero can now either unlock Continue (legacy)
// ✅ Or call onRequestNext to skip Continue and auto-proceed.

import 'package:flame/components.dart' show Vector2;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:running_robot/core/app_router.dart';
import 'package:running_robot/game/events/event_type.dart';
import 'package:running_robot/z_pages/assets/lessonAssets/continueButton.dart';
import 'package:running_robot/z_pages/assets/lessonAssets/icon_button.dart';
import 'package:running_robot/z_pages/assets/lessonAssets/progress_bar.dart'
    as flutter_ui_bar;

import 'package:running_robot/z_pages/lessons/lesson1/lesson1_1.dart'; // StepZero + StepOne
import 'package:running_robot/z_pages/lessons/lesson1/lesson1_2.dart';
import 'package:running_robot/z_pages/lessons/lesson1/lesson1_3.dart';
import 'package:running_robot/z_pages/lessons/lesson1/lesson1_4.dart';

import 'package:running_robot/game/decorations/progress_bar.dart'
    show LessonProgressBar;

class LessonOne extends StatefulWidget {
  final AppNavigate onNavigate;
  const LessonOne({super.key, required this.onNavigate});

  @override
  State<LessonOne> createState() => _LessonOneState();
}

class _LessonOneState extends State<LessonOne> {
  int currentStep = 0;
  final ValueNotifier<bool> _stepAnswered = ValueNotifier(false);

  final Map<int, double> topOffsets = const {
    0: 280, // StepZero
    1: 220, // StepOne
    2: 150, // StepTwo
    3: 160,
    4: 160,
    5: 160,
    6: 160,
    7: 160
  };

  // CHANGED: we now have 3 pre-quiz steps (0,1,2)
  int get totalStages => 3 + LessonStepThree.quizCount; // was 2 + ...

  bool _lessonCompleted = false;
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

  void _goNextStep() {
    if (currentStep < totalStages - 1) {
      setState(() {
        currentStep++;
        _stepAnswered.value = false;
      });
    } else {
      setState(() {
        _lessonCompleted = true;
        _stepAnswered.value = false;
      });

      final endBar = LessonProgressBar(
        position: Vector2.zero(),
        stages: totalStages,
      );
      for (int i = 0; i < totalStages; i++) {
        endBar.switchPhase(EventProgressBar.proceed);
      }

      const int xp = 50;
      const int streak = 1;
      const int chapterProgress = 1;
      const int totalChapterLessons = 10;

      widget.onNavigate(
        RouteEndLesson(
          xp: xp,
          streak: streak,
          progressBar: endBar,
          chapterProgress: chapterProgress,
          totalChapterLessons: totalChapterLessons,
          topText: "Lesson 1 complete! 🎉",
          illustrationPath: null,
          repeatLesson: const RouteLesson(1),
          nextLesson: const RouteLesson(2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final double topOffset = topOffsets[currentStep] ?? 120;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Positioned(
            top: 70,
            left: MediaQuery.of(context).size.width / 2 - (279 / 2),
            child: flutter_ui_bar.LessonProgressBar(
              totalStages: totalStages,
              currentStage: _lessonCompleted ? totalStages : currentStep,
            ),
          ),
          Positioned(top: 69, left: 30, child: returnButton),
          Positioned.fill(
            top: topOffset,
            bottom: 100,
            child: _buildCurrentStep(),
          ),
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Center(
              child: ValueListenableBuilder<bool>(
                valueListenable: _stepAnswered,
                builder: (context, answered, _) {
                  if (_lessonCompleted) return const SizedBox.shrink();

                  // also unlock Continue on step 2 (LessonStepTwo)
                  final showContinue = (currentStep == 0)
                      ? answered
                      : ((currentStep == 1 || currentStep == 2)
                          ? true
                          : answered);

                  if (!showContinue) return const SizedBox.shrink();

                  return ContinueButton(onPressed: _goNextStep);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentStep() {
    if (currentStep == 0) {
      return LessonStepZero(
        onFinished: () {
          _stepAnswered.value = true; // legacy unlock Continue
        },
        onRequestNext: _goNextStep, // ✅ new direct next API
      );
    }
    if (currentStep == 1) return const LessonStepOne();
    if (currentStep == 2) return const LessonStepTwo();

    // CHANGED: first quiz is now at currentStep == 3
    final quizIndex = currentStep - 3; // was currentStep - 2
    return LessonStepThree(
      key: ValueKey('quiz-$quizIndex'),
      quizIndex: quizIndex,
      onQuizCompleted: (index) {
        _stepAnswered.value = true;
      },
    );
  }
}
