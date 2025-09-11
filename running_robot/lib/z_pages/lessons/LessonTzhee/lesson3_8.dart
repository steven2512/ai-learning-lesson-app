// lib/z_pages/lessons/LessonTzhee/lesson3_7.dart
// ✅ LessonStepSeven — Falling Words Game (catch QUALITATIVE only)
// ★ Uses LayoutBuilder so basket renders inside the constrained step area.
// ★ Intro LessonText.box (narrow, colorful, with emojis) + Start Game just below.
// ★ Larger word sizes, 100+ word pool, difficulty ramps over time.
// ★ Miss penalty only when the missed word was QUALITATIVE.

import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
// LessonText helpers (your file)
import 'package:running_robot/z_pages/assets/lessonAssets/helpful_tools.dart';

/// ─────────────────────────────────────────────────────────────────
/// 🔧 GLOBAL TUNING KNOBS
/// ─────────────────────────────────────────────────────────────────
const double kBasketWidth = 140;
const double kBasketHeight = 60;
const double kBasketBottomMargin = 40;

const double kBasketDragSensitivity = 1.0;
const bool kSmoothTapMove = true;
const double kBasketMoveSpeed = 560;

// ★ WORD FONT RANGE
const double kWordFontMin = 26;
const double kWordFontMax = 34;

// Base physics
const double kFallSpeed = 140; // px/sec (base)
const double kSpawnPerSecond = 1.2; // base spawns/sec

// ★ Difficulty scaling
const double kFallSpeedGrowthPerSec = 0.020; // +2% / sec
const double kFallSpeedMaxMultiplier = 2.6; // cap
const double kSpawnGrowthPerSec = 0.020; // +2% / sec
const double kSpawnMaxPerSecond = 5.0; // cap
const int kSpawnTickMs = 100; // scheduler tick

const int kMaxActiveWords = 9;
const double kMinHorizontalGap = 110;
const double kSpawnSidePadding = 16;
const double kSpawnStartY = -120;
const double kFadeInDistance = 160;

// ★ Scoring & win/lose
const int kPointsToWin = 50;
const int kPointsToLose = -50;
const int kScoreCorrect = 5; // correct catch (qual)
const int kScoreIncorrect = -5; // wrong catch (quant caught)
const bool kPenaltyOnMiss = true; // only applies to QUAL (see logic)
const int kScoreMissPenalty = -5;

// kept for compatibility (continue button)
const int kTargetQualitative = 10;

// ★ NEW: Global top margins you can tweak
const double kHeaderBoxesTopMargin = 60.0; // header boxes (in-game) from top
const double kIntroBoxesTopMargin = 12.0; // intro overlay space before 1st box

/// ─────────────────────────────────────────────────────────────────
/// WORD POOLS (≈120 total)
/// ─────────────────────────────────────────────────────────────────
const List<String> _qualitativeWords = <String>[
  "Color",
  "Eye Color",
  "Hair Color",
  "Texture",
  "Flavor",
  "Scent",
  "Mood",
  "Emotion",
  "Hobby",
  "Sport",
  "Team",
  "Position",
  "Role",
  "Job Title",
  "Department",
  "College Major",
  "Subject",
  "Fruit",
  "Vegetable",
  "Animal",
  "Bird",
  "Fish",
  "Flower",
  "Tree",
  "Season",
  "Weather",
  "Pattern",
  "Shape",
  "Style",
  "Material",
  "Brand",
  "Model Name",
  "OS",
  "Browser",
  "Device Type",
  "File Type",
  "Payment Method",
  "Membership Tier",
  "Subscription Plan",
  "Status",
  "Genre (Book)",
  "Genre (Movie)",
  "Genre (Game)",
  "Music Instrument",
  "Transport Mode",
  "Station Name",
  "Airport Code",
  "Currency Code",
  "Country",
  "Country of Birth",
  "City",
  "Region",
  "Continent",
  "Language",
  "Accent",
  "Dialekt",
  "Zodiac Sign",
  "Blood Type",
  "Yes/No",
  "True/False",
  "Priority",
  "Risk Level",
  "Access Level",
  "Ticket Type",
  "Seat Class",
  "Meal Preference",
  "Allergy Type",
  "Pet Type",
  "Coffee Roast",
  "Tea Type",
  "Ice Cream Flavor",
  "Shirt Size (S/M/L)",
  "Color Family",
  "Fabric",
  "Finish",
  "Packaging Type",
  "Warranty Type",
  "Service Plan",
  "Badge",
  "Achievement",
  "Label",
  "Category",
  "Tag",
  "Brand Family",
];

