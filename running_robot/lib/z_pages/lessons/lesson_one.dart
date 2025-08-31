import 'dart:async';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flutter/material.dart' hide IconButton;
import 'package:running_robot/game/buttons/generic_button.dart';
import 'package:running_robot/game/events/event_type.dart';
import 'package:running_robot/game/obstacles/bird.dart';
import 'package:running_robot/game/obstacles/fence.dart';
import 'package:running_robot/game/decorations/progress_bar.dart';
import 'package:running_robot/game/obstacles/finger.dart' hide EventFinger;
import 'package:running_robot/game/texts/arrow.dart';
import 'package:running_robot/game/static/background.dart';
import 'package:running_robot/game/static/ground.dart';
import 'package:running_robot/game/obstacles/cloud.dart';
import 'package:running_robot/game/characters/robot.dart';
import 'package:running_robot/game/texts/mcq.dart';
import 'package:running_robot/game/texts/text_box.dart';
import 'package:running_robot/game/obstacles/rain.dart';
import 'package:running_robot/game/texts/lessons_text/lesson1_text.dart';
import 'package:running_robot/core/app_router.dart';
import 'package:running_robot/game/buttons/icon_button.dart';

enum GamePhase {
  intro,
  waitingForSwipe,
  fisrtRun,
  contemplation,
  tutorial,
  secondRun,
  finalExplanation,
  paused,
}

class LessonOne extends FlameGame with PanDetector, HasCollisionDetection {
  GamePhase phase = GamePhase.intro;
  int failCount = 0;

  bool colliedJumpObstacles = false;
  bool colliedRainObstacles = false;

  Vector2? dragStart;
  Vector2? dragLast;
  // In class LessonOne extends FlameGame ...
  @override
  Color backgroundColor() => const Color(0xFFFFFFFF);
  // ─────── Global component references ───────
  late final Background background;
  late final Ground ground;
  late final Robot robot;
  late final Fence barell;
  late final Bird bird;
  late final FancyTextBox introTextBox;
  late final FancyTextBox firstRunTextBox;
  late final IconButton returnButton;

  // Reserved (not initialized here per your current scaffolding)
  late final FancyTextBox resultCorrectBox;
  late final FancyTextBox resultWrongBox;

  late final LessonProgressBar progressBar;
  late final Cloud cloudRain;
  late List<Cloud> clouds = [];
  late final List<Rain> rainFall;
  late final Arrow arrowDown;
  late final McqBox mcqFirstRun;
  late final GenericButton<String> continueButton;
  late final Finger finger;
  final AppNavigate onNavigate;

  LessonOne({
    required this.onNavigate,
  });

