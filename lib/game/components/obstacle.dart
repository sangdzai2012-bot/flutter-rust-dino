import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../dino_runner_game.dart';

/// Ba kiểu hình dáng chướng ngại vật khác nhau để tạo sự đa dạng khi chơi.
enum ObstacleShape { singleBlock, tallBlock, tripleCluster }

/// Chướng ngại vật mà khủng long phải nhảy qua. Cũng được vẽ hoàn toàn bằng
/// các khối hình học bo góc, đổ màu theo bảng màu Material 3 Expressive.
class Obstacle extends PositionComponent with HasGameReference<DinoRunnerGame> {
  final ObstacleShape shapeType;
  final Color fillColor;
  final Color shadowColor;

  Obstacle({
    required this.shapeType,
    required Vector2 size,
    required Vector2 position,
    required this.fillColor,
    required this.shadowColor,
  }) : super(
          size: size,
          position: position,
          anchor: Anchor.bottomLeft,
          children: <Component>[
            RectangleHitbox(
              size: Vector2(size.x * 0.78, size.y * 0.86),
              position: Vector2(size.x * 0.11, size.y * 0.08),
            ),
          ],
        );

  @override
  void update(double dt) {
    super.update(dt);

    if (!game.isPlaying) {
      return;
    }

    position.x -= game.currentSpeed * dt;
    if (position.x + size.x < 0) {
      removeFromParent();
    }
  }

  @override
  void render(Canvas canvas) {
    switch (shapeType) {
      case ObstacleShape.singleBlock:
        _drawRoundedColumn(canvas, left: 0, width: size.x, height: size.y);
        break;
      case ObstacleShape.tallBlock:
        _drawRoundedColumn(canvas, left: 0, width: size.x, height: size.y);
        break;
      case ObstacleShape.tripleCluster:
        final double columnWidth = size.x / 3.4;
        _drawRoundedColumn(
          canvas,
          left: 0,
          width: columnWidth,
          height: size.y * 0.70,
        );
        _drawRoundedColumn(
          canvas,
          left: columnWidth * 1.15,
          width: columnWidth,
          height: size.y,
        );
        _drawRoundedColumn(
          canvas,
          left: columnWidth * 2.30,
          width: columnWidth,
          height: size.y * 0.55,
        );
        break;
    }
  }

  void _drawRoundedColumn(
    Canvas canvas, {
    required double left,
    required double width,
    required double height,
  }) {
    final double top = size.y - height;
    final Paint mainPaint = Paint()..color = fillColor;
    final Paint sidePaint = Paint()..color = shadowColor;

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(left, top, width, height),
        const Radius.circular(14),
      ),
      mainPaint,
    );

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(left + width * 0.62, top, width * 0.38, height),
        const Radius.circular(14),
      ),
      sidePaint,
    );
  }
}
