// lib/core/app_router.dart
enum AppEvent { lessonComplete, repeatLesson, nextLesson, mainMenu }

typedef AppRouter = void Function(AppEvent event, {Object? payload});
