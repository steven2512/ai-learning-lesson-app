// FILE: lib/z_pages/lessons/lesson2/lesson2_6.dart
// ✅ LessonStepSix — Binary Pairs with end-of-step Analytics Overlay
// CHANGES (non-breaking):
// • Added smooth scene fade-out on completion.
// • Added end overlay that slides up then reveals analytics downward (time, correct pairs, longest streak, incorrect attempts).
// • Kept original success text EXACT and unchanged; analytics reveal beneath it.
// • Continue button still controlled by parent; we call onCompleted ONLY after the reveal finishes.
// • Drag & drop logic untouched.
// 🔧 CHANGE (2025-09-15):
// • Precisely center the end overlay AFTER reveal: we invisibly measure the
//   revealed end-card height and slide to top = centerY - revealedHeight/2.
//   (Adds a tiny MeasureSize helper + one import. Everything else is legacy.)
//
// 🔧 CHANGE (2025-09-15, v2):
// • When a pair is correct, both baskets briefly “good flash” (green border + tiny scale pop).
// • Removed the hidden cooldown: after a correct pair, baskets are freed immediately so next drop can happen right away.
//
// 🔧 CHANGE (2025-09-15, v3):
// • Added a nice "Try Again" button BELOW the analytics inside the end card.
// • Removed green glow entirely (no blur/shadow). Green = clean border only.
// • Made "That's correct!" pill stay longer and retrigger seamlessly for fast players.
// • Added global control: kSuccessFeedbackVisibleMs.
//
// 🔧 CHANGE (2025-09-15, v4):
// • Added onRestartRequested callback so parent hides Continue when "Try Again" is pressed.
//
// 🔧 FIX (2025-09-15, v5):
// • Align analytics rows: emoji now sit in a fixed-width slot so labels line up perfectly.
//
// 🔧 FIX (2025-09-15, v6):
// • Two independent knobs for analytics-row centering:
//   kStatsWordsCenterPull  → moves the label (emoji + words) toward center.
//   kStatsValueCenterPull  → moves the numeric pill toward center.
//   Higher value = closer to center. Only affects the 4 analytics rows.

import 'dart:math';
import 'package:flutter/material.dart';
// 🔧 CHANGE: need RenderProxyBox for the minimal MeasureSize widget
import 'package:flutter/rendering.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:running_robot/z_pages/assets/lessonAssets/helpful_tools.dart';

const Color mainConceptColor = Color.fromARGB(255, 255, 109, 12);
const Color keyConceptGreen = Color.fromARGB(255, 0, 163, 54);

// 🔧 CHANGE (global control): how long the inline success pill stays visible (ms)
const int kSuccessFeedbackVisibleMs = 500;

// 🔧 NEW (only affects the 4 analytics rows):
// Increase either to pull that side closer to the card center (in pixels).
const double kStatsWordsCenterPull =
    35.0; // label side (emoji + words) → center
const double kStatsValueCenterPull = 22.0; // numeric pill → center

class BinaryDragDropGame extends StatefulWidget {
  /// Call this when ALL pairs are correctly matched and removed.
  final VoidCallback onCompleted;

  /// 🔧 NEW: Parent can hide Continue when user restarts the round.
  final VoidCallback? onRestartRequested;

  const BinaryDragDropGame({
    super.key,
    required this.onCompleted,
    this.onRestartRequested,
  });

  @override
  State<BinaryDragDropGame> createState() => _BinaryDragDropGameState();
}

enum _Feedback { none, success, error }

