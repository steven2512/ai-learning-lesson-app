// lib/ui/end_lesson.dart
// CHANGED: implement a visible EndLesson scene (was blank).
import 'dart:ui';
import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart'; // CHANGED: use Flutter's VoidCallback
import 'package:running_robot/accessories/buttons/button.dart';
import 'package:running_robot/accessories/decorations/stars.dart';
import 'package:running_robot/accessories/events/event_type.dart';
import 'package:running_robot/accessories/static/background.dart';

class EndLessonPage extends FlameGame {
  final VoidCallback onRepeat; // repeat current/previous lesson
  final VoidCallback onNext; // go to next lesson
  final VoidCallback onMainMenu; // go to main menu

  late Background background;
  late Star star1;
  late Star star2;
  late Star star3;

  EndLessonPage({
    required this.onRepeat,
    required this.onNext,
    required this.onMainMenu,
  });
  @override
  Future<void> onLoad() async {
    final sz = size;

    background = Background(backgroundSize: Vector2(size.x, size.y));
    star1 = Star(
      position: Vector2(size.x / 2 - 90, 200),
      size: Vector2.all(120),
      angle: -0.08,
    );
    star2 = Star(
      position: Vector2(size.x / 2, 160),
      size: Vector2.all(120),
      angle: 0,
    );
    star3 = Star(
      position: Vector2(size.x / 2 + 90, 200),
      size: Vector2.all(120),
      angle: 0.08,
    );

    //add objects on screen
    addAll([
      background,
      star1,
      star2,
      star3,
    ]); // await so star.onLoad() finishes
    star1.switchPhase(EventProgressBar.proceed);

    // Helper to create your pill buttons
    GenericButton<String> makeBtn(String label, double y, VoidCallback cb) {
      return GenericButton<String>(
        position: Vector2(sz.x / 2, y),
        anchor: Anchor.center,
        buttonSize: Vector2(240, 56),
        padding: const [10, 16, 10, 16],
        content: label,
        boxColor: const Color.fromARGB(255, 0, 125, 226),
        boxOpacity: 1,
        fontSize: 18,
        fontWeight: FontWeight.w600,
        fontColor: Colors.white,
        borderRadius: 22,
        payload: null, // CHANGED: no payload
        onPressed: (_) => cb(), // CHANGED: wire to callback
        bevelHeight: 6.0,
      )..show(); // CHANGED: ensure visible
    }

    add(makeBtn('Repeat lesson', sz.y * 0.50, onRepeat));
    add(makeBtn('Next lesson', sz.y * 0.62, onNext));
    add(makeBtn('Main menu', sz.y * 0.74, onMainMenu));
  }
}
