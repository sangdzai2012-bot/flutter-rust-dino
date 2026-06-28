import 'package:shared_preferences/shared_preferences.dart';

/// Kết quả trả về sau khi lưu một lượt chơi vừa kết thúc.
class GameResultRecord {
  final int highScore;
  final bool isNewHighScore;
  final List<int> recentScores;

  const GameResultRecord({
    required this.highScore,
    required this.isNewHighScore,
    required this.recentScores,
  });
}

/// Lớp dịch vụ chịu trách nhiệm đọc và ghi dữ liệu cục bộ của game
/// (điểm cao nhất và lịch sử các trận chơi gần nhất) bằng shared_preferences.
class ScoreStorageService {
  static const String _highScoreKey = 'dino_jump_high_score';
  static const String _recentScoresKey = 'dino_jump_recent_scores';
  static const int maxRecentScores = 3;

  /// Đọc điểm cao nhất đã được lưu trước đó. Nếu chưa từng chơi, trả về 0.
  Future<int> loadHighScore() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_highScoreKey) ?? 0;
  }

  /// Đọc danh sách điểm của các trận chơi gần nhất, trận mới nhất đứng đầu.
  Future<List<int>> loadRecentScores() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final List<String>? rawList = prefs.getStringList(_recentScoresKey);
    if (rawList == null) {
      return <int>[];
    }
    return rawList.map((String value) => int.tryParse(value) ?? 0).toList();
  }

  /// Lưu lại kết quả của một lượt chơi vừa kết thúc.
  ///
  /// Phương thức này sẽ tự động:
  /// 1. So sánh điểm vừa đạt được với điểm cao nhất hiện tại và cập nhật
  ///    điểm cao nhất nếu cần.
  /// 2. Thêm điểm vừa đạt được vào đầu danh sách lịch sử và chỉ giữ lại
  ///    tối đa [maxRecentScores] trận gần nhất.
  Future<GameResultRecord> saveGameResult(int latestScore) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    final int currentHighScore = prefs.getInt(_highScoreKey) ?? 0;
    final bool isNewHighScore = latestScore > currentHighScore;
    final int updatedHighScore = isNewHighScore ? latestScore : currentHighScore;
    await prefs.setInt(_highScoreKey, updatedHighScore);

    final List<String> existingRaw =
        prefs.getStringList(_recentScoresKey) ?? <String>[];
    final List<int> existingScores =
        existingRaw.map((String value) => int.tryParse(value) ?? 0).toList();

    final List<int> updatedScores = <int>[latestScore, ...existingScores];
    final List<int> trimmedScores = updatedScores.take(maxRecentScores).toList();

    await prefs.setStringList(
      _recentScoresKey,
      trimmedScores.map((int value) => value.toString()).toList(),
    );

    return GameResultRecord(
      highScore: updatedHighScore,
      isNewHighScore: isNewHighScore,
      recentScores: trimmedScores,
    );
  }
}
