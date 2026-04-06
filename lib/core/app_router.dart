// FILE: lib/core/app_router.dart
import 'package:running_robot/game/decorations/progress_bar.dart';

abstract class AppRoute {
  const AppRoute();
}

/// ---------------- LESSON ROUTES ----------------
/// 🔹 Generic lesson route instead of many classes
class RouteLesson extends AppRoute {
  final int lessonNumber;
  const RouteLesson(this.lessonNumber);
}

/// ---------------- END LESSON ROUTE ----------------
class RouteEndLesson extends AppRoute {
  final int xp;
  final int streak;
  final LessonProgressBar progressBar;
  final int chapterProgress;
  final int totalChapterLessons;
  final String topText;
  final String nextButtonText;
  final String? illustrationPath;
  final AppRoute repeatLesson;
  final AppRoute? nextLesson;

  const RouteEndLesson({
    required this.xp,
    required this.streak,
    required this.progressBar,
    required this.chapterProgress,
    required this.totalChapterLessons,
    required this.topText,
    required this.nextButtonText,
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

// class RoutePause extends AppRoute {
//   const RoutePause();
// }

/// Single navigation function children will receive and call.
typedef AppNavigate = void Function(AppRoute route);
