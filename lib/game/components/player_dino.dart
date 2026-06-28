import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';
import '../dino_runner_game.dart';
import 'obstacle.dart';

/// Nhân vật chính của game: chú khủng long được vẽ hoàn toàn bằng các hình
/// khối hình học bo góc (không dùng hình ảnh/sprite có sẵn), theo đúng tinh
/// thần tối giản của Material 3.
class PlayerDino extends PositionComponent
    with CollisionCallbacks, HasGameReference<DinoRunnerGame> {
  static const double gravity = 2600;
  static const double jumpVelocity = -920;
  static const double bodyWidth = 54;
  static const double bodyHeight = 58;

  double _verticalVelocity = 0;
  double _groundY = 0;
  bool _isOnGround = true;
  double _legSwingTimer = 0;
  bool _showAlternateLegFrame = false;

  PlayerDino()
      : super(
          size: Vector2(bodyWidth, bodyHeight),
          anchor: Anchor.bottomLeft,
          children: <Component>[
            RectangleHitbox(
              size: Vector2(bodyWidth * 0.78, bodyHeight * 0.82),
              position: Vector2(bodyWidth * 0.11, bodyHeight * 0.10),
            ),
          ],
        );

  /// Đặt khủng long lên đúng vị trí mặt đất và làm mới mọi trạng thái vật lý.
  void placeOnGround(double groundLevelY) {
    _groundY = groundLevelY;
    position = Vector2(position.x, _groundY);
    _isOnGround = true;
    _verticalVelocity = 0;
  }

  /// Cho khủng long nhảy lên, chỉ có tác dụng khi đang ở trên mặt đất.
  void jump() {
    if (_isOnGround) {
      _verticalVelocity = jumpVelocity;
      _isOnGround = false;
    }
  }

  /// Đưa khủng long trở lại mặt đất khi bắt đầu một lượt chơi mới.
  void resetToGround() {
    position = Vector2(position.x, _groundY);
    _verticalVelocity = 0;
    _isOnGround = true;
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (!game.isPlaying) {
      return;
    }

    if (!_isOnGround) {
      _verticalVelocity += gravity * dt;
      position.y += _verticalVelocity * dt;
      if (position.y >= _groundY) {
        position.y = _groundY;
        _verticalVelocity = 0;
        _isOnGround = true;
      }
    } else {
      _legSwingTimer += dt;
      if (_legSwingTimer > 0.12) {
        _legSwingTimer = 0;
        _showAlternateLegFrame = !_showAlternateLegFrame;
      }
    }
  }

  @override
  void onCollisionStart(
    Set<Vector2> intersectionPoints,
    PositionComponent other,
  ) {
    super.onCollisionStart(intersectionPoints, other);
    if (other is Obstacle) {
      game.triggerGameOver();
    }
  }

  @override
  void render(Canvas canvas) {
    final Paint bodyPaint = Paint()..color = AppPalette.dinoBody;
    final Paint shadowPaint = Paint()..color = AppPalette.dinoBodyDark;
    final Paint eyePaint = Paint()..color = AppPalette.dinoEye;

    final double legLiftA = _showAlternateLegFrame ? 5.0 : 0.0;
    final double legLiftB = _showAlternateLegFrame ? 0.0 : 5.0;

    // Hai chân của khủng long, đổi vị trí lên xuống để tạo cảm giác đang chạy.
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          size.x * 0.18,
          size.y * 0.80 - legLiftA,
          size.x * 0.18,
          size.y * 0.20 + legLiftA,
        ),
        const Radius.circular(7),
      ),
      shadowPaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          size.x * 0.58,
          size.y * 0.80 - legLiftB,
          size.x * 0.18,
          size.y * 0.20 + legLiftB,
        ),
        const Radius.circular(7),
      ),
      shadowPaint,
    );

    // Đuôi khủng long, vẽ bằng một hình tam giác bo góc đơn giản.
    final Path tailPath = Path()
      ..moveTo(size.x * 0.10, size.y * 0.40)
      ..lineTo(-size.x * 0.20, size.y * 0.28)
      ..lineTo(size.x * 0.10, size.y * 0.58)
      ..close();
    canvas.drawPath(tailPath, bodyPaint);

    // Thân khủng long.
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          size.x * 0.08,
          size.y * 0.20,
          size.x * 0.72,
          size.y * 0.62,
        ),
        const Radius.circular(22),
      ),
      bodyPaint,
    );

    // Đầu khủng long.
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          size.x * 0.50,
          0,
          size.x * 0.48,
          size.y * 0.48,
        ),
        const Radius.circular(18),
      ),
      bodyPaint,
    );

    // Mắt khủng long.
    canvas.drawCircle(
      Offset(size.x * 0.82, size.y * 0.17),
      size.x * 0.05,
      eyePaint,
    );
  }
}
