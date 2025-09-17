// lib/z_pages/lessons/LessonTzhee/lesson3_7.dart
// ✅ LessonStepSeven — Falling Words Game (catch QUALITATIVE only)

import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
// LessonText helpers (your file)
import 'package:running_robot/z_pages/assets/lessonAssets/helpful_tools.dart';

/// ─────────────────────────────────────────────────────────────────
/// 🔧 GLOBAL TUNING KNOBS
/// ─────────────────────────────────────────────────────────────────
const double kBasketWidth = 110; // narrowed
const double kBasketHeight = 60;
const double kBasketBottomMargin = 40;

const double kBasketDragSensitivity = 1.0;
const bool kSmoothTapMove = false;
const double kBasketMoveSpeed = 560;

// WORD FONT RANGE
const double kWordFontMin = 22;
const double kWordFontMax = 28;

// Base physics
const double kFallSpeed = 120; // px/sec (base)
const double kSpawnPerSecond = 0.5; // base spawns/sec

// Difficulty scaling
const double kFallSpeedGrowthPerSec = 0.020;
const double kFallSpeedMaxMultiplier = 2.6;
const double kSpawnGrowthPerSec = 0.005; // +0.5% per second
const double kSpawnMaxPerSecond = 3.0;
const int kSpawnTickMs = 100;

const int kMaxActiveWords = 9;
const double kMinHorizontalGap = 110;
const double kSpawnSidePadding = 16;
const double kSpawnStartY = -120;
const double kFadeInDistance = 160;
const double kMinVerticalGap = 100; // vertical spacing

// Scoring
const int kPointsToWin = 10;
const int kPointsToLose = -10;
const int kScoreCorrect = 10;
const int kScoreIncorrect = -10;
const int kScoreMissPenalty = -10;

// Layout
const double kHeaderBoxesTopMargin = 70.0;
const double kIntroBoxesTopMargin = 100.0;

/// 🧷 keep the top-left area (close button + progress bar) tappable
const double kTopSafeInsetForClose = 108.0;

/// 🎯 End-box & stats alignment (left icon/text gutter & right chip gutter)
const double kStatsLeftGutter = 8.0;
const double kStatsRightGutter = 8.0;
const double kStatChipMinWidth = 36.0;

/// ✨ End overlay choreography knobs
const int kEndBoxFadeMs = 600; // general opacity fade for overlay
const int kGlowDelayMs = 400; // ⏱️ glow before compact box shows
const int kDelayBeforeFinalBoxMs = 0; // extra delay before compact box
const int kFadeInTimeMs = 450; // compact box fade-in time
const int kSlideUpDurationMs = 650; // slide up duration
const int kRevealDownDurationMs = 500; // expand/reveal duration
const double kSlideUpFromBottomPx = 120.0; // how far the compact box slides up

/// 🔧 NEW (separate anchors): where the compact end box stops before unveiling
/// (Y from the top of the step area below the close/progress zone)
const double finalYPositionAfterSlideUpSuccess = 120.0;
const double finalYPositionAfterSlideUpFail = 100.0;

// End box font sizes (consistent win/lose)
const double kEndTitleFont = 22;
const double kEndScoreFont = 18;
const double kEndBodyFont = 16;

/// ─────────────────────────────────────────────────────────────────
/// WORD POOLS
/// ─────────────────────────────────────────────────────────────────
const List<String> _qualitativeWords = <String>[
  "Color",
  "Mood",
  "Job",
  "Fruit",
  "Animal",
  "Sport",
  "Style",
  "Team",
  "Role",
  "Genre",
  "City",
  "Country",
  "Season",
  "Shape",
  "Brand",
];

const List<String> _quantitativeWords = <String>[
  "Age",
  "Height",
  "Weight",
  "Score",
  "Steps",
  "Speed",
  "Time",
  "Price",
  "Level",
  "Rank",
  "Days",
  "XP",
  "Rate",
  "Likes",
  "Units",
];

final Random _rng = Random();

