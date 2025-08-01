import 'dart:async';

import 'package:flame/components.dart';
import 'package:flutter/material.dart';

class Robot extends SpriteComponent {
  ///Represents a robot object (character)
  //Later on velocity changes when Flame calls update -> position of Robot changes
  Vector2 velocity = Vector2.zero();
  Vector2 initialPosition;
  final double gravity = 800;
  bool isOnGround = true;
  bool isFalling = false;

  //Constructor
  Robot({required this.initialPosition})
    : super(
        size: Vector2.all(100),
        paint: Paint()..color = Colors.blue,
      ) {
    position = initialPosition.clone();
  }

  void resetPosition() {
    position.setFrom(initialPosition);
  }

  void fall() {
    isFalling = true;
  }

  @override
  FutureOr<void> onLoad() async {
    sprite = await Sprite.load('robot_yellowDamage1.png');
  }

  @override
  Rect toRect() {
    return super.toRect();
  }

  //Called 60 times per second
  @override
  void update(double dt) {
    super.update(dt);

    //Add gravity if we accelerate upwards + falling down
    if (!isOnGround) {
      velocity.y += gravity * dt;
    }

    if (isFalling) {
      //standard force apply upward
      angle += 5 * dt;
    }

    position += velocity * dt;

    //Readjust position to the Ground when
    //falling down past the initialPoint
    if (position.y >= initialPosition.y) {
      isOnGround = true;
      velocity.y = 0;
      position.y = initialPosition.y;
    }
  }
}
