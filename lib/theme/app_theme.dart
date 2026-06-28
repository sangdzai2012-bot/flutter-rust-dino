import 'package:flutter/material.dart';

/// Bảng màu "Expressive" dùng riêng cho toàn bộ game.
/// Tất cả các thành phần vẽ tay trong Flame (khủng long, chướng ngại vật,
/// nền trời, mặt đất...) và toàn bộ giao diện Flutter (điểm số, dialog...)
/// đều lấy màu từ đúng một nơi duy nhất này để đảm bảo đồng bộ.
class AppPalette {
  AppPalette._();

  // Nền và bầu trời
  static const Color background = Color(0xFFFFF6EE);
  static const Color skyTop = Color(0xFFFFE3CB);
  static const Color skyBottom = Color(0xFFFFF6EE);
  static const Color cloudColor = Color(0xFFFFFFFF);

  // Mặt đất
  static const Color groundLine = Color(0xFF3C2A21);

  // Khủng long (nhân vật chính)
  static const Color dinoBody = Color(0xFFFF6F3C);
  static const Color dinoBodyDark = Color(0xFFE0552A);
  static const Color dinoEye = Color(0xFF241405);

  // Chướng ngại vật - xanh ngọc
  static const Color cactusJade = Color(0xFF1FAA59);
  static const Color cactusJadeDark = Color(0xFF137A40);

  // Chướng ngại vật - vàng nắng
  static const Color tertiaryAccent = Color(0xFFFFC857);
  static const Color tertiaryAccentDark = Color(0xFFE3A220);

  // Màu gốc dùng để sinh ColorScheme Material 3
  static const Color seed = Color(0xFFFF6F3C);
}

/// Tạo ThemeData chuẩn Material 3 cho toàn bộ ứng dụng.
ThemeData buildAppTheme() {
  final ColorScheme colorScheme = ColorScheme.fromSeed(
    seedColor: AppPalette.seed,
    brightness: Brightness.light,
  ).copyWith(
    secondary: AppPalette.cactusJade,
    tertiary: AppPalette.tertiaryAccent,
  );

  return ThemeData(
    useMaterial3: true,
    colorScheme: colorScheme,
    scaffoldBackgroundColor: AppPalette.background,
    textTheme: const TextTheme(
      headlineSmall: TextStyle(fontWeight: FontWeight.w800),
      titleMedium: TextStyle(fontWeight: FontWeight.w700),
      bodyMedium: TextStyle(fontWeight: FontWeight.w500),
    ),
  );
}
