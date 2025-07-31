import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(
    GameWidget(
      game: FlameGame(
        world: MyWorld(),
      ),
    ),
  );
}

class MyWorld extends World {
  @override
  //You don't need to wait for me, just go ahead
  //We are gonna be async
  Future<void> onLoad() async {
    add(Player(position: Vector2(0, 0)));
  }
}

class Player extends SpriteComponent with TapCallbacks {
  Player({super.position})
    : super(size: Vector2.all(200), anchor: Anchor.center);

  @override
  Future<void> onLoad() async {
    sprite = await Sprite.load('characters/tree.png');
  }

  @override
  void onTapUp(TapUpEvent info) {
    size += Vector2.all(50);
  }
}
