/// All navigable pages as strongly-typed routes (no Map<String, dynamic>).

import 'package:running_robot/game/decorations/progress_bar.dart';

abstract class AppRoute {
  const AppRoute();
}

class RouteLesson1 extends AppRoute {
  const RouteLesson1();
}

class RouteEndLesson extends AppRoute {
  final int xp;
  final int streak;

  /// 🔹 The final, already-filled bar to display on the end screen.
  final LessonProgressBar progressBar;

  /// 🔹 Chapter aggregate progress (e.g., lessons completed in chapter).
  final int chapterProgress;

  /// 🔹 Total lessons in the chapter.
  final int totalChapterLessons;

  final String topText;
  final String? illustrationPath; // asset path (optional)

  const RouteEndLesson({
    required this.xp,
    required this.streak,
    required this.progressBar,
    required this.chapterProgress,
    required this.totalChapterLessons,
    required this.topText,
    this.illustrationPath,
  });
}

/// Entry to the tab shell (Home/Lessons/Stats/Settings).
/// Tabs themselves are switched internally (no new routes),
/// but this lets you jump straight to a specific tab from outside the shell.
/// 0 = Home, 1 = Lessons, 2 = Stats, 3 = Settings
class RouteMainMenu extends AppRoute {
  final int tab;
  const RouteMainMenu({this.tab = 0});
}

class RoutePause extends AppRoute {
  const RoutePause();
}

/// Single navigation function children will receive and call.
typedef AppNavigate = void Function(AppRoute route);
