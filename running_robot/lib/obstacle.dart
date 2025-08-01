import 'package:flame/components.dart';
import 'package:flutter/material.dart';

class Obstacle extends RectangleComponent {
  ///Represents an obstacle that might interact with main Object
  Vector2 initialPosition;
  Vector2 velocity = Vector2(-200, 0);
  bool isOnGround = true;

  Obstacle({required this.initialPosition})
    : super(
        size: Vector2.all(50),
        paint: Paint()..color = Colors.white,
      ) {
    position = initialPosition.clone();
  }
  void resetPosition() {
    position.setFrom(initialPosition);
    velocity = Vector2.zero();
  }

  @override
  void update(double dt) {
    super.update(dt);
    position.x += velocity.x * dt;
    if (position.x <= -100) {
      position.setFrom(initialPosition);
    }
  }
}