  @override
  FutureOr<void> onLoad() async {
    // ──────────────────────────────────────────────────────────────
    // [CHANGED] SceneBuilder(build) → inline construction here
    // ──────────────────────────────────────────────────────────────
    final gameSize = size;

    ground = Ground(dimensions: Vector2(gameSize.x, gameSize.y));
    final double groundY = ground.topY;
    // Robot
    robot = Robot(
      initialPosition: Vector2(gameSize.x / 2, gameSize.y / 2),
      groundY: groundY,
    );

    // Fence (barrel)
    barell = Fence(
      initialPosition: Vector2(gameSize.x + 200, groundY - 28),
      picturePath: 'barrell_red.png',
      groundY: groundY,
      size: Vector2(50, 60),
      velocity: Vector2(-100, 0),
    );

    // Arrow
    arrowDown = Arrow(
      imageFile: 'down_arrow.png',
      position: Vector2(gameSize.x / 2 - 18, gameSize.y - 560),
      size: Vector2(35, 54),
    );

    // Bird
    bird = Bird(
      framePaths: ['bat.png', 'bat_hang.png', 'bat_fly.png'],
      startPosition: Vector2(gameSize.x + 100, 450),
      endPosition: Vector2(-100, 450),
      velocity: Vector2(-80, 0),
      customSize: Vector2(80, 50),
    );

    // Story text
    introTextBox = FancyTextBox(
      sequence: introText,
      interval: 4,
      fadeDuration: 0.5,
      position: Vector2(gameSize.x / 2, gameSize.y / 3),
      anchor: Anchor.center,
      fontSize: 25,
      letterSpacing: 0.5,
      fontWeight: FontWeight.w800,
      maxWidth: 350,
    );

    firstRunTextBox = FancyTextBox(
      sequence: firstRunText,
      durations: [3, 3, 3, 3, 5],
      intervals: [0, 3, 8, 4, 2],
      fadeDuration: 0.5,
      position: Vector2(gameSize.x / 2, gameSize.y / 3),
      anchor: Anchor.center,
      fontSize: 25,
      letterSpacing: 0.5,
      fontWeight: FontWeight.w800,
      maxWidth: 350,
    );

    // MCQ
    mcqFirstRun = McqBox(
      questions: ['Why do you think Robo failed?'],
      answers: [
        'Robo is not intelligent enough',
        'Robo has not learned this course',
      ],
      answerExplanations: [
        ['✅  Correct'],
        [
          "❌  Not exactly. \n⇒  Robo just hasn't been trained on this coure yet",
          "🤖  Even the smartest AI is blindly guessing without examples and feedback",
        ],
      ],
      correctAnswerIndex: 1,
      outerBoxSize: Vector2(320, 170),
      innerBoxSize: Vector2(255, 38),
      alignments: [
        'center',
        'center',
        'left',
      ], // question, answers, explanation
      padding: [
        18,
        17,
        10,
        16,
        16,
      ], // [topBottom, qToOptions, between, left, right]
      borderRadius: 24,
      anchor: Anchor.center,
      opacities: [0.7, 1.0, 1.0], // outer, inner, selected
      textColors: [Colors.white, Colors.white], // question, answer
      fillColors: [
        Colors.black, // outer
        const Color(0xFF757575), // inner
        const Color(0xFF00B530), // select correct
        const Color(0xFFE53935), // select wrong
      ],
      position: Vector2(gameSize.x / 2, gameSize.y - 600),
      textSizes: [20, 15],
      showDuration: 1,
      hideDuration: 0.5,
      explanationFontSize: 23,
      explanationFontWeight: FontWeight.w600,
      explanationFontStyle: FontStyle.italic,
      onClosePressed: () {
        continueButton.switchPhase(EventHorizontalObstacle.startMoving);
      },
    );

    // Clouds & rain
    cloudRain = Cloud(
      initialPosition: Vector2(gameSize.x + 300, 220),
      picturePath: 'cloud_grey.png',
      stretchY: 1.5,
      stretchX: 1.5,
      velocity: Vector2(-70, 0),
    );

    clouds = <Cloud>[
      Cloud(
        initialPosition: Vector2(gameSize.x + 150, 320),
        picturePath: 'cloud_shape4_4.png',
        stretchY: 0.7,
        velocity: Vector2(-100, 0),
        randomizeRest: true,
        opacity: 0.2,
      ),
      Cloud(
        initialPosition: Vector2(gameSize.x + 300, 360),
        picturePath: 'cloud_shape3_5.png',
        stretchY: 0.7,
        velocity: Vector2(-90, 0),
        randomizeRest: true,
        opacity: 0.3,
      ),
    ];

    rainFall = Rain.generateRain(
      count: 70,
      startAreaTopLeft: Vector2(gameSize.x / 3, 200),
      startAreaBottomRight: Vector2(gameSize.x * 2 / 3, 280),
      endPosition: Vector2(gameSize.x / 2, groundY),
      minSpeed: 150,
      maxSpeed: 300,
      cloud: cloudRain,
    );

    // UI
    progressBar = LessonProgressBar(
      position: Vector2(gameSize.x / 2, 70),
      stages: 3,
    );

    // [CHANGED] uses your new GenericButton signature
    continueButton = GenericButton<String>(
      position: Vector2(size.x / 2, size.y - 100),
      anchor: Anchor.center,
      buttonSize: Vector2(200, 56),
      padding: const [10, 16, 10, 16], // [top, left, bottom, right]
      content: 'Next Stage',
      boxColor: const Color.fromARGB(255, 0, 125, 226), // fill
      boxOpacity: 1,
      fontSize: 20,
      fontWeight: FontWeight.w600,
      fontColor: Colors.white,
      payload: 'next_phase',
      onPressed: (value) {
        // endLesson();
        endLesson();
      },
      borderRadius: 22,
    );

    returnButton = IconButton<void>(
      position: Vector2(40, 81),
      size: Vector2(22, 22),
      anchor: Anchor.center,
      iconPath: 'x_icon.png',
      tint: Colors.black87,
      onPressed: (_) => close(),
    )..show();

    finger = Finger(
      initialPosition: Vector2(size.x / 2 - 50, size.y / 2 + 80),
      picturePath: 'finger.png',
      size: Vector2(200, 200),
      speed: 100,
      cutoffs: [100, size.y, size.x - 100, 50], // [upY, downY, rightX, leftX]
    );

    // Draw order preserved
    addAll(<Component>[
      ground,
      progressBar,
      arrowDown,
      ...clouds,
      robot,
      cloudRain,
      ...rainFall,
      barell,
      bird,
      introTextBox,
      firstRunTextBox,
      mcqFirstRun,
      continueButton,
      returnButton,
      finger
    ]);

    // Kick off
    handlePhase();
  }

