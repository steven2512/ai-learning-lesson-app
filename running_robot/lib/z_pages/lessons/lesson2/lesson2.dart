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
import 'package:running_robot/z_pages/lessons/lesson2/lesson2_3.dart';
import 'package:running_robot/z_pages/lessons/lesson2/lesson2_4.dart';
import 'package:running_robot/z_pages/lessons/lesson2/lesson2_5.dart';
import 'package:running_robot/z_pages/lessons/lesson2/lesson2_6.dart';

import 'lesson2_1.dart'; // StepZero
import 'lesson2_2.dart'; // StepOne (quiz step)
import 'lesson2_3.dart'
    show LessonStepTwo; // ensure we import the updated StepTwo

class LessonTwo extends StatefulWidget {
  final AppNavigate onNavigate;
  const LessonTwo({super.key, required this.onNavigate});

  @override
  State<LessonTwo> createState() => _LessonTwoState();
}

class _LessonTwoState extends State<LessonTwo> {
  int currentStep = 0;
  final ValueNotifier<bool> _stepAnswered = ValueNotifier(false);

  /// Per-step vertical offsets
  final Map<int, double> topOffsets = const {
    0: 160, // StepZero
    1: 170, // StepOne
    2: 180, // StepTwo
    3: 250, // StepThree
    4: 250, // StepFour
  };

  int get totalStages => 6;

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

  @override
  Widget build(BuildContext context) {
    final double topOffset = topOffsets[currentStep] ?? 120;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Progress bar
          Positioned(
            top: 70,
            left: MediaQuery.of(context).size.width / 2 - (279 / 2),
            child: flutter_ui_bar.LessonProgressBar(
              totalStages: totalStages,
              currentStage: _lessonCompleted ? totalStages : currentStep,
            ),
          ),

          // Close button
          Positioned(top: 69, left: 30, child: returnButton),

          // Active step with offset
          Positioned.fill(
            top: topOffset,
            bottom: 100,
            child: _buildCurrentStep(),
          ),

          // Continue button (now with a soft fade via AnimatedSwitcher)
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Center(
              child: ValueListenableBuilder<bool>(
                valueListenable: _stepAnswered,
                builder: (context, answered, _) {
                  if (_lessonCompleted) return const SizedBox.shrink();

                  // Step 0,1,3,4 → always visible
                  // Step 2 and 5 → only visible when answered = true
                  final showContinue = (currentStep == 0 ||
                          currentStep == 1 ||
                          currentStep == 3 ||
                          currentStep == 4)
                      ? true
                      : ((currentStep == 2 || currentStep == 5)
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
                            onPressed: () {
                              if (currentStep < totalStages - 1) {
                                setState(() {
                                  currentStep++;
                                  _stepAnswered.value = false;
                                });
                              } else {
                                // Final step
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

                                // Stub values
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
                                    nextLesson: const RouteMainMenu(),
                                    illustrationPath: null,
                                  ),
                                );
                              }
                            },
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
      // IMPORTANT: LessonStepTwo should call onStarted AFTER it shows "COMPLETE"
      return LessonStepTwo(
        onStarted: () {
          _stepAnswered.value = true; // unlock Continue only after COMPLETE
        },
      );
    }
    if (currentStep == 3) {
      return LessonStepThree();
    }
    if (currentStep == 4) {
      return LessonStepFour();
    }
    if (currentStep == 5) {
      return LessonStepFive(
        onCompleted: () {
          _stepAnswered.value = true; // unlock Continue after activity complete
        },
      );
    }
    return const SizedBox.shrink();
  }
}
