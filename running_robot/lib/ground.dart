import 'dart:ui';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

class Ground extends PositionComponent {
  Vector2 dimensions;
  double scroll = 0; // horizontal offset for motion

  Ground({required this.dimensions}) {
    size = dimensions;
    anchor = Anchor.center;

    // Raise the horizon higher -> less ground visible
    position = Vector2(dimensions.x / 2, dimensions.y / 2 + 90);
  }

  @override
  void update(double dt) {
    super.update(dt);
    scroll += dt * 50; // subtle horizontal motion
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    final groundY = size.y / 2;

    // Clean top horizon line
    final linePaint = Paint()
      ..color =
          const Color(0xFFE4ECF3) // very light gray-blue
      ..strokeWidth = 2;
    canvas.drawLine(
      Offset(0, groundY),
      Offset(size.x, groundY),
      linePaint,
    );

    // Main block fill - lighter, desaturated gray
    final blockRect = Rect.fromLTWH(0, groundY, size.x, size.y - groundY);
    final blockPaint = Paint()
      ..shader = LinearGradient(
        colors: [
          const Color(0xFF7D8790), // top: light stone gray
          const Color(0xFFA3ADB5), // bottom: even lighter
        ],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(blockRect);
    canvas.drawRect(blockRect, blockPaint);

    // Subtle horizontal moving bands
    final bandPaint = Paint()
      ..color = const Color(0x11111111); // very faint bands

    const bandWidth = 80.0; // wide bands, very few visible
    final offsetX = -(scroll % (bandWidth * 2));

    for (double x = offsetX; x < size.x; x += bandWidth * 2) {
      canvas.drawRect(
        Rect.fromLTWH(x, groundY, bandWidth, size.y - groundY),
        bandPaint,
      );
    }
  }
}
