// lib/my_app.dart
import 'package:flutter/material.dart';
import 'package:flame/game.dart';

// Your LessonOne must accept: LessonOne({required AppRouter onNavigate, AppEvent completeEvent = AppEvent.lessonComplete})
import 'package:running_robot/lessons/lesson_one.dart';

enum AppEvent { lessonComplete, repeatLesson, nextLesson, mainMenu }

typedef AppRouter = void Function(AppEvent event, {Object? payload});

enum AppPage { lesson1 /*, endLesson, lesson2, mainMenu */ }

class MyApp extends StatefulWidget {
  const MyApp({super.key});
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  AppPage _currentPage = AppPage.lesson1;
  late FlameGame _game;
  int _sceneKey = 0; // if/when you swap scenes, bump this to remount

  @override
  void initState() {
    super.initState();
    _game = _buildLessonOne(); // load LessonOne immediately
  }

  // ---- FACTORY: current lesson
  FlameGame _buildLessonOne() => LessonOne(
    onNavigate: _navigate, // <-- the "navigate thingy"
    completeEvent: AppEvent.lessonComplete,
  );

  // ---- CENTRAL ROUTER (dummy for now)
  void _navigate(AppEvent event, {Object? payload}) {
    // This is what all pages/games call to lift state up.
    // Wire real scene swaps later.
    debugPrint('[NAV] event=$event payload=$payload');

    // Example of future handling (leave commented until you add pages):
    // switch (event) {
    //   case AppEvent.lessonComplete:
    //     setState(() {
    //       _currentPage = AppPage.endLesson;
    //       _game = EndLessonPage(onRepeat: () => _navigate(AppEvent.repeatLesson),
    //                             onNext:   () => _navigate(AppEvent.nextLesson),
    //                             onMainMenu: () => _navigate(AppEvent.mainMenu));
    //       _sceneKey++;
    //     });
    //     break;
    //   case AppEvent.repeatLesson:
    //     setState(() { _currentPage = AppPage.lesson1; _game = _buildLessonOne(); _sceneKey++; });
    //     break;
    //   // add others when ready
    // }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: GameWidget(
          key: ValueKey(_sceneKey),
          game: _game,
        ),
      ),
    );
  }
}
