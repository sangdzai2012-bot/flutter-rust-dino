import 'package:flame/game.dart';
import 'package:flutter/material.dart';

import '../game/dino_runner_game.dart';
import '../services/score_storage_service.dart';
import '../theme/app_theme.dart';
import 'game_over_dialog.dart';
import 'score_badge.dart';

/// Màn hình chơi game chính của ứng dụng.
///
/// Đây là một widget Flutter thông thường, bên trong chứa [GameWidget] của
/// Flame (vẽ trực tiếp lên canvas, hiệu năng tối ưu, không qua WebView) và
/// các lớp giao diện Flutter native phía trên (điểm số, dialog kết thúc).
class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  final ScoreStorageService _storageService = ScoreStorageService();

  DinoRunnerGame? _game;
  bool _isLoadingInitialData = true;
  bool _isDialogShowing = false;

  @override
  void initState() {
    super.initState();
    _initializeGame();
  }

  Future<void> _initializeGame() async {
    final int savedHighScore = await _storageService.loadHighScore();

    if (!mounted) {
      return;
    }

    setState(() {
      _game = DinoRunnerGame(
        initialHighScore: savedHighScore,
        onGameOver: _handleGameOver,
      );
      _isLoadingInitialData = false;
    });
  }

  Future<void> _handleGameOver(int finalScore) async {
    final GameResultRecord result = await _storageService.saveGameResult(finalScore);

    if (!mounted) {
      return;
    }

    _game?.highScoreNotifier.value = result.highScore;

    setState(() {
      _isDialogShowing = true;
    });

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return GameOverDialog(
          latestScore: finalScore,
          highScore: result.highScore,
          isNewHighScore: result.isNewHighScore,
          recentScores: result.recentScores,
          onRestart: () {
            Navigator.of(dialogContext).pop();
          },
        );
      },
    );

    if (!mounted) {
      return;
    }

    setState(() {
      _isDialogShowing = false;
    });

    _game?.startGame();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoadingInitialData || _game == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final DinoRunnerGame game = _game!;

    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: <Widget>[
            Positioned.fill(
              child: GameWidget(game: game),
            ),
            Positioned(
              top: 16,
              left: 16,
              child: ValueListenableBuilder<int>(
                valueListenable: game.currentScoreNotifier,
                builder: (BuildContext context, int value, Widget? child) {
                  return ScoreBadge(
                    label: 'ĐIỂM',
                    value: value,
                    accentColor: AppPalette.dinoBody,
                    icon: Icons.directions_run_rounded,
                  );
                },
              ),
            ),
            Positioned(
              top: 16,
              right: 16,
              child: ValueListenableBuilder<int>(
                valueListenable: game.highScoreNotifier,
                builder: (BuildContext context, int value, Widget? child) {
                  return ScoreBadge(
                    label: 'KỶ LỤC',
                    value: value,
                    accentColor: AppPalette.tertiaryAccentDark,
                    icon: Icons.emoji_events_rounded,
                  );
                },
              ),
            ),
            ValueListenableBuilder<GameRunState>(
              valueListenable: game.stateNotifier,
              builder: (BuildContext context, GameRunState state, Widget? child) {
                if (state != GameRunState.waitingToStart || _isDialogShowing) {
                  return const SizedBox.shrink();
                }
                return _buildStartHint();
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStartHint() {
    return Positioned(
      left: 0,
      right: 0,
      bottom: 90,
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.55),
            borderRadius: BorderRadius.circular(24),
          ),
          child: const Text(
            'CHẠM MÀN HÌNH ĐỂ BẮT ĐẦU',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.8,
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }
}
