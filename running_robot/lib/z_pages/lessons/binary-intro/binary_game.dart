// FILE: lib/z_pages/lessons/lesson2/lesson2_6.dart
// ✅ LessonStepSix — Binary Pairs with end-of-step Analytics Overlay
// Now uses the split PairMatch widget (built on the abstract DragDropGameBase).

import 'package:flutter/material.dart';
import 'package:running_robot/z_pages/mini-games/drag_drop_game.dart';
import 'package:running_robot/z_pages/assets/lessonAssets/helpful_tools.dart';
import 'package:running_robot/z_pages/mini-games/pair_match.dart';
// PairMatch

const Color mainConceptColor = Color.fromARGB(255, 255, 109, 12);
const Color keyConceptGreen = Color.fromARGB(255, 0, 163, 54);

class BinaryDragDropGame extends StatelessWidget {
  /// Call this when ALL pairs are correctly matched and removed.
  final VoidCallback onCompleted;

  /// Parent can hide Continue when user restarts the round.
  final VoidCallback? onRestartRequested;

  const BinaryDragDropGame({
    super.key,
    required this.onCompleted,
    this.onRestartRequested,
  });

  @override
  Widget build(BuildContext context) {
    return PairMatch(
      // Exactly two baskets, labeled 0 and 1 like before
      baskets: const [
        BasketSpec(key: "0", displayName: "0"),
        BasketSpec(key: "1", displayName: "1"),
      ],
      // Same emoji pairs as the original lesson
      tokens: [
        DragToken.pair(emoji: "🙂", pairId: "faceA"),
        DragToken.pair(emoji: "🙁", pairId: "faceA"),
        DragToken.pair(emoji: "😃", pairId: "faceB"),
        DragToken.pair(emoji: "😢", pairId: "faceB"),
        DragToken.pair(emoji: "🌞", pairId: "celestial"),
        DragToken.pair(emoji: "🌚", pairId: "celestial"),
        DragToken.pair(emoji: "👍", pairId: "vote"),
        DragToken.pair(emoji: "👎", pairId: "vote"),
        DragToken.pair(emoji: "❤️", pairId: "love"),
        DragToken.pair(emoji: "💔", pairId: "love"),
      ],

      // ──────────────────────────────────────────────────────────
      // Title (identical wording & styling — the generic wraps it)
      // ──────────────────────────────────────────────────────────
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

      // End card body (header “Great work 🎉” is hardcoded in the base)
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

      // Labels exactly as before (override default “Correct Attempts”)
      labelTime: "Time taken",
      labelCorrectAttempts: "Correct Pairs",
      labelLongestStreak: "Longest Streak",
      labelIncorrectAttempts: "Incorrect Attempts",
      tryAgainLabel: "Try Again",

      // Basket title remains "Basket <label>"
      basketTitlePrefix: "Basket",

      // Callbacks preserved
      onCompleted: onCompleted,
      onRestartRequested: onRestartRequested,

      // Keep time string identical format (e.g., "51.3 s")
      timeValueBuilder: (sec) => "${sec.toStringAsFixed(1)} s",
    );
  }
}
