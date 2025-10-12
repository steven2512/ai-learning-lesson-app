// FILE: plane_tag.dart
// One-at-a-time tags above the plane with a straight connector line.
// • Neutral dark pill for every tag; colored "(Feature)/(Label)" pops; value text uses same accent color.
// • Static "Data Sample" text (orange, no pill) at top-left with a small gap below.
// • Line attaches to both plane + tag; optional visual clamping.
// • Timing kept as-is.
// • Left→Right slide-in/out (short travel) from just left of the final position.
// • ClipRect keeps tags “behind the scene”; header stays on top.
// • onCompleted fires once right before the first repeat.

import 'dart:ui' show lerpDouble;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:running_robot/z_pages/assets/lessonAssets/helpful_tools.dart';

enum LineClamp { none, trimFromPlane, trimFromTag }

class PlaneAnimGlobals {
  // ---- Layout / sizing ----
  static double boxHeightFactor = 0.50;
  static double planeHeightFactor = 0.66;
  static double tagTopFraction = 0.11;

  // Space under the "Data Sample" header text
  static double headerBottomGapPx = 18.0;

  // Where the line touches the plane (fractions of the animation box)
  static double planeAnchorX = 0.54;
  static double planeAnchorY = 0.59;

  // Line insets & visual clamping
  static double lineFromInsetPx = 0;
  static double lineEndInsetPx = 0;
  static LineClamp lineClamp = LineClamp.none;
  static double lineMaxLenFrac = 0.12;

  // Tags (two lines)
  static double tagHeight = 84;

  // ---- Timing (ms) ---- (unchanged)
  static int leadInMs = 1200;
  static int fadeInMs = 1000;
  static int holdMs = 1500;
  static int fadeOutMs = 1000;
  static int secondsBeforeFirstLoop = 3;

  // Content
  static String modelValue = 'Learjet 75';
  static String yearsValue = '7';
  static String kmValue = '2,200,000';
  static String priceText = 'Price: \$7,500,000';

  // Visual tweak: lift price tag slightly to align with others (negative = up)
  static double priceYOffsetPx = -6.0;

  // Left→Right entry distance (short travel)
  static double entryOffsetPx = 80.0;

  // Colors — neutral pill + brighter accents
  static const Color neutralTagBg = Color(0xFF263238);
  static const Color featureColor = Color(0xFFE91E63); // pink
  static const Color labelColor = Color(0xFF40C4FF); // vivid cyan
  static const Color dataSampleTextColor = Color(0xFFFF6D00); // orange header
  static Color lineColor = Colors.black54;

  // Typography (Lato)
  static TextStyle labelStyle = GoogleFonts.lato(
    color: Colors.white.withOpacity(0.95),
    fontSize: 18,
    fontWeight: FontWeight.w800,
    height: 1.0,
  );
  static TextStyle valueStyle = GoogleFonts.lato(
    color: Colors.white, // overridden per tag
    fontSize: 22,
    fontWeight: FontWeight.w900,
    height: 1.0,
    letterSpacing: 0.2,
  );
  static TextStyle suffixStyle = GoogleFonts.lato(
    color: Colors.white, // overridden per tag
    fontSize: 16,
    fontWeight: FontWeight.w900,
    height: 1.0,
  );

  // Tag chrome
  static BorderRadius tagRadius = BorderRadius.circular(14);
  static EdgeInsets tagPadding =
      const EdgeInsets.symmetric(horizontal: 12, vertical: 10);
  static List<BoxShadow> tagShadow = const [
    BoxShadow(color: Colors.black26, blurRadius: 8, offset: Offset(0, 4)),
  ];

  // Header
  static TextStyle dataSampleStyle = GoogleFonts.lato(
    fontSize: 26,
    fontWeight: FontWeight.w900,
    color: dataSampleTextColor,
    height: 1.0,
    letterSpacing: 0.3,
  );
}

