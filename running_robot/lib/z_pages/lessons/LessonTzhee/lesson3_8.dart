// ✅ LessonStepSeven — Animation-only box
// Self-contained: includes all logic, tokens, painters, globals.

import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:running_robot/z_pages/assets/lessonAssets/helpful_tools.dart';

/// ============================== GLOBALS ===============================
const double kAnimBoxHeight = 420.0;
const double kAnimOuterPadding = 20.0;
const double kAnimTopLabelHeight = 34.0;
const double kAnimDividerThickness = 2.0;

const double kAnimBackgroundRadius = 18.0;
const double kAnimBinRadius = 14.0;

const Color _numbersBlue = Color.fromARGB(255, 0, 113, 206);
const Color _categoriesRed = Color.fromARGB(255, 200, 0, 0);
const Color _labelInk = Colors.black87;

const double _tokenFontSize = 15.0;
const double _hGap = 12.0;
const double _vGap = 12.0;
const double _chipHPad = 12.0;
const double _chipVPad = 7.0;
const double _chipDot = 8.0;
const double _chipDotGap = 8.0;

/// =====================================================================

class LessonStepSeven extends StatelessWidget {
  const LessonStepSeven({super.key});

  @override
  Widget build(BuildContext context) {
    return LessonText.box(
      margin: const EdgeInsets.only(bottom: 14),
      child: SizedBox(
        height: kAnimBoxHeight,
        width: double.infinity,
        child: const NumbersVsCategoriesAnimation(),
      ),
    );
  }
}

/// ======================================================================
/// NumbersVsCategoriesAnimation
/// ======================================================================
class NumbersVsCategoriesAnimation extends StatefulWidget {
  const NumbersVsCategoriesAnimation({super.key});

  @override
  State<NumbersVsCategoriesAnimation> createState() =>
      _NumbersVsCategoriesAnimationState();
}

