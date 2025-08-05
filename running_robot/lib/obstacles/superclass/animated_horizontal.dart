import 'package:flame/components.dart';

class AnimatedHorizontalObstacle extends PositionComponent {
  final Vector2 initialPosition;
  final List<String> framePaths;
  final double stepTime;
  final double speed;

  late final SpriteAnimationComponent animationComponent;

  AnimatedHorizontalObstacle({
    required this.initialPosition,
    required this.framePaths,
    this.stepTime = 0.14,
    this.speed = 250,
    required Vector2 customSize,
  }) : super(
         position: initialPosition.clone(),
         size: customSize, // ✅ use super.size
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

  @override
  void update(double dt) {
    super.update(dt);
    position.x -= speed * dt;

    if (position.x < -size.x) {
      position.setFrom(initialPosition);
    }
  }

  void resetPosition() {
    position.setFrom(initialPosition);
  }
}
