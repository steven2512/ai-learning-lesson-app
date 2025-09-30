// FILE: lib/z_pages/lessons/lesson2/lesson2_6.dart
// ✅ LessonStepSix — Binary Pairs with end-of-step Analytics Overlay
// Uses PairMatch with scrambled tokens.

import 'package:flutter/material.dart';
import 'package:running_robot/core/widgets.dart';
import 'package:running_robot/z_pages/mini-games/drag_drop_game.dart';
import 'package:running_robot/z_pages/assets/lessonAssets/helpful_tools.dart';
import 'package:running_robot/z_pages/mini-games/pair_match.dart';

const Color mainConceptColor = Color.fromARGB(255, 255, 109, 12);
const Color keyConceptGreen = Color.fromARGB(255, 0, 163, 54);

class BinaryDragDropGame extends StatelessWidget {
  final VoidCallback onCompleted;
  final VoidCallback? onRestartRequested;

  const BinaryDragDropGame({
    super.key,
    required this.onCompleted,
    this.onRestartRequested,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = ScreenSize.category == ScreenCategory.large
        ? [
            // ✅ All 6 pairs (12 emojis)
            DragToken.pair(emoji: "🙂", pairId: "face"),
            DragToken.pair(emoji: "🙁", pairId: "face"),

            DragToken.pair(emoji: "🔒", pairId: "lock"),
            DragToken.pair(emoji: "🔓", pairId: "lock"),

            DragToken.pair(emoji: "🌚", pairId: "celestial"),
            DragToken.pair(emoji: "🌞", pairId: "celestial"),

            DragToken.pair(emoji: "👎", pairId: "vote"),
            DragToken.pair(emoji: "👍", pairId: "vote"),

            DragToken.pair(emoji: "💔", pairId: "love"),
            DragToken.pair(emoji: "❤️", pairId: "love"),

            DragToken.pair(emoji: "❌", pairId: "check"),
            DragToken.pair(emoji: "✅", pairId: "check"),
          ]
        : [
            // ✅ Only 4 pairs (8 emojis total)
            DragToken.pair(emoji: "🙂", pairId: "face"),
            DragToken.pair(emoji: "🙁", pairId: "face"),

            DragToken.pair(emoji: "🔒", pairId: "lock"),
            DragToken.pair(emoji: "🔓", pairId: "lock"),

            DragToken.pair(emoji: "👎", pairId: "vote"),
            DragToken.pair(emoji: "👍", pairId: "vote"),

            DragToken.pair(emoji: "❌", pairId: "check"),
            DragToken.pair(emoji: "✅", pairId: "check"),
          ];

    return PairMatch(
      baskets: const [
        BasketSpec(key: "0", displayName: "0"),
        BasketSpec(key: "1", displayName: "1"),
      ],
      tokens: tokens,
      title: LessonText.sentence(
        alignment: WrapAlignment.center,
        [
          LessonText.word("Put", Colors.black87, fontSize: 20),
          LessonText.word("these", Colors.black87, fontSize: 20),
          LessonText.word("icons", Colors.black87, fontSize: 20),
          LessonText.word("in", Colors.black87, fontSize: 20),
          LessonText.word("their", Colors.black87, fontSize: 20),
          LessonText.word("correct", Colors.black87, fontSize: 20),
          LessonText.word("binary", keyConceptGreen,
              fontSize: 20, fontWeight: FontWeight.w800),
          LessonText.word("pairs", keyConceptGreen,
              fontSize: 20, fontWeight: FontWeight.w800),
        ],
      ),
      endCardBody: LessonText.sentence([
        LessonText.word("You", Colors.black87, fontSize: 18),
        LessonText.word("chose", Colors.black87, fontSize: 18),
        LessonText.word("all", Colors.black87, fontSize: 18),
        LessonText.word("correct", keyConceptGreen,
            fontSize: 18, fontWeight: FontWeight.w800),
        LessonText.word("binary", mainConceptColor,
            fontSize: 18, fontWeight: FontWeight.w800),
        LessonText.word("pairs!", Colors.black87, fontSize: 18),
      ]),
      labelTime: "Time taken",
      labelCorrectAttempts: "Correct Pairs",
      labelLongestStreak: "Longest Streak",
      labelIncorrectAttempts: "Incorrect Attempts",
      tryAgainLabel: "Try Again",
      basketTitlePrefix: "Basket",
      onCompleted: onCompleted,
      onRestartRequested: onRestartRequested,
      timeValueBuilder: (sec) => "${sec.toStringAsFixed(1)} s",
    );
  }
}
