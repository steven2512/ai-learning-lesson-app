import 'dart:async';
import 'package:flame/events.dart';
import 'package:running_robot/background.dart';
import 'package:running_robot/ground.dart';
import 'package:running_robot/obstacle.dart';
import 'package:running_robot/robot.dart';
import 'package:flame/components.dart';
import 'package:flame/input.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';

class MyGame extends FlameGame with PanDetector {
  ///MainGame
  late Background background;
  late Robot robot;
  late Obstacle obstacle1;
  late Ground ground;
  late int failCount = 0;
  late TextComponent failText;
  bool collied = false;
  Vector2? dragStart;
  Vector2? dragLast;

  @override
  FutureOr<void> onLoad() async {
    //main background
    background = Background(
      backgroundSize: Vector2(size.x, size.y),
    );

    //Ground
    ground = Ground(
      dimensions: Vector2(
        size.x,
        size.y,
      ),
    );

    //robot (main char)
    robot = Robot(
      initialPosition: Vector2(size.x / 2, size.y / 2),
    );

    //obstacle
    obstacle1 = Obstacle(
      initialPosition: Vector2(size.x, size.y / 3),
    );

    //Fail count - Text
    failText = TextComponent(
      text: "Fail Count: $failCount",
      position: Vector2(size.x / 2 - 60, size.y / 4.5),

      textRenderer: TextPaint(
        style: TextStyle(color: Colors.white, fontSize: 24),
      ),
    );

    //add Objects to screen
    add(background);
    add(ground);
    add(robot);
    add(obstacle1);
    add(failText);
  }

  //Increment Fail Attempts when Collison happens
  void incrementFail() {
    failCount++;
    failText.text = "Fail Count: $failCount";
  }

  @override
  void update(double dt) {
    super.update(dt);

    //Collison logic
    if (robot.toRect().overlaps(obstacle1.toRect())) {
      collied = true;
      // incrementFail();
      if (robot.isJumping) {
        robot.trip();
      }
    }
    if (collied && !robot.isTriping) {
      incrementFail();
      pauseEngine();
    } else if (collied && robot.isTriping && obstacle1.x <= -50) {
      incrementFail();
      pauseEngine();
    }
    // robot.position.setFrom(robot.initialPosition);
    // obstacle1.position.setFrom(obstacle1.initialPosition);
    // obstacle1.velocity.x = 0;
  }

  @override
  void onPanStart(DragStartInfo info) {
    dragStart = info.eventPosition.global;
    dragLast = dragStart;
  }

  @override
  void onPanUpdate(DragUpdateInfo info) {
    dragLast = info.eventPosition.global;
  }

  @override
  void onPanEnd(DragEndInfo info) {
    if (dragStart == null || dragLast == null) return;
    final delta = dragLast! - dragStart!;

    if (delta.y < -20 && delta.y.abs() > delta.x.abs()) {
      // Swipe UP
      robot.jump();
    } else if (delta.y > 20 && delta.y.abs() > delta.x.abs()) {
      // Swipe DOWN
      robot.duck();
    }

    dragStart = null;
    dragLast = null;
  }
}
