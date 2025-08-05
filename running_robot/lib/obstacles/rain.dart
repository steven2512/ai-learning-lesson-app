import 'dart:math';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:running_robot/events/event_type.dart';
import 'package:running_robot/obstacles/superclass/drawn_mover.dart';

class Rain extends DrawnMover {
  EventVerticalObstacle currentEvent = EventVerticalObstacle.stopFalling;

  final Vector2 originalStartPosition;

  Rain({
    required Vector2 startPosition,
    required Vector2 endPosition,
    required Vector2 velocity,
  }) : originalStartPosition = startPosition.clone(),
       super(
         startPosition: Vector2(0, -200),
         endPosition: endPosition,
         velocity: velocity,
         customSize: Vector2(4, 14),
         customDraw: _drawRaindrop,
       );

  static void _drawRaindrop(Canvas canvas, Size size) {
    final paint = Paint()..color = const Color(0xFF2196F3);
    final path = Path()
      ..moveTo(size.width / 2, 0)
      ..quadraticBezierTo(
        size.width,
        size.height * 0.6,
        size.width / 2,
        size.height,
      )
      ..quadraticBezierTo(0, size.height * 0.6, size.width / 2, 0)
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (currentEvent == EventVerticalObstacle.startFalling) {
      position += velocity * dt;
      if (_hasPassedEnd()) resetPosition();
    }
  }

  static List<Rain> generateRain({
    required int count,
    required Vector2 startAreaTopLeft,
    required Vector2 startAreaBottomRight,
    required Vector2 endPosition,
    double minSpeed = 100,
    double maxSpeed = 300,
  }) {
    final List<Rain> droplets = [];
    for (int i = 0; i < count; i++) {
      final double x = _randomInRange(
        startAreaTopLeft.x,
        startAreaBottomRight.x,
      );
      final double y = _randomInRange(
        startAreaTopLeft.y,
        startAreaBottomRight.y,
      );
      final double speed = _randomInRange(minSpeed, maxSpeed);

      final Vector2 start = Vector2(x, y);
      final Vector2 velocity = Vector2(0, speed);

      droplets.add(
        Rain(
          startPosition: start,
          endPosition: endPosition,
          velocity: velocity,
        ),
      );
    }
    return droplets;
  }

  void start() {
    currentEvent = EventVerticalObstacle.startFalling;
    position.setFrom(originalStartPosition);
  }

  void stop() {
    currentEvent = EventVerticalObstacle.stopFalling;
    position.setFrom(Vector2(-200, -200));
  }

  bool _hasPassedEnd() => position.y > endPosition.y;

  void resetPosition() => position.setFrom(originalStartPosition);

  static double _randomInRange(double min, double max) {
    return Random().nextDouble() * (max - min) + min;
  }
}
