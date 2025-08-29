import 'package:flutter/material.dart';

/// Paints a concrete Path. No abstractions, no indirection.
class PathPainter extends CustomPainter {
  final Path path;
  final Color color;
  final double strokeWidth;

  const PathPainter({
    required this.path,
    this.color = Colors.black26,
    this.strokeWidth = 5.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant PathPainter oldDelegate) {
    // Repaint if the paint props or the path instance changed.
    return oldDelegate.color != color ||
        oldDelegate.strokeWidth != strokeWidth ||
        oldDelegate.path != path;
  }
}