  void close() {
    onNavigate(RouteMainMenu());
  }

  void endLesson() {
    onNavigate(
      RouteEndLesson(
        xp: 82,
        streak: 1,
        progressPercent: 33, // 0..100
        stageProgress: [1, 3], // two filled out of three
        topText: 'Lesson Complete!',
        illustrationPath: 'blue_robot.png',
      ),
    );
  }

  Future<void> handlePhase() async {
    switch (phase) {
      case GamePhase.intro:
        // introTextBox.showText();
        // await Future.delayed(const Duration(seconds: 26));
        // arrowDown.switchPhase(EventHorizontalObstacle.startMoving);
        // await Future.delayed(const Duration(milliseconds: 3500));
        // arrowDown.switchPhase(EventHorizontalObstacle.stopMoving);
        // await Future.delayed(const Duration(seconds: 11));
        phase = GamePhase.waitingForSwipe;
        handlePhase();
        break;

      case GamePhase.waitingForSwipe:
        finger.switchPhase(EventFinger.show);
        finger.switchPhase(EventFinger.right);
        break;

      case GamePhase.fisrtRun:
        introTextBox.switchPhase(EventText.hideText);
        finger.switchPhase(EventFinger.hide);
        robot.switchPhase(EventRobot.resume);
        ground.switchPhase(EventHorizontalObstacle.startMoving);
        clouds.forEach(
          (x) => x.switchPhase(EventHorizontalObstacle.startMoving),
        );

        // await Future.delayed(const Duration(seconds: 4));
        // bird.switchPhase(EventHorizontalObstacle.startMoving);

        // await Future.delayed(const Duration(seconds: 4));
        // firstRunTextBox.switchPhase(EventText.showText);
        // ground.switchPhase(EventHorizontalObstacle.stopMoving);
        // clouds.forEach(
        //   (x) => x.switchPhase(EventHorizontalObstacle.stopMoving),
        // );
        // await Future.delayed(const Duration(seconds: 3));
        // bird.switchPhase(EventHorizontalObstacle.stopMoving);

        // ground.switchPhase(EventHorizontalObstacle.startMoving);
        // clouds.forEach(
        //   (x) => x.switchPhase(EventHorizontalObstacle.startMoving),
        // );

        // await Future.delayed(const Duration(seconds: 5));
        // cloudRain.switchPhase(EventHorizontalObstacle.startMoving);
        // rainFall.forEach(
        //   (x) => x.switchPhase(EventVerticalObstacle.startFalling),
        // );

        // await Future.delayed(const Duration(seconds: 12));
        // cloudRain.switchPhase(EventHorizontalObstacle.stopMoving);
        // rainFall.forEach(
        //   (x) => x.switchPhase(EventVerticalObstacle.stopFalling),
        // );

        barell.switchPhase(EventHorizontalObstacle.startMoving);

        await Future.delayed(const Duration(seconds: 2));
        robot.switchPhase(EventRobot.jump);

        await Future.delayed(const Duration(seconds: 4));
        barell.switchPhase(EventHorizontalObstacle.stopMoving);
        ground.switchPhase(EventHorizontalObstacle.stopMoving);

        await Future.delayed(const Duration(seconds: 3));
        clouds.forEach(
          (x) => x.switchPhase(EventHorizontalObstacle.stopMoving),
        );

        await Future.delayed(const Duration(seconds: 4));

        firstRunTextBox.switchPhase(EventText.hideText);
        await Future.delayed(const Duration(seconds: 2));
        mcqFirstRun.switchPhase(EventHorizontalObstacle.startMoving);
        // mcqFirstRun.switchPhase(EventHorizontalObstacle.stopMoving);
        break;

      case GamePhase.contemplation:
        break;

      case GamePhase.tutorial:
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
