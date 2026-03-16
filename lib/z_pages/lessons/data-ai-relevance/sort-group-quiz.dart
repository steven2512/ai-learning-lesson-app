// FILE: lib/z_pages/lessons/data-ai-relevance/sort_group_quiz.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:running_robot/z_pages/mini-games/mini_classify_game.dart';
import 'package:running_robot/z_pages/mini-games/drag_drop_game.dart';

/// Teaser mini version: 2 baskets with carved top slots and prefilled bottoms.
/// Categories (fixed here): Group 1 = animals, Group 2 = vehicles.
/// User only needs to place 2 + 2 correct tokens; the rest are decoys.
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
    // Exactly 2 baskets (display labels “1” and “2”)
    const baskets = <BasketSpec>[
      BasketSpec(key: 'g1', displayName: '1'),
      BasketSpec(key: 'g2', displayName: '2'),
    ];

    // 10 tokens total: 4 correct (2 animals, 2 vehicles) + 6 decoys.
    final tokens = <DragToken>[
      // ✅ animals (targets for g1)
      DragToken.classify(emoji: '🐶', targetBasketKey: 'animals'),
      DragToken.classify(emoji: '🐱', targetBasketKey: 'animals'),
      // ✅ vehicles (targets for g2)
      DragToken.classify(emoji: '✈️', targetBasketKey: 'vehicles'),
      DragToken.classify(emoji: '🚗', targetBasketKey: 'vehicles'),

      // ❌ decoys (other categories)
      DragToken.classify(emoji: '🤩', targetBasketKey: 'emotions'),
      DragToken.classify(emoji: '😡', targetBasketKey: 'emotions'),
      DragToken.classify(emoji: '🌞', targetBasketKey: 'celestial'),
      DragToken.classify(emoji: '🌚', targetBasketKey: 'celestial'),
    ];

    // Fixed mapping: which category each basket represents.
    const categoryByBasket = <String, String>{
      'g1': 'animals',
      'g2': 'vehicles',
    };

    // Prefilled “given” emojis at the bottom of each basket (not draggable).
    const givenByBasket = <String, List<String>>{
      'g1': ['🐼', '🦊'], // animals
      'g2': ['🚌', '🚲'], // vehicles
    };

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

    return MiniClassifyGame(
      baskets: baskets,
      tokens: tokens,
      categoryByBasket: categoryByBasket,
      givenByBasket: givenByBasket,
      basketTitlePrefix: 'Group', // → “Group 1”, “Group 2”
      title: title,
      endCardBodyText: 'AI is excellent at grouping tasks like these!',
      onCompleted: onCompleted,
      onRestartRequested: onRestartRequested, // ✅ reset hook
    );
  }
}
