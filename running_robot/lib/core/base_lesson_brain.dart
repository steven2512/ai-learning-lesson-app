// FILE: lib/core/base_lesson_brain.dart
import 'package:flutter/material.dart';
import 'package:running_robot/core/app_router.dart';
import 'package:running_robot/core/lesson_manifest.dart';
import 'package:running_robot/core/lesson_navigator.dart';
import 'package:running_robot/core/lesson_steps.dart';
import 'package:running_robot/core/lesson_locator.dart'; // 👈 NEW
import 'package:running_robot/core/widgets.dart';
import 'package:running_robot/services/lesson_service.dart';

import 'package:running_robot/z_pages/assets/lessonAssets/continueButton.dart';
import 'package:running_robot/z_pages/assets/lessonAssets/icon_button.dart';
import 'package:running_robot/z_pages/assets/lessonAssets/progress_bar.dart'
    as flutter_ui_bar;

final double screenH = ScreenSize.height;
final double screenW = ScreenSize.width;

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

/// 🔹 Abstract Base Lesson — now includes course + chapter context
abstract class BaseLessonBrain extends StatefulWidget {
  final AppNavigate onNavigate;

  const BaseLessonBrain({super.key, required this.onNavigate});

  String get lessonId;

  String get chapterId {
    final chapter = chapterManifest.firstWhere(
      (c) => c.lessons.any((l) => l.id == lessonId),
    );
    return chapter.id;
  }

  String get courseId {
    final course = courseManifest.firstWhere(
      (co) => co.chapters.any(
        (ch) => ch.lessons.any((l) => l.id == lessonId),
      ),
    );
    return course.id;
  }

  /// 🔹 Get global lesson index (1-based) from LessonLocator
  int get globalLessonNumber {
    final locator = LessonLocator.fromLessonId(lessonId);
    return locator.globalIndex;
  }
}

/// Shared state implementation for all lessons
abstract class BaseLessonBrainState<T extends BaseLessonBrain>
    extends State<T> {
  int currentIndex = 0;
  bool answered = false;
  late final List<SubLesson> subLessons;

  List<SubLesson> buildSubLessons();

  @override
  void initState() {
    super.initState();
    debugPrint("🔥 initState for ${widget.lessonId}");
    subLessons = buildSubLessons();
    LessonStepRegistry.register(widget.lessonId, subLessons.length);
    handleLesson();
  }

  // ─────────────────────────────
  // 🔹 API Wrappers
  // ─────────────────────────────

  Future<void> handleLesson() async {
    debugPrint("📘 handleLesson called for ${widget.lessonId}");
    await LessonService.handleLesson(
      courseId: widget.courseId,
      chapterId: widget.chapterId,
      lessonId: widget.lessonId,
      globalLessonNumber: widget.globalLessonNumber,
    );
  }

  Future<void> updateLesson(Map<String, dynamic> fields) async {
    await LessonService.updateLesson(
      courseId: widget.courseId,
      chapterId: widget.chapterId,
      lessonId: widget.lessonId,
      fields: fields,
    );
  }

  Future<void> completeLesson() async {
    await LessonService.completeLesson(
      courseId: widget.courseId,
      chapterId: widget.chapterId,
      lessonId: widget.lessonId,
      globalLessonNumber: widget.globalLessonNumber,
    );
  }

  // ─────────────────────────────

  void goNext() {
    if (currentIndex < subLessons.length - 1) {
      setState(() {
        currentIndex++;
        answered = false;
      });

      updateLesson({'lastStepIndex': currentIndex});
    } else {
      completeLesson();
      LessonNavigator.complete(widget.lessonId, widget.onNavigate);
    }
  }

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
          Align(
            alignment: Alignment.topCenter,
            child: Padding(
              padding: const EdgeInsets.only(top: 70),
              child: flutter_ui_bar.LessonProgressBar(
                totalStages: subLessons.length,
                currentStage: currentIndex,
              ),
            ),
          ),
          Positioned(
            top: 69,
            left: screenH * 0.035,
            child: IconButtonWidget<void>(
              iconPath: 'assets/images/x_icon.png',
              tint: Colors.black87,
              size: 22,
              onPressed: (_) => widget.onNavigate(const RouteMainMenu(tab: 0)),
            ),
          ),
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
