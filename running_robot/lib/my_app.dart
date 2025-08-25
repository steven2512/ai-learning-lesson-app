// lib/my_app.dart
import 'package:flutter/material.dart';
import 'package:animations/animations.dart'; // transitions for route-level changes

// Flame used only for game pages
import 'package:flame/game.dart';

// Typed routes
import 'package:running_robot/core/app_router.dart';
import 'package:running_robot/z_pages/end_lesson.dart';

// Game scenes
import 'package:running_robot/z_pages/lessons/lesson_one.dart';
import 'package:running_robot/z_pages/root_nav.dart';

class MyApp extends StatefulWidget {
  const MyApp({super.key});
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // Start on Main Menu (now the tabs shell)
  AppRoute _route = const RouteMainMenu(); // optionally: RouteMainMenu(tab: 0)

  // Keeps transitions smooth and forces clean remounts for GameWidget pages
  int _sceneKey = 0;

  /// Single navigation API your children receive and call.
  void navigate(AppRoute route) {
    setState(() {
      _route = route;
      _sceneKey++; // guarantees GameWidget remount & transition
    });
  }

  /// Unified page factory: returns either the tabs shell or a Scaffold+GameWidget.
  Widget _buildPage(AppRoute route) {
    // TAB SHELL (Home/Lessons/Stats/Settings) — no route changes for tab taps
    if (route is RouteMainMenu) {
      return RootNavScaffold(
        onNavigate: navigate,
        initialIndex: route.tab, // 0=Home, 1=Lessons, 2=Stats, 3=Settings
      );
    }

    // LESSON 1 — Flame game page
    if (route is RouteLesson1) {
      return Scaffold(
        backgroundColor: Colors.white,
        body: GameWidget(
          key: ValueKey('lesson1_$_sceneKey'), // forces clean remount
          game: LessonOne(onNavigate: navigate),
        ),
      );
    }

    // LESSON 2 — TODO: replace with real LessonTwo when ready
    if (route is RouteLesson2) {
      return Scaffold(
        backgroundColor: Colors.white,
        body: GameWidget(
          key: ValueKey('lesson2_$_sceneKey'),
          game: LessonOne(onNavigate: navigate),
        ),
      );
    }

    // END LESSON — Flame “end screen” scene
    if (route is RouteEndLesson) {
      return Scaffold(
        backgroundColor: Colors.white,
        body: GameWidget(
          key: ValueKey('endlesson_$_sceneKey'),
          game: EndLessonPage(
            onRepeat: () => navigate(const RouteLesson1()),
            onNext: () => navigate(const RouteLesson2()),
            onMainMenu: () => navigate(const RouteMainMenu(tab: 0)),
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

    // Fallback: go to the tabs shell (Home)
    return RootNavScaffold(
      onNavigate: navigate,
      initialIndex: 0,
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: PageTransitionSwitcher(
        duration: const Duration(milliseconds: 600),
        transitionBuilder: (child, a, sa) => FadeThroughTransition(
          animation: a,
          secondaryAnimation: sa,
          child: child,
        ),
        // Each top-level page (Tabs shell or Game) owns its own Scaffold/background
        child: KeyedSubtree(
          key: ValueKey(_sceneKey), // ties the switcher to route/scene changes
          child: _buildPage(_route),
        ),
      ),
    );
  }
}
