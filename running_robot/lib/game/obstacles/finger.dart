// finger.dart — SHOW/HIDE WITH FADE ANIMATION
import 'dart:async';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:running_robot/game/events/event_type.dart';
import 'package:running_robot/game/obstacles/superclass/simple_mover.dart';

class Finger extends SimpleMover {
  EventFinger currentEvent = EventFinger.hide;

  final double speed;
  Vector2 velocity = Vector2.zero();

  late final Vector2 _originalPosition;

  final double cutoffUp;
  final double cutoffDown;
  final double cutoffRight;
  final double cutoffLeft;

  // 👇 Global flag: fade duration in seconds (0 = instant)
  static double fadeDuration = 0.5;

  double opacity = 1.0;
  bool isVisible = false;
  bool _fading = false;

  Finger({
    required super.initialPosition,
    required super.picturePath,
    required super.size,
    this.speed = 150.0,
    required List<double> cutoffs, // [up, down, right, left]
  })  : cutoffUp = cutoffs[0],
        cutoffDown = cutoffs[1],
        cutoffRight = cutoffs[2],
        cutoffLeft = cutoffs[3] {
    _originalPosition = initialPosition.clone();
  }

  // ────────── Public API ──────────
  void switchPhase(EventFinger phase) {
    currentEvent = phase;
    switch (phase) {
      case EventFinger.up:
        up();
        break;
      case EventFinger.down:
        down();
        break;
      case EventFinger.left:
        left();
        break;
      case EventFinger.right:
        right();
        break;
      case EventFinger.hide:
        fadeOut();
        break;
      case EventFinger.show:
        fadeIn();
        break;
    }
  }

  void up() => velocity = Vector2(0, -speed);
  void down() => velocity = Vector2(0, speed);
  void left() => velocity = Vector2(-speed, 0);
  void right() => velocity = Vector2(speed, 0);

  /// Hard reset (kill instantly)
  void reset() {
    position = _originalPosition.clone();
    velocity = Vector2.zero();
    currentEvent = EventFinger.hide;
    isVisible = false;
    opacity = 0.0;
  }

  /// Smooth fade in
  Future<void> fadeIn() async {
    if (_fading) return;
    _fading = true;
    isVisible = true;

    final steps = 20;
    for (int i = 0; i <= steps; i++) {
      opacity = (i / steps);
      await Future.delayed(
          Duration(milliseconds: (fadeDuration * 1000 / steps).round()));
    }

    opacity = 1.0;
    _fading = false;
  }

  /// Smooth fade out
  Future<void> fadeOut() async {
    if (_fading) return;
    _fading = true;

    final steps = 20;
    for (int i = 0; i <= steps; i++) {
      opacity = 1.0 - (i / steps);
      await Future.delayed(
          Duration(milliseconds: (fadeDuration * 1000 / steps).round()));
    }

    opacity = 0.0;
    isVisible = false;
    _fading = false;
  }

  /// Fade out → reset → fade in (loop when hitting cutoffs)
  Future<void> fadeOutAndRestart() async {
    if (_fading) return;
    _fading = true;

    final steps = 20;
    for (int i = 0; i <= steps; i++) {
      opacity = 1.0 - (i / steps);
      await Future.delayed(
          Duration(milliseconds: (fadeDuration * 1000 / steps).round()));
    }

    position = _originalPosition.clone();

    for (int i = 0; i <= steps; i++) {
      opacity = (i / steps);
      await Future.delayed(
          Duration(milliseconds: (fadeDuration * 1000 / steps).round()));
    }

    switchPhase(currentEvent);
    _fading = false;
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (isVisible && velocity != Vector2.zero() && !_fading) {
      position += velocity * dt;

      // cutoff checks → fade and restart
      if (currentEvent == EventFinger.up && position.y <= cutoffUp) {
        fadeOutAndRestart();
      }
      if (currentEvent == EventFinger.down && position.y >= cutoffDown) {
        fadeOutAndRestart();
      }
      if (currentEvent == EventFinger.right && position.x >= cutoffRight) {
        fadeOutAndRestart();
      }
      if (currentEvent == EventFinger.left && position.x <= cutoffLeft) {
        fadeOutAndRestart();
      }
    }
  }

  @override
  void render(Canvas canvas) {
    if (isVisible && opacity > 0) {
      canvas.saveLayer(
          null, Paint()..color = Colors.white.withOpacity(opacity));
      super.render(canvas);
      canvas.restore();
    }
  }
}
