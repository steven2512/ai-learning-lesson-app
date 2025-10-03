// lib/core/lesson_navigator.dart
import 'package:running_robot/core/app_router.dart';
import 'package:running_robot/core/lesson_manifest.dart';
import 'package:running_robot/core/lesson_steps.dart';
import 'package:running_robot/game/decorations/progress_bar.dart';
import 'package:flame/components.dart' show Vector2;
import 'package:running_robot/game/events/event_type.dart'
    show EventProgressBar;

class LessonNavigator {
  /// Flatten all chapters into a single ordered list of lessons
  static List<LessonMeta> get _allLessons =>
      chapterManifest.expand((c) => c.lessons).toList();

  static void complete(String lessonId, AppNavigate onNavigate) {
    final idx = _allLessons.indexWhere((m) => m.id == lessonId);
    if (idx < 0) return;

    // 🔹 Ask brain how many steps it had
    final steps = LessonStepRegistry.stepsFor(lessonId);

    final endBar = LessonProgressBar(position: Vector2.zero(), stages: steps);
    for (var i = 0; i < steps; i++) {
      endBar.switchPhase(EventProgressBar.proceed);
    }

    final next = (idx + 1 < _allLessons.length) ? RouteLesson(idx + 2) : null;

    onNavigate(
      RouteEndLesson(
        xp: 50,
        streak: 1,
        progressBar: endBar,
        chapterProgress: idx + 1,
        totalChapterLessons: _allLessons.length,
        topText: "Lesson ${idx + 1} completed!",
        repeatLesson: RouteLesson(idx + 1),
        nextLesson: next,
      ),
    );
  }
}
