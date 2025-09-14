import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:running_robot/z_pages/assets/lessonAssets/helpful_tools.dart';

const Color mainConceptColor = Color.fromARGB(255, 255, 109, 12);
const Color keyConceptGreen = Color.fromARGB(255, 0, 163, 54);

class LessonStepSix extends StatefulWidget {
  /// Call this when ALL pairs are correctly matched and removed.
  final VoidCallback onCompleted;
  const LessonStepSix({super.key, required this.onCompleted});

  @override
  State<LessonStepSix> createState() => _LessonStepSixState();
}

enum _Feedback { none, success, error }

class _LessonStepSixState extends State<LessonStepSix>
    with TickerProviderStateMixin {
  static const double _narrowMaxWidth = 350;
  static const double _finalOverlayAlignY = -0.2;

  static const Duration dShake = Duration(milliseconds: 260);
  static const Duration dInlineFeedbackFade = Duration(milliseconds: 220);
  static const Duration dAfterPairBeforeRemove = Duration(milliseconds: 800);
  static const Duration dHidePerPairSuccess = Duration(milliseconds: 400);
  static const Duration dErrorFlash = Duration(milliseconds: 350);
  static const Duration dErrorAutoHide = Duration(milliseconds: 900);
  static const Duration dDelayBeforeFinalOverlay = Duration(milliseconds: 250);
  static const Duration dFinalOverlayFade = Duration(milliseconds: 380);

  static const double _tileWidthGuess = 68;
  static const double _rowExtent = 76;
  static const double _spacing = 12;

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

  late final List<_EmojiCard> _pool;
  final Map<String, _EmojiCard?> _basket = {"0": null, "1": null};
  _EmojiCard? _firstInPair;

  _Feedback _feedback = _Feedback.none;
  bool _completed = false;

  double _overlayOpacity = 0;
  double? _reservedPoolHeight;

  late final AnimationController _shakeCtrl0;
  late final AnimationController _shakeCtrl1;
  late final Animation<Offset> _shakeAnim0;
  late final Animation<Offset> _shakeAnim1;
  bool _flash0 = false;
  bool _flash1 = false;

  @override
  void initState() {
    super.initState();
    _pool = [...seedCards]..shuffle(Random());

    _shakeCtrl0 = AnimationController(vsync: this, duration: dShake);
    _shakeCtrl1 = AnimationController(vsync: this, duration: dShake);

    final shakeTween = TweenSequence<Offset>([
      TweenSequenceItem(
        tween: Tween(begin: Offset.zero, end: const Offset(0.07, 0)),
        weight: 1,
      ),
      TweenSequenceItem(
        tween: Tween(begin: const Offset(0.07, 0), end: const Offset(-0.07, 0)),
        weight: 1,
      ),
      TweenSequenceItem(
        tween: Tween(begin: const Offset(-0.07, 0), end: Offset.zero),
        weight: 1,
      ),
    ]);

    _shakeAnim0 = shakeTween
        .animate(CurvedAnimation(parent: _shakeCtrl0, curve: Curves.easeInOut));
    _shakeAnim1 = shakeTween
        .animate(CurvedAnimation(parent: _shakeCtrl1, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _shakeCtrl0.dispose();
    _shakeCtrl1.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final poolCards = _pool.where((c) => !_basket.values.contains(c)).toList();

    return Stack(
      children: [
        SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 20),

                // ✅ Title box with green "binary pairs"
                Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 330),
                    child: LessonText.box(
                      margin: const EdgeInsets.only(bottom: 20),
                      padding: const EdgeInsets.symmetric(
                          vertical: 14, horizontal: 10),
                      child: Center(
                        child: LessonText.sentence(
                          alignment: WrapAlignment.center,
                          [
                            LessonText.word("Put", Colors.black87,
                                fontSize: 20),
                            LessonText.word("these", Colors.black87,
                                fontSize: 20),
                            LessonText.word("icons", Colors.black87,
                                fontSize: 20),
                            LessonText.word("in", Colors.black87, fontSize: 20),
                            LessonText.word("their", Colors.black87,
                                fontSize: 20),
                            LessonText.word("correct", Colors.black87,
                                fontSize: 20),
                            LessonText.word("binary", keyConceptGreen,
                                fontSize: 20, fontWeight: FontWeight.w800),
                            LessonText.word("pairs", keyConceptGreen,
                                fontSize: 20, fontWeight: FontWeight.w800),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                // Pool (fixed height)
                LayoutBuilder(
                  builder: (context, constraints) {
                    final maxW = constraints.maxWidth;
                    final perRow = max(
                      1,
                      ((maxW + _spacing) / (_tileWidthGuess + _spacing))
                          .floor(),
                    );
                    final rowsNow = (poolCards.length + perRow - 1) ~/ perRow;
                    final neededHeight = max(1, rowsNow) * _rowExtent;

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

                const SizedBox(height: 70),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildBasket("0"),
                    _buildBasket("1"),
                  ],
                ),

                const SizedBox(height: 12),

                if (!_completed)
                  AnimatedSwitcher(
                    duration: dInlineFeedbackFade,
                    switchInCurve: Curves.easeOut,
                    switchOutCurve: Curves.easeIn,
                    child: _buildInlineFeedback(),
                  ),

                const SizedBox(height: 28),
              ],
            ),
          ),
        ),
        if (_completed)
          Positioned.fill(
            child: IgnorePointer(
              ignoring: false,
              child: Align(
                alignment: Alignment(0, _finalOverlayAlignY),
                child: AnimatedOpacity(
                  opacity: _overlayOpacity,
                  duration: dFinalOverlayFade,
                  curve: Curves.easeOut,
                  child: SizedBox(
                    width: _narrowMaxWidth,
                    child: LessonText.box(
                      decoration: BoxDecoration(
                        color: Colors.green[50],
                        borderRadius: BorderRadius.circular(16),
                        border:
                            Border.all(color: Colors.green.shade400, width: 1),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 6,
                            offset: Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          LessonText.sentence([
                            LessonText.word("Great", Colors.black87,
                                fontSize: 20),
                            LessonText.word("work", keyConceptGreen,
                                fontSize: 20, fontWeight: FontWeight.w800),
                            LessonText.word("🎉", Colors.black87, fontSize: 20),
                          ]),
                          const SizedBox(height: 6),
                          LessonText.sentence([
                            LessonText.word("You", Colors.black87,
                                fontSize: 18),
                            LessonText.word("chose", Colors.black87,
                                fontSize: 18),
                            LessonText.word("all", Colors.black87,
                                fontSize: 18),
                            LessonText.word("correct", keyConceptGreen,
                                fontSize: 18, fontWeight: FontWeight.w800),
                            LessonText.word("binary", mainConceptColor,
                                fontSize: 18, fontWeight: FontWeight.w800),
                            LessonText.word("pairs!", Colors.black87,
                                fontSize: 18),
                          ]),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildInlineFeedback() {
    if (_feedback == _Feedback.success) {
      return KeyedSubtree(
        key: const ValueKey("pair-success"),
        child: Center(
          child: SizedBox(
            width: _narrowMaxWidth,
            child: LessonText.box(
              decoration: BoxDecoration(
                color: Colors.green[50],
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.green.shade400, width: 1),
                boxShadow: const [
                  BoxShadow(
                      color: Colors.black12,
                      blurRadius: 6,
                      offset: Offset(0, 3)),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.check_circle, color: Colors.green, size: 24),
                  const SizedBox(width: 8),
                  LessonText.sentence([
                    LessonText.word("That's", Colors.black87, fontSize: 18),
                    LessonText.word("correct!", keyConceptGreen,
                        fontSize: 18, fontWeight: FontWeight.w800),
                  ]),
                ],
              ),
            ),
          ),
        ),
      );
    } else if (_feedback == _Feedback.error) {
      return KeyedSubtree(
        key: const ValueKey("error"),
        child: Center(
          child: SizedBox(
            width: _narrowMaxWidth,
            child: LessonText.box(
              decoration: BoxDecoration(
                color: Colors.red[50],
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.red.shade400, width: 1),
                boxShadow: const [
                  BoxShadow(
                      color: Colors.black12,
                      blurRadius: 6,
                      offset: Offset(0, 3)),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.close_rounded, color: Colors.red, size: 24),
                  const SizedBox(width: 8),
                  LessonText.sentence([
                    LessonText.word("Try", Colors.black87, fontSize: 18),
                    LessonText.word("again!", Colors.red,
                        fontSize: 18, fontWeight: FontWeight.w800),
                  ]),
                ],
              ),
            ),
          ),
        ),
      );
    }
    return const SizedBox.shrink();
  }

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
    final isZero = label == "0";
    final slideAnim = isZero ? _shakeAnim0 : _shakeAnim1;
    final flash = isZero ? _flash0 : _flash1;

    return SlideTransition(
      position: slideAnim,
      child: DragTarget<_EmojiCard>(
        onWillAccept: (card) {
          return _basket[label] == null && card != null && _pool.contains(card);
        },
        onAccept: (card) {
          setState(() {
            if (_firstInPair == null) {
              _basket[label] = card;
              _firstInPair = card;
              _feedback = _Feedback.none;
              return;
            }

            if (_basket[label] != null) {
              _triggerWrong(label);
              return;
            }

            final first = _firstInPair!;
            final isCorrectPair =
                (card.pairId == first.pairId) && (card != first);

            if (isCorrectPair) {
              _basket[label] = card;
              _feedback = _Feedback.success;

              Future.delayed(dAfterPairBeforeRemove, () {
                setState(() {
                  _pool.remove(first);
                  _pool.remove(card);
                  _basket["0"] = null;
                  _basket["1"] = null;
                  _firstInPair = null;
                });

                if (_pool.isEmpty) {
                  Future.delayed(dDelayBeforeFinalOverlay, () {
                    if (!mounted) return;
                    setState(() {
                      _completed = true;
                      _feedback = _Feedback.none;
                      _overlayOpacity = 0;
                    });
                    Future.delayed(const Duration(milliseconds: 16), () {
                      if (mounted) setState(() => _overlayOpacity = 1);
                    });
                    widget.onCompleted();
                  });
                } else {
                  Future.delayed(dHidePerPairSuccess, () {
                    if (mounted && !_completed) {
                      setState(() => _feedback = _Feedback.none);
                    }
                  });
                }
              });
            } else {
              _triggerWrong(label);
            }
          });
        },
        builder: (context, candidate, rejected) {
          return AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            width: 140,
            height: 180,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: flash ? Colors.red[50] : Colors.grey[100],
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(60),
                bottom: Radius.circular(20),
              ),
              border: Border.all(
                color: flash ? Colors.red : Colors.black54,
                width: flash ? 3 : 2,
              ),
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
      ),
    );
  }

  void _triggerWrong(String label) {
    _feedback = _Feedback.error;

    if (label == "0") {
      _flash0 = true;
      _shakeCtrl0.forward(from: 0);
    } else {
      _flash1 = true;
      _shakeCtrl1.forward(from: 0);
    }
    setState(() {});

    Future.delayed(dErrorFlash, () {
      if (!mounted) return;
      setState(() {
        if (label == "0") {
          _flash0 = false;
        } else {
          _flash1 = false;
        }
      });
    });

    Future.delayed(dErrorAutoHide, () {
      if (!mounted) return;
      if (_feedback == _Feedback.error && !_completed) {
        setState(() => _feedback = _Feedback.none);
      }
    });
  }
}

class _EmojiCard {
  final String emoji;
  final String pairId;
  const _EmojiCard(this.emoji, this.pairId);
}
