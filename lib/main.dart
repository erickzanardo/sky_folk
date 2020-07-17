import 'package:flutter/material.dart';

import 'package:flame/flame.dart';

import './game/sky_folk_game.dart';

void main() async {
  final size = await Flame.util.initialDimensions();
  runApp(SkyFolkGame(size).widget);
}
