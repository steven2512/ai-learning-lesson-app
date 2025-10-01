// FILE: lib/z_pages/lessons/binary-intro/_brain.dart
import 'package:flutter/material.dart';
import 'package:running_robot/core/app_router.dart';
import 'package:running_robot/core/base_lesson_brain.dart';
import 'package:running_robot/core/widgets.dart';

// legacy steps
import 'photo.dart'; // HumanSeePhoto
import 'music.dart'; // HumanHearMusic
import 'comp_0101.dart' show ComputerSeeZeroOne;
import 'binary_intro.dart';
import 'bin_example.dart';
import 'unicode.dart';
import 'binary_game.dart';

final screenH = ScreenSize.height;
final screenW = ScreenSize.width;

class BinaryIntroBrain extends BaseLessonBrain {
  const BinaryIntroBrain({super.key, required AppNavigate onNavigate})
      : super(onNavigate: onNavigate);

  @override
  String get lessonId => "binary-intro";

  @override
  State<BinaryIntroBrain> createState() => _BinaryIntroBrainState();
}

class _BinaryIntroBrainState extends BaseLessonBrainState<BinaryIntroBrain> {
  // 🔹 NEW: Precache lesson-specific images when lesson starts
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      final ctx = context;
      precacheImage(const AssetImage("assets/images/monitor.png"), ctx);
      precacheImage(const AssetImage("assets/images/cameraman.png"), ctx);
      precacheImage(const AssetImage("assets/images/dialogue_box.png"), ctx);
      precacheImage(const AssetImage("assets/images/music_listening.png"), ctx);
      // 👆 covers all Image.asset calls used inside HumanSeePhoto, HumanHearMusic,
      // ComputerSeeZeroOne, and dialogue overlays.
    });
  }
  // 🔹 END NEW

  @override
  List<SubLesson> buildSubLessons() => [
        SubLesson(
          topOffset: screenH * 0.20,
          mechanic: LessonMechanic.manual,
          build: (_, __) => const HumanSeePhoto(),
        ),
        SubLesson(
          topOffset: screenH * 0.22,
          mechanic: LessonMechanic.manual,
          build: (_, __) => const HumanHearMusic(),
        ),
        SubLesson(
          topOffset: screenH * 0.2,
          mechanic: LessonMechanic.emit,
          build: (done, __) => ComputerSeeZeroOne(onStarted: done),
        ),
        SubLesson(
          topOffset: screenH * 0.2,
          mechanic: LessonMechanic.auto,
          build: (done, __) => BinaryIntro(
            onFinished: done,
            onRequestNext: done,
          ),
        ),
        SubLesson(
          topOffset: screenH * 0.24,
          mechanic: LessonMechanic.manual,
          build: (_, __) => BinaryExample(),
        ),
        SubLesson(
          topOffset: screenH * 0.27,
          mechanic: LessonMechanic.manual,
          build: (_, __) => HelloInUnicode(),
        ),
        SubLesson(
          topOffset: screenH * 0.1,
          mechanic: LessonMechanic.emit,
          build: (done, reset) => BinaryDragDropGame(
            onCompleted: done,
            onRestartRequested: reset, // ✅ uses the parent resetAnswer
          ),
        ),
      ];
}
