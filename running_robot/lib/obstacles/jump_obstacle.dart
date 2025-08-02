import 'dart:async';
import 'package:flame/components.dart';

class JumpObstacle extends SpriteComponent {
  final Vector2 initialPosition;
  Vector2 obstacleSize;
  final String picturePath;
  bool isPaused = false;
  Vector2 velocity = Vector2(-200, 0);

  JumpObstacle({
    required this.initialPosition,
    required this.picturePath,
    required this.obstacleSize,
  }) : super(
         position: initialPosition.clone(),
         size: obstacleSize, // give it a size up-front
         anchor: Anchor.center,
       );

  // load the PNG and attach it to this component
  @override
  Future<void> onLoad() async {
    sprite = await Sprite.load(picturePath);
    // optional: resize to the sprite’s native size
    // size = sprite!.srcSize;
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (isPaused) {
      return;
    }

    position.x += velocity.x * dt;
    if (position.x <= -50) {
      position.setFrom(initialPosition);
    }
  }

  // optional helper
  void resetPosition() {
    position.setFrom(initialPosition);
    velocity = Vector2.zero();
  }
}