const List<String> _quantitativeWords = <String>[
  "Age",
  "Height",
  "Weight",
  "Score",
  "Count",
  "Quantity",
  "Steps",
  "Calories",
  "Time (s)",
  "Speed",
  "Distance",
  "Price",
  "Revenue",
  "Cost",
  "Profit",
  "Margin %",
  "Discount %",
  "Tax %",
  "Rate",
  "Temperature",
  "Humidity",
  "Rainfall",
  "Wind Speed",
  "Voltage",
  "Current",
  "Power",
  "Frequency",
  "Bandwidth",
  "Bitrate",
  "File Size",
  "Resolution Width",
  "Resolution Height",
  "Frame Rate",
  "Pixels",
  "Latitude",
  "Longitude",
  "Altitude",
  "Pressure",
  "Page Views",
  "Clicks",
  "CTR %",
  "Impressions",
  "Bounce %",
  "GPA",
  "Test Score",
  "Queue Length",
  "Wait Time",
  "Service Time",
  "Run Time",
  "Compile Time",
  "Memory (MB)",
  "CPU %",
  "GPU %",
  "Ping (ms)",
  "Latency (ms)",
  "Throughput",
  "Packets",
  "Errors",
  "Stars",
  "Rating",
  "Rank",
  "Level",
  "XP",
  "Lives",
  "Books Read",
  "Tasks Done",
  "Days",
  "Hours",
  "Minutes",
  "Likes",
  "Followers",
  "Subscribers",
  "Shares",
  "Comments",
  "Tickets",
  "Orders",
  "Units",
  "Sessions",
  "Installs",
];

final Random _rng = Random();

class LessonStepSeven extends StatefulWidget {
  final VoidCallback? onStepCompleted;
  const LessonStepSeven({super.key, this.onStepCompleted});

  @override
  State<LessonStepSeven> createState() => _LessonStepSevenState();
}

