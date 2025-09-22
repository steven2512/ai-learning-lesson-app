// FILE: lib/z_pages/lessons/widgets/drag_drop_game.dart
//
// GENERIC DRAG & DROP GAME — HARD-STYLED, REUSABLE
// ------------------------------------------------
// 🔒 HARDLOCK (WORDS):
//   • Success pill: "That's correct!"
//   • Error pill:   "Try again!"
//   • End-card header: "Great work 🎉"
// 🔧 CHANGE: Default stats say "Correct Attempts" (generic).
//
// Customizable (inputs only):
//   • Mode: pairMatch | classify
//   • Baskets (1..4) + display names
//   • Tokens (pairId or targetBasketKey)
//   • Title: titleText OR title (Widget)
//   • End-card body: endCardBodyText OR endCardBody (Widget)
//   • Stat labels: labelTime, labelCorrectAttempts, labelLongestStreak, labelIncorrectAttempts
//   • Try-again button text: tryAgainLabel
//   • Basket titles: basketTitlePrefix OR basketTitleBuilder
//   • Time formatting: timeValueBuilder(seconds)
//
// Everything visual (Lato font, shapes, shadows, paddings, spacings, animations,
// overlay choreography, pool-row limit) remains hardcoded.

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:google_fonts/google_fonts.dart';

/// ─────────────────────────────────────────────────────────────────────────
const Color _kMainConceptColor = Color.fromARGB(255, 255, 109, 12);
const Color _kKeyGreen = Color.fromARGB(255, 0, 163, 54);

const int _kSuccessFeedbackVisibleMs = 500;
const double _kStatsWordsCenterPull = 35.0;
const double _kStatsValueCenterPull = 22.0;

const double _kNarrowMaxWidth = 350;
const Duration _dShake = Duration(milliseconds: 260);
const Duration _dInlineFeedbackFade = Duration(milliseconds: 220);
const Duration _dErrorFlash = Duration(milliseconds: 350);
const Duration _dErrorAutoHide = Duration(milliseconds: 900);
const Duration _dContentFadeOut = Duration(milliseconds: 450);
const Duration _dHidePerPairSuccess =
    Duration(milliseconds: _kSuccessFeedbackVisibleMs);

const int _kEndBoxFadeMs = 600;
const int _kFadeInTimeMs = 450;
const int _kSlideUpDurationMs = 650;
const int _kRevealDownDurationMs = 600;
const double _kSlideUpFromBottomFrac = 0.001;
const Duration _dContinueAfterReveal = Duration(milliseconds: 150);

const double _kTileWidthGuess = 68;
const double _kRowExtent = 76;
const double _kSpacing = 12;

const Duration _dGoodFlash = Duration(milliseconds: 450);
const double _kGoodScaleBump = 1.03;

const int _kMaxPoolRows = 4;

/// ─────────────────────────────────────────────────────────────────────────
enum DragDropMode { pairMatch, classify }

class BasketSpec {
  final String key;
  final String displayName;
  const BasketSpec({required this.key, required this.displayName});
}

class DragToken {
  final String emoji;
  final String? pairId; // pairMatch
  final String? targetBasketKey; // classify → treated as CATEGORY KEY

  DragToken._(this.emoji, this.pairId, this.targetBasketKey);
  factory DragToken.pair({required String emoji, required String pairId}) =>
      DragToken._(emoji, pairId, null);
  factory DragToken.classify(
          {required String emoji, required String targetBasketKey}) =>
      DragToken._(emoji, null, targetBasketKey);
}

class DragDropGame extends StatefulWidget {
  final DragDropMode mode;
  final List<BasketSpec> baskets;
  final List<DragToken> tokens;

  final String? titleText;
  final Widget? title;

  // End-card header is hardlocked → only BODY is customizable
  final String? endCardBodyText;
  final Widget? endCardBody;

  final String? labelTime;
  final String? labelCorrectAttempts; // "Correct Attempts"
  final String? labelLongestStreak;
  final String? labelIncorrectAttempts;
  final String? tryAgainLabel;

  final String? basketTitlePrefix; // default "Basket"
  final Widget Function(BasketSpec spec)? basketTitleBuilder;

  final VoidCallback onCompleted;
  final VoidCallback? onRestartRequested;

  final String Function(double seconds)? timeValueBuilder;

