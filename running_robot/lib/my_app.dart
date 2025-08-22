// lib/my_app.dart
import 'package:flutter/material.dart';
import 'package:animations/animations.dart'; // ADDED: transition widgets

// Flame used only for game pages
import 'package:flame/game.dart';

// Typed routes
import 'package:running_robot/core/app_router.dart';

// Pure Flutter page (no Flame)
import 'package:running_robot/z_pages/main_menu.dart';

// Game scenes
import 'package:running_robot/z_pages/lessons/lesson_one.dart';
import 'package:running_robot/ui/end_lesson.dart';

class MyApp extends StatefulWidget {
  const MyApp({super.key});
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // CHANGED: start on Main Menu (pure Flutter). Switch to RouteLesson1() if you prefer.
  AppRoute _route = const RouteMainMenu();

  // Keeps transitions smooth and forces clean remounts for GameWidget pages
  int _sceneKey = 0;

  /// Single navigation API your children receive and call.
  void navigate(AppRoute route) {
    setState(() {
      _route = route;
      _sceneKey++; // ADDED: guarantees GameWidget remount & transition
    });
  }

  /// Unified page factory: returns either a pure Flutter page or a Scaffold+GameWidget.
  Widget _buildPage(AppRoute route) {
    // Prefer a simple if-chain to avoid pattern-matching surprises across Dart versions.
    if (route is RouteMainMenu) {
      // PURE FLUTTER PAGE (no Flame)
      return const MainMenuPage(); // should render a white Scaffold, empty body
    }

    if (route is RouteLesson1) {
      // GAME PAGE
      return Scaffold(
        backgroundColor: Colors.white,
        body: GameWidget(
          key: ValueKey('lesson1_$_sceneKey'), // forces clean remount
          game: LessonOne(onNavigate: navigate),
        ),
      );
    }

    if (route is RouteLesson2) {
      // TODO: swap to your real LessonTwo when ready
      return Scaffold(
        backgroundColor: Colors.white,
        body: GameWidget(
          key: ValueKey('lesson2_$_sceneKey'),
          game: LessonOne(onNavigate: navigate),
        ),
      );
    }

    if (route is RouteEndLesson) {
      // GAME PAGE (end screen)
      return Scaffold(
        backgroundColor: Colors.white,
        body: GameWidget(
          key: ValueKey('endlesson_$_sceneKey'),
          game: EndLessonPage(
            onRepeat: () => navigate(const RouteLesson1()),
            onNext: () => navigate(const RouteLesson2()),
            onMainMenu: () => navigate(const RouteMainMenu()),
            xp: route.xp,
            streak: route.streak,
            progressPercent: route.progressPercent,
            stageProgress: route.stageProgress,
            topText: route.topText,
            illustrationPath: route.illustrationPath,
          ),
        ),
      );
    }

    // Fallback
    return const MainMenuPage();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: PageTransitionSwitcher(
        // CHANGED: tweak duration to taste (you used 1500ms earlier)
        duration: const Duration(milliseconds: 600),
        transitionBuilder: (child, a, sa) => FadeThroughTransition(
          animation: a,
          secondaryAnimation: sa,
          child: child,
        ),
        // Each page (Flutter or Game) owns its own Scaffold/background
        child: KeyedSubtree(
          key: ValueKey(_sceneKey), // CHANGED: ties transition to scene changes
          child: _buildPage(_route),
        ),
      ),
    );
  }
}