class _LessonStepSevenState extends State<LessonStepSeven>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ticker;
  late final Timer _spawnTimer;

  final List<_FallingWord> _active = [];
  final List<_FloatText> _fx = [];

  double _basketX = 40;
  double _basketTargetX = 40;
  int _score = 0;
  int _qualitativeCaught = 0;

  Duration? _lastTick;
  double _vw = 0, _vh = 0;

  // spawn scheduler (dynamic rate)
  double _spawnAccumulator = 0;

  // intro overlay state
  bool _started = false;
  bool _showIntro = true;
  double _introOpacity = 1.0;

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

    // dynamic fall speed
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
          _score += isQual ? kScoreCorrect : kScoreIncorrect;
          if (isQual) _qualitativeCaught++;

          _spawnFx(
            text: isQual ? "Correct ✅ +5" : "Wrong ❌ −5",
            x: basketRect.center.dx,
            y: basketRect.top - 10,
            color: isQual ? Colors.green : Colors.red,
          );

          if (_score >= kPointsToWin) {
            widget.onStepCompleted?.call(); // unlock continue
            _spawnFx(
                text: "You win! 🏆",
                x: basketRect.center.dx,
                y: basketRect.top - 40,
                color: Colors.black);
            _started = false;
          } else if (_score <= kPointsToLose) {
            _spawnFx(
                text: "You lose! 💥",
                x: basketRect.center.dx,
                y: basketRect.top - 40,
                color: Colors.black);
            _started = false;
            _showIntro = true;
            _introOpacity = 1.0;
          }
          return true;
        }

        // Missed (only penalize if it was QUALITATIVE)
        if (w.y + w.size.height >= basketTopY) {
          final bool isQual = _qualitativeWords.contains(w.text);
          if (kPenaltyOnMiss && isQual) {
            _score += kScoreMissPenalty;
            _spawnFx(
              text: "Miss (Qual) −5",
              x: w.x + w.size.width / 2,
              y: basketTopY - 10,
              color: Colors.black87,
            );
          } else {
            _spawnFx(
              text: "Miss",
              x: w.x + w.size.width / 2,
              y: basketTopY - 10,
              color: Colors.black45,
            );
          }

          if (_score <= kPointsToLose) {
            _started = false;
            _showIntro = true;
            _introOpacity = 1.0;
            _spawnFx(
                text: "You lose! 💥",
                x: _vw / 2,
                y: basketTopY - 40,
                color: Colors.black);
          }
          return true;
        }
        return false;
      });
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

    // choose non-overlapping horizontal slot
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
        if (!horizontalSeparated) {
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
    setState(() {
      _active.clear();
      _fx.clear();
      _score = 0;
      _qualitativeCaught = 0;
      _spawnAccumulator = 0;
      _introOpacity = 0.0;
    });
    Future.delayed(const Duration(milliseconds: 250), () {
      if (!mounted) return;
      setState(() {
        _showIntro = false;
        _started = true;
      });
    });
  }

  // keep LessonText.box narrow like other lessons
  Widget _narrowBox({required Widget child, Color? color}) {
    final deco = LessonText.defaultBoxDecoration().copyWith(color: color);
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: LessonText.maxTextWidth),
        child: LessonText.box(decoration: deco, child: child),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: LayoutBuilder(
        builder: (context, constraints) {
          _vw = constraints.maxWidth;
          _vh = constraints.maxHeight;
          final double basketTopY = _vh - kBasketBottomMargin - kBasketHeight;

          return GestureDetector(
            behavior: HitTestBehavior.opaque,
            onPanUpdate: (d) => _moveBasketByDrag(d.delta.dx),
            onTapDown: (d) => _moveBasketToTap(d.localPosition.dx),
            child: Stack(
              children: [
                // ── Header boxes (narrow, colorful) ──
                Positioned(
                  top: kHeaderBoxesTopMargin, // ★ uses global
                  left: 0,
                  right: 0,
                  child: Column(
                    children: [
                      _narrowBox(
                        color: const Color(0xFFE8F5E9), // light green
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
                        color: const Color(0xFFE3F2FD), // light blue
                        child: Text(
                          "Score: $_score    |    Qual caught: $_qualitativeCaught",
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

                // Falling words
                ..._active.map(
                  (w) => Positioned(
                    left: w.x,
                    top: w.y,
                    child: Opacity(
                      opacity: w.opacity,
                      child: SizedBox(
                        width: w.size.width,
                        height: w.size.height,
                        child: CustomPaint(painter: _WordPainter(w)),
                      ),
                    ),
                  ),
                ),

                // Floating feedback
                ..._fx.map(
                  (f) => Positioned(
                    left: f.x,
                    top: f.y,
                    child: Opacity(
                      opacity: f.opacity,
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

                // Basket
                Positioned(
                  left: _basketX,
                  top: basketTopY,
                  child: _UBasketPlaceholder(
                      width: kBasketWidth, height: kBasketHeight),
                ),

                // ── Intro overlay (narrow boxes + button directly under rules) ──
                if (_showIntro)
                  Positioned.fill(
                    child: AnimatedOpacity(
                      opacity: _introOpacity,
                      duration: const Duration(milliseconds: 250),
                      child: Container(
                        color: Colors.white.withOpacity(0.94),
                        alignment: Alignment.topCenter,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 14),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            SizedBox(
                                height: kIntroBoxesTopMargin), // ★ uses global
                            _narrowBox(
                              color: const Color(0xFFFFF3E0), // light orange
                              child: Text(
                                "🎮 Mini-Game: Catch The Qualitative",
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
                              color: const Color(0xFFF3E5F5), // light purple
                              child: Text(
                                "🧺 Use the basket at the bottom to catch as many Qualitative WORDS as possible.\n\n"
                                "🏆 Reach 50 points to win.\n"
                                "💥 Hit −50 points and you lose.\n\n"
                                "✅ Correct catch (Qual): +5\n"
                                "❌ Wrong catch (Quant): −5\n"
                                "😬 Missed Qualitative: −5\n"
                                "😌 Missed Quantitative: 0",
                                textAlign: TextAlign.left,
                                style: GoogleFonts.lato(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  height: 1.35,
                                  color: Colors.purple.shade900,
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            Center(
                              child: ConstrainedBox(
                                constraints: const BoxConstraints(
                                    maxWidth: LessonText.maxTextWidth),
                                child: ElevatedButton(
                                  onPressed: _startGame,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.deepOrange,
                                    foregroundColor: Colors.white,
                                    shape: const StadiumBorder(),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 28, vertical: 14),
                                    textStyle: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w900),
                                    elevation: 3,
                                  ),
                                  child: const Text("Start Game"),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
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

/// Basket (bold black U)
class _UBasketPlaceholder extends StatelessWidget {
  final double width;
  final double height;
  const _UBasketPlaceholder({required this.width, required this.height});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(painter: _UBasketPainter(), size: Size(width, height));
  }
}

class _UBasketPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Paint stroke = Paint()
      ..color = Colors.black
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
  bool shouldRepaint(covariant _UBasketPainter oldDelegate) => false;
}
