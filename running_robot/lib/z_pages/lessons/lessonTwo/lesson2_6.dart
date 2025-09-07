import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:running_robot/z_pages/assets/lessonAssets/helpful_tools.dart';

const Color mainConceptColor = Color.fromARGB(255, 255, 109, 12);
const Color keyConceptGreen = Color.fromARGB(255, 0, 163, 54);

class LessonStepFive extends StatefulWidget {
  /// Call this when ALL pairs are correctly matched and removed.
  final VoidCallback onCompleted;
  const LessonStepFive({super.key, required this.onCompleted});

  @override
  State<LessonStepFive> createState() => _LessonStepFiveState();
}

class _LessonStepFiveState extends State<LessonStepFive>
    with TickerProviderStateMixin {
  /// Explicit two-emoji pairs via pairId (each pairId appears twice).
  static const List<_EmojiCard> seedCards = [
    _EmojiCard("🙂", "faceA"),
    _EmojiCard("🙁", "faceA"),
    _EmojiCard("😃", "faceB"),
    _EmojiCard("😢", "faceB"),
    _EmojiCard("🌞", "celestial"),
    _EmojiCard("🌚", "celestial"),
    _EmojiCard("👍", "vote"),
    _EmojiCard("👎", "vote"),
    _EmojiCard("❤️", "love"),
    _EmojiCard("💔", "love"),
  ];

  /// Remaining cards in the pool. Correct pairs get removed permanently.
  late final List<_EmojiCard> _pool;

  /// Each basket holds at most ONE emoji at a time.
  final Map<String, _EmojiCard?> _basket = {"0": null, "1": null};

  /// The first emoji placed (waiting for its opposite).
  _EmojiCard? _firstInPair;

  /// For polite success box below baskets
  bool _showFeedback = false;

  /// We reserve enough height for the emoji pool to keep baskets from moving.
  double? _reservedPoolHeight;

  /// Layout guesses for tile sizing/spacing (tuned for your _emojiTile).
  static const double _tileWidthGuess = 68; // approx width of a tile
  static const double _rowExtent = 76; // approx height per row (tile + spacing)
  static const double _spacing = 12; // Wrap spacing and runSpacing

  @override
  void initState() {
    super.initState();
    _pool = [...seedCards]..shuffle(Random());
  }

  @override
  Widget build(BuildContext context) {
    // Cards not currently sitting in a basket are shown in the pool.
    final poolCards = _pool.where((c) => !_basket.values.contains(c)).toList();

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20),

            // Title/instruction
            LessonText.box(
              margin: const EdgeInsets.only(bottom: 20),
              child: Center(
                child: Text(
                  "Put these icons in their correct binary pairs",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.lato(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                ),
              ),
            ),

            // Emoji pool without scrolling; height reserved to fit all rows at least once.
            LayoutBuilder(
              builder: (context, constraints) {
                final maxW = constraints.maxWidth;
                // How many tiles per row can we fit?
                final perRow = max(1,
                    ((maxW + _spacing) / (_tileWidthGuess + _spacing)).floor());
                final rowsNow = (poolCards.length + perRow - 1) ~/ perRow;
                final neededHeight = max(1, rowsNow) * _rowExtent;

                // Only ever grow the reserved height; never shrink (so baskets don't move up).
                if (_reservedPoolHeight == null ||
                    neededHeight > _reservedPoolHeight!) {
                  _reservedPoolHeight = neededHeight.toDouble();
                }

                return SizedBox(
                  height: _reservedPoolHeight!,
                  child: Wrap(
                    spacing: _spacing,
                    runSpacing: _spacing,
                    children: poolCards.map(_buildDraggable).toList(),
                  ),
                );
              },
            ),

            const SizedBox(height: 40),

            // Baskets — fixed apparent position because pool above has a reserved height
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildBasket("0"),
                _buildBasket("1"),
              ],
            ),

            const SizedBox(height: 12),

            // Polite success message BELOW baskets, using LessonText.* helpers
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: _showFeedback
                  ? KeyedSubtree(
                      key: const ValueKey("success-box"),
                      child: LessonText.box(
                        decoration: BoxDecoration(
                          color: Colors.green[50],
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                              color: Colors.green.shade400, width: 1),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 6,
                              offset: Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.check_circle,
                                color: Colors.green, size: 24),
                            const SizedBox(width: 8),
                            LessonText.sentence([
                              LessonText.word("That's", Colors.black87,
                                  fontSize: 18),
                              LessonText.word("correct!", keyConceptGreen,
                                  fontSize: 18, fontWeight: FontWeight.w800),
                            ]),
                          ],
                        ),
                      ),
                    )
                  : const SizedBox.shrink(),
            ),

            const SizedBox(height: 28),
          ],
        ),
      ),
    );
  }

  // ———————————————————————————————————————————————————————————
  // UI builders
  // ———————————————————————————————————————————————————————————

  Widget _buildDraggable(_EmojiCard card) {
    return Draggable<_EmojiCard>(
      data: card,
      feedback: _emojiTile(card.emoji, dragging: true),
      childWhenDragging: Opacity(opacity: 0.3, child: _emojiTile(card.emoji)),
      child: _emojiTile(card.emoji),
    );
  }

  Widget _emojiTile(String emoji, {bool dragging = false}) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: dragging ? Colors.orange[50] : Colors.white,
        border: Border.all(color: Colors.black26, width: 2),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          if (!dragging)
            const BoxShadow(
              color: Colors.black12,
              blurRadius: 4,
              offset: Offset(2, 2),
            ),
        ],
      ),
      child: Text(emoji, style: const TextStyle(fontSize: 32)),
    );
  }

  Widget _buildBasket(String label) {
    return DragTarget<_EmojiCard>(
      onWillAccept: (card) {
        // Only accept if this basket is empty and the card is still in the pool (not already used).
        return _basket[label] == null && card != null && _pool.contains(card);
      },
      onAccept: (card) {
        setState(() {
          // FIRST DROP — anything goes, anywhere.
          if (_firstInPair == null) {
            _basket[label] = card;
            _firstInPair = card;
            _showFeedback = false; // clear any old message
            return;
          }

          // If user tries to drop into a non-empty basket, reject with shake (guard).
          if (_basket[label] != null) {
            _shake();
            return;
          }

          // SECOND DROP — must be the opposite (same pairId, different emoji), in the other (empty) basket.
          final first = _firstInPair!;
          final isCorrectPair =
              (card.pairId == first.pairId) && (card != first);

          if (isCorrectPair) {
            _basket[label] = card;
            _showFeedback = true;

            // Remove both from the game after a short beat and reset baskets.
            Future.delayed(const Duration(milliseconds: 800), () {
              setState(() {
                _pool.remove(first);
                _pool.remove(card);
                _basket["0"] = null;
                _basket["1"] = null;
                _firstInPair = null;
              });

              // Hide the success box after a moment
              Future.delayed(const Duration(milliseconds: 300), () {
                if (mounted) setState(() => _showFeedback = false);
              });

              // Game finished?
              if (_pool.isEmpty) {
                widget.onCompleted(); // tells parent to enable Continue
              }
            });
          } else {
            // Wrong opposite → soft shake, keep first in its basket, this card returns to pool.
            _shake();
          }
        });
      },
      builder: (context, candidate, rejected) {
        return Container(
          width: 140,
          height: 180,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(60),
              bottom: Radius.circular(20),
            ),
            border: Border.all(color: Colors.black54, width: 2),
          ),
          child: Column(
            children: [
              Text(
                "Basket $label",
                style: GoogleFonts.lato(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: label == "0" ? Colors.blue : Colors.red,
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: Center(
                  child: _basket[label] == null
                      ? const SizedBox.shrink()
                      : _emojiTile(_basket[label]!.emoji),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ———————————————————————————————————————————————————————————
  // Effects
  // ———————————————————————————————————————————————————————————

  void _shake() {
    final controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 250));
    final animation = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(0.06, 0),
    ).chain(CurveTween(curve: Curves.elasticIn)).animate(controller);

    final overlay = OverlayEntry(
      builder: (_) => Positioned.fill(
        child: IgnorePointer(
          ignoring: true,
          child: SlideTransition(
            position: animation,
            child: Container(color: Colors.transparent),
          ),
        ),
      ),
    );

    Overlay.of(context).insert(overlay);
    controller.forward().whenComplete(() {
      overlay.remove();
      controller.dispose();
    });
  }
}

class _EmojiCard {
  final String emoji;
  final String pairId;
  const _EmojiCard(this.emoji, this.pairId);
}
