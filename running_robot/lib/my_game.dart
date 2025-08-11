import 'dart:async';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flutter/material.dart';
import 'package:running_robot/decorations/pause.dart';
import 'package:running_robot/events/event_type.dart';
import 'package:running_robot/obstacles/bird.dart';
import 'package:running_robot/obstacles/fence.dart';
import 'package:running_robot/decorations/progress_bar.dart';
import 'package:running_robot/static/arrow.dart';
import 'package:running_robot/static/background.dart';
import 'package:running_robot/static/ground.dart';
import 'package:running_robot/obstacles/cloud.dart';
import 'package:running_robot/characters/robot.dart';
import 'package:running_robot/texts/text_box.dart';
import 'package:running_robot/texts/lessons/lesson1_text.dart';
import 'package:running_robot/obstacles/rain.dart';

enum GamePhase {
  intro,
  waitingForSwipe,
  fisrtRun,
  contemplation,
  firstTutorial,
  secondRun,
  finalExplanation,
  paused,
}

class MyGame extends FlameGame with PanDetector, HasCollisionDetection {
  GamePhase phase = GamePhase.intro;
  int failCount = 0;

  bool colliedJumpObstacles = false;
  bool colliedRainObstacles = false;

  Vector2? dragStart;
  Vector2? dragLast;

  // ─────── Global component references ───────
  late final Background background;
  late final Ground ground;
  late final Robot robot;
  late final Fence barell;
  late final Bird bird;
  late final FancyTextBox introTextBox;
  late final FancyTextBox firstRunTextBox;
  late final LessonProgressBar progressBar;
  late final PauseButton pauseButton;
  late final Cloud cloudRain;
  late final List<Cloud> clouds = [];
  late final List<Rain> rainFall;
  late final Arrow arrowDown;

  @override
  FutureOr<void> onLoad() async {
    background = Background(backgroundSize: Vector2(size.x, size.y));

    ground = Ground(dimensions: Vector2(size.x, size.y));
    final groundY = ground.topY;

    robot = Robot(
      initialPosition: Vector2(size.x / 2, size.y / 2),
      groundY: groundY,
    );

    barell = Fence(
      initialPosition: Vector2(size.x + 200, groundY - 45),
      picturePath: 'barrell_red.png',
      groundY: groundY,
      size: Vector2(90, 90),
      velocity: Vector2(-70, 0),
    );

    arrowDown = Arrow(
      imageFile: 'down_arrow.png',
      position: Vector2(size.x / 2 - 18, size.y - 560),
      size: Vector2(35, 54),
    );

    bird = Bird(
      framePaths: [
        'bat.png',
        'bat_hang.png',
        'bat_fly.png',
      ],
      startPosition: Vector2(size.x + 100, 450),
      endPosition: Vector2(-100, 450),
      velocity: Vector2(-80, 0),
      customSize: Vector2(80, 50),
    );

    introTextBox = FancyTextBox(
      sequence: introText,
      interval: 4.5,
      fadeDuration: 0.5,
      position: Vector2(size.x / 2, size.y / 3),
      anchor: Anchor.center,
      fontSize: 25,
      letterSpacing: 0.5,
      fontWeight: FontWeight.w800,
      maxWidth: 350,
    );

    firstRunTextBox = FancyTextBox(
      sequence: firstRunText,
      durations: [3, 3, 3, 1, 4, 4, 2],
      intervals: [0, 3, 8, 5, 3, 3],
      fadeDuration: 0.5,
      position: Vector2(size.x / 2, size.y / 3),
      anchor: Anchor.center,
      fontSize: 25,
      letterSpacing: 0.5,
      fontWeight: FontWeight.w800,
      maxWidth: 350,
    );

    cloudRain = Cloud(
      initialPosition: Vector2(size.x + 300, 220),
      picturePath: 'cloud_grey.png',
      stretchY: 1.5,
      stretchX: 1.5,
      velocity: Vector2(-70, 0),
      // randomizeRest: false, // (default) keep stable for rain anchor
    );

    clouds.add(
      Cloud(
        initialPosition: Vector2(size.x + 150, 320),
        picturePath: 'cloud_shape4_4.png',
        stretchY: 0.7,
        velocity: Vector2(-100, 0),
        randomizeRest: true, // ✅ parallax
        opacity: 0.2,
      ),
    );

    clouds.add(
      Cloud(
        initialPosition: Vector2(size.x + 300, 360),
        picturePath: 'cloud_shape3_5.png',
        stretchY: 0.7,
        velocity: Vector2(-90, 0),
        randomizeRest: true, // ✅ parallax
        opacity: 0.3,
      ),
    );

    // clouds.add(
    //   Cloud(
    //     initialPosition: Vector2(size.x + 150, 320),
    //     picturePath: 'cloud_shape4_4.png',
    //     stretchY: 0.7,
    //     velocity: Vector2(-30, 0),
    //     randomizeRest: true, // ✅ parallax
    //     opacity: 0.2,
    //   ),
    // );

    // clouds.add(
    //   Cloud(
    //     initialPosition: Vector2(size.x + 300, 360),
    //     picturePath: 'cloud_shape3_5.png',
    //     stretchY: 0.7,
    //     velocity: Vector2(-30, 0),
    //     randomizeRest: true, // ✅ parallax
    //     opacity: 0.2,
    //   ),
    // );

    rainFall = Rain.generateRain(
      count: 70,
      startAreaTopLeft: Vector2(size.x / 3, 200),
      startAreaBottomRight: Vector2(size.x * 2 / 3, 280),
      endPosition: Vector2(size.x / 2, groundY),
      minSpeed: 150,
      maxSpeed: 300,
      cloud: cloudRain, // <—
    );

    progressBar = LessonProgressBar(
      position: Vector2(size.x / 2, 80),
      stages: 3,
    );

    pauseButton = PauseButton(position: Vector2(size.x - 18, 75.5));
    add(background);
    add(ground);
    add(progressBar);
    add(arrowDown);
    add(pauseButton);
    addAll(clouds);
    add(robot);
    add(cloudRain);
    addAll(rainFall);
    add(barell);
    add(bird);
    add(introTextBox);
    add(firstRunTextBox);

    //Start chain of Event
    handlePhase();
  }

