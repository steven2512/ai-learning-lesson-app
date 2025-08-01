import 'dart:async';
import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(
    //As soon as GameWidget obj is created, Flame will repeatedly runs game.update() 60 times per minute
    //So everything that is added on Load will constantly be updated
    GameWidget(
      game: EmptyGame(),
    ),
  );
}

class EmptyGame extends FlameGame with TapDetector {
  late Robot robot;
  late Obstacle obstacle1;

  @override
  FutureOr<void> onLoad() async {
    //square object
    robot = Robot(
      initialPosition: Vector2(size.x / 2 - 50, size.y / 2 - 50),
    );

    obstacle1 = Obstacle(
      initialPosition: Vector2(size.x, size.y / 2),
    );
    //change pos of object to middle of screen

    //add Objects to screen
    add(robot);
    add(obstacle1);
  }

  @override
  void onTap() {
    robot.velocity.y = -400;
    robot.isOnGround = false;
  }
}

class Robot extends RectangleComponent {
  //Later on velocity changes when Flame calls update -> position of Robot changes
  Vector2 velocity = Vector2.zero();
  Vector2 initialPosition;
  final double gravity = 800;
  bool isOnGround = true;

  //Constructor
  Robot({required this.initialPosition})
    : super(
        size: Vector2.all(100),
        paint: Paint()..color = Colors.blue,
      ) {
    position = initialPosition.clone();
  }

  //Called 60 times per second
  @override
  void update(double dt) {
    super.update(dt);

    //Add gravity if we accelerate upwards + falling down
    if (velocity.y != 0) {
      velocity.y += gravity * dt;
    }
    //standard force apply upward
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

class Obstacle extends RectangleComponent {
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

  @override
  void update(double dt) {
    super.update(dt);
    position.x += velocity.x * dt;
    if (position.x <= -100) {
      position.setFrom(initialPosition);
    }
  }
}