class PlaneTagsPriceAnimation extends StatefulWidget {
  const PlaneTagsPriceAnimation({
    super.key,
    this.planeAsset = 'assets/images/airplane.png',
    this.onCompleted,
  });

  final String planeAsset;

  /// Called once, right after the last tag finishes its hold (before the loop restarts).
  final void Function(bool didLoop)? onCompleted;

  @override
  State<PlaneTagsPriceAnimation> createState() =>
      _PlaneTagsPriceAnimationState();
}

class _PlaneTagsPriceAnimationState extends State<PlaneTagsPriceAnimation>
    with TickerProviderStateMixin {
  late final AnimationController _c;
  bool _loopStarted = false;
  late final int _totalMs;

  @override
  void initState() {
    super.initState();

    final per = PlaneAnimGlobals.fadeInMs +
        PlaneAnimGlobals.holdMs +
        PlaneAnimGlobals.fadeOutMs;
    _totalMs = PlaneAnimGlobals.leadInMs + per * 4; // 4 tags + lead-in

    _c = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: _totalMs),
    )
      ..addListener(() => setState(() {}))
      ..addStatusListener((status) async {
        if (status == AnimationStatus.completed && !_loopStarted) {
          widget.onCompleted?.call(true);
          _loopStarted = true;
          final delay =
              Duration(seconds: PlaneAnimGlobals.secondsBeforeFirstLoop);
          if (delay.inMilliseconds > 0) {
            await Future.delayed(delay);
            if (!mounted) return;
          }
          _c.repeat();
        }
      })
      ..forward();
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  double seg(double t, double a, double b) {
    if (t <= a) return 0;
    if (t >= b) return 1;
    return (t - a) / (b - a);
  }

  // smoother curves
  double _smooth(double x) => Curves.easeInOutCubic.transform(x);

  Offset _lerp(Offset a, Offset b, double t) =>
      Offset(lerpDouble(a.dx, b.dx, t)!, lerpDouble(a.dy, b.dy, t)!);

  // ---- Text measurement (snug tags) ----
  double _measureTextWidth(String text, TextStyle style) {
    final tp = TextPainter(
      text: TextSpan(text: text, style: style),
      maxLines: 1,
      textDirection: TextDirection.ltr,
    )..layout();
    return tp.width;
  }

  // Width = max(line1, line2) + padding
  double _twoLineTagWidth({
    required String label,
    required String value,
    required String suffix,
    required double maxAllowed,
  }) {
    final line1 = '$label: $value';
    final w1 = _measureTextWidth(line1, PlaneAnimGlobals.valueStyle);
    final w2 = _measureTextWidth(suffix, PlaneAnimGlobals.suffixStyle);
    final base = (w1 > w2 ? w1 : w2) + PlaneAnimGlobals.tagPadding.horizontal;
    return base.clamp(0, maxAllowed).toDouble();
  }

  // ms → controller fraction
  double _f(int ms) => ms / _totalMs;

  @override
  Widget build(BuildContext context) {
    final t = _c.value; // 0..1

    return LayoutBuilder(builder: (context, box) {
      final size = box.biggest;

      // Measurements (clamp to 92% of box width)
      final maxW = size.width * 0.92;
      final modelW = _twoLineTagWidth(
        label: 'Model',
        value: PlaneAnimGlobals.modelValue,
        suffix: '(Feature)',
        maxAllowed: maxW,
      );
      final yearsW = _twoLineTagWidth(
        label: 'Years Operated',
        value: PlaneAnimGlobals.yearsValue,
        suffix: '(Feature)',
        maxAllowed: maxW,
      );
      final kmW = _twoLineTagWidth(
        label: 'Total Km',
        value: PlaneAnimGlobals.kmValue,
        suffix: '(Feature)',
        maxAllowed: maxW,
      );
      final priceValue = PlaneAnimGlobals.priceText.replaceFirst('Price: ', '');
      final priceW = _twoLineTagWidth(
        label: 'Price',
        value: priceValue,
        suffix: '(Label)',
        maxAllowed: maxW,
      );

      final tagH = PlaneAnimGlobals.tagHeight.toDouble();

      // Final (resting) position centered horizontally
      final centerX = size.width * 0.5;
      Offset targetForWidth(double w) => Offset(
            centerX - w / 2,
            size.height * PlaneAnimGlobals.tagTopFraction +
                PlaneAnimGlobals.headerBottomGapPx,
          );

      // LEFT→RIGHT: start just a bit to the LEFT of the final spot
      Offset startForWidth(double w) =>
          targetForWidth(w).translate(-PlaneAnimGlobals.entryOffsetPx, 0);

      // Plane anchor for the line (global fractions)
      final planeAnchor = Offset(
        size.width * PlaneAnimGlobals.planeAnchorX,
        size.height * PlaneAnimGlobals.planeAnchorY,
      );

      // --- Time segments (with lead-in) — unchanged ---
      final inMs = PlaneAnimGlobals.fadeInMs;
      final holdMs = PlaneAnimGlobals.holdMs;
      final outMs = PlaneAnimGlobals.fadeOutMs;
      final per = inMs + holdMs + outMs;

      int start0 = PlaneAnimGlobals.leadInMs;
      int start1 = start0 + per;
      int start2 = start1 + per;
      int start3 = start2 + per;

      TagState stateFor(int startMs, double w) {
        final a0 = _f(startMs);
        final a1 = _f(startMs + inMs);
        final a2 = _f(startMs + inMs + holdMs);
        final a3 = _f(startMs + inMs + holdMs + outMs);

        final inP = seg(t, a0, a1);
        final holdP = seg(t, a1, a2);
        final outP = seg(t, a2, a3);

        final visible = (inP > 0 && inP < 1) ||
            (holdP > 0 && holdP < 1) ||
            (outP > 0 && outP < 1);
        if (!visible) return TagState.hidden();

        final target = targetForWidth(w);
        final startPos = startForWidth(w);

        Offset pos;
        double opacity;
        if (inP < 1) {
          final k = _smooth(inP);
          pos = _lerp(startPos, target, k);
          opacity = _smooth(inP).clamp(0, 1).toDouble();
        } else if (outP > 0) {
          final k = _smooth(outP);
          pos = _lerp(target, startPos, k);
          opacity = (1 - _smooth(outP)).clamp(0, 1).toDouble();
        } else {
          pos = target;
          opacity = 1.0;
        }

        // >>> FIX: aim the line at the tag's *current* bottom-center, not centerX
        final midX = pos.dx + w / 2;
        final toPoint = Offset(midX, pos.dy + tagH);

        return TagState.visible(
            pos: pos, opacity: opacity, lineTo: toPoint, width: w);
      }

      final stModel = stateFor(start0, modelW);
      final stYears = stateFor(start1, yearsW);
      final stKm = stateFor(start2, kmW);

      // Price with upward correction
      final stPrice = stateFor(start3, priceW);
      final priceVisible = stPrice.visible;
      final pricePos =
          stPrice.pos.translate(0, PlaneAnimGlobals.priceYOffsetPx);
      final priceOpacity = stPrice.opacity.toDouble();
      // >>> FIX for price line too: use adjusted X + width/2
      final priceLineTo = Offset(pricePos.dx + priceW / 2, pricePos.dy + tagH);

      // Which line to draw (one at a time)
      Offset? lineTo;
      if (stModel.visible)
        lineTo = stModel.lineTo;
      else if (stYears.visible)
        lineTo = stYears.lineTo;
      else if (stKm.visible)
        lineTo = stKm.lineTo;
      else if (priceVisible) lineTo = priceLineTo;

      // --- RENDER (clipped box so tags come “from behind”) ---
      return ClipRect(
        child: Stack(
          clipBehavior: Clip.hardEdge,
          children: [
            // Plane (bottom)
            Align(
              alignment: Alignment.bottomCenter,
              child: FractionallySizedBox(
                heightFactor: PlaneAnimGlobals.planeHeightFactor,
                child: FittedBox(
                  fit: BoxFit.contain,
                  child: Image.asset(
                    widget.planeAsset,
                    errorBuilder: (_, __, ___) => const SizedBox(),
                  ),
                ),
              ),
            ),

            // Connector line (follows live tag position)
            if (lineTo != null)
              Positioned.fill(
                child: CustomPaint(
                  painter: _StraightLinePainter(
                    from: planeAnchor,
                    to: lineTo!,
                    shortenFromPx: PlaneAnimGlobals.lineFromInsetPx,
                    endInsetPx: PlaneAnimGlobals.lineEndInsetPx,
                    clampMode: PlaneAnimGlobals.lineClamp,
                    maxLengthFrac: PlaneAnimGlobals.lineMaxLenFrac,
                    color: PlaneAnimGlobals.lineColor,
                  ),
                ),
              ),

            // Model (Feature)
            if (stModel.visible)
              Positioned(
                left: stModel.pos.dx,
                top: stModel.pos.dy,
                child: Opacity(
                  opacity: stModel.opacity.toDouble(),
                  child: _InfoTag.twoLine(
                    width: stModel.width,
                    height: tagH,
                    bg: PlaneAnimGlobals.neutralTagBg,
                    label: 'Model',
                    value: PlaneAnimGlobals.modelValue,
                    valueColor: PlaneAnimGlobals.featureColor,
                    suffixText: '(Feature)',
                    suffixColor: PlaneAnimGlobals.featureColor,
                  ),
                ),
              ),

            // Years Operated (Feature)
            if (stYears.visible)
              Positioned(
                left: stYears.pos.dx,
                top: stYears.pos.dy,
                child: Opacity(
                  opacity: stYears.opacity.toDouble(),
                  child: _InfoTag.twoLine(
                    width: stYears.width,
                    height: tagH,
                    bg: PlaneAnimGlobals.neutralTagBg,
                    label: 'Years Operated',
                    value: PlaneAnimGlobals.yearsValue,
                    valueColor: PlaneAnimGlobals.featureColor,
                    suffixText: '(Feature)',
                    suffixColor: PlaneAnimGlobals.featureColor,
                  ),
                ),
              ),

            // Total Km (Feature)
            if (stKm.visible)
              Positioned(
                left: stKm.pos.dx,
                top: stKm.pos.dy,
                child: Opacity(
                  opacity: stKm.opacity.toDouble(),
                  child: _InfoTag.twoLine(
                    width: stKm.width,
                    height: tagH,
                    bg: PlaneAnimGlobals.neutralTagBg,
                    label: 'Total Km',
                    value: PlaneAnimGlobals.kmValue,
                    valueColor: PlaneAnimGlobals.featureColor,
                    suffixText: '(Feature)',
                    suffixColor: PlaneAnimGlobals.featureColor,
                  ),
                ),
              ),

            // Price (Label) — value colored vivid cyan
            if (priceVisible)
              Positioned(
                left: pricePos.dx,
                top: pricePos.dy,
                child: Opacity(
                  opacity: priceOpacity.toDouble(),
                  child: _InfoTag.twoLine(
                    width: priceW,
                    height: tagH,
                    bg: PlaneAnimGlobals.neutralTagBg,
                    label: 'Price',
                    value: priceValue,
                    valueColor: PlaneAnimGlobals.labelColor,
                    suffixText: '(Label)',
                    suffixColor: PlaneAnimGlobals.labelColor,
                  ),
                ),
              ),

            // Header on top so tags/line never cover it
            const Positioned(
              left: 6,
              top: 6,
              child: _DataSampleHeader(),
            ),
          ],
        ),
      );
    });
  }
}

