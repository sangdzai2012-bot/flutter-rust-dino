import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Bảng thông báo hiển thị khi người chơi thua cuộc.
///
/// Bao gồm: số điểm vừa đạt được, điểm cao nhất, nút chơi lại và danh sách
/// lịch sử ba trận chơi gần nhất, tất cả được trình bày theo phong cách
/// Material 3 với các góc bo tròn mềm mại.
class GameOverDialog extends StatelessWidget {
  final int latestScore;
  final int highScore;
  final bool isNewHighScore;
  final List<int> recentScores;
  final VoidCallback onRestart;

  const GameOverDialog({
    super.key,
    required this.latestScore,
    required this.highScore,
    required this.isNewHighScore,
    required this.recentScores,
    required this.onRestart,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(28, 32, 28, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Container(
              alignment: Alignment.center,
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: AppPalette.dinoBody.withOpacity(0.14),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.sports_score_rounded,
                color: AppPalette.dinoBody,
                size: 32,
              ),
            ),
            const SizedBox(height: 18),
            const Text(
              'Bạn Đã Thua!',
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 22),
            ),
            const SizedBox(height: 6),
            Text(
              isNewHighScore
                  ? 'Chúc mừng, bạn vừa lập kỷ lục mới!'
                  : 'Cố gắng lần sau nhé!',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
            ),
            const SizedBox(height: 20),
            Row(
              children: <Widget>[
                Expanded(
                  child: _StatBox(
                    title: 'ĐIỂM VỪA ĐẠT',
                    value: latestScore,
                    color: AppPalette.dinoBody,
                    highlighted: isNewHighScore,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _StatBox(
                    title: 'KỶ LỤC',
                    value: highScore,
                    color: AppPalette.tertiaryAccentDark,
                    highlighted: false,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'LỊCH SỬ 3 TRẬN GẦN NHẤT',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: Colors.grey.shade500,
                  letterSpacing: 0.6,
                ),
              ),
            ),
            const SizedBox(height: 8),
            ..._buildRecentScoresList(),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: onRestart,
                style: FilledButton.styleFrom(
                  backgroundColor: AppPalette.dinoBody,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                  textStyle: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Icon(Icons.refresh_rounded),
                    SizedBox(width: 8),
                    Text('CHƠI LẠI'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildRecentScoresList() {
    if (recentScores.isEmpty) {
      return <Widget>[
        Text(
          'Chưa có lịch sử nào trước đó.',
          style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
        ),
      ];
    }

    return List<Widget>.generate(recentScores.length, (int index) {
      final int score = recentScores[index];
      return Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFFF4F1EC),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: <Widget>[
            Container(
              width: 26,
              height: 26,
              alignment: Alignment.center,
              decoration: const BoxDecoration(
                color: AppPalette.dinoBody,
                shape: BoxShape.circle,
              ),
              child: Text(
                '${index + 1}',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              index == 0 ? 'Lần vừa chơi' : 'Trận trước đó',
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
            ),
            const Spacer(),
            Text(
              score.toString(),
              style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
            ),
          ],
        ),
      );
    });
  }
}

class _StatBox extends StatelessWidget {
  final String title;
  final int value;
  final Color color;
  final bool highlighted;

  const _StatBox({
    required this.title,
    required this.value,
    required this.color,
    required this.highlighted,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.10),
        borderRadius: BorderRadius.circular(20),
        border: highlighted ? Border.all(color: color, width: 1.6) : null,
      ),
      child: Column(
        children: <Widget>[
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: color,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value.toString(),
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
