import 'package:flame/game.dart';

import 'dart:ui';

import './palette.dart';

import './components/island.dart';
import './components/clouded_sky.dart';

class SkyFolkGame extends BaseGame {
  SkyFolkGame(Size initialSize) {
    size = initialSize;

    add(CloudedSky());
    add(Island());
  }

  @override
  Color backgroundColor() => Palette.blue2;
}
