import 'package:flutter/animation.dart';

import 'package:flame/components/component.dart';
import 'package:flame/components/mixins/has_game_ref.dart';
import 'package:flame/position.dart';

import 'package:tinycolor/tinycolor.dart';

import 'dart:ui';
import 'dart:math';

import '../sky_folk_game.dart';
import '../palette.dart';

enum IslandTileType {
  GRASS,
}

class IslandTile {
  final IslandTileType type;
  final int x;
  final int y;

  final double depth;

  final Position position;
  final double size;

  Rect _rect;
  Rect _borderRect;
  Paint _paint;
  Paint _borderPaint;

  static final tween = Tween<int>(
    begin: 40,
    end: 0,
  );

  IslandTile({
    this.size,
    this.position,
    this.depth,
    this.type,
    this.x,
    this.y,
  }) {
    _rect = Rect.fromLTWH(position.x, position.y, size, size);
    final tinyColor = TinyColor(Palette.green1).darken(tween.transform(depth));


    _paint = Paint()..color = tinyColor.color;
  }

  set hasBorder(bool _hasBorder) {
    if (_hasBorder) {
      _borderRect = _rect.translate(0, _rect.height);

      final tinyColor = TinyColor(Palette.brown).darken(tween.transform(depth));
      _borderPaint = Paint()..color = tinyColor.color;
    }
  }

  void render(Canvas canvas) {
    canvas.drawRect(_rect, _paint);
    if (_borderRect != null) {
      canvas.drawRect(_borderRect, _borderPaint);
    }
  }
}

class Island extends Component with HasGameRef<SkyFolkGame> {
  final int width;
  final int height;
  double maxTileSize;

  double _projectedHeight;
  double _projectedWidth;

  Position cameraTranslate;

  Island({
    this.width = 20,
    this.height = 20,
  });

  List<List<IslandTile>> tiles;

  @override
  void onMount() {
    maxTileSize = ((gameRef.size.height - 200) / height).floorToDouble();
    final minTileSize = (maxTileSize / 2).floorToDouble();

    final tween = Tween<double>(
      begin: minTileSize,
      end: maxTileSize,
    );

    final rowSize = width * maxTileSize;
    _projectedWidth = rowSize;

    double _lastY = 0;

    final middleX = (width / 2).ceil();
    final middleY = (height /2).ceil();

    final radius = height / 2;

    tiles = List.generate(height, (y) {
      final depth = (y + 1) / height;
      final size = tween.transform(depth).ceilToDouble();

      final currentRowSize = width * size;

      final rowOffset =
          (rowSize / 2).ceilToDouble() - (currentRowSize / 2).ceilToDouble();

      final tiles = List.generate(width, (x) {
        if ((pow(x - middleX, 2) + pow(y - middleY, 2)) <= pow(radius, 2)) {
          return IslandTile(
              size: size,
              position: Position(x * size + rowOffset, _lastY),
              depth: depth,
              x: x,
              y: y,
          );
        }

        return null;
      });

      _lastY += size;
      return tiles;
    });

    // Calc if there is border on the tile
    for (var y = 0; y < tiles.length; y++) {
      for (var x = 0; x < tiles[y].length; x++) {
        final currentTile = tiles[y][x];
        if (currentTile != null) {
          if (y + 1 == tiles.length) {
            currentTile.hasBorder = true;
          } else if (tiles[y + 1][x] == null) {
            currentTile.hasBorder = true;
          }
        }
      }
    }

    _projectedHeight = _lastY;
    _calcCamera();
  }

  void _calcCamera() {
    final screenMiddleX = gameRef.size.width / 2;
    final screenMiddleY = gameRef.size.height / 2;

    final gameMiddleX = _projectedWidth / 2;
    final gameMiddleY = _projectedHeight / 2;

    cameraTranslate = Position(
      screenMiddleX - gameMiddleX,
      screenMiddleY - gameMiddleY,
    );
  }

  @override
  void update(double dt) {}

  @override
  void render(Canvas canvas) {
    canvas.save();
    canvas.translate(cameraTranslate.x, cameraTranslate.y);
    tiles.forEach((row) {
      row.forEach((tile) {
        tile?.render(canvas);
      });
    });
    canvas.restore();
  }

  @override
  int priority() => 2;
}
