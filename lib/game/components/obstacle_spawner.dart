import 'dart:math';

import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';
import '../dino_runner_game.dart';
import 'obstacle.dart';

/// Một cặp màu (màu chính và màu đậm hơn dùng làm bóng) cho chướng ngại vật.
class ObstacleColorPair {
  final Color fill;
  final Color shadow;

  const ObstacleColorPair({required this.fill, required this.shadow});
}

/// Thành phần logic (không có hình ảnh riêng) chịu trách nhiệm sinh ra
/// chướng ngại vật mới một cách ngẫu nhiên theo thời gian.
class ObstacleSpawner extends Component with HasGameReference<DinoRunnerGame> {
  final double groundY;
  final Random _random = Random();
  double _timeUntilNextSpawn = 0;

  ObstacleSpawner({required this.groundY});

  @override
  void onMount() {
    super.onMount();
    _scheduleNextSpawn();
  }

  void _scheduleNextSpawn() {
    final double speedProgress =
        (game.currentSpeed - DinoRunnerGame.initialSpeed) / 900;
    final double minGap = max(0.55, 1.35 - speedProgress);
    _timeUntilNextSpawn = minGap + _random.nextDouble() * 0.9;
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (!game.isPlaying) {
      return;
    }

    _timeUntilNextSpawn -= dt;
    if (_timeUntilNextSpawn <= 0) {
      _spawnObstacle();
      _scheduleNextSpawn();
    }
  }

  void _spawnObstacle() {
    final List<ObstacleShape> allShapes = ObstacleShape.values;
    final ObstacleShape pickedShape =
        allShapes[_random.nextInt(allShapes.length)];

    late Vector2 obstacleSize;
    switch (pickedShape) {
      case ObstacleShape.singleBlock:
        obstacleSize = Vector2(38, 46);
        break;
      case ObstacleShape.tallBlock:
        obstacleSize = Vector2(34, 76);
        break;
      case ObstacleShape.tripleCluster:
        obstacleSize = Vector2(100, 50);
        break;
    }

    final List<ObstacleColorPair> colorOptions = <ObstacleColorPair>[
      const ObstacleColorPair(
        fill: AppPalette.cactusJade,
        shadow: AppPalette.cactusJadeDark,
      ),
      const ObstacleColorPair(
        fill: AppPalette.tertiaryAccent,
        shadow: AppPalette.tertiaryAccentDark,
      ),
    ];
    final ObstacleColorPair chosenColors =
        colorOptions[_random.nextInt(colorOptions.length)];

    final Obstacle obstacle = Obstacle(
      shapeType: pickedShape,
      size: obstacleSize,
      position: Vector2(game.size.x + obstacleSize.x, groundY),
      fillColor: chosenColors.fill,
      shadowColor: chosenColors.shadow,
    );

    game.world.add(obstacle);
  }
}
