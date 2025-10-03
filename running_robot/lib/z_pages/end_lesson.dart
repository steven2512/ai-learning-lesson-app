import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/sprite.dart';
import 'package:flutter/material.dart' hide IconButton;

import 'package:running_robot/game/decorations/fancy_box.dart';
import 'package:running_robot/game/decorations/progress_bar.dart';
import 'package:running_robot/game/events/event_type.dart';
import 'package:running_robot/game/buttons/generic_button.dart';
import 'package:running_robot/game/buttons/icon_button.dart';
import 'package:running_robot/game/texts/text_box.dart';

/// EndLessonPage
/// Renders a pre-built (final) LessonProgressBar passed via constructor.
class EndLessonPage extends FlameGame {
  // ---- Callbacks ----
  final VoidCallback onRepeat; // kept for API parity
  final VoidCallback onNext;
  final VoidCallback onMainMenu;

  // ---- Inputs ----
  final int xp; // left box
  final int streak; // right box
  final int chapterProgress; // e.g. 3
  final int totalChapterLessons; // e.g. 10   => shows "3/10"
  final String topText; // headline
  final String?
      illustrationPath; // optional extra asset (kept for compatibility)
  final LessonProgressBar progressBar; // 🔹 final task bar to display

  // ---- Internals ----
  late GenericButton nextLessonButton;
  late IconButton returnButton;
  late FancyTextBox textBox;

  EndLessonPage({
    required this.onRepeat,
    required this.onNext,
    required this.onMainMenu,
    required this.xp,
    required this.streak,
    required this.chapterProgress,
    required this.totalChapterLessons,
    required this.topText,
    required this.progressBar,
    this.illustrationPath,
  });

  @override
  Color backgroundColor() => const Color(0xFFFFFFFF);

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // -------- Next button --------
    nextLessonButton = GenericButton(
      position: Vector2(size.x / 2, size.y - 80),
      anchor: Anchor.center,
      buttonSize: Vector2(350, 60),
      padding: const [5, 10, 5, 10],
      content: "Next Lesson",
      boxColor: const Color.fromARGB(255, 136, 32, 255),
      boxOpacity: 1,
      fontSize: 22,
      fontWeight: FontWeight.w800,
      fontColor: Colors.white,
      borderRadius: 30,
      onPressed: (_) => onNext(),
    )..switchPhase(EventHorizontalObstacle.startMoving);

    // -------- Close/X button --------
    returnButton = IconButton<void>(
      position: Vector2(40, 81),
      size: Vector2(30, 25),
      anchor: Anchor.center,
      iconPath: 'x_icon.png',
      tint: Colors.black87,
      onPressed: (_) => onMainMenu(),
    )..show();

    // -------- Top text --------
    textBox = FancyTextBox(
      position: Vector2(size.x / 2, 200),
      anchor: Anchor.center,
      sequence: [topText],
      fadeDuration: 0,
      fontSize: 30,
      letterSpacing: 0.5,
      fontWeight: FontWeight.w700,
      maxWidth: 300,
    )..switchPhase(EventText.showText);

    // -------- Progress bar (NO animation; use prebuilt) --------
    progressBar.position = Vector2(size.x / 2, 70);
    add(progressBar);

    // ---- Layout knobs for robot & spacing ----
    const double gapUnderTitle = 24.0; // space between title and robot
    const double gapBelowRobot = 15.0; // space between robot and boxes
    const double robotSideMargin = 32.0; // keeps robot away from screen edges

    // -------- Blue robot illustration (bigger, centered) --------
    // We size the robot generously while fitting within both width & height caps.
    // Then we anchor the boxes relative to the robot’s bottom + a clean gap.
    double robotW = 0, robotH = 0;
    double robotCenterY = 0;

    try {
      final robot = await Sprite.load('blue_robot.png');
      final Vector2 src = robot.srcSize;
      final double aspect = (src.y == 0) ? 1.0 : (src.x / src.y);

      // Generous max sizes to make it feel big:
      final double maxRobotW =
          (size.x - 2 * robotSideMargin).clamp(260.0, 9999.0);
      final double maxRobotH = (size.y * 0.33).clamp(180.0, 360.0);

      // Fit within both constraints while preserving aspect ratio.
      if (maxRobotW / aspect <= maxRobotH) {
        robotW = maxRobotW;
        robotH = robotW / aspect;
      } else {
        robotH = maxRobotH;
        robotW = robotH * aspect;
      }

      // Place the robot below the title with a consistent gap.
      final double topTextY = textBox.position.y; // 200
      final double robotTop = topTextY + gapUnderTitle;
      robotCenterY = robotTop + robotH / 2;

      add(
        SpriteComponent(
          sprite: robot,
          size: Vector2(robotW, robotH),
          position: Vector2(size.x / 2, robotCenterY),
          anchor: Anchor.center,
        ),
      );
    } catch (_) {
      // If the asset can't be loaded, fall back to old layout numbers
      // so nothing crashes.
      final double topTextY = textBox.position.y;
      robotH = 0;
      robotCenterY = topTextY; // boxes will compute below
    }

