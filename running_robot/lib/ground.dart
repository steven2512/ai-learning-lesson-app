import 'dart:ui';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

class Ground extends PositionComponent {
  // ────────── CONFIG ──────────
  final Vector2 dimensions;

  Ground({
    required this.dimensions,
  }) {
    size = dimensions;
    anchor = Anchor.center;

    // Raise the ground a little so there’s less of it on screen
    position = Vector2(dimensions.x / 2, dimensions.y / 2 + 90);
  }

  double get topY => absolutePosition.y;
  @override
  void update(double dt) {
    // Pause everything when the game is stopped
    super.update(dt);
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    final groundY = size.y / 2;

    // Clean horizon line
    canvas.drawLine(
      Offset(0, groundY),
      Offset(size.x, groundY),
      Paint()
        ..color = const Color(0xFFE4ECF3)
        ..strokeWidth = 2,
    );

    // Single-colour ground fill (dark grey)
    canvas.drawRect(
      Rect.fromLTWH(0, groundY, size.x, size.y - groundY),
      Paint()..color = const Color.fromARGB(255, 233, 233, 233),
    );
  }
}
