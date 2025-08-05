import 'dart:async';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flutter/material.dart';
import 'package:running_robot/obstacles/bird.dart';
import 'package:running_robot/obstacles/fence.dart';
import 'package:running_robot/static/background.dart';
import 'package:running_robot/static/ground.dart';
import 'package:running_robot/obstacles/cloud.dart';
import 'package:running_robot/characters/robot.dart';
import 'package:running_robot/texts/text_box.dart';
import 'package:running_robot/texts/lessons/lesson1_text.dart';
import 'package:running_robot/obstacles/rain.dart';

enum GamePhase {
  intro,
  fisrtRun,
  contemplation,
  firstTutorial,
  secondRun,
  finalExplanation,
  paused,
}

class MyGame extends FlameGame with PanDetector {
  GamePhase phase = GamePhase.intro;
  int failCount = 0;

  bool colliedJumpObstacles = false;
  bool colliedRainObstacles = false;

  Vector2? dragStart;
  Vector2? dragLast;

  @override
  FutureOr<void> onLoad() async {
    //Background
    final background = Background(backgroundSize: Vector2(size.x, size.y));

    //Ground
    final ground = Ground(dimensions: Vector2(size.x, size.y));

    //Set absolute ground
    final groundY = ground.topY;

    //Robot
    final robot = Robot(
      initialPosition: Vector2(size.x / 2, size.y / 2),
    );

    //Fence
    final fence = Fence(
      initialPosition: Vector2(size.x + 200, groundY - 36),
      picturePath: 'fence.png',
      size: Vector2(70, 70),
      velocity: Vector2(-200, 0),
    );

    // Bird
    final bird = Bird(
      framePaths: [
        'bird1.png',
        'bird2.png',
        'bird3.png',
        'bird4.png',
      ],
      startPosition: Vector2(800, 350),
      endPosition: Vector2(-100, 350),
      velocity: Vector2(-150, 0),
      customSize: Vector2.all(50), // make it a big bird
    );

    //Text
    final mainText = FancyTextBox(
      sequence: introText,
      interval: 5.0,
      fadeDuration: 0.5,
      position: Vector2(size.x / 2, size.y / 3.5),
      anchor: Anchor.center,
      fontSize: 25,
      letterSpacing: 0.5,
      fontWeight: FontWeight.w800,
      maxWidth: 350,
    );

    //Cloud
    final cloud = Cloud(
      initialPosition: Vector2(size.x + 300, 220),
      scale: 1.5,
      velocity: Vector2(-30, 0),
    );

    //Rain
    final rainFall = Rain.generateRain(
      count: 30,
      startAreaTopLeft: Vector2(size.x / 3, 200),
      startAreaBottomRight: Vector2(size.x * 2 / 3, 280),
      endPosition: Vector2(size.x / 2, groundY),
      minSpeed: 100,
      maxSpeed: 250,
    );

    //Add all objects
    addAll(rainFall);
    add(background);
    add(ground);
    add(robot);
    add(cloud);
    add(fence);
    add(bird);
    addAll(rainFall);
    add(mainText);
  }

  Future<void> handlePhase() async {
    switch (phase) {
      case GamePhase.intro:
        // TODO: Instructions for intro phase
        break;

      case GamePhase.fisrtRun:
        // TODO: Instructions for firstRun phase
        break;

      case GamePhase.contemplation:
        // TODO: Instructions for contemplation phase
        break;

      case GamePhase.firstTutorial:
        // TODO: Instructions for firstTutorial phase
        break;

      case GamePhase.secondRun:
        // TODO: Instructions for secondRun phase
        break;

      case GamePhase.finalExplanation:
        // TODO: Instructions for finalExplanation phase
        break;

      case GamePhase.paused:
        // TODO: Instructions for paused phase (optional)
        break;
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
  void onPanEnd(DragEndInfo info) {}
}
