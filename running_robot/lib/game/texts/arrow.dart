import 'dart:ui' show Canvas, Paint, Rect, Color;
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:running_robot/game/events/event_type.dart';

class Arrow extends SpriteComponent implements OpacityProvider {
  final String imageFile;
  final double fadeDuration;

  EventHorizontalObstacle currentEvent = EventHorizontalObstacle.stopMoving;

  double _opacity = 1.0;
  @override
  double get opacity => _opacity;
  @override
  set opacity(double value) => _opacity = value.clamp(0.0, 1.0);

  OpacityEffect? _fadeEffect;

  Arrow({
    required this.imageFile,
    required Vector2 position,
    required Vector2 size,
    this.fadeDuration = 0.25,
  }) : super(position: position, size: size);

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    sprite = await Sprite.load(imageFile);
    opacity = currentEvent == EventHorizontalObstacle.startMoving ? 1.0 : 0.0;
  }

  void switchPhase(EventHorizontalObstacle event) {
    if (event == EventHorizontalObstacle.startMoving) {
      start();
    } else {
      stop();
    }
  }

  void start() {
    _fadeEffect?.removeFromParent();
    _fadeEffect = null;
    currentEvent = EventHorizontalObstacle.startMoving;
  }

  void stop() {
    _fadeEffect?.removeFromParent();
    _fadeEffect = null;
    currentEvent = EventHorizontalObstacle.stopMoving;
  }

  void _startFade(
    double target,
    double duration, {
    void Function()? onComplete,
  }) {
    _fadeEffect?.removeFromParent();
    final fx = OpacityEffect.to(
      target,
      EffectController(duration: duration),
      onComplete: () {
        _fadeEffect = null;
        onComplete?.call();
      },
    );
    _fadeEffect = fx;
    add(fx);
  }

  @override
  void update(double dt) {
    super.update(dt);
    switch (currentEvent) {
      case EventHorizontalObstacle.startMoving:
        if (_fadeEffect == null && opacity < 1.0) {
          _startFade(1.0, fadeDuration);
        }
        break;
      case EventHorizontalObstacle.stopMoving:
        if (_fadeEffect == null && opacity > 0.0) {
          _startFade(0.0, fadeDuration);
        }
        break;
    }
  }

  @override
  void render(Canvas canvas) {
    final r = Rect.fromLTWH(0, 0, size.x, size.y);
    canvas.saveLayer(
      r,
      Paint()..color = Color.fromRGBO(255, 255, 255, opacity),
    );
    super.render(canvas);
    canvas.restore();
  }

  void reset() {
    // Return to initial hidden state
    currentEvent = EventHorizontalObstacle.stopMoving;
    _fadeEffect?.removeFromParent();
    _fadeEffect = null;
    opacity = 0.0;
  }
}
