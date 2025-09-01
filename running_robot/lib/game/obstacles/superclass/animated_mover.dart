import 'package:flame/components.dart';

class AnimatedMover extends PositionComponent {
  final List<String> framePaths;
  final Vector2 startPosition;
  final Vector2 endPosition;
  final Vector2 velocity;
  final double stepTime;
  final Vector2 customSize;

  late final SpriteAnimationComponent animationComponent;

  AnimatedMover({
    required this.framePaths,
    required this.startPosition,
    required this.endPosition,
    required this.velocity,
    required this.customSize,
    this.stepTime = 0.12,
  }) : super(
          position: startPosition.clone(),
          size: customSize,
          anchor: Anchor.center,
        );

  @override
  Future<void> onLoad() async {
    final frames = await Future.wait(framePaths.map(Sprite.load));
    animationComponent = SpriteAnimationComponent(
      animation: SpriteAnimation.spriteList(frames, stepTime: stepTime),
      size: size,
      anchor: Anchor.center,
    );
    add(animationComponent);
  }

  // ❌ Don't override update at all
  // The child will call these explicitly

  void updateAnimation(double dt) {
    animationComponent.update(dt);
  }

  void updateMovement(double dt) {
    position += velocity * dt;

    if (_hasPassedEnd()) {
      position.setFrom(startPosition);
    }
  }

  bool _hasPassedEnd() {
    final dx = endPosition.x - startPosition.x;
    final dy = endPosition.y - startPosition.y;

    final passedX =
        dx >= 0 ? position.x >= endPosition.x : position.x <= endPosition.x;
    final passedY =
        dy >= 0 ? position.y >= endPosition.y : position.y <= endPosition.y;

    return passedX && passedY;
  }
}
