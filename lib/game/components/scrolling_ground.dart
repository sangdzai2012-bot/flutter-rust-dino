import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';

/// Mặt đất cuộn liên tục để tạo cảm giác khủng long đang chạy về phía trước.
/// Thành phần này không tự tính tốc độ, mà được điều khiển trực tiếp bởi
/// [DinoRunnerGame] thông qua phương thức [scroll].
class ScrollingGround extends PositionComponent {
  static const double _dashWidth = 26;
  static const double _dashGap = 18;
  static const double _lineThickness = 6;

  double _scrollOffset = 0;

  ScrollingGround({required Vector2 size, required Vector2 position})
      : super(size: size, position: position, anchor: Anchor.topLeft);

  /// Di chuyển các đường gạch trang trí trên mặt đất sang trái theo [distance]
  /// pixel đã đi được trong khung hình hiện tại.
  void scroll(double distance) {
    _scrollOffset = (_scrollOffset + distance) % (_dashWidth + _dashGap);
  }

  @override
  void render(Canvas canvas) {
    final Paint groundLinePaint = Paint()..color = AppPalette.groundLine;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, size.x, _lineThickness),
        const Radius.circular(3),
      ),
      groundLinePaint,
    );

    final Paint dashPaint = Paint()
      ..color = AppPalette.groundLine.withOpacity(0.45);
    double startX = -_scrollOffset;
    while (startX < size.x) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(startX, _lineThickness + 10, _dashWidth, 4),
          const Radius.circular(2),
        ),
        dashPaint,
      );
      startX += _dashWidth + _dashGap;
    }
  }
}
