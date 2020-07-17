import 'package:flutter/animation.dart';

import 'package:flame/components/component.dart';
import 'package:flame/components/mixins/has_game_ref.dart';
import 'package:flame/position.dart';

import 'package:tinycolor/tinycolor.dart';

import 'dart:ui';

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
  Paint _paint;

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

  void render(Canvas canvas) {
    canvas.drawRect(_rect, _paint);
  }
}

class Island extends Component with HasGameRef<SkyFolkGame> {
  final int width;
  final int height;
  double maxTileSize;

  double _projectedHeight;
  double _projectedWidth;

  Rect _borderRect;
  Paint _borderPaint = Paint()..color = Palette.brown;

  Position _cameraTranslate;

  Island({
    this.width = 15,
    this.height = 10,
  });

  List<List<IslandTile>> tiles;

  @override
  void onMount() {
    maxTileSize = ((gameRef.size.width - 200) / width).floorToDouble();
    final minTileSize = (maxTileSize / 2).floorToDouble();

    final tween = Tween<double>(
      begin: minTileSize,
      end: maxTileSize,
    );

    final rowSize = width * maxTileSize;
    _projectedWidth = rowSize;

    double _lastY = 0;

    tiles = List.generate(height, (y) {
      final depth = (y + 1) / height;
      final size = tween.transform(depth).ceilToDouble();

      final currentRowSize = width * size;

      final rowOffset =
          (rowSize / 2).ceilToDouble() - (currentRowSize / 2).ceilToDouble();

      final tiles = List.generate(width, (x) {
        return IslandTile(
          size: size,
          position: Position(x * size + rowOffset, _lastY),
          depth: depth,
          x: x,
          y: y,
        );
      });

      _lastY += size;
      return tiles;
    });

    _projectedHeight = _lastY;
    _borderRect = Rect.fromLTWH(
      0,
      _projectedHeight,
      _projectedWidth,
      (maxTileSize / 2).ceilToDouble(),
    );
    _calcCamera();
  }

  void _calcCamera() {
    final screenMiddleX = gameRef.size.width / 2;
    final screenMiddleY = gameRef.size.height / 2;

    final gameMiddleX = _projectedWidth / 2;
    final gameMiddleY = _projectedHeight / 2;

    _cameraTranslate = Position(
      screenMiddleX - gameMiddleX,
      screenMiddleY - gameMiddleY,
    );
  }

  @override
  void update(double dt) {}

  @override
  void render(Canvas canvas) {
    canvas.save();
    canvas.translate(_cameraTranslate.x, _cameraTranslate.y);
    tiles.forEach((row) {
      row.forEach((tile) {
        tile.render(canvas);
      });
    });
    canvas.drawRect(_borderRect, _borderPaint);
    canvas.restore();
  }

  @override
  int priority() => 2;
}