class TagState {
  final bool visible;
  final Offset pos;
  final double opacity;
  final Offset? lineTo;
  final double width;

  const TagState._(
      this.visible, this.pos, this.opacity, this.lineTo, this.width);
  factory TagState.hidden() => const TagState._(false, Offset.zero, 0, null, 0);
  factory TagState.visible({
    required Offset pos,
    required double opacity,
    required Offset lineTo,
    required double width,
  }) =>
      TagState._(true, pos, opacity, lineTo, width);
}

class _StraightLinePainter extends CustomPainter {
  final Offset from; // plane anchor
  final Offset to; // bottom-center of tag
  final double shortenFromPx;
  final double endInsetPx;
  final LineClamp clampMode;
  final double maxLengthFrac;
  final Color color;

  const _StraightLinePainter({
    required this.from,
    required this.to,
    required this.shortenFromPx,
    required this.endInsetPx,
    required this.clampMode,
    required this.maxLengthFrac,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final v = to - from;
    final dist = v.distance;
    if (dist == 0) return;
    final unit = v / dist;

    var start = from + unit * shortenFromPx;
    var end = to - unit * endInsetPx;

    if (clampMode != LineClamp.none && maxLengthFrac > 0) {
      final fullLen = (end - start).distance;
      final cap = (maxLengthFrac.clamp(0.0, 1.0)) * size.height;
      final actualLen = fullLen.clamp(0.0, cap);
      if (clampMode == LineClamp.trimFromPlane) {
        start = end - unit * actualLen; // keep tag end fixed
      } else if (clampMode == LineClamp.trimFromTag) {
        end = start + unit * actualLen; // keep plane end fixed
      }
    }

    final p = Paint()
      ..color = color
      ..strokeWidth = 2.4
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(start, end, p);

    final dot = Paint()..color = color;
    canvas.drawCircle(start, 3.0, dot);
    canvas.drawCircle(end, 3.0, dot);
  }

  @override
  bool shouldRepaint(covariant _StraightLinePainter old) =>
      old.from != from ||
      old.to != to ||
      old.shortenFromPx != shortenFromPx ||
      old.endInsetPx != endInsetPx ||
      old.clampMode != clampMode ||
      old.maxLengthFrac != maxLengthFrac ||
      old.color != color;
}

/// Static "Data Sample" header (orange, no pill)
class _DataSampleHeader extends StatelessWidget {
  const _DataSampleHeader();

