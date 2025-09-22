import 'package:flutter/material.dart';
import 'drag_drop_game.dart';

/// MiniClassifyGame — teaser version of classification.
/// Exactly 2 baskets; each shows two “given” emojis on the bottom row.
/// User must drag 2 more correct emojis into the two carved slots on top.
class MiniClassifyGame extends DragDropGameBase {
  final Map<String, String> categoryByBasket;
  final Map<String, List<String>> givenByBasket;

  const MiniClassifyGame({
    super.key,
    required super.baskets, // must be exactly 2
    required super.tokens, // include decoys; only 4 will be placed
    required this.categoryByBasket,
    required this.givenByBasket,
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
  }) : assert(baskets.length == 2, "MiniClassifyGame needs exactly 2 baskets");

  @override
  State<MiniClassifyGame> createState() => _MiniClassifyGameState();
}

class _MiniClassifyGameState extends DragDropGameBaseState<MiniClassifyGame> {
  // For each basket: the two filled top slots (0..1). Tokens are kept visible.
  final Map<String, List<DragToken>> _filledTop = <String, List<DragToken>>{};

  static const int _slotsPerBasket = 2;

  @override
  void initState() {
    super.initState();
    for (final b in widget.baskets) {
      _filledTop[b.key] = <DragToken>[];
    }
  }

  @override
  bool basketTemporarilyAvailable(String basketKey) {
    // Allow up to 2 tokens (top slots); no single-slot staging.
    return _filledTop[basketKey]!.length < _slotsPerBasket;
  }

  @override
  bool canAccept(String basketKey, DragToken t) {
    final cat = t.targetBasketKey;
    if (cat == null) return false;

    final expected = widget.categoryByBasket[basketKey];
    if (expected == null) return false;

    if (_filledTop[basketKey]!.length >= _slotsPerBasket) return false;

    if (cat != expected) return false;

    return poolContains(t);
  }

  @override
  void onAcceptToken(String basketKey, DragToken t) {
    if (!canAccept(basketKey, t)) {
      triggerWrong(basketKey);
      return;
    }
    _snapIntoSlot(basketKey, t);
  }

  void _snapIntoSlot(String basketKey, DragToken t) {
    bumpSuccessAndFlash(basketKey);

    _filledTop[basketKey]!.add(t); // keep visible in carved slot
    removeFromPool(t); // consume from pool

    if (_allSlotsFilled()) {
      // Drain the pool (decoys etc.) and finish.
      for (final token in widget.tokens) {
        removeFromPool(token);
      }
      maybeFinishIfDone();
    }
    setState(() {});
  }

  bool _allSlotsFilled() {
    int total = 0;
    for (final entry in _filledTop.values) {
      total += entry.length;
    }
    return total == widget.baskets.length * _slotsPerBasket;
  }

  @override
  Widget basketContent(String basketKey) {
    final filled = _filledTop[basketKey]!;
    final given = widget.givenByBasket[basketKey] ?? const <String>[];

    return _MiniBasketView(
      filledTop: filled.map((t) => t.emoji).toList(),
      givenBottom: given,
      // Use the base emoji tile for consistent styling; we’ll scale it inside
      // the slot to appear bigger with less padding.
      emojiTileBuilder: (e) => emojiTile(e),
    );
  }

  @override
  void onSubclassReset() {
    for (final k in _filledTop.keys) {
      _filledTop[k] = <DragToken>[];
    }
  }
}

/// Visual for a single mini basket:
/// - Top row: two "carved" dashed slots (show placed emojis in order).
/// - Bottom row: two given emojis already present.
/// Responsive & overflow-safe; icons and slots scaled up with tighter gaps.
class _MiniBasketView extends StatelessWidget {
  final List<String> filledTop; // length 0..2
  final List<String> givenBottom; // ideally length 2
  final Widget Function(String emoji) emojiTileBuilder;

  const _MiniBasketView({
    required this.filledTop,
    required this.givenBottom,
    required this.emojiTileBuilder,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, cts) {
        // Tighter spacing to make room for bigger content
        const double gap = 6.0;
        const double cushion = 2.0; // tiny breathing room to prevent clipping

        final double maxW = cts.maxWidth;
        final double maxH = cts.maxHeight;

        final double safeW = maxW.isFinite ? maxW : 160;
        final double safeH = maxH.isFinite ? maxH : 160;

        // Two rows (slots + given) and one vertical gap.
        // Two columns and one horizontal gap.
        final double slotFromHeight = (safeH - gap - cushion) / 2.0;
        final double slotFromWidth = (safeW - gap) / 2.0;

        // Allow a larger slot ceiling, but still respect the basket’s height.
        final double slot =
            (slotFromHeight < slotFromWidth ? slotFromHeight : slotFromWidth)
                .clamp(44.0, 64.0);

        // Scale the base emoji tile so it visually fills more of the slot
        // (less perceived padding) without changing the global styling.
        Widget fittedTile(String emoji) => SizedBox(
              width: slot,
              height: slot,
              child: FittedBox(
                fit: BoxFit.contain,
                child: Transform.scale(
                  scale: 1.18, // ↔ bigger icon vs. slot
                  child: emojiTileBuilder(emoji),
                ),
              ),
            );

        Widget slotView(int index) {
          if (index < filledTop.length) {
            return fittedTile(filledTop[index]);
          }
          return _DashedSlot(size: slot);
        }

        return Padding(
          // Tiny safety margin so bottom row never touches basket border.
          padding: const EdgeInsets.only(bottom: 2.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Top carved row (2 slots)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  slotView(0),
                  SizedBox(width: gap),
                  slotView(1),
                ],
              ),
              SizedBox(height: gap),
              // Bottom “given” row (2 emojis, not draggable)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  for (int i = 0; i < givenBottom.length && i < 2; i++) ...[
                    fittedTile(givenBottom[i]),
                    if (i == 0) SizedBox(width: gap),
                  ]
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

/// A dashed rounded-rect slot to suggest a carved-out space.
class _DashedSlot extends StatelessWidget {
  final double size;
  const _DashedSlot({required this.size});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size.square(size),
      painter: _DashedRectPainter(
        color: Colors.black38,
        radius: 12,
        dashLength: 7, // slightly longer to read better at larger size
        gapLength: 7,
        strokeWidth: 2,
      ),
    );
  }
}

class _DashedRectPainter extends CustomPainter {
  final Color color;
  final double radius;
  final double dashLength;
  final double gapLength;
  final double strokeWidth;

  _DashedRectPainter({
    required this.color,
    required this.radius,
    required this.dashLength,
    required this.gapLength,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rrect = RRect.fromRectAndRadius(
      Offset.zero & size,
      Radius.circular(radius),
    );

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    final path = Path()..addRRect(rrect);
    for (final metric in path.computeMetrics()) {
      double distance = 0.0;
      while (distance < metric.length) {
        final double next = (distance + dashLength).clamp(0, metric.length);
        final extract = metric.extractPath(distance, next);
        canvas.drawPath(extract, paint);
        distance += dashLength + gapLength;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DashedRectPainter old) =>
      old.color != color ||
      old.radius != radius ||
      old.dashLength != dashLength ||
      old.gapLength != gapLength ||
      old.strokeWidth != strokeWidth;
}
