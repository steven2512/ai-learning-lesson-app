import 'dart:async';
import 'package:flame/events.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:running_robot/background.dart';
import 'package:running_robot/game_state.dart';
import 'package:running_robot/ground.dart';
import 'package:running_robot/obstacles/duck_obstacle.dart';
import 'package:running_robot/obstacles/jump_obstacle.dart';
import 'package:running_robot/characters/robot.dart';
import 'package:flame/components.dart';
import 'package:flame/input.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';

class MyGame extends FlameGame with PanDetector {
  late Background background;

  late Robot robot;
  late JumpObstacle smallFence;
  late DuckObstacle bird;
  late Ground ground;
  int failCount = 0;
  late TextComponent mainText;
  final GameState gameState = GameState();
  late JumpObstacle currentColliedJumpObstacles;
  bool useFancyDuck = false;

  bool colliedJumpObstacles = false;
  bool colliedDuckObstacles = false;
  bool colliedRainObstacles = false;

  List<JumpObstacle> allJumpObstacles = [];
  List<DuckObstacle> allDuckObstacles = [];
  // List<FallObstacles> allFallObstacles = [];

  Vector2? dragStart;
  Vector2? dragLast;

  @override
  FutureOr<void> onLoad() async {
    background = Background(backgroundSize: Vector2(size.x, size.y));
    ground = Ground(
      dimensions: Vector2(size.x, size.y),
    );

    // Robot no longer takes gameState
    robot = Robot(
      initialPosition: Vector2(size.x / 2, size.y / 2),
    );

    // Jump obstacle
    smallFence = JumpObstacle(
      initialPosition: Vector2(size.x + 200, size.y / 1.797),
      picturePath: 'fence.png',
      obstacleSize: Vector2.all(75),
    );
    allJumpObstacles.add(smallFence);

    // Duck obstacle
    bird = DuckObstacle(
      initialPosition: Vector2(size.x + 1000, size.y / 2.5),
    );
    allDuckObstacles.add(bird);

    // Text
    mainText = TextBoxComponent(
      align: Anchor.center,
      text: "Let's now observe our little friend: Robot A",
      anchor: Anchor.center,
      boxConfig: const TextBoxConfig(
        maxWidth: 350,
        timePerChar: 0.0,
      ),
      position: Vector2(size.x / 2, size.y / 4.5),
      textRenderer: TextPaint(
        style: GoogleFonts.lato(
          fontSize: 25,
          letterSpacing: 0.5,
          color: Colors.black,
          fontWeight: FontWeight.w800,
        ),
      ),
    );

    add(background);
    add(ground);
    add(robot);
    add(mainText);
    for (var obstacle in allJumpObstacles) {
      add(obstacle);
    }
    for (var obstacle in allDuckObstacles) {
      add(obstacle);
    }
  }

  // ---- Pause & Resume methods ----
  void pauseAllObstacles() {
    for (var x in allJumpObstacles) {
      x.isPaused = true;
    }
    for (var x in allDuckObstacles) {
      x.isPaused = true;
    }
    // for (var x in allFallObstacles) {
    //   x.isPaused = true;
    // }
  }

  void resumeAllObstacles() {
    for (var x in allJumpObstacles) {
      x.isPaused = false;
    }
    for (var x in allDuckObstacles) {
      x.isPaused = false;
    }
    // for (var x in allFallObstacles) {
    //   x.isPaused = false;
    // }
  }

  void pauseAllJumpObstacles() {
    for (var obstacle in allJumpObstacles) {
      obstacle.isPaused = true;
    }
  }

  void pauseAllDuckObstacles() {
    for (var obstacle in allDuckObstacles) {
      obstacle.isPaused = true;
    }
  }

  // void pauseAllFallObstacles() {
  //   for (var obstacle in allFallObstacles) {
  //     obstacle.isPaused = true;
  //   }
  // }

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

    // Swipe up = jump
    if (delta.y < -20 && delta.y.abs() > delta.x.abs()) {
      if (!robot.isDucking && !robot.isNormalDucking) robot.jump();
    }
    // Swipe down = duck
    else if (delta.y > 20 && delta.y.abs() > delta.x.abs()) {
      if (useFancyDuck) {
        robot.fancyDuck();
      } else {
        robot.normalDuck();
      }
    }
    // Swipe left = pause all obstacles
    else if (delta.x < -20 && delta.x.abs() > delta.y.abs()) {
      robot.stop();
      pauseAllJumpObstacles();
    }
    // Swipe right = resume all obstacles
    else if (delta.x > 20 && delta.x.abs() > delta.y.abs()) {
      robot.resume();
      resumeAllObstacles();
    }

    dragStart = null;
    dragLast = null;
  }
}
