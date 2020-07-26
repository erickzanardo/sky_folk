import 'package:flutter/animation.dart';

import 'package:flame/components/component.dart';
import 'package:flame/components/mixins/has_game_ref.dart';
import 'package:flame/position.dart';

import 'package:tinycolor/tinycolor.dart';

import '../sky_folk_game.dart';
import '../palette.dart';

import 'dart:ui';

class Villager extends Component with HasGameRef<SkyFolkGame> {
  static final tween = Tween<int>(
    begin: 40,
    end: 0,
  );

  Position position;
  String name;

  Paint hairPaint;
  Paint headPaint;
  Paint bodyPaint;

  Rect hairRect;
  Rect headRect;
  Rect bodyRect;

  Villager({
    this.position,
    this.name,
  });

  @override
  void onMount() {
    _buildVillager();
  }

  void _buildVillager() {
    // TODO get random colors

    final myTile = gameRef.island.tiles[position.y.floor()][position.x.floor()];
    final tileSize = myTile.size;

    final height = tileSize * 0.8;
    final width = tileSize / 5;

    hairPaint = Paint()..color = TinyColor(Palette.brown).darken(tween.transform(myTile.depth)).color;
    headPaint = Paint()..color = TinyColor(Palette.yellow1).darken(tween.transform(myTile.depth)).color;
    bodyPaint = Paint()..color = TinyColor(Palette.red1).darken(tween.transform(myTile.depth)).color;

    final hairPortion = 0.2;
    final headPortion = 0.3;
    final bodyPortion = 0.5;

    final tileX = position.x * myTile.size + myTile.position.x;
    final tileY = position.y * myTile.size + myTile.position.y;

    hairRect = Rect.fromLTWH(
        tileX,
        tileY,
        width, 
        height * hairPortion, 
    );

    headRect = Rect.fromLTWH(
        tileX,
        tileY + hairRect.height,
        width, 
        height * headPortion, 
    );

    bodyRect = Rect.fromLTWH(
        tileX,
        tileY + headRect.height,
        width, 
        height * bodyPortion, 
    );

    print(bodyRect);
  }

  @override
  void update(double dt) {
  }

  @override
  void render(Canvas canvas) {
    // TODO This is not good, need to think on a better solution
    final cameraTranslate = gameRef.island.cameraTranslate;
    canvas.save();
    canvas.translate(cameraTranslate.x, cameraTranslate.y);

    canvas.drawRect(hairRect, hairPaint);
    canvas.drawRect(headRect, headPaint);
    canvas.drawRect(bodyRect, bodyPaint);

    canvas.restore();
  }

  @override
  int priority() => 3;
}
