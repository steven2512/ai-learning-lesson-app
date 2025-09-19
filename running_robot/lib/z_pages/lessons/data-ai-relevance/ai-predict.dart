// FILE: lib/z_pages/lessons/data-ai-relevance/ai_predict.dart
import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:running_robot/z_pages/assets/lessonAssets/helpful_tools.dart';

/// ─────────────────────────────────────────────────────────────────────────
/// Colors
/// ─────────────────────────────────────────────────────────────────────────
const Color aiPink = Color(0xFFE91E63);
const Color titleInk = Colors.black87;
const Color houseNumRed = Color(0xFFE53935); // "4" in House 4
const Color sizeOrange = Color(0xFFFF6D00); // "500 m²"
const Color priceGreen = Color.fromARGB(255, 0, 163, 54);

/// Price badge (simple black-border pill)
const Color priceBadgeBg = Colors.white;
const Color priceBadgeBorder = Colors.black;
const int kPriceBadgeAnimMs = 180;

/// ─────────────────────────────────────────────────────────────────────────
/// Layout
/// ─────────────────────────────────────────────────────────────────────────
const double headerFontSize = 20;
const double sceneHeight = 360;

/// ─────────────────────────────────────────────────────────────────────────
/// Motion knobs (≈15s total when kLoop = true)
/// ─────────────────────────────────────────────────────────────────────────
const bool kLoop = true; // repeat the whole sequence
const int kStartDelayMs = 200;

// Each "page turn" (we're sliding/tilting, not a 3D flip)
const int kTurnMs = 600; // duration of each turn
const int kHoldMs = 1200; // hold between page turns (1..3)
const int kRevealHoldMs = 1200; // hold after page 4 shows '?'
const int kThinkingMs = 1800; // "thinking" pause
const int kGuessHoldMs = 6000; // hold on final guess to land near 15s

// Geometry of the turn (counter-clockwise)
const double kTurnAngleRad = -math.pi / 18; // subtle CCW twist
const double kSlideOutPx = 140; // outgoing slides left INSIDE box
const double kSlideInStartPx = 220; // incoming starts just outside R
const double kOvershootPx = 14; // slight left overshoot → settle

class AIPredict extends StatefulWidget {
  const AIPredict({super.key});
  @override
  State<AIPredict> createState() => _AIPredictState();
}

enum _Phase { page1, page2, page3, page4ShowUnknown, thinking, guessed }

class _AIPredictState extends State<AIPredict> with TickerProviderStateMixin {
  _Phase _phase = _Phase.page1;

  /// Turn controller (0→1 for each counter-clockwise “turn”)
  late final AnimationController _turnCtrl;

  /// Pops: house number + size on every landing page
  late final AnimationController _pageNumPopCtrl;

  /// Pop: final price on guess
  late final AnimationController _guessPopCtrl;

  /// Current and next page indices (0..3 → House 1..4)
  int _currentIndex = 0;
  int? _nextIndex;

  final List<Timer> _timers = [];

