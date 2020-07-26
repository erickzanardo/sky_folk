import 'package:flame/game.dart';
import 'package:flame/position.dart';

import 'dart:ui';

import './palette.dart';

import './components/island.dart';
import './components/clouded_sky.dart';
import './components/villager.dart';

class SkyFolkGame extends BaseGame {
  Island island;

  SkyFolkGame(Size initialSize) {
    size = initialSize;

    add(CloudedSky());
    add(island = Island());
    add(Villager(
      position: Position(5, 10),
      name: "John",
    ));
  }

  @override
  Color backgroundColor() => Palette.blue1;
}
