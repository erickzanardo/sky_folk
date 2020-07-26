import 'package:flame/components/component.dart';
import 'package:flame/components/mixins/has_game_ref.dart';

import 'package:flame/time.dart';

import 'package:tinycolor/tinycolor.dart';

import 'dart:ui';
import 'dart:math';

import '../sky_folk_game.dart';
import '../palette.dart';

const CLOUD_SPEED = -5;
const CLOUD_WIDTH = 100.0;
const CLOUD_HEIGHT = 50.0;

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

  void move(double ammount) {
    final o = Offset(ammount, 0);
    rrect1 = rrect1.shift(o);
    rrect2 = rrect2.shift(o);
  }
}

class CloudedSky extends Component with HasGameRef<SkyFolkGame> {

  Paint _color1;
  Paint _color2;

  List<Cloud> _clouds;

  Timer _cloudCreator;

  Random r = Random();

  double _spaceAvailable;

  CloudedSky() {
    _color1 = Paint()..color = Palette.white;
    _color2 = Paint()..color = TinyColor(Palette.white).darken(10).color;

    _cloudCreator = Timer((CLOUD_WIDTH / CLOUD_SPEED).abs(), repeat: true, callback: _spawnCloud)..start();
  }

  @override
  void onMount() {
    _spaceAvailable = gameRef.size.height / 4;
    _generateInitialClouds();
  }

  void _generateInitialClouds() {
    final cloudCount = (gameRef.size.width / CLOUD_WIDTH).floor();


    _clouds = List.generate(cloudCount, (i) {
      return Cloud(
          rect: Rect.fromLTWH(
              (i * CLOUD_WIDTH) - min(0.5, r.nextDouble()) * CLOUD_WIDTH,
              r.nextDouble() * _spaceAvailable,
              CLOUD_WIDTH - 20,
              CLOUD_HEIGHT,
          ),
          color1: _color1,
          color2: _color2,
      );
    });
  }

  void _spawnCloud() {
    _clouds.add(Cloud(
          rect: Rect.fromLTWH(
              gameRef.size.width + CLOUD_WIDTH,
              r.nextDouble() * _spaceAvailable,
              CLOUD_WIDTH - 20,
              CLOUD_HEIGHT,
          ),
          color1: _color1,
          color2: _color2,
      ),
    );
  }

  @override
  void update(double dt) {
    _cloudCreator.update(dt);
    _clouds.forEach((c) {
      c.move(CLOUD_SPEED * dt);
    });

    _clouds.removeWhere((c) {
      return c.rrect2.right < 0;
    });
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
