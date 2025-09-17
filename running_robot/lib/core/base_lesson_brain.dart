// FILE: lib/core/base_lesson_brain.dart
import 'package:flutter/material.dart';
import 'package:running_robot/core/app_router.dart';
import 'package:running_robot/core/lesson_navigator.dart';
import 'package:running_robot/core/lesson_steps.dart';

import 'package:running_robot/z_pages/assets/lessonAssets/continueButton.dart';
import 'package:running_robot/z_pages/assets/lessonAssets/icon_button.dart';
import 'package:running_robot/z_pages/assets/lessonAssets/progress_bar.dart'
    as flutter_ui_bar;

/// Mechanics each sublesson can declare
enum LessonMechanic { manual, emit, auto }

/// One entry in the sublesson array
class SubLesson {
  final double topOffset;
  final LessonMechanic mechanic;
  final Widget Function(VoidCallback onComplete, VoidCallback onReset) build;

  const SubLesson({
    required this.topOffset,
    required this.mechanic,
    required this.build,
  });
}

/// 🔹 Abstract Base Lesson — only requires `id` + `subLessons`.
abstract class BaseLessonBrain extends StatefulWidget {
  final AppNavigate onNavigate;
  const BaseLessonBrain({super.key, required this.onNavigate});

  String get lessonId;
}

/// Shared state implementation for all lessons
abstract class BaseLessonBrainState<T extends BaseLessonBrain>
    extends State<T> {
  int currentIndex = 0;
  bool answered = false;
  late final List<SubLesson> subLessons;

  /// Override this to declare sub-lessons
  List<SubLesson> buildSubLessons();

  @override
  void initState() {
    super.initState();
    subLessons = buildSubLessons();
    LessonStepRegistry.register(widget.lessonId, subLessons.length);
  }

  void goNext() {
    if (currentIndex < subLessons.length - 1) {
      setState(() {
        currentIndex++;
        answered = false;
      });
    } else {
      LessonNavigator.complete(widget.lessonId, widget.onNavigate);
    }
  }

  /// 🔹 Helper: reset answered flag (e.g., Try Again → hide Continue)
  void resetAnswer() {
    setState(() => answered = false);
  }

  @override
  Widget build(BuildContext context) {
    final sub = subLessons[currentIndex];

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // progress bar
          Positioned(
            top: 70,
            left: MediaQuery.of(context).size.width / 2 - 140,
            child: flutter_ui_bar.LessonProgressBar(
              totalStages: subLessons.length,
              currentStage: currentIndex,
            ),
          ),

          // back button
          Positioned(
            top: 69,
            left: 30,
            child: IconButtonWidget<void>(
              iconPath: 'assets/images/x_icon.png',
              tint: Colors.black87,
              size: 22,
              onPressed: (_) => widget.onNavigate(const RouteMainMenu(tab: 0)),
            ),
          ),

          // main content
          Positioned.fill(
            top: sub.topOffset,
            bottom: 100,
            child: sub.build(() {
              setState(() => answered = true);
              if (sub.mechanic == LessonMechanic.auto) {
                goNext();
              }
            }, resetAnswer),
          ),

          // continue button
          if (sub.mechanic == LessonMechanic.manual ||
              (sub.mechanic == LessonMechanic.emit && answered))
            Positioned(
              bottom: 40,
              left: 0,
              right: 0,
              child: ContinueButton(onPressed: goNext),
            ),
        ],
      ),
    );
  }
}
