// FILE: lib/z_pages/assets/lessonPage/map_geometry.dart
import 'dart:math';
import 'package:flutter/material.dart';

/// Geometry generator for lesson maps.
/// Nodes flow vertically with zig-zag inside the center portion of the screen.
class LessonMapGeometry {
  static const double verticalGap = 200.0; // distance between nodes (Y)
  static const double startY = 140.0;

  /// 🔹 Change this to 1/2, 1/3, 1/4 etc. to control how wide the map sits.
  /// Example: 1/4 means nodes restricted to the middle quarter of the screen.
  static const double centerFraction = 1 / 5;

  static Size mapSize(BuildContext context, int lessonCount) {
    final height = startY + (lessonCount - 1) * verticalGap + 200;
    return Size(MediaQuery.of(context).size.width, height);
  }

  /// Generate bezier path through all nodes.
  static Path pathFor(int lessonCount, Size size) {
    if (lessonCount <= 1) return Path();
    final nodes = nodesFor(lessonCount, size);
    return _pathThrough(nodes, bend: 60);
  }

  /// Node positions: fixed Y gap, zigzag X inside center fraction of screen.
  static List<Offset> nodesFor(int lessonCount, Size size) {
    final List<Offset> nodes = [];
    final double screenWidth = size.width;

    // Restrict swings inside centerFraction of screen width
    final double leftBound = (1 - centerFraction) / 2 * screenWidth;
    final double rightBound = leftBound + centerFraction * screenWidth;
    final double swing = (rightBound - leftBound) / 2;
    final double centerX = (leftBound + rightBound) / 2;

    for (int i = 0; i < lessonCount; i++) {
      final y = startY + i * verticalGap;
      final x = (i % 2 == 0) ? centerX - swing : centerX + swing;
      nodes.add(Offset(x, y));
    }
    return nodes;
  }

  /// Bezier curve through nodes.
  static Path _pathThrough(List<Offset> pts, {double bend = 60}) {
    final p = Path()..moveTo(pts.first.dx, pts.first.dy);

    for (var i = 0; i < pts.length - 1; i++) {
      final a = pts[i];
      final b = pts[i + 1];
      final mx = (a.dx + b.dx) / 2;
      final my = (a.dy + b.dy) / 2;

      // perpendicular offset for control point
      final dx = b.dx - a.dx;
      final dy = b.dy - a.dy;
      final len = sqrt(dx * dx + dy * dy);
      final px = len == 0 ? 0.0 : -dy / len;
      final py = len == 0 ? 0.0 : dx / len;

      final sgn = (i % 2 == 0) ? 1.0 : -1.0;

      final cx = mx + px * bend * sgn;
      final cy = my + py * bend * sgn;
      p.quadraticBezierTo(cx, cy, b.dx, b.dy);
    }
    return p;
  }
}