  const DragDropGame({
    super.key,
    required this.mode,
    required this.baskets,
    required this.tokens,
    this.titleText,
    this.title,
    this.endCardBodyText,
    this.endCardBody,
    this.labelTime,
    this.labelCorrectAttempts,
    this.labelLongestStreak,
    this.labelIncorrectAttempts,
    this.tryAgainLabel,
    this.basketTitlePrefix,
    this.basketTitleBuilder,
    this.timeValueBuilder,
    required this.onCompleted,
    this.onRestartRequested,
  });

  @override
  State<DragDropGame> createState() => _DragDropGameState();
}

enum _Feedback { none, success, error }

class _DragDropGameState extends State<DragDropGame>
    with TickerProviderStateMixin {
  late List<DragToken> _pool;
  final Map<String, DragToken?> _basket = {};

  // ── New: dynamic classification binding ─────────────────────────
  // basketKey -> categoryKey (once set by first accepted token)
  final Map<String, String> _basketToCategory = {};
  // categoryKey -> basketKey (enforces one basket per category)
  final Map<String, String> _categoryToBasket = {};

  DragToken? _firstInPair;
  String? _firstBasketKey;

  DateTime _createdAt = DateTime.now();
  DateTime? _startedAt;
  DateTime? _finishedAt;
  int _correctCount = 0;
  int _incorrectAttempts = 0;
  int _currentStreak = 0;
  int _bestStreak = 0;

  bool _completed = false;
  double _contentOpacity = 1.0;
  bool _showEndBox = false;
  double _endBoxOpacity = 0.0;
  bool _compactVisible = false;
  bool _compactSlidUp = false;
  bool _revealed = false;
  double? _revealedEndCardHeight;

  late final Map<String, AnimationController> _shakeCtrls;
  late final Map<String, Animation<Offset>> _shakeAnims;
  final Set<String> _flashRed = {};
  final Set<String> _flashGreen = {};
  _Feedback _feedback = _Feedback.none;
  int _successBadgeVersion = 0;

  double? _reservedPoolHeight;

  @override
  void initState() {
    super.initState();
    assert(widget.baskets.isNotEmpty && widget.baskets.length <= 4,
        "baskets must be 1..4");

    _resetPool();
    for (final b in widget.baskets) {
      _basket[b.key] = null;
    }

    _shakeCtrls = {
      for (final b in widget.baskets)
        b.key: AnimationController(vsync: this, duration: _dShake)
    };

    final shakeTween = TweenSequence<Offset>([
      TweenSequenceItem(
          tween: Tween(begin: Offset.zero, end: const Offset(0.07, 0)),
          weight: 1),
      TweenSequenceItem(
          tween:
              Tween(begin: const Offset(0.07, 0), end: const Offset(-0.07, 0)),
          weight: 1),
      TweenSequenceItem(
          tween: Tween(begin: const Offset(-0.07, 0), end: Offset.zero),
          weight: 1),
    ]);

    _shakeAnims = {
      for (final b in widget.baskets)
        b.key: shakeTween.animate(CurvedAnimation(
            parent: _shakeCtrls[b.key]!, curve: Curves.easeInOut))
    };
  }

  @override
  void dispose() {
    for (final c in _shakeCtrls.values) {
      c.dispose();
    }
    super.dispose();
  }

  void _resetPool() {
    _pool = [...widget.tokens]..shuffle(Random());
  }

  double _secondsTaken() {
    final start = _startedAt ?? _createdAt;
    final end = _finishedAt ?? DateTime.now();
    return (end.difference(start).inMilliseconds / 1000.0)
        .clamp(0, 9999)
        .toDouble();
  }

  @override
  Widget build(BuildContext context) {
    final poolCards = _pool.where((t) => !_basket.values.contains(t)).toList();

    return LayoutBuilder(builder: (context, constraints) {
      final double centerY = constraints.maxHeight * 0.5;

      return Stack(
        children: [
          // Scene
          AnimatedOpacity(
            opacity: _contentOpacity,
            duration: _dContentFadeOut,
            curve: Curves.easeInOut,
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 20),

                    // Title box (style locked; content customizable)
                    Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 330),
                        child: _hardBox(
                          margin: const EdgeInsets.only(bottom: 20),
                          padding: const EdgeInsets.symmetric(
                              vertical: 14, horizontal: 10),
                          child: Center(child: _buildTitleContent()),
                        ),
                      ),
                    ),

                    // Pool with hard limit on rows
                    LayoutBuilder(builder: (context, cts) {
                      final maxW = cts.maxWidth;
                      final perRow = max(
                          1,
                          ((maxW + _kSpacing) / (_kTileWidthGuess + _kSpacing))
                              .floor());
                      final rowsNow = (poolCards.length + perRow - 1) ~/ perRow;

                      if (rowsNow > _kMaxPoolRows) {
                        throw FlutterError(
                          "Pool overflow: requires $rowsNow rows (limit is $_kMaxPoolRows). "
                          "Reduce tokens or widen layout.",
                        );
                      }

                      final neededHeight = max(1, rowsNow) * _kRowExtent;
                      if (_reservedPoolHeight == null ||
                          neededHeight > _reservedPoolHeight!) {
                        _reservedPoolHeight = neededHeight.toDouble();
                      }

                      return SizedBox(
                        height: _reservedPoolHeight!,
                        child: Wrap(
                          spacing: _kSpacing,
                          runSpacing: _kSpacing,
                          children: poolCards.map(_buildDraggable).toList(),
                        ),
                      );
                    }),

                    const SizedBox(height: 70),

                    // Baskets 1..4 evenly spaced
                    _buildBasketsRow(),

                    const SizedBox(height: 12),

                    if (!_completed)
                      AnimatedSwitcher(
                        duration: _dInlineFeedbackFade,
                        switchInCurve: Curves.easeOut,
                        switchOutCurve: Curves.easeIn,
                        child: _buildInlineFeedback(),
                      ),

                    const SizedBox(height: 28),
                  ],
                ),
              ),
            ),
          ),

          // End overlay
          if (_showEndBox)
            Positioned.fill(
              child: Stack(
                children: [
                  const IgnorePointer(
                    ignoring: true,
                    child: ColoredBox(color: Color(0xF0FFFFFF)),
                  ),
                  AnimatedOpacity(
                    opacity: _endBoxOpacity,
                    duration: const Duration(milliseconds: _kFadeInTimeMs),
                    child: LayoutBuilder(builder: (context, cts) {
                      final double startTop =
                          centerY + cts.maxHeight * _kSlideUpFromBottomFrac;

                      const double fallbackRevealedHeight = 120;
                      final double revealedH =
                          _revealedEndCardHeight ?? fallbackRevealedHeight;
                      final double endTopComputed =
                          max(16.0, centerY - revealedH / 2);

                      return Stack(
                        children: [
                          // Hidden measurement for perfect centering (fixed width)
                          Opacity(
                            opacity: 0,
                            child: Center(
                              child: SizedBox(
                                width: _kNarrowMaxWidth,
                                child: _MeasureSize(
                                  onChange: (size) {
                                    if (!mounted) return;
                                    final h = size.height;
                                    if (h > 0 && _revealedEndCardHeight != h) {
                                      setState(
                                          () => _revealedEndCardHeight = h);
                                    }
                                  },
                                  child: _buildEndCard(revealed: true),
                                ),
                              ),
                            ),
                          ),

                          AnimatedPositioned(
                            duration: const Duration(
                                milliseconds: _kSlideUpDurationMs),
                            curve: Curves.easeInOutCubic,
                            left: 0,
                            right: 0,
                            top: _compactSlidUp ? endTopComputed : startTop,
                            child: Center(
                              child: AnimatedSize(
                                duration: const Duration(
                                    milliseconds: _kRevealDownDurationMs),
                                curve: Curves.easeOutCubic,
                                alignment: Alignment.topCenter,
                                child: _buildEndCard(revealed: _revealed),
                              ),
                            ),
                          ),
                        ],
                      );
                    }),
                  ),
                ],
              ),
            ),
        ],
      );
    });
  }

  // ────────────────────────────────────────────────────────────────
  // Content builders (strings OR widgets)
  // ────────────────────────────────────────────────────────────────
  Widget _buildTitleContent() {
    if (widget.title != null) return widget.title!;
    if (widget.titleText != null) {
      return Text(
        widget.titleText!,
        textAlign: TextAlign.center,
        style: GoogleFonts.lato(fontSize: 20, color: Colors.black87),
      );
    }
    return Text(
      "Drag the icons into the correct baskets",
      textAlign: TextAlign.center,
      style: GoogleFonts.lato(fontSize: 20, color: Colors.black87),
    );
  }

  String _labelTime() => widget.labelTime ?? "Time taken";
  String _labelCorrectAttempts() =>
      widget.labelCorrectAttempts ?? "Correct Attempts";
  String _labelLongestStreak() => widget.labelLongestStreak ?? "Longest Streak";
  String _labelIncorrectAttempts() =>
      widget.labelIncorrectAttempts ?? "Incorrect Attempts";
  String _tryAgainLabel() => widget.tryAgainLabel ?? "Try Again";

  Widget _buildBasketTitle(BasketSpec spec) {
    if (widget.basketTitleBuilder != null) {
      return widget.basketTitleBuilder!(spec);
    }
    final prefix = widget.basketTitlePrefix ?? "Basket";
    return Text(
      "$prefix ${spec.displayName}",
      style: GoogleFonts.lato(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: _basketTitleColor(spec),
      ),
    );
  }

  // ────────────────────────────────────────────────────────────────
  // Hard-styled wrappers
  // ────────────────────────────────────────────────────────────────
  Widget _hardBox({
    required Widget child,
    EdgeInsetsGeometry? margin,
    EdgeInsetsGeometry? padding,
  }) {
    return Container(
      margin: margin,
      padding: padding,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black12, width: 1),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 3)),
        ],
      ),
      child: DefaultTextStyle.merge(
        style: GoogleFonts.lato(),
        child: child,
      ),
    );
  }

  Widget _hardCardGreen(Widget child) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.green[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.green.shade400, width: 1),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 3))
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: DefaultTextStyle.merge(style: GoogleFonts.lato(), child: child),
    );
  }

  Widget _hardCardRed(Widget child) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.red[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.red.shade400, width: 1),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 3))
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: DefaultTextStyle.merge(style: GoogleFonts.lato(), child: child),
    );
  }

  TextSpan _word(String text, Color color,
      {double size = 16, bool bold = false}) {
    return TextSpan(
      text: "$text ",
      style: GoogleFonts.lato(
        fontSize: size,
        fontWeight: bold ? FontWeight.w800 : FontWeight.w400,
        color: color,
      ),
    );
  }

  Widget _sentence(List<InlineSpan> spans) =>
      RichText(text: TextSpan(children: spans));

  // ────────────────────────────────────────────────────────────────
  // End card (HEADER hardlocked; BODY customizable)
  // ────────────────────────────────────────────────────────────────
  Widget _buildEndCard({required bool revealed}) {
    // HARDLOCK header — bolded
    final header = Text(
      "Great work 🎉",
      style: GoogleFonts.lato(
        fontSize: 20,
        fontWeight: FontWeight.w800,
        color: Colors.black87,
      ),
      textAlign: TextAlign.center,
    );

    // Body is customizable (widget > text > default sentence)
    final body = widget.endCardBody ??
        (widget.endCardBodyText != null
            ? Text(
                widget.endCardBodyText!,
                style: GoogleFonts.lato(fontSize: 18, color: Colors.black87),
                textAlign: TextAlign.center,
              )
            : _sentence([
                _word("You", Colors.black87, size: 18),
                _word("chose", Colors.black87, size: 18),
                _word("all", Colors.black87, size: 18),
                _word("correct", _kKeyGreen, size: 18, bold: true),
                _word("binary", _kMainConceptColor, size: 18, bold: true),
                _word("pairs!", Colors.black87, size: 18),
              ]));

    final timeValue = widget.timeValueBuilder != null
        ? widget.timeValueBuilder!(_secondsTaken())
        : "${_secondsTaken().toStringAsFixed(1)} s";

    // Fixed width + green card for both compact & revealed states
    return SizedBox(
      width: _kNarrowMaxWidth,
      child: _hardCardGreen(
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            header,
            const SizedBox(height: 6),
            body,
            if (revealed) ...[
              const SizedBox(height: 14),
              _statRow("⏱️", _labelTime(), timeValue, Colors.indigo),
              _statRow(
                  "✅", _labelCorrectAttempts(), "$_correctCount", Colors.green),
              _statRow(
                  "🔥", _labelLongestStreak(), "$_bestStreak", Colors.orange),
              _statRow("❌", _labelIncorrectAttempts(), "$_incorrectAttempts",
                  Colors.red),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _handleTryAgain,
                  icon: const Icon(Icons.refresh_rounded),
                  label: Text(
                    _tryAgainLabel(),
                    style: GoogleFonts.lato(
                        fontSize: 16, fontWeight: FontWeight.w800),
                  ),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    backgroundColor: _kKeyGreen,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side:
                          BorderSide(color: Colors.green.shade700, width: 1.2),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _statRow(String icon, String label, String value, Color color) {
    const double kIconSlotWidth = 26;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      child: Padding(
        padding: EdgeInsets.only(
            left: _kStatsWordsCenterPull, right: _kStatsValueCenterPull),
        child: Row(
          children: [
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    width: kIconSlotWidth,
                    child: Text(icon,
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 18)),
                  ),
                  const SizedBox(width: 8),
                  Text(label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.lato(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: color)),
                ],
              ),
            ),
            Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: color.withOpacity(0.10),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: color.withOpacity(0.5)),
              ),
              child: Text(value,
                  style: GoogleFonts.lato(
                      fontSize: 16, fontWeight: FontWeight.bold, color: color)),
            ),
          ],
        ),
      ),
    );
  }

  // Reset state and notify parent when "Try Again" is pressed.
  void _handleTryAgain() {
    widget.onRestartRequested?.call();

    setState(() {
      _createdAt = DateTime.now();
      _startedAt = null;
      _finishedAt = null;
      _correctCount = 0;
      _incorrectAttempts = 0;
      _currentStreak = 0;
      _bestStreak = 0;

      _resetPool();
      for (final b in widget.baskets) {
        _basket[b.key] = null;
      }
      _firstInPair = null;
      _firstBasketKey = null;
      _feedback = _Feedback.none;
      _successBadgeVersion++;
      _flashRed.clear();
      _flashGreen.clear();

      // clear dynamic bindings
      _basketToCategory.clear();
      _categoryToBasket.clear();

      _showEndBox = false;
      _endBoxOpacity = 0.0;
      _compactVisible = false;
      _compactSlidUp = false;
      _revealed = false;
      _revealedEndCardHeight = null;
      _contentOpacity = 1.0;
      _completed = false;

      _reservedPoolHeight = null;
    });
  }

  // Inline feedback
  Widget _buildInlineFeedback() {
    switch (_feedback) {
      case _Feedback.success:
        return KeyedSubtree(
          key: ValueKey("success-$_successBadgeVersion"),
          child: Center(
            child: SizedBox(
              width: _kNarrowMaxWidth,
              child: _hardCardGreen(
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.check_circle,
                        color: Colors.green, size: 24),
                    const SizedBox(width: 8),
                    Text("That's correct!",
                        style: GoogleFonts.lato(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: _kKeyGreen)),
                  ],
                ),
              ),
            ),
          ),
        );
      case _Feedback.error:
        return KeyedSubtree(
          key: const ValueKey("error"),
          child: Center(
            child: SizedBox(
              width: _kNarrowMaxWidth,
              child: _hardCardRed(
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.close_rounded,
                        color: Colors.red, size: 24),
                    const SizedBox(width: 8),
                    Text("Try again!",
                        style: GoogleFonts.lato(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: Colors.red)),
                  ],
                ),
              ),
            ),
          ),
        );
      case _Feedback.none:
        return const SizedBox.shrink();
    }
  }

  // Draggables & Baskets
  Widget _buildDraggable(DragToken t) {
    return Draggable<DragToken>(
      data: t,
      feedback: _emojiTile(t.emoji, dragging: true),
      childWhenDragging: Opacity(opacity: 0.3, child: _emojiTile(t.emoji)),
      child: _emojiTile(t.emoji),
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
                color: Colors.black12, blurRadius: 4, offset: Offset(2, 2)),
        ],
      ),
      child: Text(emoji, style: GoogleFonts.lato(fontSize: 32)),
    );
  }

  Widget _buildBasketsRow() {
    final children = <Widget>[];
    for (var i = 0; i < widget.baskets.length; i++) {
      if (i > 0) children.add(const SizedBox(width: 14));
      children.add(Expanded(child: _buildBasket(widget.baskets[i])));
    }
    return Row(children: children);
  }

  // ── New: classify rule helper ───────────────────────────────────
  bool _canDropClassify(String basketKey, DragToken t) {
    final String? cat = t.targetBasketKey;
    if (cat == null) return false;

    final String? basketBoundCat = _basketToCategory[basketKey];
    final String? catBoundBasket = _categoryToBasket[cat];

    // If this basket already bound to a category, only that category can go in.
    if (basketBoundCat != null && basketBoundCat != cat) return false;

    // If this category already bound to a different basket, disallow here.
    if (catBoundBasket != null && catBoundBasket != basketKey) return false;

    // Otherwise allowed: either both unbound, or both already matched together.
    return true;
  }

  Widget _buildBasket(BasketSpec spec) {
    final slideAnim = _shakeAnims[spec.key]!;
    final isRed = _flashRed.contains(spec.key);
    final isGreen = _flashGreen.contains(spec.key);

    final Color borderColor =
        isRed ? Colors.red : (isGreen ? Colors.green : Colors.black54);
    final Color? bgColor = isRed
        ? Colors.red[50]
        : (isGreen ? Colors.green[50] : Colors.grey[100]);
    final double borderWidth = (isRed || isGreen) ? 3 : 2;

    return SlideTransition(
      position: slideAnim,
      child: AnimatedScale(
        scale: isGreen ? _kGoodScaleBump : 1.0,
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        child: DragTarget<DragToken>(
          onWillAccept: (t) {
            if (t == null) return false;
            if (!_pool.contains(t)) return false;
            if (_basket[spec.key] != null) return false; // occupied briefly
            switch (widget.mode) {
              case DragDropMode.classify:
                return _canDropClassify(spec.key, t);
              case DragDropMode.pairMatch:
                return true;
            }
          },
          onAccept: (t) {
            _startedAt ??= DateTime.now();
            setState(() {
              switch (widget.mode) {
                case DragDropMode.classify:
                  {
                    final String basketKey = spec.key;
                    final String? cat = t.targetBasketKey;

                    if (cat == null) {
                      _triggerWrong(basketKey);
                      break;
                    }

                    final String? basketBoundCat = _basketToCategory[basketKey];
                    final String? catBoundBasket = _categoryToBasket[cat];

                    // Case A: basket already bound → must match same category
                    if (basketBoundCat != null && basketBoundCat != cat) {
                      _triggerWrong(basketKey);
                      break;
                    }
                    // Case B: category already bound → must be the same basket
                    if (catBoundBasket != null && catBoundBasket != basketKey) {
                      _triggerWrong(basketKey);
                      break;
                    }
                    // Bind if both unbound (first placement defines the mapping)
                    if (basketBoundCat == null && catBoundBasket == null) {
                      _basketToCategory[basketKey] = cat;
                      _categoryToBasket[cat] = basketKey;
                    }
                    // Success for this drop
                    _applySuccessClassify(t, basketKey);
                    break;
                  }

                case DragDropMode.pairMatch:
                  {
                    if (_firstInPair == null) {
                      _basket[spec.key] = t;
                      _firstInPair = t;
                      _firstBasketKey = spec.key;
                      _feedback = _Feedback.none;
                      return;
                    }
                    if (_basket[spec.key] != null) {
                      _triggerWrong(spec.key);
                      return;
                    }
                    final first = _firstInPair!;
                    final isCorrectPair = (t.pairId != null &&
                        first.pairId != null &&
                        t.pairId == first.pairId &&
                        t != first);
                    if (isCorrectPair) {
                      _applySuccessPair(first, t, spec.key);
                    } else {
                      _triggerWrong(spec.key);
                    }
                    break;
                  }
              }
            });
          },
          builder: (context, candidate, rejected) {
            return AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              height: 180,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(60),
                  bottom: Radius.circular(20),
                ),
                border: Border.all(color: borderColor, width: borderWidth),
                boxShadow: const [
                  BoxShadow(
                      color: Colors.black12,
                      blurRadius: 6,
                      offset: Offset(0, 3)),
                ],
              ),
              child: Column(
                children: [
                  _buildBasketTitle(spec),
                  const SizedBox(height: 8),
                  Expanded(
                    child: Center(
                      child: _basket[spec.key] == null
                          ? const SizedBox.shrink()
                          : _emojiTile(_basket[spec.key]!.emoji),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Color _basketTitleColor(BasketSpec spec) {
    final idx = widget.baskets.indexWhere((b) => b.key == spec.key);
    switch (idx) {
      case 0:
        return Colors.blue;
      case 1:
        return Colors.red;
      case 2:
        return Colors.teal;
      default:
        return Colors.deepPurple;
    }
  }

  // Success paths
  void _applySuccessClassify(DragToken t, String basketKey) {
    _basket[basketKey] = t;

    _currentStreak += 1;
    if (_currentStreak > _bestStreak) _bestStreak = _currentStreak;
    _correctCount += 1;

    final myVersion = ++_successBadgeVersion;
    _feedback = _Feedback.success;

    _flashGreen..add(basketKey);
    Future.delayed(_dGoodFlash, () {
      if (!mounted) return;
      setState(() => _flashGreen.remove(basketKey));
    });

    Future.microtask(() {
      if (!mounted) return;
      setState(() {
        _pool.remove(t);
        _basket[basketKey] = null;
      });
      _maybeFinishIfDone();
    });

    Future.delayed(_dHidePerPairSuccess, () {
      if (!mounted) return;
      if (!_completed && _successBadgeVersion == myVersion) {
        setState(() => _feedback = _Feedback.none);
      }
    });
  }

  void _applySuccessPair(
      DragToken first, DragToken second, String secondBasketKey) {
    final firstKey = _firstBasketKey ?? secondBasketKey;

    _basket[secondBasketKey] = second;

    _currentStreak += 1;
    if (_currentStreak > _bestStreak) _bestStreak = _currentStreak;
    _correctCount += 1;

    final myVersion = ++_successBadgeVersion;
    _feedback = _Feedback.success;

    _flashGreen
      ..add(firstKey)
      ..add(secondBasketKey);
    Future.delayed(_dGoodFlash, () {
      if (!mounted) return;
      setState(() {
        _flashGreen.remove(firstKey);
        _flashGreen.remove(secondBasketKey);
      });
    });

    Future.microtask(() {
      if (!mounted) return;
      setState(() {
        _pool.remove(first);
        _pool.remove(second);
        for (final b in widget.baskets) {
          _basket[b.key] = null;
        }
        _firstInPair = null;
        _firstBasketKey = null;
      });
      _maybeFinishIfDone();
    });

    Future.delayed(_dHidePerPairSuccess, () {
      if (!mounted) return;
      if (!_completed && _successBadgeVersion == myVersion) {
        setState(() => _feedback = _Feedback.none);
      }
    });
  }

  void _maybeFinishIfDone() {
    if (_pool.isNotEmpty) return;
    _finishedAt ??= DateTime.now();

    setState(() => _contentOpacity = 0);

    Future.delayed(_dContentFadeOut, () {
      if (!mounted) return;
      setState(() {
        _completed = true;
        _showEndBox = true;
      });

      Future.delayed(const Duration(milliseconds: 30), () {
        if (!mounted) return;
        setState(() {
          _endBoxOpacity = 1.0;
          _compactVisible = true;
        });
      });

      Future.delayed(const Duration(milliseconds: 700), () {
        if (!mounted) return;
        setState(() => _compactSlidUp = true);

        Future.delayed(const Duration(milliseconds: _kSlideUpDurationMs), () {
          if (!mounted) return;
          setState(() => _revealed = true);

          Future.delayed(_dContinueAfterReveal, () {
            if (mounted) widget.onCompleted();
          });
        });
      });
    });
  }

  // Errors
  void _triggerWrong(String basketKey) {
    _feedback = _Feedback.error;
    _incorrectAttempts += 1;
    _currentStreak = 0;

    _flashRed.add(basketKey);
    _shakeCtrls[basketKey]!.forward(from: 0);
    setState(() {});

    Future.delayed(_dErrorFlash, () {
      if (!mounted) return;
      setState(() => _flashRed.remove(basketKey));
    });

    Future.delayed(_dErrorAutoHide, () {
      if (!mounted) return;
      if (_feedback == _Feedback.error && !_completed) {
        setState(() => _feedback = _Feedback.none);
      }
    });
  }
}

/// Measure child size after layout (for centering the revealed card)
class _MeasureSize extends SingleChildRenderObjectWidget {
  final ValueChanged<Size> onChange;
  const _MeasureSize({required this.onChange, required Widget child, Key? key})
      : super(key: key, child: child);

  @override
  RenderObject createRenderObject(BuildContext context) =>
      _RenderMeasureSize(onChange);

  @override
  void updateRenderObject(
      BuildContext context, covariant _RenderMeasureSize renderObject) {
    renderObject.onChange = onChange;
  }
}

class _RenderMeasureSize extends RenderProxyBox {
  _RenderMeasureSize(this.onChange);
  ValueChanged<Size> onChange;
  Size? _oldSize;

  @override
  void performLayout() {
    super.performLayout();
    final newSize = child?.size ?? Size.zero;
    if (_oldSize == newSize) return;
    _oldSize = newSize;
    WidgetsBinding.instance.addPostFrameCallback((_) => onChange(newSize));
  }
}
