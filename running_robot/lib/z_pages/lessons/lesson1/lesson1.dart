// FILE: lib/z_pages/lessons/lesson1/lesson1.dart
// CHANGED: imports stay the same files; lesson1_1.dart now also defines NEW LessonStepOne (intro)
// CHANGED: lesson1_2.dart now defines LessonStepTwo (the old quiz step, renamed)

import 'package:flame/components.dart' show Vector2;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:running_robot/core/app_router.dart';
import 'package:running_robot/z_pages/assets/lessonAssets/continueButton.dart';
import 'package:running_robot/z_pages/assets/lessonAssets/icon_button.dart';
import 'package:running_robot/z_pages/assets/lessonAssets/progress_bar.dart'
    as flutter_ui_bar;

import 'package:running_robot/z_pages/lessons/lesson1/lesson1_1.dart'; // contains LessonStepZero (unchanged) + NEW LessonStepOne (intro)
import 'package:running_robot/z_pages/lessons/lesson1/lesson1_2.dart'; // contains LessonStepTwo (old quizzes renamed)

// 🔹 Flame progress bar (final bar to pass to EndLessonPage)
import 'package:running_robot/game/decorations/progress_bar.dart'
    show LessonProgressBar;
import 'package:running_robot/game/events/event_type.dart'
    show EventProgressBar;
import 'package:running_robot/z_pages/lessons/lesson1/lesson1_3.dart';

class LessonOne extends StatefulWidget {
  final AppNavigate onNavigate;
  const LessonOne({super.key, required this.onNavigate});

  @override
  State<LessonOne> createState() => _LessonOneState();
}

class _LessonOneState extends State<LessonOne> {
  int currentStep = 0;

  final ValueNotifier<bool> _stepAnswered = ValueNotifier(false);

  /// ✅ Each step can define its own vertical offset
  /// CHANGED: Added entry for new step 1 (intro). Quizzes shift by +1.
  final Map<int, double> topOffsets = const {
    0: 150, // StepZero (unchanged)
    1: 150, // NEW LessonStepOne (intro)
    2: 160, // Quiz 1 (now in LessonStepTwo)
    3: 160, // Quiz 2
    4: 160, // Quiz 3
    5: 160, // Quiz 4
    6: 160, // Quiz 5
  };

  // CHANGED: total stages = StepZero + NEW StepOne intro + quizzes (now in StepTwo)
  int get totalStages => 2 + LessonStepTwo.quizCount;

  // Track "lesson completed" so the Flutter UI bar can render 100%
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
          // ✅ Progress bar (Flutter UI version for this page)
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

          // ✅ Active step with offset applied
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
                  // CHANGED: Allow auto-continue for StepZero (0) and NEW StepOne (1)
                  final showContinue = (currentStep <= 1) ? true : answered;
                  if (!showContinue) return const SizedBox.shrink();

                  return ContinueButton(
                    onPressed: () {
                      if (currentStep < totalStages - 1) {
                        setState(() {
                          currentStep++;
                          _stepAnswered.value = false;
                        });
                      } else {
                        // Final step: mark complete and route to end screen
                        setState(() {
                          _lessonCompleted = true;
                          _stepAnswered.value = false;
                        });

                        // 🔹 Build the FINAL Flame progress bar (fully filled) to pass along.
                        final endBar = LessonProgressBar(
                          position:
                              Vector2.zero(), // EndLessonPage will position it
                          stages: totalStages,
                        );
                        for (int i = 0; i < totalStages; i++) {
                          endBar.switchPhase(EventProgressBar.proceed);
                        }

                        // 🔹 Hardcoded sample stats (wire real values later)
                        const int xp = 50; // 10 XP per quiz × 5
                        const int streak = 1; // stub
                        const int chapterProgress = 1; // e.g., lesson 1 done
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
                            repeatLesson:
                                const RouteLesson(1), // 👈 repeat this lesson
                            nextLesson: const RouteLesson(2),
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
    // CHANGED: Step mapping: 0 -> StepZero (unchanged), 1 -> NEW StepOne (intro),
    //          2.. -> LessonStepTwo quizzes with shifted index (currentStep-2)
    if (currentStep == 0) return const LessonStepZero();
    if (currentStep == 1) return const LessonStepOne();

    final quizIndex = currentStep - 2;
    return LessonStepTwo(
      key: ValueKey('quiz-$quizIndex'),
      quizIndex: quizIndex,
      onQuizCompleted: (index) {
        debugPrint("Quiz $index completed");
        _stepAnswered.value = true;
      },
    );
  }
}
