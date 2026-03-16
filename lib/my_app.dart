// FILE: lib/my_app.dart
import 'package:flutter/material.dart';
import 'package:animations/animations.dart';
import 'package:flame/game.dart';

// Typed routes
import 'package:running_robot/core/app_router.dart';
import 'package:running_robot/core/lesson_manifest.dart';
import 'package:running_robot/core/widgets.dart';
import 'package:running_robot/z_pages/end_lesson.dart';
import 'package:running_robot/z_pages/root_nav.dart';

// ✅ NEW: import your ScreenSize utility
class MyApp extends StatefulWidget {
  const MyApp({super.key});
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  AppRoute _route = const RouteMainMenu();
  int _sceneKey = 0;

  // 🔹 Flatten chapter → lessons once for easy lookup
  List<LessonMeta> get _allLessons =>
      chapterManifest.expand((c) => c.lessons).toList();

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

    if (route is RouteLesson) {
      // 🔹 Use flattened list, not lessonManifest
      final lesson = _allLessons[route.lessonNumber - 1];
      return lesson.builder(navigate);
    }

    if (route is RouteEndLesson) {
      return Scaffold(
        backgroundColor: Colors.white,
        body: GameWidget(
          key: ValueKey('endlesson_$_sceneKey'),
          game: EndLessonPage(
            onRepeat: () => navigate(route.repeatLesson),
            onNext: () {
              if (route.nextLesson != null) {
                navigate(route.nextLesson!);
              } else {
                navigate(const RouteMainMenu(tab: 0));
              }
            },
            onMainMenu: () => navigate(const RouteMainMenu(tab: 0)),
            xp: route.xp,
            streak: route.streak,
            progressBar: route.progressBar,
            chapterProgress: route.chapterProgress,
            totalChapterLessons: route.totalChapterLessons,
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
    // ✅ Initialize ScreenSize once at root
    ScreenSize.init(context);

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
