import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:running_robot/z_pages/assets/lessonN/icon_button.dart';
import 'package:running_robot/z_pages/assets/lessonN/progress_bar.dart';
import 'package:running_robot/core/app_router.dart';
import 'package:running_robot/z_pages/lessons/lessonOne/lesson1_1.dart';
import 'package:running_robot/z_pages/lessons/lessonOne/lesson1_2.dart';
import 'package:running_robot/z_pages/lessons/lessonOne/lesson1_3.dart';
import 'package:running_robot/z_pages/lessons/lessonOne/lesson1_3_2.dart';
import 'package:running_robot/z_pages/lessons/lessonOne/lesson1_4.dart';
import 'package:running_robot/z_pages/lessons/lessonTwo/lesson1_5.dart';
import 'package:running_robot/z_pages/lessons/lessonTwo/lesson1_6.dart';

/// ✅ Shared Continue Button widget
class ContinueButton extends StatelessWidget {
  final VoidCallback onPressed;

  const ContinueButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ElevatedButton(
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all<Color>(Colors.teal),
            padding: MaterialStateProperty.all<EdgeInsets>(
              const EdgeInsets.symmetric(horizontal: 38, vertical: 14),
            ),
            shape: MaterialStateProperty.all<RoundedRectangleBorder>(
              RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
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

  const LessonOne({
    super.key,
    required this.onNavigate,
  });

  @override
  State<LessonOne> createState() => _LessonOneState();
}

class _LessonOneState extends State<LessonOne> {
  int currentStep = 0;

  // Each lesson can have its own vertical padding
  final Map<int, double> topOffsets = {
    0: 200,
    1: 200,
    2: 140,
    3: 140, // new LessonStepTwoTwo
    4: 220,
    5: 120,
    6: 180,
    7: 130,
  };

  // ✅ Notifiers
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
              totalStages: 7,
              currentStage: currentStep,
            ),
          ),

          // ✅ Close button
          Positioned(
            top: 69,
            left: 30,
            child: returnButton,
          ),

          // ✅ Active step (content only, offset applied)
          Positioned.fill(
            top: topOffset,
            bottom: 100, // leave space for button
            child: _buildCurrentStep(),
          ),

          // ✅ Fixed Continue button at bottom
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
                      onPressed: () =>
                          setState(() => currentStep = currentStep + 1),
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
        return LessonStepOne(answeredNotifier: _stepOneAnswered);
      case 2:
        return const LessonStepTwo();
      case 3:
        return const LessonStepTwoTwo();
      case 4:
        return LessonStepThree(answeredNotifier: _stepThreeAnswered);
      case 5:
        return const LessonStepFour();
      case 6:
        return const LessonStepFive();
      default:
        return Container();
    }
  }

  /// Decides when to show the Continue button
  bool _showContinueButton(bool stepOneAnswered, bool stepThreeAnswered) {
    if (currentStep == 1) return stepOneAnswered;
    if (currentStep == 4) return stepThreeAnswered;
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
