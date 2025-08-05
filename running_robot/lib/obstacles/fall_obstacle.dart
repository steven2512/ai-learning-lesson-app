import 'dart:math';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:running_robot/my_game.dart';

class FallObstacle extends PositionComponent with HasGameRef<MyGame> {
  final Vector2 initialPosition;
  GamePhase gamePhase;
  bool isPaused = false;
  late final Vector2 velocity;
  double topY;

  FallObstacle({
    required this.initialPosition,
    required this.topY,
    required this.gamePhase,
  }) {
    velocity = Vector2(0, Random().nextDouble() * 100 + 200);
    position = initialPosition.clone();
    size = Vector2(8, 16);
    anchor = Anchor.center;
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    final paint = Paint()..color = const Color(0xFF2196F3);

    final path = Path()
      ..moveTo(size.x / 2, 0)
      ..quadraticBezierTo(size.x, size.y * 0.6, size.x / 2, size.y)
      ..quadraticBezierTo(0, size.y * 0.6, size.x / 2, 0)
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (isPaused || gamePhase == GamePhase.paused) return;

    position += velocity * dt;

    if (position.y > topY) {
      position.setFrom(initialPosition);
    }
  }

  void resetPosition() {
    position.setFrom(initialPosition);
    velocity = Vector2.zero();
  }
}
