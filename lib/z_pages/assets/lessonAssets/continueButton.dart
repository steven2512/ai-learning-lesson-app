import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ContinueButton extends StatelessWidget {
  final VoidCallback onPressed;
  const ContinueButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    const Color boxColor = Colors.teal;
    const double radius = 30.0;
    const double bevelHeight = 5.0;
    final double dpr = MediaQuery.of(context).devicePixelRatio;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Keep Material semantics but remove visual feedback
        Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(radius),
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
            hoverColor: Colors.transparent,
            onTap: onPressed,
            child: CustomPaint(
              painter: _PillPainter(
                boxColor: boxColor,
                radius: radius,
                bevelHeight: bevelHeight,
                dpr: dpr,
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
      ],
    );
  }
}

class _PillPainter extends CustomPainter {
  final Color boxColor;
  final double radius;
  final double bevelHeight;
  final double dpr;

  _PillPainter({
    required this.boxColor,
    required this.radius,
    required this.bevelHeight,
    required this.dpr,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Snap function to align to physical pixels (prevents jaggies)
    double snap(double v) => (v * dpr).round() / dpr;
    final double onePx = snap(1.0 / dpr); // exactly 1 physical pixel
    final double h = snap(bevelHeight.clamp(0.0, size.height / 2));

    final RRect pill = RRect.fromRectAndRadius(
      Offset.zero & size,
      Radius.circular(radius),
    );

    // Base fill: solid color (no blending artifacts)
    final Paint body = Paint()
      ..isAntiAlias = true
      ..blendMode = BlendMode.src
      ..color = boxColor;

    // Overlay paint for highlight/bevel stripes
    final Paint overlay = Paint()
      ..isAntiAlias = false // crisp 1px lines
      ..blendMode = BlendMode.srcOver;

    canvas.save();
    canvas.clipRRect(pill); // anti-aliased curved edges

    // 1) Base
    canvas.drawRRect(pill, body);

    // 2) Top inner 1px highlight
    overlay.color = _lighten(boxColor, 0.22);
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, onePx), overlay);

    // 3) Bottom inner bevel band
    overlay.color = _darken(boxColor, 0.18);
    canvas.drawRect(
      Rect.fromLTWH(0, size.height - h, size.width, h),
      overlay,
    );

    // 4) Bottom 1px lip
    overlay.color = _darken(boxColor, 0.28);
    canvas.drawRect(
      Rect.fromLTWH(0, size.height - onePx, size.width, onePx),
      overlay,
    );

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _PillPainter old) =>
      old.boxColor != boxColor ||
      old.radius != radius ||
      old.bevelHeight != bevelHeight ||
      old.dpr != dpr;
}

// ---- Color helpers (same math as your Flame button) ----
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
