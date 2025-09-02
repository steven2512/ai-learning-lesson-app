import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:running_robot/z_pages/assets/lessonN/icon_button.dart';
import 'package:running_robot/z_pages/assets/lessonN/progress_bar.dart';
import 'package:running_robot/core/app_router.dart';
import 'package:running_robot/z_pages/lessons/lessonOne/lesson1_1.dart';
import 'package:running_robot/z_pages/lessons/lessonOne/lesson1_2.dart';

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
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // ✅ Progress bar
          Positioned(
            top: 70,
            left: MediaQuery.of(context).size.width / 2 - (279 / 2),
            child: LessonProgressBar(
              totalStages: 3,
              currentStage: currentStep,
            ),
          ),

          // ✅ Close button
          Positioned(
            top: 69,
            left: 30,
            child: returnButton,
          ),

          // ✅ Active step
          Positioned.fill(
            top: 120,
            child: _buildCurrentStep(),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentStep() {
    switch (currentStep) {
      case 0:
        return LessonStepZero(
          onContinue: () => setState(() => currentStep = 1),
        );
      case 1:
        return LessonStepOne(
          onContinue: () => setState(() => currentStep = 2),
        );
      // case 2:
      //   return LessonStepTwo(
      //     onContinue: () => setState(() => currentStep = 0), // loop back
      //   );
      default:
        return Container();
    }
  }
}