  @override
  Widget build(BuildContext context) {
    return Text('Data Sample', style: PlaneAnimGlobals.dataSampleStyle);
  }
}

/// Two-line tag with shared-baseline first row so the value sits perfectly level.
class _InfoTag extends StatelessWidget {
  const _InfoTag.twoLine({
    required this.width,
    required this.height,
    required this.bg,
    required this.label,
    required this.value,
    required this.valueColor,
    required this.suffixText,
    required this.suffixColor,
  });

  final double width;
  final double height;
  final Color bg;
  final String label;
  final String value;
  final Color valueColor;
  final String suffixText;
  final Color suffixColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      padding: PlaneAnimGlobals.tagPadding,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: PlaneAnimGlobals.tagRadius,
        boxShadow: PlaneAnimGlobals.tagShadow,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RichText(
            text: TextSpan(
              style: GoogleFonts.lato(height: 1.0),
              children: [
                TextSpan(
                  text: '$label: ',
                  style:
                      PlaneAnimGlobals.labelStyle.copyWith(color: Colors.white),
                ),
                TextSpan(
                  text: value,
                  style:
                      PlaneAnimGlobals.valueStyle.copyWith(color: valueColor),
                ),
              ],
            ),
            textAlign: TextAlign.left,
            textHeightBehavior: const TextHeightBehavior(
              applyHeightToFirstAscent: false,
              applyHeightToLastDescent: false,
            ),
          ),
          const SizedBox(height: 4),
          LessonText.sentence([
            LessonText.word(suffixText, suffixColor,
                fontSize: PlaneAnimGlobals.suffixStyle.fontSize ?? 16,
                fontWeight: FontWeight.w900),
          ]),
        ],
      ),
    );
  }
}
