import 'package:flutter/material.dart';
import 'package:animations/animations.dart'; // transitions for route-level changes

// Flame used only for game pages
import 'package:flame/game.dart';

// Typed routes
import 'package:running_robot/core/app_router.dart';
import 'package:running_robot/z_pages/end_lesson.dart';
import 'package:running_robot/z_pages/lessons/lessonOne/lesson1.dart';

// Game scenes
import 'package:running_robot/z_pages/root_nav.dart';

class MyApp extends StatefulWidget {
  const MyApp({super.key});
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  AppRoute _route = const RouteMainMenu();
  int _sceneKey = 0;

  void navigate(AppRoute route) {
    setState(() {
      _route = route;
      _sceneKey++;
    });
  }

  Widget _buildPage(AppRoute route) {
    if (route is RouteMainMenu) {
      return RootNavScaffold(
        onNavigate: navigate,
        initialIndex: route.tab,
      );
    }

    // LESSON 1 — Flutter lesson page
    if (route is RouteLesson1) {
      return LessonOne(onNavigate: navigate); // ✅ pass navigate
    }

    // END LESSON — uses the new API (final progressBar + chapter progress)
    if (route is RouteEndLesson) {
      return Scaffold(
        backgroundColor: Colors.white,
        body: GameWidget(
          key: ValueKey('endlesson_$_sceneKey'),
          game: EndLessonPage(
            onRepeat: () => navigate(const RouteLesson1()),
            onNext: () => navigate(const RouteMainMenu(tab: 0)),
            onMainMenu: () => navigate(const RouteMainMenu(tab: 0)),
            xp: route.xp,
            streak: route.streak,
            progressBar: route.progressBar, // 🔹 final prebuilt bar
            chapterProgress: route.chapterProgress, // 🔹 X
            totalChapterLessons: route.totalChapterLessons, // 🔹 Y
            topText: route.topText,
            illustrationPath: route.illustrationPath,
          ),
        ),
      );
    }

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
        child: KeyedSubtree(
          key: ValueKey(_sceneKey),
          child: _buildPage(_route),
        ),
      ),
    );
  }
}
