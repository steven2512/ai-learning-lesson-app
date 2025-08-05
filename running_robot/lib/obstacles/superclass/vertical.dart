import 'dart:math';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:running_robot/my_game.dart';

class VerticalObstacle extends PositionComponent with HasGameRef<MyGame> {
  final Vector2 initialPosition;
  double topY;
  late Vector2 velocity;
  bool isPaused = false;

  VerticalObstacle({
    required this.initialPosition,
    required this.topY,
    Vector2? customVelocity,
    Vector2? sizeOverride,
  }) {
    velocity = customVelocity ?? Vector2(0, Random().nextDouble() * 100 + 200);
    position = initialPosition.clone();
    size = sizeOverride ?? Vector2(8, 16);
    anchor = Anchor.center;
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    // Default fallback shape — subclasses should override this
    final paint = Paint()..color = const Color(0xFF2196F3);
    canvas.drawRect(size.toRect(), paint);
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (isPaused) return;

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
