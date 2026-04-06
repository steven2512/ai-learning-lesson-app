// lib/core/lesson_navigator.dart
import 'package:running_robot/core/app_router.dart';
import 'package:running_robot/core/lesson_manifest.dart';
import 'package:running_robot/core/lesson_steps.dart';
import 'package:running_robot/game/decorations/progress_bar.dart';
import 'package:flame/components.dart' show Vector2;
import 'package:running_robot/game/events/event_type.dart'
    show EventProgressBar;
import 'package:running_robot/services/app_progression_controller.dart';
import 'package:running_robot/services/lesson_service.dart';

class LessonNavigator {
  /// Flatten all chapters into a single ordered list of lessons
  static List<LessonMeta> get _allLessons =>
      chapterManifest.expand((c) => c.lessons).toList();

  static void complete(
    String lessonId,
    AppNavigate onNavigate, {
    required AppProgressionController progression,
    required LessonCompletionResult completion,
  }) {
    final idx = _allLessons.indexWhere((m) => m.id == lessonId);
    if (idx < 0) return;

    // 🔹 Ask brain how many steps it had
    final steps = LessonStepRegistry.stepsFor(lessonId);

    final endBar = LessonProgressBar(position: Vector2.zero(), stages: steps);
    for (var i = 0; i < steps; i++) {
      endBar.switchPhase(EventProgressBar.proceed);
    }

    final AppRoute? next;
    final String nextButtonText;
    if (completion.firstCompletion) {
      next = (idx + 1 < _allLessons.length) ? RouteLesson(idx + 2) : null;
      nextButtonText = next == null ? 'Back to Home' : 'Next Lesson';
    } else {
      final currentLessonNumber = progression.currentLessonNumber;
      next =
          currentLessonNumber > 0 && currentLessonNumber <= _allLessons.length
              ? RouteLesson(currentLessonNumber)
              : const RouteMainMenu(tab: 0);
      nextButtonText = 'Continue Journey';
    }
    final profile = progression.profile;
    final totalXp = profile?.xp ?? 0;
    final streak = profile?.dailyStreak ?? completion.dailyStreak;
    final chapterProgress = (profile?.lessonsCompleted ?? idx + 1).clamp(
      0,
      _allLessons.length,
    );

    onNavigate(
      RouteEndLesson(
        xp: totalXp,
        streak: streak,
        progressBar: endBar,
        chapterProgress: chapterProgress,
        totalChapterLessons: _allLessons.length,
        topText: completion.firstCompletion
            ? "Lesson ${idx + 1} completed!"
            : "Lesson ${idx + 1} reviewed!",
        nextButtonText: nextButtonText,
        repeatLesson: RouteLesson(idx + 1),
        nextLesson: next,
      ),
    );
  }
}
