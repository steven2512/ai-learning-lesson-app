import 'package:flutter/material.dart';
import 'package:running_robot/core/app_router.dart';
import 'package:running_robot/core/base_lesson_brain.dart';

// legacy steps
import 'photo.dart';
import 'music.dart';
import 'comp_0101.dart' show ComputerSeeZeroOne;
import 'binary_intro.dart';
import 'bin_example.dart';
import 'unicode.dart';
import 'binary_game.dart';

class BinaryIntroBrain extends BaseLessonBrain {
  const BinaryIntroBrain({super.key, required AppNavigate onNavigate})
      : super(onNavigate: onNavigate);

  @override
  String get lessonId => "binary-intro";

  @override
  State<BinaryIntroBrain> createState() => _BinaryIntroBrainState();
}

class _BinaryIntroBrainState extends BaseLessonBrainState<BinaryIntroBrain> {
  @override
  List<SubLesson> buildSubLessons() => [
        SubLesson(
          topOffset: 180,
          mechanic: LessonMechanic.manual,
          build: (_) => const HumanSeePhoto(),
        ),
        SubLesson(
          topOffset: 190,
          mechanic: LessonMechanic.manual,
          build: (_) => const HumanHearMusic(),
        ),
        SubLesson(
          topOffset: 180,
          mechanic: LessonMechanic.emit,
          build: (done) => ComputerSeeZeroOne(onStarted: done),
        ),
        SubLesson(
          topOffset: 250,
          mechanic: LessonMechanic.auto,
          build: (done) => BinaryIntro(
            onFinished: done,
            onRequestNext: done,
          ),
        ),
        SubLesson(
          topOffset: 250,
          mechanic: LessonMechanic.manual,
          build: (_) => BinaryExample(),
        ),
        SubLesson(
          topOffset: 250,
          mechanic: LessonMechanic.manual,
          build: (_) => HelloInUnicode(),
        ),
        SubLesson(
          topOffset: 120,
          mechanic: LessonMechanic.emit,
          build: (done) => BinaryDragDropGame(
            onCompleted: done,
            onRestartRequested: resetAnswer, // ✅ clean + works
          ),
        ),
      ];
}