  Future<void> handlePhase() async {
    switch (phase) {
      case GamePhase.intro:
        introTextBox.switchPhase(EventText.showText);
        // await Future.delayed(const Duration(seconds: 28));

        // //Arrow for pointing to Robo
        // arrowDown.switchPhase(EventHorizontalObstacle.startMoving);
        // await Future.delayed(const Duration(milliseconds: 4500));
        // arrowDown.switchPhase(EventHorizontalObstacle.stopMoving);

        phase = GamePhase.waitingForSwipe;
        break;
      case GamePhase.waitingForSwipe:
        break;
      case GamePhase.fisrtRun:
        //Robot starts running
        introTextBox.switchPhase(EventText.hideText);
        robot.switchPhase(EventRobot.resume);
        ground.switchPhase(EventHorizontalObstacle.startMoving);
        clouds.forEach(
          (x) => x.switchPhase(EventHorizontalObstacle.startMoving),
        );

        await Future.delayed(const Duration(seconds: 4));

        //Bird
        bird.switchPhase(EventHorizontalObstacle.startMoving);

        await Future.delayed(const Duration(seconds: 4));
        firstRunTextBox.switchPhase(EventText.showText);
        //Wait 8 seconds
        await Future.delayed(const Duration(seconds: 3));

        //Bird now stops moving
        bird.switchPhase(EventHorizontalObstacle.stopMoving);

        await Future.delayed(const Duration(seconds: 5));
        //Cloud and rain starts moving
        cloudRain.switchPhase(EventHorizontalObstacle.startMoving);
        rainFall.forEach(
          (x) => x.switchPhase(EventVerticalObstacle.startFalling),
        );

        //CLoud and rain disappear
        await Future.delayed(const Duration(seconds: 12));
        cloudRain.switchPhase(EventHorizontalObstacle.stopMoving);
        rainFall.forEach(
          (x) => x.switchPhase(EventVerticalObstacle.stopFalling),
        );

        //Barrell
        barell.switchPhase(EventHorizontalObstacle.startMoving);

        await Future.delayed(const Duration(seconds: 4));

        //jump and fail
        robot.switchPhase(EventRobot.jump);

        await Future.delayed(const Duration(seconds: 4));
        barell.switchPhase(EventHorizontalObstacle.stopMoving);
        ground.switchPhase(EventHorizontalObstacle.stopMoving);

        await Future.delayed(const Duration(seconds: 3));
        clouds.forEach(
          (x) => x.switchPhase(EventHorizontalObstacle.stopMoving),
        );
        break;
      case GamePhase.contemplation:
        break;

      case GamePhase.firstTutorial:
        break;

      case GamePhase.secondRun:
        break;

      case GamePhase.finalExplanation:
        break;

      case GamePhase.paused:
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
  void onPanEnd(DragEndInfo info) {
    if (phase == GamePhase.waitingForSwipe) {
      if (dragStart != null && dragLast != null) {
        if (dragLast!.x - dragStart!.x > 50) {
          phase = GamePhase.fisrtRun;
          handlePhase();
        }
      }
    }
    dragStart = null;
    dragLast = null;
  }
}
