import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/foundation.dart';

import 'components/background_sky.dart';
import 'components/obstacle.dart';
import 'components/obstacle_spawner.dart';
import 'components/player_dino.dart';
import 'components/scrolling_ground.dart';

/// Ba trạng thái có thể có của một lượt chơi.
enum GameRunState { waitingToStart, playing, gameOver }

/// Lớp game chính, kế thừa từ [FlameGame] của Flame Engine.
///
/// Đây là bộ não điều khiển toàn bộ trò chơi: tạo ra nhân vật, mặt đất,
/// nền trời, bộ sinh chướng ngại vật, đồng thời quản lý tốc độ, điểm số
/// và trạng thái thắng/thua.
class DinoRunnerGame extends FlameGame with HasCollisionDetection, TapCallbacks {
  /// Tốc độ cuộn màn hình khi vừa bắt đầu, tính theo pixel mỗi giây.
  static const double initialSpeed = 320;

  /// Tốc độ cuộn màn hình tối đa, trò chơi sẽ không nhanh hơn mức này.
  static const double maxSpeed = 760;

  /// Mức tăng tốc mỗi giây khi đang chơi.
  static const double speedRampPerSecond = 9;

  /// Chiều cao phần mặt đất tính từ đáy màn hình.
  static const double groundHeightFromBottom = 78;

  /// Điểm số hiện tại, các widget Flutter bên ngoài sẽ lắng nghe giá trị này
  /// để cập nhật giao diện theo thời gian thực.
  final ValueNotifier<int> currentScoreNotifier = ValueNotifier<int>(0);

  /// Điểm cao nhất từng đạt được, được nạp sẵn từ bộ nhớ cục bộ khi khởi tạo.
  final ValueNotifier<int> highScoreNotifier = ValueNotifier<int>(0);

  /// Trạng thái hiện tại của lượt chơi.
  final ValueNotifier<GameRunState> stateNotifier =
      ValueNotifier<GameRunState>(GameRunState.waitingToStart);

  /// Hàm callback được gọi đúng một lần ngay khi người chơi va vào
  /// chướng ngại vật, mang theo điểm số cuối cùng của lượt chơi đó.
  final void Function(int finalScore) onGameOver;

  /// Tốc độ cuộn màn hình ở thời điểm hiện tại, tăng dần theo thời gian chơi.
  double currentSpeed = initialSpeed;

  double _distanceScoreAccumulator = 0;
  late double groundY;
  late PlayerDino _player;
  late ScrollingGround _ground;

  DinoRunnerGame({
    required this.onGameOver,
    required int initialHighScore,
  }) {
    highScoreNotifier.value = initialHighScore;
  }

  /// Cho biết trò chơi có đang trong trạng thái chơi (chưa thua) hay không.
  bool get isPlaying => stateNotifier.value == GameRunState.playing;

  @override
  Future<void> onLoad() async {
    super.onLoad();

    // Đặt gốc tọa độ (0, 0) ở góc trên-trái màn hình để dễ tính toán vị trí.
    camera.viewfinder.anchor = Anchor.topLeft;

    groundY = size.y - groundHeightFromBottom;

    final BackgroundSky sky = BackgroundSky(size: size.clone());
    await world.add(sky);

    _ground = ScrollingGround(
      size: Vector2(size.x, groundHeightFromBottom),
      position: Vector2(0, groundY),
    );
    await world.add(_ground);

    _player = PlayerDino();
    _player.position = Vector2(size.x * 0.16, groundY);
    _player.placeOnGround(groundY);
    await world.add(_player);

    final ObstacleSpawner spawner = ObstacleSpawner(groundY: groundY);
    await world.add(spawner);
  }

  /// Bắt đầu (hoặc khởi động lại) một lượt chơi mới từ đầu.
  void startGame() {
    if (stateNotifier.value == GameRunState.playing) {
      return;
    }

    currentSpeed = initialSpeed;
    currentScoreNotifier.value = 0;
    _distanceScoreAccumulator = 0;

    final List<Obstacle> existingObstacles =
        world.children.whereType<Obstacle>().toList();
    for (final Obstacle obstacle in existingObstacles) {
      obstacle.removeFromParent();
    }

    _player.resetToGround();
    stateNotifier.value = GameRunState.playing;
  }

  /// Xử lý hành động chạm màn hình của người chơi, tùy theo trạng thái hiện
  /// tại mà sẽ bắt đầu trò chơi hoặc cho khủng long nhảy lên.
  void registerJumpInput() {
    switch (stateNotifier.value) {
      case GameRunState.waitingToStart:
        startGame();
        break;
      case GameRunState.playing:
        _player.jump();
        break;
      case GameRunState.gameOver:
        break;
    }
  }

  /// Được gọi khi khủng long va vào chướng ngại vật. Dừng trò chơi lại và
  /// báo điểm số cuối cùng ra ngoài thông qua [onGameOver].
  void triggerGameOver() {
    if (stateNotifier.value != GameRunState.playing) {
      return;
    }
    final int finalScore = currentScoreNotifier.value;
    stateNotifier.value = GameRunState.gameOver;
    onGameOver(finalScore);
  }

  @override
  void onTapDown(TapDownEvent event) {
    super.onTapDown(event);
    registerJumpInput();
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (!isPlaying) {
      return;
    }

    if (currentSpeed < maxSpeed) {
      currentSpeed += speedRampPerSecond * dt;
      if (currentSpeed > maxSpeed) {
        currentSpeed = maxSpeed;
      }
    }

    _ground.scroll(currentSpeed * dt);

    _distanceScoreAccumulator += currentSpeed * dt * 0.04;
    final int newScore = _distanceScoreAccumulator.floor();
    if (newScore != currentScoreNotifier.value) {
      currentScoreNotifier.value = newScore;
    }
  }
}