class CatchQualGame extends StatefulWidget {
  final VoidCallback? onStepCompleted;
  final VoidCallback? onReset; // 👈 add this

  const CatchQualGame({super.key, this.onStepCompleted, this.onReset});

  @override
  State<CatchQualGame> createState() => _CatchQualGameState();
}

class _CatchQualGameState extends State<CatchQualGame>
    with TickerProviderStateMixin {
  late final AnimationController _ticker;
  late final Timer _spawnTimer;

  final List<_FallingWord> _active = [];
  final List<_FloatText> _fx = [];

  double _basketX = 40;
  double _basketTargetX = 40;
  int _score = 0;

  // Stats
  int _qualitativeCaught = 0;
  int _quantitativeCaught = 0;
  int _qualitativeMissed = 0;
  int _quantitativeAvoided = 0;

  Duration? _lastTick;
  double _vw = 0, _vh = 0;
  double _spawnAccumulator = 0;

  bool _started = false; // playing? shows HUD + basket + input plane
  bool _showEndBox = false;
  bool _didWin = false;

  // Prevents the pre-game pane flash during end sequence
  bool _inEndSequence = false;

  // Fade choreography
  bool _fadeScene = false; // fades header/words/basket/FX when overlay shows
  double _endBoxOpacity = 0.0; // fades end box container in
  bool _glowNow = false; // basket edge green before overlay appears

  // Compact → slide → expand
  bool _compactVisible = false; // first small box visible
  bool _compactSlidUp = false; // small box slid upward
  bool _revealed = false; // expanded content revealed

  @override
  void initState() {
    super.initState();
    _ticker =
        AnimationController(vsync: this, duration: const Duration(days: 1))
          ..addListener(_onTick)
          ..forward();

    _spawnTimer =
        Timer.periodic(const Duration(milliseconds: kSpawnTickMs), (_) {
      if (!mounted || !_started) return;
      final double t =
          (_ticker.lastElapsedDuration?.inMilliseconds ?? 0) / 1000.0;
      final double spawnRate = min(
          kSpawnMaxPerSecond, kSpawnPerSecond * (1.0 + kSpawnGrowthPerSec * t));
      _spawnAccumulator += spawnRate * (kSpawnTickMs / 1000.0);
      int n = _spawnAccumulator.floor();
      _spawnAccumulator -= n;
      while (n-- > 0) _trySpawnWord();
    });
  }

  @override
  void dispose() {
    _spawnTimer.cancel();
    _ticker.dispose();
    super.dispose();
  }

  // ────────────────────────────────────────────────────────────────
  // Game Loop
  // ────────────────────────────────────────────────────────────────
  void _onTick() {
    if (!_started) return;
    if (_vw <= 0 || _vh <= 0) return;

    final now = _ticker.lastElapsedDuration ?? Duration.zero;
    final dtMs =
        (_lastTick == null) ? 16 : max(1, (now - _lastTick!).inMilliseconds);
    _lastTick = now;

    final double dt = dtMs / 1000.0;
    final double t = now.inMilliseconds / 1000.0;

    final double speedMultiplier =
        min(kFallSpeedMaxMultiplier, 1.0 + kFallSpeedGrowthPerSec * t);
    final double dy = (kFallSpeed * speedMultiplier) * dt;

    final double basketTopY = _vh - kBasketBottomMargin - kBasketHeight;

    setState(() {
      // move basket
      if (kSmoothTapMove) {
        final double maxDx = kBasketMoveSpeed * dt;
        final double dx = (_basketTargetX - _basketX);
        _basketX =
            (dx.abs() <= maxDx) ? _basketTargetX : _basketX + maxDx * dx.sign;
      } else {
        _basketX = _basketTargetX;
      }

      // update words
      for (final w in _active) {
        w.y += dy;
        w.opacity = (((w.y - kSpawnStartY) / kFadeInDistance).clamp(0.0, 1.0));
      }

      // update FX
      for (final f in _fx) {
        f.ageMs += dtMs;
        f.y -= 0.04 * dtMs;
        f.opacity = (1.0 - f.ageMs / f.lifetimeMs).clamp(0.0, 1.0);
      }
      _fx.removeWhere((f) => f.ageMs >= f.lifetimeMs);

      // collisions
      final Rect basketRect =
          Rect.fromLTWH(_basketX, basketTopY, kBasketWidth, kBasketHeight);

      _active.removeWhere((w) {
        final Rect wordRect =
            Rect.fromLTWH(w.x, w.y, w.size.width, w.size.height);

        // Caught
        if (basketRect.overlaps(wordRect)) {
          final bool isQual = _qualitativeWords.contains(w.text);
          if (isQual) {
            _score += kScoreCorrect;
            _qualitativeCaught++;
          } else {
            _score += kScoreIncorrect;
            _quantitativeCaught++;
          }

          _spawnFx(
            text: isQual ? "+10 ✅" : "−10 ❌",
            x: basketRect.center.dx,
            y: basketRect.top - 10,
            color: isQual ? Colors.green : Colors.red,
          );

          if (_score >= kPointsToWin) {
            _endGame(true); // defer onStepCompleted until reveal finishes
          } else if (_score <= kPointsToLose) {
            _endGame(false);
          }
          return true;
        }

        // Missed (passed the basket level)
        if (w.y + w.size.height >= basketTopY) {
          if (_qualitativeWords.contains(w.text)) {
            _score += kScoreMissPenalty;
            _qualitativeMissed++;
            _spawnFx(
              text: "Miss −10",
              x: w.x + w.size.width / 2,
              y: basketTopY - 10,
              color: Colors.black87,
            );
          } else {
            _quantitativeAvoided++;
          }
          if (_score <= kPointsToLose) _endGame(false);
          return true;
        }
        return false;
      });
    });
  }

  void _endGame(bool didWin) {
    setState(() {
      _inEndSequence = true; // ← prevents pre-game flash
      _started = false;
      _didWin = didWin;

      // basket glow; scene still visible
      _glowNow = didWin;

      // reset end overlay states
      _showEndBox = false;
      _compactVisible = false;
      _compactSlidUp = false;
      _revealed = false;
      _fadeScene = false;
      _endBoxOpacity = 0.0;
    });

    // 1) Wait for glow to be visible before showing the first compact box
    Future.delayed(
        Duration(milliseconds: kGlowDelayMs + kDelayBeforeFinalBoxMs), () {
      if (!mounted) return;

      // start fading scene and show compact box
      setState(() {
        _fadeScene = true;
        _showEndBox = true;
      });

      // fade in the compact box
      Future.delayed(const Duration(milliseconds: 30), () {
        if (!mounted) return;
        setState(() {
          _endBoxOpacity = 1.0;
          _compactVisible = true;
        });
      });

      // 2) Hold compact box briefly, then slide it up to its anchor
      Future.delayed(const Duration(seconds: 2), () {
        if (!mounted) return;
        setState(() {
          _compactSlidUp = true;
        });

        // 3) After slide finishes, reveal expanded stats/advice downward
        Future.delayed(Duration(milliseconds: kSlideUpDurationMs), () {
          if (!mounted) return;
          setState(() {
            _revealed = true;
          });

          // Only after reveal finishes, allow the lesson "Continue" to appear
          if (_didWin && widget.onStepCompleted != null) {
            Future.delayed(
              Duration(milliseconds: kRevealDownDurationMs + 150),
              () => widget.onStepCompleted?.call(),
            );
          }
        });
      });
    });

    // Turn glow off once scene starts fading (just in case)
    Future.delayed(Duration(milliseconds: kGlowDelayMs), () {
      if (!mounted) return;
      setState(() => _glowNow = false);
    });
  }

  // ────────────────────────────────────────────────────────────────
  // Spawning & Input
  // ────────────────────────────────────────────────────────────────
  void _spawnFx(
      {required String text,
      required double x,
      required double y,
      required Color color}) {
    _fx.add(_FloatText(
        text: text, x: x, y: y, color: color, lifetimeMs: 900, fontSize: 16));
  }

  void _trySpawnWord() {
    if (!mounted) return;
    if (_active.length >= kMaxActiveWords) return;
    if (_vw <= 0) return;

    final bool pickQual = _rng.nextBool();
    final List<String> pool = pickQual ? _qualitativeWords : _quantitativeWords;
    final String text = pool[_rng.nextInt(pool.length)];

    final double fontSize =
        _rng.nextDouble() * (kWordFontMax - kWordFontMin) + kWordFontMin;
    final Color color = Colors.primaries[_rng.nextInt(Colors.primaries.length)];
    final TextStyle style = GoogleFonts.lato(
        fontSize: fontSize, fontWeight: FontWeight.w800, color: color);

    final TextPainter tp = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: TextDirection.ltr,
      maxLines: 1,
    )..layout();
    final Size wordSize = tp.size;

    const int maxTries = 28;
    double? xCandidate;

    for (int i = 0; i < maxTries; i++) {
      final double minX = kSpawnSidePadding;
      final double maxX = max(minX, _vw - kSpawnSidePadding - wordSize.width);
      final double x = _rng.nextDouble() * (maxX - minX) + minX;

      final Rect newRect =
          Rect.fromLTWH(x, kSpawnStartY, wordSize.width, wordSize.height);

      bool overlaps = false;
      for (final w in _active) {
        final Rect r = Rect.fromLTWH(w.x, w.y, w.size.width, w.size.height);
        final bool horizontalSeparated =
            (newRect.right + kMinHorizontalGap <= r.left) ||
                (r.right + kMinHorizontalGap <= newRect.left);
        final bool verticalSeparated =
            (newRect.top >= r.bottom + kMinVerticalGap) ||
                (r.top >= newRect.bottom + kMinVerticalGap);
        if (!(horizontalSeparated || verticalSeparated)) {
          overlaps = true;
          break;
        }
      }
      if (!overlaps) {
        xCandidate = x;
        break;
      }
    }

    if (xCandidate == null) return;

    setState(() {
      _active.add(_FallingWord(
        text: text,
        x: xCandidate!,
        y: kSpawnStartY,
        size: wordSize,
        painter: tp,
        opacity: 0.0,
      ));
    });
  }

  void _moveBasketByDrag(double dx) {
    final double next = (_basketTargetX + dx * kBasketDragSensitivity)
        .clamp(0.0, (_vw - kBasketWidth).clamp(0.0, double.infinity));
    setState(() => _basketTargetX = next);
  }

  void _moveBasketToTap(double tapDx) {
    final double centered = (tapDx - kBasketWidth / 2)
        .clamp(0.0, (_vw - kBasketWidth).clamp(0.0, double.infinity));
    setState(() => _basketTargetX = centered);
  }

  void _startGame() {
    widget.onReset?.call(); // 👈 hide Continue on Try Again

    setState(() {
      _inEndSequence = false;
      _active.clear();
      _fx.clear();
      _score = 0;
      _qualitativeCaught = 0;
      _quantitativeCaught = 0;
      _qualitativeMissed = 0;
      _quantitativeAvoided = 0;
      _spawnAccumulator = 0;
      _showEndBox = false;
      _fadeScene = false;
      _endBoxOpacity = 0.0;
      _compactVisible = false;
      _compactSlidUp = false;
      _revealed = false;
      _glowNow = false;
      _started = true;
    });
  }

  Widget _narrowBox({required Widget child, Color? color}) {
    final deco = LessonText.defaultBoxDecoration().copyWith(color: color);
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: LessonText.maxTextWidth),
        child: LessonText.box(decoration: deco, child: child),
      ),
    );
  }

  // ────────────────────────────────────────────────────────────────
  // UI
  // ────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        _vw = constraints.maxWidth;
        _vh = constraints.maxHeight;
        final double basketTopY = _vh - kBasketBottomMargin - kBasketHeight;

        return Stack(
          children: [
            // HUD: title + score (hidden until Start Game)
            Positioned(
              top: kHeaderBoxesTopMargin,
              left: 0,
              right: 0,
              child: IgnorePointer(
                ignoring: true,
                child: AnimatedOpacity(
                  opacity: (!_fadeScene && _started) ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 350),
                  child: Column(
                    children: [
                      _narrowBox(
                        color: const Color(0xFFE8F5E9),
                        child: Text(
                          "Catch all Qualitative Words 🧺",
                          textAlign: TextAlign.center,
                          style: GoogleFonts.lato(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            color: Colors.green.shade900,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      _narrowBox(
                        color: const Color(0xFFE3F2FD),
                        child: Text(
                          "Score: $_score",
                          textAlign: TextAlign.center,
                          style: GoogleFonts.lato(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: Colors.blueGrey.shade900,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Falling words (fade out on end)
            ..._active.map(
              (w) => Positioned(
                left: w.x,
                top: w.y,
                child: AnimatedOpacity(
                  opacity: _fadeScene ? 0.0 : w.opacity,
                  duration: const Duration(milliseconds: kEndBoxFadeMs),
                  child: SizedBox(
                    width: w.size.width,
                    height: w.size.height,
                    child: CustomPaint(painter: _WordPainter(w)),
                  ),
                ),
              ),
            ),

            // Floating feedback (fade out on end)
            ..._fx.map(
              (f) => Positioned(
                left: f.x,
                top: f.y,
                child: AnimatedOpacity(
                  opacity: _fadeScene ? 0.0 : f.opacity,
                  duration: const Duration(milliseconds: kEndBoxFadeMs),
                  child: Text(
                    f.text,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.lato(
                      fontSize: f.fontSize,
                      fontWeight: FontWeight.w700,
                      color: f.color,
                    ),
                  ),
                ),
              ),
            ),

            // Basket (hidden until Start Game; glows green briefly on win)
            Positioned(
              left: _basketX,
              top: basketTopY,
              child: AnimatedOpacity(
                opacity: (_fadeScene || !_started) ? 0.0 : 1.0,
                duration: const Duration(milliseconds: 350),
                child: _UBasketPlaceholder(
                  width: kBasketWidth,
                  height: kBasketHeight,
                  glowGreen: _glowNow,
                ),
              ),
            ),

            // INPUT PLANE — full-screen, only while playing
            // ✅ Updated input plane: ignores touches in the top safe inset
            if (_started && !_showEndBox)
              Positioned.fill(
                child: Listener(
                  behavior: HitTestBehavior
                      .translucent, // allow pass-through when not handled
                  onPointerDown: (e) {
                    if (e.localPosition.dy > kTopSafeInsetForClose) {
                      _moveBasketToTap(e.localPosition.dx);
                    }
                    // else: do nothing, let tap fall through
                  },
                  onPointerMove: (e) {
                    if (e.localPosition.dy > kTopSafeInsetForClose) {
                      _moveBasketByDrag(e.delta.dx);
                    }
                    // else: ignore drag in top safe zone
                  },
                ),
              ),

            // PRE-GAME PANE (only middle two boxes + Start button)
            if (!_started && !_showEndBox && !_inEndSequence)
              Positioned.fill(
                top: kTopSafeInsetForClose,
                child: Align(
                  alignment: Alignment.topCenter,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const SizedBox(height: kIntroBoxesTopMargin),
                        _narrowBox(
                          color: const Color(0xFFFFF3E0),
                          child: Text(
                            "🎮 Catch the Qualitative!",
                            textAlign: TextAlign.center,
                            style: GoogleFonts.lato(
                              fontSize: 22,
                              fontWeight: FontWeight.w900,
                              color: Colors.deepOrange.shade900,
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        _narrowBox(
                          color: const Color(0xFFF3E5F5),
                          child: Text(
                            "🏆 Reach 100 points to win.\n"
                            "✅ Qualitative +10\n"
                            "❌ Quantitative −10\n"
                            "💥 Hit −100 and you lose.",
                            textAlign: TextAlign.center,
                            style: GoogleFonts.lato(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              height: 1.35,
                              color: Colors.purple.shade900,
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: _startGame,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 50, vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            elevation: 6,
                            backgroundColor: Colors.deepOrange,
                            foregroundColor: Colors.white,
                            textStyle: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          child: const Text("🚀 Start Game"),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

            // End Game Overlay (compact → slide up to fixed Y → reveal downward)
            if (_showEndBox)
              Positioned.fill(
                child: Stack(
                  children: [
                    // soft scrim
                    const IgnorePointer(
                      ignoring: true,
                      child: ColoredBox(color: Color(0xF0FFFFFF)),
                    ),

                    // Overlay content below safe zone
                    Positioned.fill(
                      top: kTopSafeInsetForClose,
                      child: AnimatedOpacity(
                        opacity: _endBoxOpacity,
                        duration: Duration(milliseconds: kFadeInTimeMs),
                        child: Stack(
                          children: [
                            AnimatedPositioned(
                              duration:
                                  Duration(milliseconds: kSlideUpDurationMs),
                              curve: Curves.easeInOutCubic,
                              top: _compactSlidUp
                                  ? (_didWin
                                      ? finalYPositionAfterSlideUpSuccess
                                      : finalYPositionAfterSlideUpFail)
                                  : (_didWin
                                          ? finalYPositionAfterSlideUpSuccess
                                          : finalYPositionAfterSlideUpFail) +
                                      kSlideUpFromBottomPx,
                              left: 0,
                              right: 0,
                              child: Center(
                                child: AnimatedSize(
                                  duration: Duration(
                                      milliseconds: kRevealDownDurationMs),
                                  curve: Curves.easeOutCubic,
                                  alignment: Alignment
                                      .topCenter, // expand downward only
                                  child: _buildEndCard(revealed: _revealed),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        );
      },
    );
  }

  // Unified builder for the end card (win stats OR lose advice)
  Widget _buildEndCard({Key? key, required bool revealed}) {
    return _narrowBox(
      child: Padding(
        key: key,
        padding: EdgeInsets.symmetric(
          horizontal: max(kStatsLeftGutter, kStatsRightGutter),
          vertical: 8,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              _didWin ? "🎉 Congratulations! You win!" : "💥 Game Over",
              textAlign: TextAlign.center,
              style: GoogleFonts.lato(
                fontSize: kEndTitleFont,
                fontWeight: FontWeight.w900,
                color: _didWin ? Colors.green.shade900 : Colors.red.shade900,
              ),
            ),
            const SizedBox(height: 8),
            LessonText.sentence(
              [
                LessonText.word("Final", Colors.black87,
                    fontWeight: FontWeight.w700, fontSize: kEndScoreFont),
                LessonText.word("Score:", Colors.black87,
                    fontWeight: FontWeight.w700, fontSize: kEndScoreFont),
                LessonText.word("$_score", Colors.black87,
                    fontWeight: FontWeight.w900, fontSize: kEndScoreFont),
              ],
              alignment: WrapAlignment.center,
            ),

            // Revealed content only after slide completes
            if (revealed) ...[
              const SizedBox(height: 14),
              if (_didWin) ...[
                _statRow(
                    "🎯 Qualitative caught", _qualitativeCaught, Colors.green),
                _statRow(
                    "❌ Quantitative caught", _quantitativeCaught, Colors.red),
                _statRow("🛡️ Quantitative avoided", _quantitativeAvoided,
                    Colors.blue),
                _statRow(
                    "📉 Qualitative missed", _qualitativeMissed, Colors.orange),
                const SizedBox(height: 14),
                Center(
                  child: ElevatedButton.icon(
                    onPressed: _startGame,
                    icon: const Icon(Icons.refresh),
                    label: const Text("Try Again"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 4, 160, 124),
                      foregroundColor: Colors.white,
                      elevation: 2,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 28, vertical: 12),
                      textStyle: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
              ] else ...[
                const SizedBox(height: 6),
                LessonText.sentence(
                  [
                    LessonText.word("💡", Colors.amber.shade800,
                        fontSize: kEndBodyFont),
                    LessonText.word("Ask yourself:", Colors.black87,
                        fontWeight: FontWeight.w900, fontSize: kEndBodyFont),
                  ],
                  alignment: WrapAlignment.center,
                ),
                const SizedBox(height: 6),
                LessonText.sentence(
                  [
                    LessonText.word("Can", Colors.black87,
                        fontSize: kEndBodyFont),
                    LessonText.word("you", Colors.black87,
                        fontSize: kEndBodyFont),
                    LessonText.word("measure", Colors.indigo,
                        fontWeight: FontWeight.w900, fontSize: kEndBodyFont),
                    LessonText.word("this", Colors.black87,
                        fontSize: kEndBodyFont),
                    LessonText.word("word?", Colors.black87,
                        fontSize: kEndBodyFont),
                    LessonText.word("Can", Colors.black87,
                        fontSize: kEndBodyFont),
                    LessonText.word("you", Colors.black87,
                        fontSize: kEndBodyFont),
                    LessonText.word("do", Colors.indigo,
                        fontWeight: FontWeight.w900, fontSize: kEndBodyFont),
                    LessonText.word("math", Colors.indigo,
                        fontWeight: FontWeight.w900, fontSize: kEndBodyFont),
                    LessonText.word("with", Colors.black87,
                        fontSize: kEndBodyFont),
                    LessonText.word("it?", Colors.black87,
                        fontSize: kEndBodyFont),
                  ],
                  alignment: WrapAlignment.center,
                ),
                const SizedBox(height: 6),
                LessonText.sentence(
                  [
                    LessonText.word("If", Colors.black87,
                        fontSize: kEndBodyFont),
                    LessonText.word("yes", Colors.black87,
                        fontSize: kEndBodyFont),
                    LessonText.word("→", Colors.black45,
                        fontSize: kEndBodyFont),
                    LessonText.word("Quantitative", Colors.red.shade700,
                        fontWeight: FontWeight.w900, fontSize: kEndBodyFont),
                  ],
                  alignment: WrapAlignment.center,
                ),
                LessonText.sentence(
                  [
                    LessonText.word("If", Colors.black87,
                        fontSize: kEndBodyFont),
                    LessonText.word("not", Colors.black87,
                        fontSize: kEndBodyFont),
                    LessonText.word("→", Colors.black45,
                        fontSize: kEndBodyFont),
                    LessonText.word("Qualitative", Colors.green.shade700,
                        fontWeight: FontWeight.w900, fontSize: kEndBodyFont),
                  ],
                  alignment: WrapAlignment.center,
                ),
                const SizedBox(height: 6),
                LessonText.sentence(
                  [
                    LessonText.word("E.g.", Colors.blue.shade700,
                        fontSize: kEndBodyFont),
                    LessonText.word("You", Colors.blue.shade700,
                        fontSize: kEndBodyFont),
                    LessonText.word("can't", Colors.blue.shade700,
                        fontSize: kEndBodyFont),
                    LessonText.word("measure", Colors.blue.shade700,
                        fontSize: kEndBodyFont),
                    LessonText.word("colors,", Colors.blue.shade700,
                        fontSize: kEndBodyFont),
                    LessonText.word("but", Colors.blue.shade700,
                        fontSize: kEndBodyFont),
                    LessonText.word("you", Colors.blue.shade700,
                        fontSize: kEndBodyFont),
                    LessonText.word("can", Colors.blue.shade700,
                        fontSize: kEndBodyFont),
                    LessonText.word("measure", Colors.blue.shade700,
                        fontSize: kEndBodyFont),
                    LessonText.word("height", Colors.blue.shade700,
                        fontSize: kEndBodyFont),
                    LessonText.word("or", Colors.blue.shade700,
                        fontSize: kEndBodyFont),
                    LessonText.word("score.", Colors.blue.shade700,
                        fontSize: kEndBodyFont),
                  ],
                  alignment: WrapAlignment.center,
                ),
                const SizedBox(height: 14),
                Center(
                  child: ElevatedButton.icon(
                    onPressed: _startGame,
                    icon: const Icon(Icons.refresh),
                    label: const Text("Try Again"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red.shade300,
                      foregroundColor: Colors.white,
                      elevation: 2,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 28, vertical: 12),
                      textStyle: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }

  Widget _statRow(String label, int value, Color color) {
    return Padding(
      padding: EdgeInsets.only(
        left: kStatsLeftGutter,
        right: kStatsRightGutter,
        top: 4,
        bottom: 4,
      ),
      child: Row(
        children: [
          Expanded(
            child: LessonText.sentence(
              [
                LessonText.word(label, color,
                    fontWeight: FontWeight.w600, fontSize: kEndBodyFont)
              ],
              constrainWidth: false,
            ),
          ),
          ConstrainedBox(
            constraints: BoxConstraints(minWidth: kStatChipMinWidth),
            child: Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: color.withOpacity(0.10),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: color.withOpacity(0.5)),
              ),
              child: Text(
                "$value",
                style: GoogleFonts.lato(
                  fontSize: kEndBodyFont,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// MODELS
class _FallingWord {
  final String text;
  double x;
  double y;
  double opacity;
  final Size size;
  final TextPainter painter;

  _FallingWord({
    required this.text,
    required this.x,
    required this.y,
    required this.size,
    required this.painter,
    this.opacity = 0.0,
  });
}

class _FloatText {
  final String text;
  final double fontSize;
  final Color color;
  final int lifetimeMs;

  double x;
  double y;
  int ageMs = 0;
  double opacity = 1.0;

  _FloatText({
    required this.text,
    required this.x,
    required this.y,
    required this.color,
    required this.lifetimeMs,
    this.fontSize = 16,
  });
}

/// PAINTERS
class _WordPainter extends CustomPainter {
  final _FallingWord word;
  _WordPainter(this.word);

  @override
  void paint(Canvas canvas, Size size) {
    word.painter.paint(canvas, Offset.zero);
  }

  @override
  bool shouldRepaint(covariant _WordPainter oldDelegate) {
    return oldDelegate.word.painter.text != word.painter.text;
  }
}

/// Basket (bold black U, glows green on win)
class _UBasketPlaceholder extends StatelessWidget {
  final double width;
  final double height;
  final bool glowGreen;
  const _UBasketPlaceholder({
    required this.width,
    required this.height,
    this.glowGreen = false,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
        painter: _UBasketPainter(glowGreen: glowGreen),
        size: Size(width, height));
  }
}

class _UBasketPainter extends CustomPainter {
  final bool glowGreen;
  _UBasketPainter({this.glowGreen = false});

  @override
  void paint(Canvas canvas, Size size) {
    final Paint stroke = Paint()
      ..color = glowGreen ? Colors.green : Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6;

    final Paint fill = Paint()
      ..color = Colors.black.withOpacity(0.08)
      ..style = PaintingStyle.fill;

    final RRect bowl = RRect.fromRectAndCorners(
      Rect.fromLTWH(0, 0, size.width, size.height),
      topLeft: const Radius.circular(10),
      topRight: const Radius.circular(10),
      bottomLeft: const Radius.circular(18),
      bottomRight: const Radius.circular(18),
    );
    canvas.drawRRect(bowl, fill);

    final Path u = Path()
      ..moveTo(0, 0)
      ..lineTo(0, size.height)
      ..lineTo(size.width, size.height)
      ..lineTo(size.width, 0);
    canvas.drawPath(u, stroke);
  }

  @override
  bool shouldRepaint(covariant _UBasketPainter oldDelegate) =>
      oldDelegate.glowGreen != glowGreen;
}
