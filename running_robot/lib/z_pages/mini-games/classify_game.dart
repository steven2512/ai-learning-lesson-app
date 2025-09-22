import 'package:flutter/material.dart';
import 'drag_drop_game.dart';

/// ClassifyGame — flexible category⇄basket binding on first drop.
/// Use DragToken.classify(emoji, targetBasketKey: <category>).
/// The first token dropped into a basket binds that basket to its category.
/// Tokens remain visible in the basket as an overlapping “pile”.
class ClassifyGame extends DragDropGameBase {
  const ClassifyGame({
    super.key,
    required super.baskets, // 1..4
    required super.tokens, // tokens with targetBasketKey = category
    super.titleText,
    super.title,
    super.endCardBodyText,
    super.endCardBody,
    super.labelTime,
    super.labelCorrectAttempts,
    super.labelLongestStreak,
    super.labelIncorrectAttempts,
    super.tryAgainLabel,
    super.basketTitlePrefix,
    super.basketTitleBuilder,
    super.timeValueBuilder,
    required super.onCompleted,
    super.onRestartRequested,
  });

  @override
  State<ClassifyGame> createState() => _ClassifyGameState();
}

class _ClassifyGameState extends DragDropGameBaseState<ClassifyGame> {
  // basketKey -> categoryKey
  final Map<String, String> _basketToCategory = {};
  // categoryKey -> basketKey
  final Map<String, String> _categoryToBasket = {};

  // Tokens kept visibly in each basket (pile/overlap).
  final Map<String, List<DragToken>> _keptByBasket = {};

  // Small deterministic offsets for a neat “pile” look.
  static const List<Offset> _pileOffsets = <Offset>[
    Offset(-8, -6),
    Offset(6, -4),
    Offset(-2, 6),
    Offset(10, 4),
    Offset(-10, 8),
    Offset(4, -10),
  ];

  @override
  bool basketTemporarilyAvailable(String basketKey) {
    // Allow multiple tokens per basket (we don’t use single-slot staging).
    return true;
  }

  @override
  bool canAccept(String basketKey, DragToken t) {
    final String? cat = t.targetBasketKey;
    if (cat == null) return false;

    final String? basketBoundCat = _basketToCategory[basketKey];
    final String? catBoundBasket = _categoryToBasket[cat];

    // If basket already bound to another category → reject
    if (basketBoundCat != null && basketBoundCat != cat) return false;

    // If category already bound to a different basket → reject
    if (catBoundBasket != null && catBoundBasket != basketKey) return false;

    // Otherwise allowed: either both unbound or already bound to each other.
    return true;
  }

  @override
  void onAcceptToken(String basketKey, DragToken t) {
    final String? cat = t.targetBasketKey;
    if (cat == null) {
      triggerWrong(basketKey);
      return;
    }

    final String? basketBoundCat = _basketToCategory[basketKey];
    final String? catBoundBasket = _categoryToBasket[cat];

    // Enforce mapping consistency
    if (basketBoundCat != null && basketBoundCat != cat) {
      triggerWrong(basketKey);
      return;
    }
    if (catBoundBasket != null && catBoundBasket != basketKey) {
      triggerWrong(basketKey);
      return;
    }

    // First-time binding if both unbound
    if (basketBoundCat == null && catBoundBasket == null) {
      _basketToCategory[basketKey] = cat;
      _categoryToBasket[cat] = basketKey;
    }

    // Visually keep token in a pile; bump stats & flash success.
    _placeAndKeep(basketKey, t);
  }

  void _placeAndKeep(String basketKey, DragToken t) {
    bumpSuccessAndFlash(basketKey);

    // Keep token visible inside the basket (pile).
    final list = _keptByBasket.putIfAbsent(basketKey, () => <DragToken>[]);
    list.add(t);

    // Remove from pool and check finish.
    removeFromPool(t);
    maybeFinishIfDone();
  }

  @override
  Widget basketContent(String basketKey) {
    final tokens = _keptByBasket[basketKey];
    if (tokens == null || tokens.isEmpty) return const SizedBox.shrink();

    // Overlapping pile, centered.
    return SizedBox(
      width: 120,
      height: 120,
      child: Stack(
        alignment: Alignment.center,
        children: [
          for (int i = 0; i < tokens.length; i++)
            Transform.translate(
              offset: _pileOffsets[i % _pileOffsets.length],
              child: emojiTile(tokens[i].emoji),
            ),
        ],
      ),
    );
  }

  @override
  void onSubclassReset() {
    _basketToCategory.clear();
    _categoryToBasket.clear();
    _keptByBasket.clear();
  }
}
