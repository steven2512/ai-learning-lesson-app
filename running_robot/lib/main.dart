import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:running_robot/my_game.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:running_robot/my_game.dart';

void main() {
  runApp(
    //As soon as GameWidget obj is created, Flame will repeatedly runs game.update() 60 times per minute
    //So everything that is added on Load will constantly be updated
    GameWidget(
      game: MyGame(),
    ),
  );
}
