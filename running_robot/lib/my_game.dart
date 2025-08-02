import 'dart:async';
import 'package:flame/events.dart';
import 'package:running_robot/background.dart';
import 'package:running_robot/game_state.dart';
import 'package:running_robot/ground.dart';
import 'package:running_robot/obstacle.dart';
import 'package:running_robot/robot.dart';
import 'package:flame/components.dart';
import 'package:flame/input.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';

class MyGame extends FlameGame with PanDetector {
  late Background background;
  late Robot robot;
  late Obstacle obstacle1;
  late Ground ground;
  int failCount = 0;
  late TextComponent failText;
  final GameState gameState = GameState(); // NEW

  bool collied = false;
  Vector2? dragStart;
  Vector2? dragLast;

  @override
  FutureOr<void> onLoad() async {
    background = Background(backgroundSize: Vector2(size.x, size.y));
    ground = Ground(
      dimensions: Vector2(size.x, size.y),
      gameState: gameState,
    );

    robot = Robot(
      initialPosition: Vector2(size.x / 2, size.y / 2),
      gameState: gameState,
    );
    obstacle1 = Obstacle(
      initialPosition: Vector2(size.x, size.y / 3),
      gameState: gameState,
    );

    failText = TextComponent(
      text: "Fail Count: $failCount",
      position: Vector2(size.x / 2 - 60, size.y / 4.5),
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.white,
          fontSize: 24,
        ),
      ),
    );

    add(background);
    add(ground);
    add(robot);
    add(obstacle1);
    add(failText);
  }

  void incrementFail() {
    failCount++;
    failText.text = "Fail Count: $failCount";
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (gameState.isStopped) return;
    // Simple collision detection
    if (robot.toRect().overlaps(obstacle1.toRect())) {
      collied = true;
      if (robot.isJumping) {
        robot.trip();
      }
    }

    // Handle fail conditions
    if (collied && !robot.isTriping) {
      incrementFail();
      pauseEngine();
    } else if (collied && robot.isTriping && obstacle1.x <= -50) {
      incrementFail();
      pauseEngine();
    }
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

    // Swipe up = jump (only if not ducking)
    if (delta.y < -20 && delta.y.abs() > delta.x.abs()) {
      if (!robot.isDucking) {
        robot.jump();
      }
    }
    // Swipe down = duck
    else if (delta.y > 20 && delta.y.abs() > delta.x.abs()) {
      robot.duck();
    }
    // Swipe left = stop wheels
    else if (delta.x < -20 && delta.x.abs() > delta.y.abs()) {
      robot.stop();
    }
    // Swipe right = resume wheels
    else if (delta.x > 20 && delta.x.abs() > delta.y.abs()) {
      robot.resume();
    }

    dragStart = null;
    dragLast = null;
  }
}
