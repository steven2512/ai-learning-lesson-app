import 'dart:math';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:running_robot/events/event_type.dart';
import 'package:running_robot/obstacles/cloud.dart';
import 'package:running_robot/obstacles/superclass/drawn_mover.dart';
import 'package:flame/collisions.dart'; // + add this

class Rain extends DrawnMover with CollisionCallbacks {
  EventVerticalObstacle currentEvent = EventVerticalObstacle.stopFalling;

  final Cloud cloud; // <— follow THIS cloud only
  final double offsetX;
  final double offsetY;
  final Vector2 originalStartPosition;

  static const double _spawnYOffset = 30;

  Rain({
    required Vector2 startPosition,
    required Vector2 endPosition,
    required Vector2 velocity,
    required this.offsetX,
    required this.offsetY,
    required this.cloud, // <— required
  }) : originalStartPosition = startPosition.clone(),
       super(
         startPosition: startPosition,
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

  void _snapToCloudTop() {
    final c = cloud;
    if (!c.isRemoved) {
      position
        ..x = c.position.x + offsetX
        ..y = c.position.y + _spawnYOffset + offsetY;
    } else {
      position.setFrom(originalStartPosition);
    }
  }

  void switchPhase(EventVerticalObstacle phase) {
    switch (phase) {
      case EventVerticalObstacle.stopFalling:
        stop();
        break;
      case EventVerticalObstacle.startFalling:
        start();
        break;
    }
  }

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    if (currentEvent == EventVerticalObstacle.stopFalling) {
      position.setValues(-200, -200);
    }
    add(RectangleHitbox()..collisionType = CollisionType.passive);
  }

  @override
  void render(Canvas canvas) {
    if (currentEvent == EventVerticalObstacle.stopFalling) return;
    super.render(canvas);
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (currentEvent == EventVerticalObstacle.startFalling) {
      // lock under its own cloud only
      position.x = cloud.position.x + offsetX;

      position.y += velocity.y * dt;
      if (_hasPassedEnd()) _snapToCloudTop();
    }
  }

  static List<Rain> generateRain({
    required int count,
    required Vector2 startAreaTopLeft,
    required Vector2 startAreaBottomRight,
    required Vector2 endPosition,
    required Cloud cloud, // <— bind to this cloud
    double minSpeed = 100,
    double maxSpeed = 300,
    double xSpread = 62,
    double yJitter = 14,
  }) {
    final rng = Random();
    double r(double a, double b) => rng.nextDouble() * (b - a) + a;
    final height = (startAreaBottomRight.y - startAreaTopLeft.y).clamp(0, 30);

    return List.generate(count, (_) {
      final start = Vector2(
        r(startAreaTopLeft.x, startAreaBottomRight.x),
        r(startAreaTopLeft.y, startAreaBottomRight.y),
      );
      final fallSpeed = r(minSpeed, maxSpeed);
      return Rain(
        startPosition: start,
        endPosition: endPosition,
        velocity: Vector2(0, fallSpeed),
        offsetX: r(-xSpread / 2, xSpread / 2),
        offsetY: r(0, min<double>(height.toDouble(), yJitter)),
        cloud: cloud, // <— tie each drop to that cloud
      );
    });
  }

  void start() {
    currentEvent = EventVerticalObstacle.startFalling;
    _snapToCloudTop();
  }

  void stop() {
    currentEvent = EventVerticalObstacle.stopFalling;
    position.setFrom(Vector2(-200, -200));
  }

  bool _hasPassedEnd() => position.y > endPosition.y;
  void reset() {
    // Back to initial state
    currentEvent = EventVerticalObstacle.stopFalling;
    // Hide offscreen like at startup/onLoad
    position.setValues(-200, -200);
  }
}
