// lib/my_app.dart
import 'package:flutter/material.dart';
import 'package:flame/game.dart';
import 'package:running_robot/lessons/lesson_one.dart';
import 'package:running_robot/ui/end_lesson.dart';
import 'package:running_robot/core/app_router.dart';
// ADDED: global transition widgets
import 'package:animations/animations.dart'; // <-- ADDED

class MyApp extends StatefulWidget {
  const MyApp({super.key});
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  AppRoute _route = const RouteLesson1();
  late FlameGame _game;
  int _sceneKey = 0; // bump to remount GameWidget when scene changes

  @override
  void initState() {
    super.initState();
    _game = _buildScene(_route);
  }

  /// The only API children need: call navigate(RouteX(...))
  void navigate(AppRoute route) {
    setState(() {
      _route = route;
      _game = _buildScene(route);
      _sceneKey++; // <-- triggers transition
    });
  }

  /// Central scene factory — typed, tiny, no stringly-typed args.
  FlameGame _buildScene(AppRoute route) {
    if (route is RouteLesson1) {
      return LessonOne(onNavigate: navigate);
    } else if (route is RouteEndLesson) {
      return EndLessonPage(
        onRepeat: () => navigate(const RouteLesson1()),
        onNext: () => navigate(const RouteLesson2()),
        onMainMenu: () => navigate(const RouteMainMenu()),
        xp: route.xp,
        streak: route.streak,
        progressPercent: route.progressPercent,
        stageProgress: route.stageProgress,
        topText: route.topText,
        illustrationPath: route.illustrationPath,
      );
    } else if (route is RouteLesson2) {
      return LessonOne(onNavigate: navigate);
    } else if (route is RouteMainMenu) {
      return LessonOne(onNavigate: navigate);
    }
    return LessonOne(onNavigate: navigate);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        // CHANGED: one global transition wrapper
        body: PageTransitionSwitcher(
          // <-- ADDED
          duration: const Duration(milliseconds: 3000), // <-- ADDED
          transitionBuilder: (child, a, sa) => FadeThroughTransition(
            // <-- ADDED
            animation: a,
            secondaryAnimation: sa,
            child: child,
          ),
          child: KeyedSubtree(
            // <-- ADDED
            key: ValueKey(_sceneKey), // changes -> animate
            child: GameWidget(
              // key removed; KeyedSubtree handles it
              game: _game,
            ),
          ),
        ),
      ),
    );
  }
}
