// FILE: lib/z_pages/lessons/lesson2/lesson2.dart
// NOTE: No behavioral changes to the flow. Step 6 now also exposes
// onRestartRequested so we can hide Continue whenever the user taps Try Again.

import 'package:flame/components.dart' show Vector2;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:running_robot/core/app_router.dart';
import 'package:running_robot/z_pages/assets/lessonAssets/continueButton.dart';
import 'package:running_robot/z_pages/assets/lessonAssets/icon_button.dart';
import 'package:running_robot/z_pages/assets/lessonAssets/progress_bar.dart'
    as flutter_ui_bar;
import 'package:running_robot/game/decorations/progress_bar.dart'
    show LessonProgressBar;
import 'package:running_robot/game/events/event_type.dart'
    show EventProgressBar;
import 'package:running_robot/z_pages/lessons/binary/comp_0101.dart';
import 'package:running_robot/z_pages/lessons/binary/binary_intro.dart';
import 'package:running_robot/z_pages/lessons/binary/bin_example.dart';
import 'package:running_robot/z_pages/lessons/binary/unicode.dart';
import 'package:running_robot/z_pages/lessons/binary/binary_game.dart';

import 'photo.dart'; // StepZero
import 'music.dart'; // StepOne (quiz step)
import 'comp_0101.dart' show LessonStepTwo;

class LessonTwo extends StatefulWidget {
  final AppNavigate onNavigate;
  const LessonTwo({super.key, required this.onNavigate});

  @override
  State<LessonTwo> createState() => _LessonTwoState();
}

class _LessonTwoState extends State<LessonTwo> {
  int currentStep = 0;
  final ValueNotifier<bool> _stepAnswered = ValueNotifier(false);

  final Map<int, double> topOffsets = const {
    0: 180,
    1: 190,
    2: 180,
    3: 250,
    4: 250,
    5: 250,
    6: 120,
  };

  int get totalStages => 7;

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
      const int chapterProgress = 2;
      const int totalChapterLessons = 10;

      widget.onNavigate(
        RouteEndLesson(
          xp: xp,
          streak: streak,
          progressBar: endBar,
          chapterProgress: chapterProgress,
          totalChapterLessons: totalChapterLessons,
          topText: "Lesson 2 complete! 🎉",
          repeatLesson: const RouteLesson(2),
          nextLesson: const RouteLesson(3),
          illustrationPath: null,
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

                  final showContinue = (currentStep == 0 ||
                          currentStep == 1 ||
                          currentStep == 4 ||
                          currentStep == 5)
                      ? true
                      : ((currentStep == 2 || currentStep == 6)
                          ? answered
                          : false);

                  return AnimatedSwitcher(
                    duration: const Duration(milliseconds: 220),
                    reverseDuration: const Duration(milliseconds: 120),
                    switchInCurve: Curves.easeOut,
                    switchOutCurve: Curves.easeIn,
                    transitionBuilder: (child, animation) =>
                        FadeTransition(opacity: animation, child: child),
                    child: showContinue
                        ? ContinueButton(
                            key: const ValueKey('continue-btn'),
                            onPressed: _goNextStep,
                          )
                        : const SizedBox(
                            key: ValueKey('continue-hidden'),
                          ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentStep() {
    if (currentStep == 0) return const LessonStepZero();
    if (currentStep == 1) return const LessonStepOne();
    if (currentStep == 2) {
      return LessonStepTwo(
        onStarted: () {
          _stepAnswered.value = true;
        },
      );
    }
    if (currentStep == 3) {
      return LessonStepThree(
        onFinished: () => _stepAnswered.value = true,
        onRequestNext: _goNextStep, // ✅ direct skip with Finish
      );
    }
    if (currentStep == 4) return LessonStepFour();
    if (currentStep == 5) return LessonStepFive();
    if (currentStep == 6) {
      return LessonStepSix(
        onCompleted: () {
          _stepAnswered.value = true; // show Continue only after overlay reveal
        },
        onRestartRequested: () {
          _stepAnswered.value = false; // hide Continue on Try Again
        },
      );
    }
    return const SizedBox.shrink();
  }
}
