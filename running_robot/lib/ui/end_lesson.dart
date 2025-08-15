// lib/ui/end_lesson.dart
// CHANGED: implement a visible EndLesson scene (was blank).
import 'dart:ui';
import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart'; // CHANGED: use Flutter's VoidCallback
import 'package:running_robot/accessories/buttons/button.dart';

class EndLessonPage extends FlameGame {
  final VoidCallback onRepeat; // repeat current/previous lesson
  final VoidCallback onNext; // go to next lesson
  final VoidCallback onMainMenu; // go to main menu

  EndLessonPage({
    required this.onRepeat,
    required this.onNext,
    required this.onMainMenu,
  });

  @override
  Future<void> onLoad() async {
    final sz = size;

    // Background
    add(
      RectangleComponent(
        position: Vector2.zero(),
        size: sz,
        paint: Paint()..color = const Color(0xFF0F1115),
        priority: -1,
      ),
    );

    // Title
    add(
      TextComponent(
        text: 'Lesson Complete',
        textRenderer: TextPaint(
          style: const TextStyle(
            fontSize: 28,
            color: Colors.white,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
          ),
        ),
        anchor: Anchor.center,
        position: Vector2(sz.x / 2, sz.y / 3),
      ),
    );

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
