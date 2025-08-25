// lib/core/app_router.dart

/// All navigable pages as strongly-typed routes (no Map<String, dynamic>).
abstract class AppRoute {
  const AppRoute();
}

class RouteLesson1 extends AppRoute {
  const RouteLesson1();
}

class RouteEndLesson extends AppRoute {
  final int xp;
  final int streak;
  final int progressPercent; // 0..100
  final List<int> stageProgress; // e.g. [1, 0, 0] => 3 stages, first filled
  final String topText;
  final String? illustrationPath; // pass just an asset path

  const RouteEndLesson({
    required this.xp,
    required this.streak,
    required this.progressPercent,
    required this.stageProgress,
    required this.topText,
    this.illustrationPath,
  });
}

class RouteLesson2 extends AppRoute {
  const RouteLesson2();
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
