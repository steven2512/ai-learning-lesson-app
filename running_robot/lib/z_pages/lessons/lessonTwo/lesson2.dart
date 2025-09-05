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

import 'lesson2_1.dart'; // StepZero
import 'lesson2_2.dart'; // StepOne (more steps can be added later)

class LessonTwo extends StatefulWidget {
  final AppNavigate onNavigate;
  const LessonTwo({super.key, required this.onNavigate});

  @override
  State<LessonTwo> createState() => _LessonTwoState();
}

class _LessonTwoState extends State<LessonTwo> {
  int currentStep = 0;
  final ValueNotifier<bool> _stepAnswered = ValueNotifier(false);

  /// Map of per-step top offsets
  final Map<int, double> topOffsets = const {
    0: 170, // StepZero
    1: 170, // StepOne
    2: 150, // StepTwo (later)
    3: 150, // StepThree
    4: 150, // StepFour
  };

  /// Total number of steps in this lesson
  int get totalStages => 5;

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

          // ✅ Active step with offset
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
              child: ValueListenableBuilder<bool>(
                valueListenable: _stepAnswered,
                builder: (context, answered, _) {
                  if (_lessonCompleted) return const SizedBox.shrink();
                  final showContinue =
                      (currentStep == 0 || currentStep == 1) ? true : answered;

                  if (!showContinue) return const SizedBox.shrink();

                  return ContinueButton(
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
                        const int chapterProgress = 2; // e.g. lesson 2 done
                        const int totalChapterLessons = 10;

                        widget.onNavigate(
                          RouteEndLesson(
                            xp: xp,
                            streak: streak,
                            progressBar: endBar,
                            chapterProgress: chapterProgress,
                            totalChapterLessons: totalChapterLessons,
                            topText: "Lesson 2 complete! 🎉",
                            repeatLesson:
                                const RouteLesson2(), // 👈 repeat this lesson
                            nextLesson: const RouteMainMenu(), // placeholder
                            illustrationPath: null,
                          ),
                        );
                      }
                    },
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
    // Later: hook up StepTwo, StepThree, StepFour
    return const SizedBox.shrink();
  }
}
