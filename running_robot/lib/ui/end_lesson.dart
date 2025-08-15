// lib/ui/end_lesson.dart
// CHANGED: implement a visible EndLesson scene (was blank).
import 'dart:ui';
import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart'
    hide IconButton; // CHANGED: use Flutter's VoidCallback
import 'package:running_robot/accessories/decorations/stars.dart';
import 'package:running_robot/accessories/events/event_type.dart';
import 'package:running_robot/accessories/static/background.dart';
import 'package:running_robot/accessories/buttons/generic_button.dart';
import 'package:running_robot/accessories/buttons/icon_button.dart';

class EndLessonPage extends FlameGame {
  final VoidCallback onRepeat; // repeat current/previous lesson
  final VoidCallback onNext; // go to next lesson
  final VoidCallback onMainMenu; // go to main menu

  late Background background;
  late Star star1;
  late Star star2;
  late Star star3;
  late GenericButton nextLessonButton;
  late IconButton returnButton;

  EndLessonPage({
    required this.onRepeat,
    required this.onNext,
    required this.onMainMenu,
  });
  @override
  Future<void> onLoad() async {
    background = Background(
      backgroundSize: Vector2(size.x, size.y),
      colors: [const Color.fromARGB(255, 255, 255, 255)],
    );

    nextLessonButton = GenericButton(
      position: Vector2(size.x / 2, size.y - 80),
      anchor: Anchor.center,
      buttonSize: Vector2(350, 60),
      padding: [5, 10, 5, 10],
      content: "Next Lesson",
      boxColor: const Color.fromARGB(255, 136, 32, 255),
      boxOpacity: 1,
      fontSize: 22,
      fontWeight: FontWeight.w800,
      fontColor: Colors.white,
      borderRadius: 30,
    );

    nextLessonButton.switchPhase(
      EventHorizontalObstacle.startMoving,
    );

    returnButton = IconButton<void>(
      position: Vector2(40, 80),
      size: Vector2(30, 25),
      anchor: Anchor.center,
      iconPath: 'arrow_left.png',
      tint: Colors.black87, // or null to keep original colors
      onPressed: (_) => onMainMenu(),
    )..show();

    add(background);
    add(nextLessonButton);
    add(returnButton);
  }
}
