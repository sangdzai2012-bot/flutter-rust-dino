import 'dart:math';

import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';
import '../dino_runner_game.dart';

/// Nền trời với gradient mềm mại và một vài đám mây trôi nhẹ phía sau,
/// tạo chiều sâu (hiệu ứng parallax) cho toàn bộ màn hình chơi.
class BackgroundSky extends PositionComponent
    with HasGameReference<DinoRunnerGame> {
  static const int _cloudCount = 5;

  final Random _random = Random();
  final List<Offset> _cloudPositions = <Offset>[];
  final List<double> _cloudScales = <double>[];

  BackgroundSky({required Vector2 size}) : super(size: size);

  @override
  void onMount() {
    super.onMount();
    if (_cloudPositions.isEmpty) {
      for (int i = 0; i < _cloudCount; i++) {
        _cloudPositions.add(_randomCloudPosition());
        _cloudScales.add(0.6 + _random.nextDouble() * 0.8);
      }
    }
  }

  Offset _randomCloudPosition() {
    return Offset(
      _random.nextDouble() * size.x,
      20 + _random.nextDouble() * (size.y * 0.45),
    );
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (!game.isPlaying) {
      return;
    }

    final double parallaxSpeed = game.currentSpeed * 0.22;
    for (int i = 0; i < _cloudPositions.length; i++) {
      final Offset currentPosition = _cloudPositions[i];
      final double newX = currentPosition.dx - parallaxSpeed * dt;
      if (newX < -90) {
        _cloudPositions[i] = Offset(
          size.x + 40,
          20 + _random.nextDouble() * (size.y * 0.45),
        );
      } else {
        _cloudPositions[i] = Offset(newX, currentPosition.dy);
      }
    }
  }

  @override
  void render(Canvas canvas) {
    final Paint skyPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: <Color>[AppPalette.skyTop, AppPalette.skyBottom],
      ).createShader(Rect.fromLTWH(0, 0, size.x, size.y));
    canvas.drawRect(Rect.fromLTWH(0, 0, size.x, size.y), skyPaint);

    final Paint cloudPaint = Paint()
      ..color = AppPalette.cloudColor.withOpacity(0.75);
    for (int i = 0; i < _cloudPositions.length; i++) {
      final Offset position = _cloudPositions[i];
      final double scale = _cloudScales[i];

      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: position,
            width: 70 * scale,
            height: 26 * scale,
          ),
          Radius.circular(20 * scale),
        ),
        cloudPaint,
      );
      canvas.drawCircle(
        Offset(position.dx - 18 * scale, position.dy - 4),
        16 * scale,
        cloudPaint,
      );
      canvas.drawCircle(
        Offset(position.dx + 16 * scale, position.dy - 6),
        18 * scale,
        cloudPaint,
      );
    }
  }
}