class _BinaryDragDropGameState extends State<BinaryDragDropGame>
    with TickerProviderStateMixin {
  // Layout
  static const double _narrowMaxWidth = 350;

  // Existing timings
  static const Duration dShake = Duration(milliseconds: 260);
  static const Duration dInlineFeedbackFade = Duration(milliseconds: 220);
  static const Duration dAfterPairBeforeRemove = Duration(milliseconds: 800);
  // 🔧 CHANGE: success pill visibility ties to global ms knob
  static const Duration dHidePerPairSuccess =
      Duration(milliseconds: kSuccessFeedbackVisibleMs);
  static const Duration dErrorFlash = Duration(milliseconds: 350);
  static const Duration dErrorAutoHide = Duration(milliseconds: 900);

  // End overlay choreography (mirrors Falling Words style)
  static const int kEndBoxFadeMs = 600; // opacity for overlay container
  static const int kFadeInTimeMs = 450; // compact box fade-in
  static const int kSlideUpDurationMs = 650; // slide up duration
  static const int kRevealDownDurationMs = 600; // expand/reveal duration
  static const double kSlideUpFromBottomFrac = 0.001; // slide from 22% below
  static const Duration dContentFadeOut = Duration(milliseconds: 450);

  // When to show Continue after reveal
  static const Duration dContinueAfterReveal = Duration(milliseconds: 150);

  // Grid guesses
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

  // Data/state
  late List<_EmojiCard> _pool;
  final Map<String, _EmojiCard?> _basket = {"0": null, "1": null};
  _EmojiCard? _firstInPair;
  _Feedback _feedback = _Feedback.none;

  // 🔧 CHANGE: remember which basket got the first card so we can flash BOTH on success
  String? _firstBasketLabel; // "0" or "1"

  // Legacy completion flag still used to hide inline feedback etc.
  bool _completed = false;

  // Scene fade
  double _contentOpacity = 1.0;

  // Shake/error flash (unchanged)
  late final AnimationController _shakeCtrl0;
  late final AnimationController _shakeCtrl1;
  late final Animation<Offset> _shakeAnim0;
  late final Animation<Offset> _shakeAnim1;
  bool _flash0 = false;
  bool _flash1 = false;

  // 🔧 CHANGE: success flash for baskets (green) — no glow
  static const Duration dGoodFlash = Duration(milliseconds: 450);
  static const double kGoodScaleBump = 1.03;
  bool _goodFlash0 = false;
  bool _goodFlash1 = false;

  // 🔧 CHANGE: to seamlessly retrigger the success pill
  int _successBadgeVersion = 0;

  double? _reservedPoolHeight;

  // ────────────────────────────────────────────────────────────────
  // Analytics
  // ────────────────────────────────────────────────────────────────
  DateTime _createdAt = DateTime.now();
  DateTime? _startedAt; // first user drop
  DateTime? _finishedAt;

  int _correctPairs = 0; // increments per successful pair
  int _incorrectAttempts = 0; // increments on every _triggerWrong
  int _currentStreak = 0;
  int _bestStreak = 0;

  // ────────────────────────────────────────────────────────────────
  // End Overlay State (slide-up then reveal-down)
  // ────────────────────────────────────────────────────────────────
  bool _showEndBox = false; // show overlay layer
  double _endBoxOpacity = 0.0; // fade end container
  bool _compactVisible = false; // compact box visible
  bool _compactSlidUp = false; // compact box slid up to center
  bool _revealed = false; // expanded stats revealed

  // 🔧 CHANGE: measured height of the *revealed* end card to compute perfect centering
  double? _revealedEndCardHeight;

  @override
  void initState() {
    super.initState();
    _resetPool();

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

  void _resetPool() {
    _pool = [...seedCards]..shuffle(Random());
  }

  // Helpers
  double _secondsTaken() {
    final start = _startedAt ?? _createdAt;
    final end = _finishedAt ?? DateTime.now();
    return (end.difference(start).inMilliseconds / 1000.0)
        .clamp(0, 9999)
        .toDouble();
  }

  @override
  Widget build(BuildContext context) {
    final poolCards = _pool.where((c) => !_basket.values.contains(c)).toList();

    return LayoutBuilder(builder: (context, constraints) {
      // Center Y target (for slide-up)
      final double centerY = constraints.maxHeight * 0.5;

      return Stack(
        children: [
          // Scene that fades out at completion
          AnimatedOpacity(
            opacity: _contentOpacity,
            duration: dContentFadeOut,
            curve: Curves.easeInOut,
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 20),

                    // Title box (UNCHANGED content)
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
                                LessonText.word("in", Colors.black87,
                                    fontSize: 20),
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
                        final rowsNow =
                            (poolCards.length + perRow - 1) ~/ perRow;
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
          ),

          // ──────────────────────────────────────────────────────────
          // End Game Overlay (compact → slide up to center → reveal stats)
          // ──────────────────────────────────────────────────────────
          if (_showEndBox)
            Positioned.fill(
              child: Stack(
                children: [
                  // Soft scrim
                  const IgnorePointer(
                    ignoring: true,
                    child: ColoredBox(color: Color(0xF0FFFFFF)),
                  ),

                  // Compact box → slide up to computed top → reveal stats
                  AnimatedOpacity(
                    opacity: _endBoxOpacity,
                    duration: const Duration(milliseconds: kFadeInTimeMs),
                    child: LayoutBuilder(builder: (context, cts) {
                      final double startTop =
                          centerY + cts.maxHeight * kSlideUpFromBottomFrac;

                      // Hidden measurement to center the revealed card
                      final double fallbackRevealedHeight = 120; // safe guess
                      final double revealedH =
                          _revealedEndCardHeight ?? fallbackRevealedHeight;
                      final double endTopComputed =
                          max(16.0, centerY - revealedH / 2);

                      return Stack(
                        children: [
                          // Hidden measurement of the revealed card
                          Opacity(
                            opacity: 0,
                            child: Center(
                              child: ConstrainedBox(
                                constraints: const BoxConstraints(
                                    maxWidth: _narrowMaxWidth),
                                child: _MeasureSize(
                                  onChange: (size) {
                                    if (!mounted) return;
                                    final h = size.height;
                                    if (h > 0 && _revealedEndCardHeight != h) {
                                      setState(() {
                                        _revealedEndCardHeight = h;
                                      });
                                    }
                                  },
                                  child: _buildEndCard(revealed: true),
                                ),
                              ),
                            ),
                          ),

                          // The visible animated overlay card
                          AnimatedPositioned(
                            duration: const Duration(
                                milliseconds: kSlideUpDurationMs),
                            curve: Curves.easeInOutCubic,
                            left: 0,
                            right: 0,
                            top: _compactSlidUp ? endTopComputed : startTop,
                            child: Center(
                              child: AnimatedSize(
                                duration: const Duration(
                                    milliseconds: kRevealDownDurationMs),
                                curve: Curves.easeOutCubic,
                                alignment:
                                    Alignment.topCenter, // expand downward
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

  // End card content: keeps legacy text, reveals analytics, and shows Try Again when revealed.
  Widget _buildEndCard({required bool revealed}) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: _narrowMaxWidth),
      child: LessonText.box(
        decoration: BoxDecoration(
          color: Colors.green[50],
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.green.shade400, width: 1),
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
            // LEGACY TEXT (unchanged)
            LessonText.sentence([
              LessonText.word("Great", Colors.black87, fontSize: 20),
              LessonText.word("work", keyConceptGreen,
                  fontSize: 20, fontWeight: FontWeight.w800),
              LessonText.word("🎉", keyConceptGreen, fontSize: 20),
            ]),
            const SizedBox(height: 6),
            LessonText.sentence([
              LessonText.word("You", Colors.black87, fontSize: 18),
              LessonText.word("chose", Colors.black87, fontSize: 18),
              LessonText.word("all", Colors.black87, fontSize: 18),
              LessonText.word("correct", keyConceptGreen,
                  fontSize: 18, fontWeight: FontWeight.w800),
              LessonText.word("binary", mainConceptColor,
                  fontSize: 18, fontWeight: FontWeight.w800),
              LessonText.word("pairs!", Colors.black87, fontSize: 18),
            ]),

            // Analytics (revealed after slide)
            if (revealed) ...[
              const SizedBox(height: 14),
              _statRow(
                icon: "⏱️",
                label: "Time taken",
                value: "${_secondsTaken().toStringAsFixed(1)} s",
                color: Colors.indigo,
              ),
              _statRow(
                icon: "✅",
                label: "Correct Pairs",
                value: "$_correctPairs",
                color: Colors.green,
              ),
              _statRow(
                icon: "🔥",
                label: "Longest Streak",
                value: "$_bestStreak",
                color: Colors.orange,
              ),
              _statRow(
                icon: "❌",
                label: "Incorrect Attempts",
                value: "$_incorrectAttempts",
                color: Colors.red,
              ),

              const SizedBox(height: 16),

              // 🔧 CHANGE: Nice Try Again button (inside the card, below analytics)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _handleTryAgain,
                  icon: const Icon(Icons.refresh_rounded),
                  label: Text(
                    "Try Again",
                    style: GoogleFonts.lato(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    backgroundColor: keyConceptGreen,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(
                        color: Colors.green.shade700,
                        width: 1.2,
                      ),
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

  void _handleTryAgain() {
    // 🔧 NEW: tell parent to hide Continue immediately
    widget.onRestartRequested?.call();

    setState(() {
      // reset analytics
      _createdAt = DateTime.now();
      _startedAt = null;
      _finishedAt = null;
      _correctPairs = 0;
      _incorrectAttempts = 0;
      _currentStreak = 0;
      _bestStreak = 0;

      // reset UI / gameplay
      _resetPool();
      _basket["0"] = null;
      _basket["1"] = null;
      _firstInPair = null;
      _firstBasketLabel = null;
      _feedback = _Feedback.none;
      _successBadgeVersion++; // bump so any lingering pill is considered stale
      _flash0 = _flash1 = false;
      _goodFlash0 = _goodFlash1 = false;

      // overlay & scene
      _showEndBox = false;
      _endBoxOpacity = 0.0;
      _compactVisible = false;
      _compactSlidUp = false;
      _revealed = false;
      _revealedEndCardHeight = null;
      _contentOpacity = 1.0;
      _completed = false;

      // layout cache
      _reservedPoolHeight = null;
    });
  }

  Widget _statRow({
    required String icon,
    required String label,
    required String value,
    required Color color,
  }) {
    // Fixed-width slot for emoji so label starts at same x across all rows.
    const double kIconSlotWidth = 26;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      // The two independent pulls toward center:
      //   - left padding shifts label block right,
      //   - right padding shifts value pill left.
      child: Padding(
        padding: EdgeInsets.only(
          left: kStatsWordsCenterPull,
          right: kStatsValueCenterPull,
        ),
        child: Row(
          children: [
            // Left: emoji + label (takes remaining space)
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    width: kIconSlotWidth,
                    child: Text(
                      icon,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 18),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.lato(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: color,
                    ),
                  ),
                ],
              ),
            ),

            // Right: value pill (anchored to the right edge of the padded area)
            Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: color.withOpacity(0.10),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: color.withOpacity(0.5)),
              ),
              child: Text(
                value,
                style: GoogleFonts.lato(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ────────────────────────────────────────────────────────────────
  // Inline feedback (success retriggers seamlessly; longer display)
  // ────────────────────────────────────────────────────────────────
  Widget _buildInlineFeedback() {
    if (_feedback == _Feedback.success) {
      // 🔧 CHANGE: use versioned key to retrigger seamlessly for back-to-back successes
      return KeyedSubtree(
        key: ValueKey("pair-success-$_successBadgeVersion"),
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
                    offset: Offset(0, 3),
                  ),
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
                    offset: Offset(0, 3),
                  ),
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

  // ────────────────────────────────────────────────────────────────
  // Drag sources — unchanged
  // ────────────────────────────────────────────────────────────────
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
            BoxShadow(
              color: Colors.black12,
              blurRadius: 4,
              offset: Offset(2, 2),
            ),
        ],
      ),
      child: Text(emoji, style: const TextStyle(fontSize: 32)),
    );
  }

  // ────────────────────────────────────────────────────────────────
  // Baskets + acceptance — success green border (no glow) & no cooldown
  // ────────────────────────────────────────────────────────────────
  Widget _buildBasket(String label) {
    final isZero = label == "0";
    final slideAnim = isZero ? _shakeAnim0 : _shakeAnim1;
    final flashRed = isZero ? _flash0 : _flash1;

    // success green flash state
    final flashGreen = isZero ? _goodFlash0 : _goodFlash1;

    // Border/background based on priority: Red error > Green success > neutral
    final Color borderColor =
        flashRed ? Colors.red : (flashGreen ? Colors.green : Colors.black54);
    final Color? bgColor = flashRed
        ? Colors.red[50]
        : (flashGreen ? Colors.green[50] : Colors.grey[100]);
    final double borderWidth = (flashRed || flashGreen) ? 3 : 2;

    return SlideTransition(
      position: slideAnim,
      child: AnimatedScale(
        // subtle pop during green success
        scale: flashGreen ? kGoodScaleBump : 1.0,
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        child: DragTarget<_EmojiCard>(
          onWillAccept: (card) {
            return _basket[label] == null &&
                card != null &&
                _pool.contains(card);
          },
          onAccept: (card) {
            // mark start time on FIRST user action
            _startedAt ??= DateTime.now();

            setState(() {
              if (_firstInPair == null) {
                _basket[label] = card;
                _firstInPair = card;
                _firstBasketLabel = label;
                _feedback = _Feedback.none;
                return;
              }

              if (_basket[label] != null) {
                // wrong: same basket already filled
                _triggerWrong(label);
                return;
              }

              final first = _firstInPair!;
              final isCorrectPair =
                  (card.pairId == first.pairId) && (card != first);

              if (isCorrectPair) {
                // Metrics: correct pair + streaks
                _currentStreak += 1;
                if (_currentStreak > _bestStreak) _bestStreak = _currentStreak;
                _correctPairs += 1;

                // briefly place the second card so the user sees it land...
                _basket[label] = card;

                // 🔧 CHANGE: retriggerable success pill
                final myVersion = ++_successBadgeVersion;
                _feedback = _Feedback.success;

                // trigger green border flash on BOTH baskets involved (no glow)
                final String otherLabel = _firstBasketLabel == "0" ? "0" : "1";
                if (label == "0" || otherLabel == "0") _goodFlash0 = true;
                if (label == "1" || otherLabel == "1") _goodFlash1 = true;

                // end of green flash
                Future.delayed(dGoodFlash, () {
                  if (!mounted) return;
                  setState(() {
                    _goodFlash0 = false;
                    _goodFlash1 = false;
                  });
                });

                // Free baskets & remove cards IMMEDIATELY (no cooldown)
                Future.microtask(() {
                  if (!mounted) return;
                  setState(() {
                    _pool.remove(first);
                    _pool.remove(card);
                    _basket["0"] = null;
                    _basket["1"] = null;
                    _firstInPair = null;
                    _firstBasketLabel = null;
                  });
                  _maybeStartEndOverlayIfDone();
                });

                // Hide success pill after global duration,
                // but only if this is still the latest success.
                Future.delayed(dHidePerPairSuccess, () {
                  if (!mounted) return;
                  if (!_completed && _successBadgeVersion == myVersion) {
                    setState(() => _feedback = _Feedback.none);
                  }
                });
              } else {
                // wrong: mismatched pair
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
                color: bgColor,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(60),
                  bottom: Radius.circular(20),
                ),
                border: Border.all(
                  color: borderColor,
                  width: borderWidth,
                ),
                boxShadow: const [
                  // base shadow only; no green glow
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 6,
                    offset: Offset(0, 3),
                  ),
                ],
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
      ),
    );
  }

  // Completion sequence after immediate removal
  void _maybeStartEndOverlayIfDone() {
    if (_pool.isNotEmpty) return;

    _finishedAt ??= DateTime.now();

    // Fade scene out
    setState(() => _contentOpacity = 0);

    // Show overlay sequence (legacy timings preserved)
    Future.delayed(dContentFadeOut, () {
      if (!mounted) return;

      setState(() {
        _completed = true; // legacy flag (hides inline feedback)
        _showEndBox = true;
      });

      // slight delay to fade in the compact box
      Future.delayed(const Duration(milliseconds: 30), () {
        if (!mounted) return;
        setState(() {
          _endBoxOpacity = 1.0;
          _compactVisible = true;
        });
      });

      // hold compact moment, then slide it up to center (computed with measurement)
      Future.delayed(const Duration(milliseconds: 700), () {
        if (!mounted) return;
        setState(() => _compactSlidUp = true);

        // after slide, reveal stats downward
        Future.delayed(
          const Duration(milliseconds: kSlideUpDurationMs),
          () {
            if (!mounted) return;
            setState(() => _revealed = true);

            // finally allow Continue to appear (parent logic)
            Future.delayed(dContinueAfterReveal, () {
              if (mounted) widget.onCompleted();
            });
          },
        );
      });
    });
  }

  void _triggerWrong(String label) {
    _feedback = _Feedback.error;

    // Metrics: wrong attempt & reset streak
    _incorrectAttempts += 1;
    _currentStreak = 0;

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

// 🔧 CHANGE: tiny helper to measure child size after layout
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
