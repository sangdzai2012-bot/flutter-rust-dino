import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'theme/app_theme.dart';
import 'ui/game_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Game này được thiết kế để chơi theo chiều dọc (portrait).
  SystemChrome.setPreferredOrientations(<DeviceOrientation>[
    DeviceOrientation.portraitUp,
  ]);

  runApp(const DinoJumpApp());
}

/// Widget gốc của toàn bộ ứng dụng.
class DinoJumpApp extends StatelessWidget {
  const DinoJumpApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dino Jump',
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(),
      home: const GameScreen(),
    );
  }
}