class _NumbersVsCategoriesAnimationState
    extends State<NumbersVsCategoriesAnimation> with TickerProviderStateMixin {
  late final AnimationController _timeline;
  late final Ticker _ticker;
  final math.Random _rng = math.Random();

  late List<_Token> _tokens;
  final List<_Particle> _particles = [];
  final Map<int, double> _prevProgress = {};
  double _elapsed = 0.0;

  TextStyle get _catTextStyle => TextStyle(
        fontSize: _tokenFontSize,
        fontWeight: FontWeight.w900,
        color: Colors.black.withOpacity(0.85),
      );
  TextStyle get _numTextStyle => TextStyle(
        fontSize: _tokenFontSize + 0.5,
        fontWeight: FontWeight.w900,
        color: Colors.black.withOpacity(0.90),
      );
  TextStyle get _unitTextStyle => TextStyle(
        fontSize: _tokenFontSize - 0.5,
        fontWeight: FontWeight.w700,
        color: Colors.black.withOpacity(0.65),
      );

  @override
  void initState() {
    super.initState();
    _tokens = _seedTokens();
    _timeline = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3600),
    )..addListener(_onTick);

    _ticker = createTicker((elapsed) {
      final dt = elapsed.inMicroseconds / 1e6 - _elapsed;
      _elapsed += dt;
      _updateParticles(dt);
      setState(() {});
    });

    _start();
  }

  void _start() {
    _particles.clear();
    for (final t in _tokens) {
      t.arrived = false;
    }
    _prevProgress.clear();
    _elapsed = 0;
    _timeline
      ..reset()
      ..forward();
    _ticker.start();
  }

  @override
  void dispose() {
    _ticker.stop();
    _ticker.dispose();
    _timeline.dispose();
    super.dispose();
  }

  List<_Token> _seedTokens() {
    final numbers = <_Token>[
      _Token.number(id: 0, value: "170", unit: "cm"),
      _Token.number(id: 1, value: "55", unit: "kg"),
      _Token.number(id: 3, value: "37", unit: "°C"),
      _Token.number(id: 4, value: "120", unit: "bpm"),
      _Token.number(id: 6, value: "1.8", unit: "m"),
      _Token.number(id: 7, value: "60", unit: "km/h"),
      _Token.number(id: 8, value: "45", unit: "%"),
    ];

    final categories = ["Red", "Dog", "Jazz", "Banana", "Metal", "Cat", "Blue"]
        .map((c) => _Token.category(text: c, id: 1000 + c.hashCode))
        .toList();

    final List<_Token> all = [...numbers, ...categories];
    int idCounter = 2000;
    for (final t in all) {
      t.delay = 0.10 + _rand(0, 0.75);
      t.duration = 0.90 + _rand(0.0, 0.45);
      t.phase = _rand(0, math.pi * 2);
      t.id = idCounter++;
    }
    all.shuffle(_rng);
    return all;
  }

  double _rand(double a, double b) => a + _rng.nextDouble() * (b - a);

  void _onTick() {
    for (final t in _tokens) {
      final prog = _normalizedProgress(t, _timeline.value);
      final prev = _prevProgress[t.id] ?? 0.0;
      if (!t.arrived && prev < 1.0 && prog >= 1.0) {
        t.arrived = true;
        final center = (t.finalPos ?? Offset.zero) +
            Offset((t.size?.width ?? 0) / 2, (t.size?.height ?? 0) / 2);
        _burstConfetti(center,
            color: t.type == _TokenType.number ? _numbersBlue : _categoriesRed);
      }
      _prevProgress[t.id] = prog;
    }

    if (_timeline.isCompleted && _particles.isEmpty) {
      _ticker.stop();
    }
    setState(() {});
  }

  double _normalizedProgress(_Token t, double g) {
    final start = t.delay, end = (t.delay + t.duration).clamp(0.0, 1.0);
    final v = g.clamp(0.0, 1.0);
    if (v <= start) return 0.0;
    if (v >= end) return 1.0;
    return (v - start) / (end - start);
  }

  void _updateParticles(double dt) {
    for (final p in _particles) {
      p.life -= dt;
      if (p.life <= 0) continue;
      p.vel += Offset(0, 200) * dt;
      p.pos += p.vel * dt;
      p.angle += p.spin * dt;
    }
    _particles.removeWhere((p) => p.life <= 0);
  }

  void _burstConfetti(Offset at, {required Color color}) {
    final n = 18 + _rng.nextInt(12);
    for (int i = 0; i < n; i++) {
      final speed = 90 + _rng.nextDouble() * 220;
      final angle = _rng.nextDouble() * math.pi * 2;
      final vel = Offset(math.cos(angle), math.sin(angle)) * speed;
      _particles.add(_Particle(
        pos: at,
        vel: vel,
        life: 0.7 + _rng.nextDouble() * 0.6,
        color: color.withOpacity(0.9 - _rng.nextDouble() * 0.4),
        size: 2.0 + _rng.nextDouble() * 3.0,
        angle: _rng.nextDouble() * math.pi,
        spin: (_rng.nextDouble() - 0.5) * 8.0,
      ));
    }
  }

  TextSpan _spanFor(_Token t) {
    if (t.type == _TokenType.number) {
      final hasUnit = (t.unit ?? "").isNotEmpty;
      return TextSpan(
        children: [
          TextSpan(text: t.value ?? t.text, style: _numTextStyle),
          if (hasUnit) const TextSpan(text: " "),
          if (hasUnit) TextSpan(text: t.unit, style: _unitTextStyle),
        ],
      );
    } else {
      return TextSpan(text: t.text, style: _catTextStyle);
    }
  }

  Size _measureChip(_Token t) {
    final tp = TextPainter(
      text: _spanFor(t),
      maxLines: 1,
      textDirection: TextDirection.ltr,
    )..layout();
    final w = _chipHPad + _chipDot + _chipDotGap + tp.width + _chipHPad;
    final h = _chipVPad + tp.height + _chipVPad;
    return Size(w, h);
  }

  List<Offset> _flowLayout(Rect rect, List<_Token> tokens) {
    final List<Offset> spots = [];
    double x = rect.left + _hGap;
    double y = rect.top + _vGap;
    double rowH = 0;
    for (final t in tokens) {
      t.size ??= _measureChip(t);
      final s = t.size!;
      if (x + s.width > rect.right - _hGap) {
        x = rect.left + _hGap;
        y += rowH + _vGap;
        rowH = 0;
      }
      spots.add(Offset(x, y));
      x += s.width + _hGap;
      rowH = math.max(rowH, s.height);
    }
    return spots;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _start,
      child: SizedBox.expand(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final Size size = constraints.biggest;

            final padding = kAnimOuterPadding;
            final labelH = kAnimTopLabelHeight;
            final dividerW = kAnimDividerThickness;

            final leftRect = Rect.fromLTWH(
              padding,
              padding + labelH,
              (size.width - padding * 2 - dividerW) / 2,
              size.height - padding * 2 - labelH,
            );
            final rightRect = Rect.fromLTWH(
              leftRect.right + dividerW,
              padding + labelH,
              (size.width - padding * 2 - dividerW) / 2,
              size.height - padding * 2 - labelH,
            );

            final centerRect = Rect.fromCenter(
              center: Offset(size.width / 2, size.height / 2),
              width: size.width * 0.38,
              height: size.height * 0.36,
            );

            final leftTokens =
                _tokens.where((t) => t.type == _TokenType.number).toList();
            final rightTokens =
                _tokens.where((t) => t.type == _TokenType.category).toList();

            final leftSpots = _flowLayout(leftRect, leftTokens);
            final rightSpots = _flowLayout(rightRect, rightTokens);

            int li = 0, ri = 0;
            for (final t in _tokens) {
              t.size ??= _measureChip(t);
              final s = t.size!;
              final startX = _rand(centerRect.left, centerRect.right - s.width);
              final startY =
                  _rand(centerRect.top, centerRect.bottom - s.height);
              t.startPos ??= Offset(startX, startY);

              if (t.type == _TokenType.number) {
                t.finalPos = leftSpots[li % leftSpots.length];
                li++;
              } else {
                t.finalPos = rightSpots[ri % rightSpots.length];
                ri++;
              }
            }

            return CustomPaint(
              painter: _BackdropPainter(
                leftRect: leftRect,
                rightRect: rightRect,
                dividerX: leftRect.right,
              ),
              child: Stack(
                children: [
                  Positioned(
                    left: leftRect.left,
                    top: padding - 2,
                    child: Row(
                      children: [
                        _legendDot(_numbersBlue),
                        const SizedBox(width: 6),
                        Text("Numbers",
                            style: TextStyle(
                              color: _labelInk,
                              fontWeight: FontWeight.w800,
                            )),
                      ],
                    ),
                  ),
                  Positioned(
                    left: rightRect.left,
                    top: padding - 2,
                    child: Row(
                      children: [
                        _legendDot(_categoriesRed),
                        const SizedBox(width: 6),
                        Text("Categories",
                            style: TextStyle(
                              color: _labelInk,
                              fontWeight: FontWeight.w800,
                            )),
                      ],
                    ),
                  ),
                  ..._tokens.map((t) {
                    final prog = _normalizedProgress(t, _timeline.value);
                    final eased = Curves.easeOutBack.transform(prog);
                    final lerp = Offset.lerp(t.startPos, t.finalPos, eased)!;

                    final lift = (1 - (2 * prog - 1) * (2 * prog - 1)) * 22.0;
                    final flyPos = lerp - Offset(0, lift);

                    final bob = prog >= 1.0
                        ? math.sin(_elapsed * 2.0 + t.phase) * 1.8
                        : 0.0;

                    final spawn =
                        Curves.easeOut.transform(prog.clamp(0.0, 0.25) / 0.25);
                    final scale = 0.9 + spawn * 0.2;
                    final opacity = (0.2 + spawn * 0.8).clamp(0.0, 1.0);

                    return Positioned(
                      left: flyPos.dx,
                      top: flyPos.dy + bob,
                      child: Opacity(
                        opacity: opacity,
                        child: Transform.scale(
                          scale: scale,
                          alignment: Alignment.center,
                          child: _TokenChip(
                            token: t,
                            color: t.type == _TokenType.number
                                ? _numbersBlue
                                : _categoriesRed,
                            spanBuilder: _spanFor,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                  Positioned.fill(
                    child: IgnorePointer(
                      child: CustomPaint(
                        painter: _ConfettiPainter(_particles),
                      ),
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

  Widget _legendDot(Color c) => Container(
        width: 10,
        height: 10,
        decoration:
            BoxDecoration(color: c, borderRadius: BorderRadius.circular(6)),
      );
}

/// ==== Models & painters =================================================
enum _TokenType { number, category }

class _Token {
  int id;
  final _TokenType type;
  final String text;
  final String? value;
  final String? unit;

  double delay;
  double duration;
  double phase;
  bool arrived;

  Offset? startPos;
  Offset? finalPos;
  Size? size;

  _Token._({
    required this.id,
    required this.type,
    required this.text,
    this.value,
    this.unit,
    this.delay = 0,
    this.duration = 1,
    this.phase = 0,
    this.arrived = false,
  });

  factory _Token.category({required String text, required int id}) =>
      _Token._(id: id, type: _TokenType.category, text: text);

  factory _Token.number(
          {required int id, required String value, String? unit}) =>
      _Token._(
          id: id, type: _TokenType.number, text: "", value: value, unit: unit);
}

class _Particle {
  Offset pos;
  Offset vel;
  double life;
  final Color color;
  final double size;
  double angle;
  double spin;

  _Particle({
    required this.pos,
    required this.vel,
    required this.life,
    required this.color,
    required this.size,
    required this.angle,
    required this.spin,
  });
}

class _BackdropPainter extends CustomPainter {
  final Rect leftRect;
  final Rect rightRect;
  final double dividerX;

  _BackdropPainter({
    required this.leftRect,
    required this.rightRect,
    required this.dividerX,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final bgPaint = Paint()
      ..color = const Color(0xFFF7F9FC)
      ..style = PaintingStyle.fill;

    final binPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final binBorder = Paint()
      ..color = const Color(0x22000000)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    final bgR = Radius.circular(kAnimBackgroundRadius);
    canvas.drawRRect(
      RRect.fromRectAndRadius(Offset.zero & size, bgR),
      bgPaint,
    );

    final rr = Radius.circular(kAnimBinRadius);
    canvas.drawRRect(RRect.fromRectAndRadius(leftRect, rr), binPaint);
    canvas.drawRRect(RRect.fromRectAndRadius(rightRect, rr), binPaint);
    canvas.drawRRect(RRect.fromRectAndRadius(leftRect, rr), binBorder);
    canvas.drawRRect(RRect.fromRectAndRadius(rightRect, rr), binBorder);

    final divider = Paint()
      ..color = const Color(0x11000000)
      ..strokeWidth = kAnimDividerThickness;
    canvas.drawLine(Offset(dividerX, leftRect.top - 16),
        Offset(dividerX, rightRect.bottom + 6), divider);
  }

  @override
  bool shouldRepaint(covariant _BackdropPainter oldDelegate) => true;
}

class _ConfettiPainter extends CustomPainter {
  final List<_Particle> particles;
  _ConfettiPainter(this.particles);

  @override
  void paint(Canvas canvas, Size size) {
    for (final p in particles) {
      final t = p.life.clamp(0.0, 1.0);
      final alpha = (t * 255).clamp(0, 255).toInt();
      final paint = Paint()..color = p.color.withAlpha(alpha);
      final s = p.size;

      canvas.save();
      canvas.translate(p.pos.dx, p.pos.dy);
      canvas.rotate(p.angle);
      final rect =
          Rect.fromCenter(center: Offset.zero, width: s * 1.3, height: s);
      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, const Radius.circular(1.2)),
        paint,
      );
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _ConfettiPainter oldDelegate) => true;
}

class _TokenChip extends StatelessWidget {
  final _Token token;
  final Color color;
  final TextSpan Function(_Token) spanBuilder;

  const _TokenChip({
    super.key,
    required this.token,
    required this.color,
    required this.spanBuilder,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: _chipHPad, vertical: _chipVPad),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(
            color: Color(0x22000000),
            blurRadius: 6,
            offset: Offset(0, 2),
          )
        ],
        border: Border.all(color: color.withOpacity(0.9), width: 1.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: _chipDot,
            height: _chipDot,
            decoration: BoxDecoration(
                color: color, borderRadius: BorderRadius.circular(6)),
          ),
          const SizedBox(width: _chipDotGap),
          RichText(text: spanBuilder(token)),
        ],
      ),
    );
  }
}
