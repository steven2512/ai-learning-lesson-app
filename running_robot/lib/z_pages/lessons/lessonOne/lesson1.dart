import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:running_robot/z_pages/assets/lessonN/icon_button.dart';
import 'package:running_robot/z_pages/assets/lessonN/progress_bar.dart';
import 'package:running_robot/core/app_router.dart';
import 'package:running_robot/z_pages/lessons/lessonOne/lesson1_1.dart';
import 'package:running_robot/z_pages/lessons/lessonOne/lesson1_2.dart';
import 'package:running_robot/z_pages/lessons/lessonOne/lesson1_3.dart';
import 'package:running_robot/z_pages/lessons/lessonOne/lesson1_4.dart';

/// ✅ Shared Continue Button
class ContinueButton extends StatelessWidget {
  final VoidCallback onPressed;
  const ContinueButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.teal,
            padding: const EdgeInsets.symmetric(horizontal: 38, vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
          ),
          onPressed: onPressed,
          child: Text(
            'Continue',
            style: GoogleFonts.lato(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }
}

class LessonOne extends StatefulWidget {
  final AppNavigate onNavigate;
  const LessonOne({super.key, required this.onNavigate});

  @override
  State<LessonOne> createState() => _LessonOneState();
}

class _LessonOneState extends State<LessonOne> {
  int currentStep = 0;

  final GlobalKey<LessonStepOneState> _stepOneKey =
      GlobalKey<LessonStepOneState>();

  final Map<int, double> topOffsets = {
    0: 150,
    1: 200,
    2: 140,
    3: 140,
  };

  final ValueNotifier<bool> _stepOneAnswered = ValueNotifier(false);
  final ValueNotifier<bool> _stepThreeAnswered = ValueNotifier(false);

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
            child: LessonProgressBar(
              totalStages: 4,
              currentStage: currentStep,
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
              child: ValueListenableBuilder2<bool, bool>(
                first: _stepOneAnswered,
                second: _stepThreeAnswered,
                builder: (context, step1, step3, _) {
                  if (_showContinueButton(step1, step3)) {
                    return ContinueButton(
                      onPressed: () {
                        if (currentStep == 1) {
                          final state = _stepOneKey.currentState;
                          if (state != null) state.nextRound();
                        } else {
                          setState(() => currentStep++);
                        }
                      },
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentStep() {
    switch (currentStep) {
      case 0:
        return const LessonStepZero();
      case 1:
        return LessonStepOne(
          key: _stepOneKey,
          answeredNotifier: _stepOneAnswered,
          onRoundComplete: () => setState(() => currentStep++),
        );
      case 2:
        return const LessonStepTwo();
      case 3:
        return LessonStepThree(answeredNotifier: _stepThreeAnswered);
      default:
        return Container();
    }
  }

  bool _showContinueButton(bool stepOneAnswered, bool stepThreeAnswered) {
    if (currentStep == 1) return stepOneAnswered;
    if (currentStep == 3) return stepThreeAnswered;
    return true;
  }
}

/// Helper for listening to two ValueNotifiers
class ValueListenableBuilder2<A, B> extends StatelessWidget {
  final ValueListenable<A> first;
  final ValueListenable<B> second;
  final Widget Function(BuildContext, A, B, Widget?) builder;

  const ValueListenableBuilder2({
    super.key,
    required this.first,
    required this.second,
    required this.builder,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<A>(
      valueListenable: first,
      builder: (context, a, _) {
        return ValueListenableBuilder<B>(
          valueListenable: second,
          builder: (context, b, child) => builder(context, a, b, child),
        );
      },
    );
  }
}
