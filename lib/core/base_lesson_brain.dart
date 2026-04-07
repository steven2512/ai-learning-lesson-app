// FILE: lib/core/base_lesson_brain.dart
import 'package:flutter/material.dart';
import 'package:running_robot/core/app_router.dart';
import 'package:running_robot/core/lesson_manifest.dart';
import 'package:running_robot/core/lesson_navigator.dart';
import 'package:running_robot/core/lesson_steps.dart';
import 'package:running_robot/core/lesson_locator.dart'; // 👈 NEW
import 'package:running_robot/core/progression_scope.dart';
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
abstract class BaseLessonBrainState<T extends BaseLessonBrain> extends State<T>
    with WidgetsBindingObserver {
  int currentIndex = 0;
  bool answered = false;
  bool _isBootstrapping = true;
  bool _isAdvancing = false;
  bool _sessionSyncInFlight = false;
  bool _lessonSessionActive = false;
  bool _lessonSessionClosed = false;
  late final List<SubLesson> subLessons;

  // ✅ FIX: a nonce that forces a full remount of the current sublesson subtree
  // when the mini-game asks to "Try Again". This resets any internal "completed"
  // flags inside the game (e.g., DragDropGameBase), so `onCompleted` fires again
  // and the Continue button reappears.
  int _restartNonce = 0; // ← added

  List<SubLesson> buildSubLessons();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    debugPrint("🔥 initState for ${widget.lessonId}");
    subLessons = buildSubLessons();
    LessonStepRegistry.register(widget.lessonId, subLessons.length);
    _bootstrapLesson();
  }

  // ─────────────────────────────
  // 🔹 API Wrappers
  // ─────────────────────────────

  Future<void> _bootstrapLesson() async {
    debugPrint("📘 handleLesson called for ${widget.lessonId}");
    final launchState = await LessonService.handleLesson(
      courseId: widget.courseId,
      chapterId: widget.chapterId,
      lessonId: widget.lessonId,
      globalLessonNumber: widget.globalLessonNumber,
    );

    if (!mounted) return;

    setState(() {
      final clampedIndex = launchState.initialStepIndex < 0
          ? 0
          : (launchState.initialStepIndex >= subLessons.length
              ? subLessons.length - 1
              : launchState.initialStepIndex);
      currentIndex = clampedIndex;
      answered = false;
      _isBootstrapping = false;
    });
    _lessonSessionActive = true;
  }

  Future<void> saveCurrentLessonStep(int stepIndex) async {
    await LessonService.saveCurrentLessonStep(
      lessonId: widget.lessonId,
      globalLessonNumber: widget.globalLessonNumber,
      stepIndex: stepIndex,
    );
  }

  Future<LessonCompletionResult> completeLesson() async {
    return LessonService.completeLesson(
      courseId: widget.courseId,
      chapterId: widget.chapterId,
      lessonId: widget.lessonId,
      globalLessonNumber: widget.globalLessonNumber,
    );
  }

  Future<void> _pauseLessonSession() async {
    if (_isBootstrapping ||
        _isAdvancing ||
        _sessionSyncInFlight ||
        !_lessonSessionActive ||
        _lessonSessionClosed) {
      return;
    }

    _sessionSyncInFlight = true;
    try {
      await LessonService.pauseLessonSession(
        lessonId: widget.lessonId,
        globalLessonNumber: widget.globalLessonNumber,
        stepIndex: currentIndex,
      );
      _lessonSessionActive = false;
    } catch (error) {
      debugPrint('Failed to pause lesson session: $error');
    } finally {
      _sessionSyncInFlight = false;
    }
  }

  Future<void> _resumeLessonSession() async {
    if (_isBootstrapping ||
        _isAdvancing ||
        _sessionSyncInFlight ||
        _lessonSessionActive ||
        _lessonSessionClosed) {
      return;
    }

    _sessionSyncInFlight = true;
    try {
      await LessonService.resumeLessonSession(
        courseId: widget.courseId,
        chapterId: widget.chapterId,
        lessonId: widget.lessonId,
        globalLessonNumber: widget.globalLessonNumber,
      );
      _lessonSessionActive = true;
    } catch (error) {
      debugPrint('Failed to resume lesson session: $error');
    } finally {
      _sessionSyncInFlight = false;
    }
  }

  Future<void> _exitLessonToMainMenu() async {
    final progression = ProgressionScope.read(context);
    await _pauseLessonSession();
    if (!mounted) return;
    await progression.refresh();
    if (!mounted) return;
    widget.onNavigate(const RouteMainMenu(tab: 0));
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        _resumeLessonSession();
        break;
      case AppLifecycleState.inactive:
      case AppLifecycleState.hidden:
      case AppLifecycleState.paused:
      case AppLifecycleState.detached:
        _pauseLessonSession();
        break;
    }
  }

  // ─────────────────────────────

  Future<void> goNext() async {
    if (_isAdvancing) return;
    _isAdvancing = true;

    try {
      if (currentIndex < subLessons.length - 1) {
        final nextIndex = currentIndex + 1;
        setState(() {
          currentIndex = nextIndex;
          answered = false;
          _restartNonce = 0;
        });

        await saveCurrentLessonStep(nextIndex);
      } else {
        final completion = await completeLesson();
        _lessonSessionClosed = true;
        _lessonSessionActive = false;
        if (!mounted) return;
        final progression = ProgressionScope.read(context);
        await progression.refresh();
        LessonNavigator.complete(
          widget.lessonId,
          widget.onNavigate,
          progression: progression,
          completion: completion,
        );
      }
    } finally {
      _isAdvancing = false;
    }
  }

  void resetAnswer() {
    // ✅ when a mini-game’s “Try Again” is tapped, the child calls this.
    // We both clear answered and bump the nonce to remount the sub-tree.
    setState(() {
      answered = false;
      _restartNonce++; // 👈 force a fresh instance of the game
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isBootstrapping) {
      return const Scaffold(
        backgroundColor: Colors.white,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final sub = subLessons[currentIndex];

    // Build current sub-lesson
    final built = sub.build(() {
      setState(() => answered = true);
      if (sub.mechanic == LessonMechanic.auto) {
        goNext();
      }
    }, resetAnswer);

    // Force remount on Try Again
    final keyedBuilt = KeyedSubtree(
      key: ValueKey(
          'lesson:${widget.lessonId}:step:$currentIndex:$_restartNonce'),
      child: built,
    );

    return PopScope(
      canPop: true,
      onPopInvoked: (didPop) async {
        if (didPop) {
          await _pauseLessonSession();
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Stack(
          clipBehavior: Clip.none,
          children: [
            // 1) Sub-lesson content UNDER everything else
            Positioned.fill(
              top: sub.topOffset,
              bottom: 100,
              child: keyedBuilt,
            ),

            // 2) Progress bar above content
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

            // 3) Continue button above content (if applicable)
            if (sub.mechanic == LessonMechanic.manual ||
                (sub.mechanic == LessonMechanic.emit && answered))
              Positioned(
                bottom: 40,
                left: 0,
                right: 0,
                child: ContinueButton(onPressed: () {
                  goNext();
                }),
              ),

            // 4) X button LAST so it paints on top and receives taps first
            Positioned(
              top: 69,
              left: screenH * 0.035,
              child: IconButtonWidget<void>(
                iconPath: 'assets/images/x_icon.png',
                tint: Colors.black87,
                size: 22,
                onPressed: (_) async {
                  await _exitLessonToMainMenu();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
