import 'dart:async';
import 'package:flame/components.dart';

class HorizontalObstacle extends SpriteComponent {
  final Vector2 initialPosition;
  final String picturePath;

  HorizontalObstacle({
    required this.initialPosition,
    required this.picturePath,
    required Vector2 size,
  }) : super(
         position: initialPosition.clone(),
         size: size,
         anchor: Anchor.center,
       );

  @override
  Future<void> onLoad() async {
    sprite = await Sprite.load(picturePath);
  }

  @override
  void update(double dt) {
    super.update(dt);
    // Base class does nothing on its own
  }

  void resetPosition() {
    position.setFrom(initialPosition);
  }
}
