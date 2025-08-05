import 'package:flame/components.dart';

class Cloud extends SpriteComponent {
  Cloud({
    required Vector2 position,
    double scale = 2.5,
  }) : super(
         position: position,
         anchor: Anchor.topCenter, // top edge stays at y=0
         scale: Vector2.all(scale),
       );

  @override
  Future<void> onLoad() async {
    sprite = await Sprite.load('cloud_grey.png');
    size = sprite!.originalSize; // lock size to prevent auto-resize later
  }
}