  @override
  void initState() {
    super.initState();

    _turnCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: kTurnMs),
    );

    _pageNumPopCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 280),
    );

    _guessPopCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 380),
      lowerBound: 0.80, // stronger pop
      upperBound: 1.10,
    );

    Future.delayed(const Duration(milliseconds: kStartDelayMs), _runStoryboard);
  }

  void _runStoryboard() {
    int t = 0;

    void turnTo(int idx, _Phase p) {
      _chain(Duration(milliseconds: t),
          () => _turnTo(idx, then: () => _setPhase(p)));
      t += kTurnMs;
      _chain(Duration(milliseconds: t), _popNumbers);
      t += (p == _Phase.page4ShowUnknown ? kRevealHoldMs : kHoldMs);
    }

    // Page 1 (visible “turn to self” so there’s always motion)
    turnTo(0, _Phase.page1);

    // Page 2
    turnTo(1, _Phase.page2);

    // Page 3
    turnTo(2, _Phase.page3);

    // Page 4 shows '?'
    turnTo(3, _Phase.page4ShowUnknown);

    // Thinking
    _chain(Duration(milliseconds: t), () => _setPhase(_Phase.thinking));
    t += kThinkingMs;

    // Final guess: pop price badge
    _chain(Duration(milliseconds: t), () {
      _setPhase(_Phase.guessed);
      _guessPopCtrl.forward(from: 0.80);
    });
    t += kGuessHoldMs;

    // Loop if desired
    if (kLoop) {
      _chain(Duration(milliseconds: t), () {
        if (!mounted) return;
        _resetAll();
        Future.delayed(
            const Duration(milliseconds: kStartDelayMs), _runStoryboard);
      });
    }
  }

  void _resetAll() {
    for (final t in _timers) t.cancel();
    _timers.clear();
    _turnCtrl.value = 0;
    _pageNumPopCtrl.value = 0;
    _guessPopCtrl.value = 0.80;
    _currentIndex = 0;
    _nextIndex = null;
    _phase = _Phase.page1;
    if (mounted) setState(() {});
  }

  void _popNumbers() => _pageNumPopCtrl.forward(from: 0.86);

  /// Turn: current slides left/tilts CCW (stays inside box),
  /// next starts just outside right, overshoots a bit left, then settles.
  void _turnTo(int index, {VoidCallback? then}) {
    _nextIndex = index;
    _turnCtrl.forward(from: 0.0).whenComplete(() {
      _currentIndex = index;
      _nextIndex = null;
      _pageNumPopCtrl.forward(from: 0.86);
      then?.call();
    });
  }

  void _chain(Duration after, VoidCallback f) {
    _timers.add(Timer(after, f));
  }

  void _setPhase(_Phase p) {
    if (!mounted) return;
    setState(() => _phase = p);
  }

  @override
  void dispose() {
    for (final t in _timers) t.cancel();
    _turnCtrl.dispose();
    _pageNumPopCtrl.dispose();
    _guessPopCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Tiny header box
            LessonText.box(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: LessonText.sentence([
                LessonText.word("AI", aiPink,
                    fontSize: headerFontSize, fontWeight: FontWeight.w900),
                LessonText.word("can", titleInk, fontSize: headerFontSize),
                LessonText.word("predict", titleInk,
                    fontSize: headerFontSize, fontWeight: FontWeight.w900),
                LessonText.word("future", titleInk, fontSize: headerFontSize),
                LessonText.word("values", titleInk,
                    fontSize: headerFontSize, fontWeight: FontWeight.w900),
              ]),
            ),

            // Big scene — the animation is clipped to this frame
            LessonText.box(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
              child: SizedBox(
                height: sceneHeight,
                child: _turnScene(), // ← animation
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Counter-clockwise “turn” scene with inside-frame slide & overshoot.
  Widget _turnScene() {
    final t = CurvedAnimation(parent: _turnCtrl, curve: Curves.easeInOutCubic);

    final current = _pageFor(_currentIndex);
    final next = _pageFor(_nextIndex ?? _currentIndex);

    // s ∈ [0,1] (clamped to avoid floating-point creep like 1.0000000000000002)
    final double s = _clamp01(t.value);

    // Outgoing transforms: slide left + CCW tilt + fade out
    final double outRot = kTurnAngleRad * s;
    final double outDx = -kSlideOutPx * _curve01(Curves.easeIn, s);
    final double outOp = 1.0 - s;

    // Incoming transforms with overshoot:
    //  - first phase (0..~0.82): approach from right to a small left overshoot
    //  - second phase (~0.82..1): settle from overshoot to center
    double inDx;
    if (s < 0.82) {
      final p = _clamp01(s / 0.82);
      final e = _curve01(Curves.easeOut, p);
      inDx = (1 - e) * kSlideInStartPx - kOvershootPx; // → -overshoot
    } else {
      final p = _clamp01((s - 0.82) / 0.18);
      final e = _curve01(Curves.easeOut, p);
      inDx = _lerp(-kOvershootPx, 0, e); // -overshoot → 0
    }
    final double inRot = kTurnAngleRad * (1.0 - s); // CCW → flat
    final double inOp = s;

    // Clip to the scene so motion looks “behind the frame”.
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (_nextIndex == null) current,
          if (_nextIndex != null) ...[
            // Outgoing (under)
            Opacity(
              opacity: outOp,
              child: Transform.translate(
                offset: Offset(outDx, 0),
                child: Transform.rotate(
                  angle: outRot,
                  alignment: Alignment.center,
                  child: current,
                ),
              ),
            ),
            // Incoming (over)
            Opacity(
              opacity: inOp,
              child: Transform.translate(
                offset: Offset(inDx, 0),
                child: Transform.rotate(
                  angle: inRot,
                  alignment: Alignment.center,
                  child: next,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// index: 0..3 → House 1..4
  Widget _pageFor(int index) {
    final labels = ["House 1", "House 2", "House 3", "House 4"];
    final numbers = [1, 2, 3, 4];
    final images = [
      "assets/images/house1.png",
      "assets/images/house2.png",
      "assets/images/house3.png",
      "assets/images/house4.png",
    ];
    final sizes = ["350 m²", "370 m²", "200 m²", "500 m²"];
    final prices = ["\$980,000", "\$700,000", "\$550,000", "?"];

    final bool isFinal = (index == 3);
    final bool isGuessed = (_phase == _Phase.guessed);
    final String priceTxt = isGuessed ? "\$1,807,250" : prices[index];

    return _HouseFullCard(
      label: labels[index],
      number: numbers[index],
      imagePath:
          (index < images.length) ? images[index] : "assets/images/house3.png",
      sizeValue: sizes[index],
      priceValue: priceTxt,
      isFinal: isFinal,
      popNumbers:
          CurvedAnimation(parent: _pageNumPopCtrl, curve: Curves.easeOutBack),
      popFinalPrice: isFinal && isGuessed
          ? CurvedAnimation(parent: _guessPopCtrl, curve: Curves.easeOutBack)
          : null,
    );
  }
}

/// Inner **card** that confines the house content inside the scene.
class _HouseFullCard extends StatelessWidget {
  final String label;
  final int number;
  final String imagePath;
  final String sizeValue;
  final String priceValue;
  final bool isFinal;

  final Animation<double> popNumbers; // house number + size
  final Animation<double>? popFinalPrice; // final price pop

  const _HouseFullCard({
    required this.label,
    required this.number,
    required this.imagePath,
    required this.sizeValue,
    required this.priceValue,
    required this.isFinal,
    required this.popNumbers,
    this.popFinalPrice,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final numberScale =
        Tween<double>(begin: 0.86, end: 1.0).animate(popNumbers);

    final priceScale = popFinalPrice == null
        ? const AlwaysStoppedAnimation(1.0)
        : Tween<double>(begin: 0.80, end: 1.10).animate(popFinalPrice!);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.black12, width: 1.2),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 8,
            offset: Offset(0, 3),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title: House N (N is big & red, pops)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "House ",
                style: GoogleFonts.lato(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  color: titleInk,
                ),
              ),
              ScaleTransition(
                scale: numberScale,
                child: Text(
                  "$number",
                  style: GoogleFonts.lato(
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                    color: houseNumRed,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Big image (safe if missing)
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.asset(
                imagePath,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (ctx, err, st) => Container(
                  color: const Color(0xFFF3F3F3),
                  alignment: Alignment.center,
                  child: Text(
                    "Image not found",
                    style: GoogleFonts.lato(
                      fontSize: 16,
                      color: Colors.black54,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Size
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Total Size: ",
                style: GoogleFonts.lato(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: titleInk,
                ),
              ),
              ScaleTransition(
                scale: numberScale,
                child: Text(
                  sizeValue,
                  style: GoogleFonts.lato(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: sizeOrange,
                  ),
                ),
              ),
            ],
          ),

          // Price (plain black-border pill)
          const SizedBox(height: 4),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Price: ",
                style: GoogleFonts.lato(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: titleInk,
                ),
              ),
              AnimatedContainer(
                duration: const Duration(milliseconds: kPriceBadgeAnimMs),
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: priceBadgeBg,
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(
                    color: priceBadgeBorder,
                    width: popFinalPrice == null ? 1.2 : 2.0,
                  ),
                ),
                child: ScaleTransition(
                  scale: priceScale,
                  child: Text(
                    priceValue,
                    style: GoogleFonts.lato(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      color: priceGreen,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Helpers
double _lerp(double a, double b, double t) => a + (b - a) * t;
double _clamp01(double x) => x < 0 ? 0 : (x > 1 ? 1 : x);
double _curve01(Curve c, double t) => c.transform(_clamp01(t));
