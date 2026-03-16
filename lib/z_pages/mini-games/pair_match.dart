// FILE: pair_match.dart
import 'package:flutter/material.dart';
import 'drag_drop_game.dart';

/// PairMatch — legacy two-step pairing with staging inside baskets.
/// Use DragToken.pair(emoji, pairId). Usually 2 baskets.
class PairMatch extends DragDropGameBase {
  const PairMatch({
    super.key,
    required super.baskets,
    required super.tokens,
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
  State<PairMatch> createState() => _PairMatchState();
}

class _PairMatchState extends DragDropGameBaseState<PairMatch> {
  DragToken? _firstInPair;
  String? _firstBasketKey;

  @override
  bool canAccept(String basketKey, DragToken t) {
    // Base already enforces: in pool, basketTemporarilyAvailable (default: empty).
    // PairMatch accepts any token for staging when empty; second token is validated onAccept.
    return true;
  }

  @override
  void onAcceptToken(String basketKey, DragToken t) {
    // First token: stage it visibly (legacy behavior).
    if (_firstInPair == null) {
      _firstInPair = t;
      _firstBasketKey = basketKey;
      stageTokenInBasket(basketKey, t); // just visual staging; no success yet
      return;
    }

    // Can't drop onto the same basket (base would usually block; treat as wrong if it happens).
    if (_firstBasketKey == basketKey) {
      triggerWrong(basketKey);
      return;
    }

    final first = _firstInPair!;
    final bool isCorrectPair = (t.pairId != null &&
        first.pairId != null &&
        t.pairId == first.pairId &&
        t != first);

    if (isCorrectPair) {
      successConsumePair(
        firstBasketKey: _firstBasketKey!,
        first: first,
        secondBasketKey: basketKey,
        second: t,
      );
      // Clear local staging markers (visuals cleared by success helper).
      _firstInPair = null;
      _firstBasketKey = null;
    } else {
      triggerWrong(basketKey);
      // Keep the first staged so the user can try a different partner (legacy).
    }
  }

  @override
  void onSubclassReset() {
    _firstInPair = null;
    _firstBasketKey = null;
  }
}
