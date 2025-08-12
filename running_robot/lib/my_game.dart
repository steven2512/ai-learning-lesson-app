import 'dart:async';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:running_robot/decorations/pause.dart';
import 'package:running_robot/events/event_type.dart';
import 'package:running_robot/obstacles/bird.dart';
import 'package:running_robot/obstacles/fence.dart';
import 'package:running_robot/decorations/progress_bar.dart';
import 'package:running_robot/texts/arrow.dart';
import 'package:running_robot/static/background.dart';
import 'package:running_robot/static/ground.dart';
import 'package:running_robot/obstacles/cloud.dart';
import 'package:running_robot/characters/robot.dart';
import 'package:running_robot/texts/mcq.dart';
import 'package:running_robot/texts/text_box.dart';
import 'package:running_robot/obstacles/rain.dart';

// CHANGE: import the builder
import 'package:running_robot/scene_builder.dart';

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

  // CHANGE: feedback boxes (not created here per your current code)
  late final FancyTextBox resultCorrectBox; // not initialized here
  late final FancyTextBox resultWrongBox; // not initialized here

  late final LessonProgressBar progressBar;
  late final PauseButton pauseButton;
  late final Cloud cloudRain;
  late final List<Cloud> clouds = [];
  late final List<Rain> rainFall;
  late final Arrow arrowDown;
  late final McqBox mcqFirstRun;

  @override
  FutureOr<void> onLoad() async {
    // CHANGE: delegate creation to SceneBuilder
    final scene = await SceneBuilder(size).build();

    // Assign references exactly as before
    background = scene.background;
    ground = scene.ground;
    robot = scene.robot;
    barell = scene.barell;
    bird = scene.bird;
    introTextBox = scene.introTextBox;
    firstRunTextBox = scene.firstRunTextBox;
    progressBar = scene.progressBar;
    pauseButton = scene.pauseButton;
    cloudRain = scene.cloudRain;
    arrowDown = scene.arrowDown;
    mcqFirstRun = scene.mcqFirstRun;

    // Lists
    clouds.addAll(scene.clouds); // keep your existing list instance
    rainFall = scene.rainFall; // late final assignment

    // Add everything in the original order
    addAll(scene.components);

    //Start chain of Event
    handlePhase();
  }

  Future<void> handlePhase() async {
    switch (phase) {
      case GamePhase.intro:
        phase = GamePhase.waitingForSwipe;
        break;

      case GamePhase.waitingForSwipe:
        break;

      case GamePhase.fisrtRun:
        robot.switchPhase(EventRobot.resume);
        ground.switchPhase(EventHorizontalObstacle.startMoving);
        clouds.forEach(
          (x) => x.switchPhase(EventHorizontalObstacle.startMoving),
        );

        await Future.delayed(const Duration(seconds: 4));
        bird.switchPhase(EventHorizontalObstacle.startMoving);

        await Future.delayed(const Duration(seconds: 4));
        firstRunTextBox.switchPhase(EventText.showText);

        await Future.delayed(const Duration(seconds: 3));
        bird.switchPhase(EventHorizontalObstacle.stopMoving);

        await Future.delayed(const Duration(seconds: 5));
        cloudRain.switchPhase(EventHorizontalObstacle.startMoving);
        rainFall.forEach(
          (x) => x.switchPhase(EventVerticalObstacle.startFalling),
        );

        await Future.delayed(const Duration(seconds: 12));
        cloudRain.switchPhase(EventHorizontalObstacle.stopMoving);
        rainFall.forEach(
          (x) => x.switchPhase(EventVerticalObstacle.stopFalling),
        );

        barell.switchPhase(EventHorizontalObstacle.startMoving);

        await Future.delayed(const Duration(seconds: 4));
        robot.switchPhase(EventRobot.jump);

        await Future.delayed(const Duration(seconds: 4));
        barell.switchPhase(EventHorizontalObstacle.stopMoving);
        ground.switchPhase(EventHorizontalObstacle.stopMoving);

        await Future.delayed(const Duration(seconds: 3));
        clouds.forEach(
          (x) => x.switchPhase(EventHorizontalObstacle.stopMoving),
        );

        await Future.delayed(const Duration(seconds: 7));
        firstRunTextBox.switchPhase(EventText.hideText);
        // await Future.delayed(const Duration(seconds: 6));
        mcqFirstRun.switchPhase(EventHorizontalObstacle.startMoving);
        // mcqFirstRun.switchPhase(EventHorizontalObstacle.stopMoving);
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
