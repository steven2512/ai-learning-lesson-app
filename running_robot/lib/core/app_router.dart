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
  final List<int>
  stageProgress; // e.g. [1.0, 0.0, 0.0] => 3 stages, first filled
  final String topText;
  final String? illustrationPath; // <- pass just an asset path

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

class RouteMainMenu extends AppRoute {
  const RouteMainMenu();
}

/// Single navigation function children will receive and call.
typedef AppNavigate = void Function(AppRoute route);
