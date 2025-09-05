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
  final VoidCallback onRepeat; // kept, not used here but part of API
  final VoidCallback onNext;
  final VoidCallback onMainMenu;

  // ---- Inputs ----
  final int xp; // left box
  final int streak; // right box
  final int chapterProgress; // e.g. 3
  final int totalChapterLessons; // e.g. 10   => shows "3/10"
  final String topText; // headline
  final String? illustrationPath; // optional asset
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
    required this.progressBar, // 🔹 passed-in bar
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

    // -------- Illustration (optional) --------
    if (illustrationPath != null && illustrationPath!.isNotEmpty) {
      final sprite = await Sprite.load(illustrationPath!);
      add(
        SpriteComponent(
          sprite: sprite,
          size: Vector2.all(400),
          position: Vector2(size.x / 2, 360),
          anchor: Anchor.center,
        ),
      );
    }

    // -------- Progress bar (NO animation; use prebuilt) --------
    // We just position and add the passed-in bar.
    progressBar.position = Vector2(size.x / 2, 70);
    // If your bar supports anchor, uncomment the next line:
    // progressBar.anchor = Anchor.center;
    add(progressBar);

    // -------- Three FancyBoxes (layout fixed) --------
    final Vector2 boxSize = Vector2(110, 96);
    const double preferredGap = 18.0;
    const double sideMargin = 24.0;
    final double y = size.y / 2 + 110;

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
      position: Vector2(firstCenterX, y),
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
      position: Vector2(secondCenterX, y),
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
      position: Vector2(thirdCenterX, y),
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

    // Draw order
    add(nextLessonButton);
    add(returnButton);
    addAll([xpBox, progressBox, streakBox]);
    add(textBox);
  }
}
