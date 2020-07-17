import 'package:flutter/animation.dart';

import 'package:flame/components/component.dart';
import 'package:flame/components/mixins/has_game_ref.dart';
import 'package:flame/position.dart';

import 'package:tinycolor/tinycolor.dart';

import 'dart:ui';
import 'dart:math';

import '../sky_folk_game.dart';
import '../palette.dart';

class Cloud {
  Rect rect;
  final Paint color1;
  final Paint color2;

  RRect rrect1;
  RRect rrect2;

  Cloud({
    this.rect,
    this.color1,
    this.color2,
  }) {
    _calcRRects();
  }

  void _calcRRects() {
    final radius = const Radius.elliptical(10, 10);
    rrect1 = RRect.fromRectAndRadius(rect, radius);
    rrect2 = RRect.fromRectAndRadius(rect.translate(10, 0), radius);
  }

  void render(Canvas canvas) {
    canvas.drawRRect(rrect2, color2);
    canvas.drawRRect(rrect1, color1);
  }
}

class CloudedSky extends Component with HasGameRef<SkyFolkGame> {

  Paint _color1;
  Paint _color2;

  List<Cloud> _clouds;

  CloudedSky() {
    _color1 = Paint()..color = Palette.white;
    _color2 = Paint()..color = TinyColor(Palette.white).darken(10).color;
  }

  @override
  void onMount() {
    _generateInitialClouds();
  }

  void _generateInitialClouds() {
    final cloudWidth = 100.0;
    final cloudHeight = 50.0;
    final cloudCount = (gameRef.size.width / cloudWidth).floor();

    Random r = Random();

    final spaceAvailable = gameRef.size.height / 4;

    _clouds = List.generate(cloudCount, (i) {
      return Cloud(
          rect: Rect.fromLTWH(
              (i * cloudWidth) - min(0.5, r.nextDouble()) * cloudWidth,
              r.nextDouble() * spaceAvailable,
              cloudWidth - 20,
              cloudHeight,
          ),
          color1: _color1,
          color2: _color2,
      );
    });
  }

  @override
  void update(double dt) {
  }

  @override
  void render(Canvas canvas) {
    _clouds.forEach((c) {
      c.render(canvas);
    });
  }

  @override
  int priority() => 2;
}
