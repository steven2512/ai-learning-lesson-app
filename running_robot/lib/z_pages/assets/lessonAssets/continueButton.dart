import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ContinueButton extends StatefulWidget {
  final VoidCallback onPressed;

  const ContinueButton({super.key, required this.onPressed});

  @override
  State<ContinueButton> createState() => _ContinueButtonState();
}

class _ContinueButtonState extends State<ContinueButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    const Color boxColor = Colors.teal;
    const double radius = 30.0;
    const double bevelHeight = 6.0;
    final double dpr = MediaQuery.of(context).devicePixelRatio;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(radius),
            onHighlightChanged: (v) => setState(() => _pressed = v),
            onTap: widget.onPressed,
            highlightColor: Colors.white.withOpacity(0.06),
            splashColor: Colors.white.withOpacity(0.10),
            child: AnimatedScale(
              scale: _pressed ? 0.985 : 1.0,
              duration: const Duration(milliseconds: 80),
              curve: Curves.easeOut,
              child: CustomPaint(
                painter: _PillPainter(
                  boxColor: boxColor,
                  radius: radius,
                  bevelHeight: bevelHeight,
                  dpr: dpr,
                  pressed: _pressed,
                ),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 38, vertical: 15),
                  alignment: Alignment.center,
                  child: Text(
                    'Continue',
                    style: GoogleFonts.lato(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      height: 1.0,
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
}

class _PillPainter extends CustomPainter {
  final Color boxColor;
  final double radius;
  final double bevelHeight;
  final double dpr;
  final bool pressed;

  _PillPainter({
    required this.boxColor,
    required this.radius,
    required this.bevelHeight,
    required this.dpr,
    required this.pressed,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..isAntiAlias = true
      ..style = PaintingStyle.fill;

    final RRect pill = RRect.fromRectAndRadius(
      Offset.zero & size,
      Radius.circular(radius),
    );

    // Base fill (brightened slightly on press)
    final Color fillColor = pressed ? _lighten(boxColor, 0.06) : boxColor;
    paint.color = fillColor;
    canvas.drawRRect(pill, paint);

    // ==== Top highlight (subtle stroke) ====
    final double onePx = 1.0 / dpr;
    paint
      ..color = _lighten(fillColor, pressed ? 0.25 : 0.20)
      ..style = PaintingStyle.stroke
      ..strokeWidth = onePx * 1.5;
    canvas.drawRRect(pill.deflate(onePx), paint);

    // ==== Bottom gradient band ====
    final double h = bevelHeight.clamp(0.0, size.height / 2);
    final rect = Rect.fromLTWH(0, size.height - h, size.width, h);
    paint
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          _darken(fillColor, pressed ? 0.20 : 0.15),
          _darken(fillColor, pressed ? 0.35 : 0.28),
        ],
      ).createShader(rect)
      ..style = PaintingStyle.fill;
    canvas.save();
    canvas.clipRRect(pill);
    canvas.drawRect(rect, paint);
    canvas.restore();

    // Reset
    paint.shader = null;
  }

  @override
  bool shouldRepaint(covariant _PillPainter old) =>
      old.boxColor != boxColor ||
      old.radius != radius ||
      old.bevelHeight != bevelHeight ||
      old.dpr != dpr ||
      old.pressed != pressed;
}

// ---- Same color math ----
Color _mix(Color a, Color b, double t) {
  t = t.clamp(0.0, 1.0);
  return Color.fromARGB(
    (a.alpha + (b.alpha - a.alpha) * t).round(),
    (a.red + (b.red - a.red) * t).round(),
    (a.green + (b.green - a.green) * t).round(),
    (a.blue + (b.blue - a.blue) * t).round(),
  );
}

Color _darken(Color c, double t) => _mix(c, Colors.black, t);
Color _lighten(Color c, double t) => _mix(c, Colors.white, t);
