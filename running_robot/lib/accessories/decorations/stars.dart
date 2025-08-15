// lib/accessories/decorations/stars.dart
// Minimal Star that only renders the PNG (no fills/tints/glow).
// Keeps the same switchPhase/fill/reset contract for later.

import 'dart:math' as math;
import 'package:flame/components.dart';
import 'package:running_robot/accessories/events/event_type.dart';

class Star extends SpriteComponent {
  final String spritePath;

  // Keep the same public state/entry points so it matches your architecture.
  EventProgressBar currentEvent = EventProgressBar.initial;

  Star({
    required Vector2 position,
    required Vector2 size,
    required double angle,
    this.spritePath = 'star.png',
    // change if your asset path differs
    double angleDeg = 0,
  }) : super(
         position: position,
         size: size,
         anchor: Anchor.center,
         angle: angle,
       ) {
    angle = angleDeg * math.pi / 180.0;
  }

  @override
  Future<void> onLoad() async {
    sprite = await Sprite.load(spritePath);
    // No tint, no extra paints — renders PNG as-is (alpha respected).
  }

  // API kept for compatibility with your EventProgressBar flow.
  void switchPhase(EventProgressBar phase) {
    currentEvent = phase;
    switch (phase) {
      case EventProgressBar.initial:
        reset();
        break;
      case EventProgressBar.proceed:
        fill();
        break;
      case EventProgressBar.finish:
        finish();
        break;
    }
  }

  void fill() {
    // Intentionally no animation right now.
  }

  void finish() {
    // Intentionally no animation right now.
  }

  void reset() {
    // Nothing to reset for the static version.
  }
}
