/// All navigable pages as strongly-typed routes (no Map<String, dynamic>).

import 'package:running_robot/game/decorations/progress_bar.dart';

abstract class AppRoute {
  const AppRoute();
}

/// ---------------- LESSON ROUTES ----------------
class RouteLesson1 extends AppRoute {
  const RouteLesson1();
}

class RouteLesson2 extends AppRoute {
  const RouteLesson2();
}

/// ---------------- END LESSON ROUTE ----------------
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

  /// 🔹 Where to go if the user taps "Repeat".
  final AppRoute repeatLesson;

  /// 🔹 Where to go if the user taps "Next Lesson" (nullable if last lesson).
  final AppRoute? nextLesson;

  const RouteEndLesson({
    required this.xp,
    required this.streak,
    required this.progressBar,
    required this.chapterProgress,
    required this.totalChapterLessons,
    required this.topText,
    required this.repeatLesson,
    this.nextLesson,
    this.illustrationPath,
  });
}

/// ---------------- MAIN MENU & UTILS ----------------
class RouteMainMenu extends AppRoute {
  final int tab;
  const RouteMainMenu({this.tab = 0});
}

class RoutePause extends AppRoute {
  const RoutePause();
}

/// Single navigation function children will receive and call.
typedef AppNavigate = void Function(AppRoute route);
