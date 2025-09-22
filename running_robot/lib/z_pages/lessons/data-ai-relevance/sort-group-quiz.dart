// FILE: lib/z_pages/lessons/data-ai-relevance/sort_group_quiz.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:running_robot/z_pages/assets/lessonAssets/drag_drop_game.dart';

/// 3-way classification using DragDropGame:
/// Group 1: Animals, Group 2: Emotions, Group 3: Vehicles
class SortGroupQuiz extends StatelessWidget {
  final VoidCallback onCompleted;
  final VoidCallback? onRestartRequested;

  const SortGroupQuiz({
    super.key,
    required this.onCompleted,
    this.onRestartRequested,
  });

  @override
  Widget build(BuildContext context) {
    // 3 baskets
    const baskets = <BasketSpec>[
      BasketSpec(key: 'animals', displayName: '1'),
      BasketSpec(key: 'emotions', displayName: '2'),
      BasketSpec(key: 'vehicles', displayName: '3'),
    ];

    // 12 emojis (scrambled)
    final tokens = <DragToken>[
      DragToken.classify(emoji: '🐶', targetBasketKey: 'animals'),
      DragToken.classify(emoji: '😀', targetBasketKey: 'emotions'),
      DragToken.classify(emoji: '🚗', targetBasketKey: 'vehicles'),
      DragToken.classify(emoji: '🐱', targetBasketKey: 'animals'),
      DragToken.classify(emoji: '😢', targetBasketKey: 'emotions'),
      DragToken.classify(emoji: '🚌', targetBasketKey: 'vehicles'),
      DragToken.classify(emoji: '🐼', targetBasketKey: 'animals'),
      DragToken.classify(emoji: '🤩', targetBasketKey: 'emotions'),
      DragToken.classify(emoji: '🚲', targetBasketKey: 'vehicles'),
      DragToken.classify(emoji: '🦊', targetBasketKey: 'animals'),
      DragToken.classify(emoji: '😡', targetBasketKey: 'emotions'),
      DragToken.classify(emoji: '✈️', targetBasketKey: 'vehicles'),
    ];

    // Title: bold + colored “corresponding group”
    const Color highlight = Color(0xFF1E88E5);
    final Widget title = Text.rich(
      TextSpan(
        style: GoogleFonts.lato(fontSize: 20, color: Colors.black87),
        children: [
          const TextSpan(text: 'Group all similar icons into their '),
          TextSpan(
            text: 'corresponding group',
            style: GoogleFonts.lato(
              fontSize: 20,
              fontWeight: FontWeight.w900,
              color: highlight,
            ),
          ),
        ],
      ),
      textAlign: TextAlign.center,
    );

    return DragDropGame(
      mode: DragDropMode.classify,
      baskets: baskets,
      tokens: tokens,
      basketTitlePrefix: 'Group', // → “Group 1”, “Group 2”, “Group 3”
      title: title,
      endCardBodyText: 'You correctly grouped all icons!',
      onCompleted: onCompleted,
      onRestartRequested: onRestartRequested, // ✅ reset hook
    );
  }
}
