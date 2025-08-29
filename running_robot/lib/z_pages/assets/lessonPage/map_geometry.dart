import 'dart:math';
import 'package:flutter/material.dart';

/// Owns ALL hardcoded geometry for the Lessons map.
/// One place to edit paths & node centers.
class LessonMapGeometry {
  static const double canvasHeight = 1800.0;

  static Size mapSize(BuildContext context) =>
      Size(MediaQuery.of(context).size.width, canvasHeight);

  /// ===== PUBLIC API =====
  static Path pathFor(int chapter, Size size) {
    switch (chapter) {
      case 1:
        // Keep your original Chapter 1 path verbatim.
        return _c1Path();
      case 2:
        return _pathThrough(_c2Nodes, bend: 60);
      case 3:
        return _pathThrough(_c3Nodes, bend: 55);
      case 4:
        return _pathThrough(_c4Nodes, bend: 50);
      case 5:
        return _pathThrough(_c5Nodes, bend: 60);
      case 6:
        return _pathThrough(_c6Nodes, bend: 45);
      case 7:
        return _pathThrough(_c7Nodes, bend: 60);
      case 8:
        return _pathThrough(_c8Nodes, bend: 50);
      case 9:
        return _pathThrough(_c9Nodes, bend: 55);
      default:
        return _c1Path();
    }
  }

  static List<Offset> nodesFor(int chapter, Size size) {
    switch (chapter) {
      case 1:
        return _c1Nodes;
      case 2:
        return _c2Nodes;
      case 3:
        return _c3Nodes;
      case 4:
        return _c4Nodes;
      case 5:
        return _c5Nodes;
      case 6:
        return _c6Nodes;
      case 7:
        return _c7Nodes;
      case 8:
        return _c8Nodes;
      case 9:
        return _c9Nodes;
      default:
        return _c1Nodes;
    }
  }

  // Shared Y positions (even spacing like Chapter 1).
  static const List<double> _ys = [
    140,
    340,
    520,
    720,
    920,
    1120,
    1320,
    1520,
    1670
  ];

  static List<Offset> _nodesFromXs(List<double> xs) =>
      List.generate(9, (i) => Offset(xs[i], _ys[i]));

  // Build a smooth S-curve that passes through all nodes.
  // Ensures every node sits exactly on the path.
  static Path _pathThrough(List<Offset> pts, {double bend = 60}) {
    assert(pts.length >= 2);
    final p = Path()..moveTo(pts.first.dx, pts.first.dy);
    for (var i = 0; i < pts.length - 1; i++) {
      final a = pts[i];
      final b = pts[i + 1];
      final mx = (a.dx + b.dx) / 2;
      final my = (a.dy + b.dy) / 2;
      final dx = b.dx - a.dx;
      final dy = b.dy - a.dy;
      final len = sqrt(dx * dx + dy * dy);
      final px = len == 0 ? 0.0 : -dy / len;
      final py = len == 0 ? 0.0 : dx / len;
      final sgn = (i % 2 == 0) ? 1.0 : -1.0; // alternate L/R
      final cx = mx + px * bend * sgn;
      final cy = my + py * bend * sgn;
      p.quadraticBezierTo(cx, cy, b.dx, b.dy);
    }
    return p;
  }

  // ==========================
  // CHAPTER 1 (baseline: your original)
  // ==========================
  static Path _c1Path() {
    return Path()
      ..moveTo(200, 140)
      ..quadraticBezierTo(320, 200, 260, 340)
      ..quadraticBezierTo(100, 420, 140, 520)
      ..quadraticBezierTo(260, 620, 210, 720)
      ..quadraticBezierTo(50, 800, 100, 920)
      ..quadraticBezierTo(300, 1000, 230, 1120)
      ..quadraticBezierTo(100, 1200, 160, 1320)
      ..quadraticBezierTo(280, 1400, 270, 1520)
      ..quadraticBezierTo(100, 1600, 160, 1670);
  }

  static const List<Offset> _c1Nodes = [
    Offset(200, 140),
    Offset(260, 340),
    Offset(140, 520),
    Offset(210, 720),
    Offset(100, 920),
    Offset(230, 1120),
    Offset(160, 1320),
    Offset(270, 1520),
    Offset(160, 1670),
  ];

  // ==========================
  // CHAPTER 2 (slightly wider than Ch1, fixed 9 unique nodes)
  // ==========================
  static final List<Offset> _c2Nodes =
      _nodesFromXs([200, 250, 150, 220, 140, 230, 170, 260, 170]);

  // ==========================
  // CHAPTER 3 (tighter zig-zag)
  // ==========================
  static final List<Offset> _c3Nodes =
      _nodesFromXs([200, 245, 155, 225, 145, 225, 165, 245, 175]);

  // ==========================
  // CHAPTER 4 (narrower, more centered)
  // ==========================
  static final List<Offset> _c4Nodes =
      _nodesFromXs([200, 240, 160, 220, 160, 220, 160, 220, 180]);

  // ==========================
  // CHAPTER 5 (wider right, soft left)
  // ==========================
  static final List<Offset> _c5Nodes =
      _nodesFromXs([200, 260, 150, 230, 150, 230, 160, 240, 170]);

  // ==========================
  // CHAPTER 6 (very centered)
  // ==========================
  static final List<Offset> _c6Nodes =
      _nodesFromXs([200, 235, 165, 215, 165, 215, 165, 215, 185]);

  // ==========================
  // CHAPTER 7 (largest swings)
  // ==========================
  static final List<Offset> _c7Nodes =
      _nodesFromXs([200, 265, 155, 235, 145, 235, 165, 255, 175]);

  // ==========================
  // CHAPTER 8 (balanced/narrow)
  // ==========================
  static final List<Offset> _c8Nodes =
      _nodesFromXs([200, 245, 155, 215, 145, 225, 165, 235, 175]);

  // ==========================
  // CHAPTER 9 (combo of Ch2+Ch3 feel)
  // ==========================
  static final List<Offset> _c9Nodes =
      _nodesFromXs([200, 255, 145, 225, 135, 225, 155, 245, 165]);
}
