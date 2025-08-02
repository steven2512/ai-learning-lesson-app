import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:running_robot/game_state.dart';

class Obstacle extends RectangleComponent {
  ///Represents an obstacle that might interact with main Object
  Vector2 initialPosition;
  Vector2 velocity = Vector2(-200, 0);
  bool isOnGround = true;
  GameState gameState;

  Obstacle({required this.initialPosition, required this.gameState})
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

    // Stop obstacle movement if global stop flag is true
    if (gameState.isStopped) return;

    position.x += velocity.x * dt;
    if (position.x <= -100) {
      position.setFrom(initialPosition);
    }
  }
}
