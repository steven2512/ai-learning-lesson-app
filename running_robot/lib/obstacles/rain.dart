import 'dart:math';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:running_robot/obstacles/superclass/vertical.dart';
import 'package:running_robot/Events/event_type.dart';

class Rain extends VerticalObstacle {
  Rain({
    required Vector2 initialPosition,
    required double topY,
  }) : super(
         initialPosition: initialPosition,
         topY: topY,
         sizeOverride: Vector2(4, 14), // ✅ Move size override here
       );

  @override
  void render(Canvas canvas) {
    final paint = Paint()..color = const Color(0xFF2196F3);

    final path = Path()
      ..moveTo(size.x / 2, 0)
      ..quadraticBezierTo(size.x, size.y * 0.6, size.x / 2, size.y)
      ..quadraticBezierTo(0, size.y * 0.6, size.x / 2, 0)
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  void update(double dt) {
    super.update(dt); //
  }

  static List<Rain> generateRain({
    required Vector2 screenSize,
    required double topY,
    int count = 20,
  }) {
    final List<Rain> obstacles = [];

    final double rainAreaWidth = screenSize.x / 3;
    final double rainStartX = (screenSize.x - rainAreaWidth) / 2;
    final double rainStartY = 270;

    for (int i = 0; i < count; i++) {
      final double x = rainStartX + Random().nextDouble() * rainAreaWidth;
      final rain = Rain(
        initialPosition: Vector2(x, rainStartY),
        topY: topY,
      );
      obstacles.add(rain);
    }

    return obstacles;
  }
}