    // -------- Three FancyBoxes (row positioned under the robot) --------
    final Vector2 boxSize = Vector2(110, 96);
    const double preferredGap = 18.0;
    const double sideMargin = 24.0;

    // Center line for the row of boxes:
    final double boxesY =
        (robotCenterY + robotH / 2) + gapBelowRobot + (boxSize.y / 2);

    double gap = preferredGap;
    final double maxRowWidth = size.x - 2 * sideMargin;
    double rowWidth = boxSize.x * 3 + gap * 2;
    if (rowWidth > maxRowWidth) {
      gap = ((maxRowWidth - boxSize.x * 3) / 2).clamp(8.0, preferredGap);
      rowWidth = boxSize.x * 3 + gap * 2;
    }
    final double firstCenterX = size.x / 2 - rowWidth / 2 + boxSize.x / 2;
    final double secondCenterX = firstCenterX + boxSize.x + gap;
    final double thirdCenterX = secondCenterX + boxSize.x + gap;

    // LEFT: TOTAL XP
    final xpBox = FancyBox(
      position: Vector2(firstCenterX, boxesY),
      anchor: Anchor.center,
      boxSize: boxSize,
      titleText: 'Total XP',
      mainContent: '$xp',
      fillColors: [Colors.orange, Colors.orange.shade300, Colors.orange],
      fontSizes: const [12, 24, 24],
      fontColors: [Colors.white, Colors.black87, Colors.orange],
      bannerTextAnchor: Anchor.center,
      insideTextAnchor: Anchor.center,
      iconData: Icons.local_fire_department,
      borderThickness: 2.0,
      borderRadius: 16.0,
      letterSpacing: 0.2,
    )..switchPhase(EventHorizontalObstacle.startMoving);

    // MIDDLE: CHAPTER PROGRESS (X / Y)
    final progressBox = FancyBox(
      position: Vector2(secondCenterX, boxesY),
      anchor: Anchor.center,
      boxSize: boxSize,
      titleText: 'Progress',
      mainContent:
          '${chapterProgress.clamp(0, totalChapterLessons)}/$totalChapterLessons',
      fillColors: const [
        Color.fromARGB(255, 25, 179, 20),
        Color.fromARGB(255, 25, 179, 20),
        Color.fromARGB(255, 25, 179, 20),
      ],
      fontSizes: const [12, 24, 24],
      fontColors: const [
        Colors.white,
        Colors.black87,
        Color.fromARGB(255, 10, 240, 2),
      ],
      bannerTextAnchor: Anchor.center,
      insideTextAnchor: Anchor.center,
      iconData: Icons.track_changes,
      borderThickness: 2.0,
      borderRadius: 16.0,
      letterSpacing: 0.2,
    )..switchPhase(EventHorizontalObstacle.startMoving);

    // RIGHT: DAILY STREAK
    final streakBox = FancyBox(
      position: Vector2(thirdCenterX, boxesY),
      anchor: Anchor.center,
      boxSize: boxSize,
      titleText: 'Streak',
      mainContent: '$streak',
      fillColors: const [
        Color.fromARGB(255, 0, 157, 255),
        Color.fromARGB(255, 0, 85, 255),
        Color.fromARGB(255, 0, 157, 255),
      ],
      fontSizes: const [12, 24, 24],
      fontColors: const [
        Colors.white,
        Colors.black87,
        Color.fromARGB(255, 0, 60, 255),
      ],
      bannerTextAnchor: Anchor.center,
      insideTextAnchor: Anchor.center,
      iconData: Icons.bolt_rounded,
      borderThickness: 2.0,
      borderRadius: 16.0,
      letterSpacing: 0.2,
    )..switchPhase(EventHorizontalObstacle.startMoving);

    // -------- Optional extra illustration (kept for compatibility) --------
    if (illustrationPath != null && illustrationPath!.isNotEmpty) {
      try {
        final sprite = await Sprite.load(illustrationPath!);
        add(
          SpriteComponent(
            sprite: sprite,
            size: Vector2.all(400),
            position: Vector2(size.x / 2, boxesY - 140),
            anchor: Anchor.center,
          ),
        );
      } catch (_) {/* ignore */}
    }

    // -------- Draw order --------
    // Robot is added earlier; boxes are added after it (so if overlap happens,
    // boxes render on top). Text and bar remain independent.
    add(nextLessonButton);
    add(returnButton);
    addAll([xpBox, progressBox, streakBox]);
    add(textBox);
  }
}
