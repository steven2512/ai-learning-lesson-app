import 'package:flutter/material.dart';

class LightBeam extends StatelessWidget {
  final Offset origin;
  final double width;
  final double height;
  final Color color;
  final Animation<double> animation; // fade in/out

  const LightBeam({
    super.key,
    required this.origin,
    required this.animation,
    this.width = 200,
    this.height = 300,
    this.color = Colors.blueAccent,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return CustomPaint(
          painter: _LightBeamPainter(
            origin: origin,
            width: width,
            height: height,
            color: color.withOpacity(animation.value),
          ),
        );
      },
    );
  }
}

class _LightBeamPainter extends CustomPainter {
  final Offset origin;
  final double width;
  final double height;
  final Color color;

  _LightBeamPainter({
    required this.origin,
    required this.width,
    required this.height,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          color.withOpacity(0.6),
          color.withOpacity(0.0),
        ],
      ).createShader(Rect.fromLTWH(
        origin.dx - width / 2,
        origin.dy,
        width,
        height,
      ));

    final path = Path()
      ..moveTo(origin.dx, origin.dy)
      ..lineTo(origin.dx - width / 2, origin.dy + height)
      ..lineTo(origin.dx + width / 2, origin.dy + height)
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _LightBeamPainter oldDelegate) {
    return oldDelegate.origin != origin ||
        oldDelegate.width != width ||
        oldDelegate.height != height ||
        oldDelegate.color != color;
  }
}
