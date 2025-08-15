// lib/pages/end_lesson_page.dart
import 'package:flame/game.dart';

// Avoid Flutter deps: define our own VoidCallback
typedef VoidCallback = void Function();

/// Blank end-of-lesson scene. No UI, just callbacks.
class EndLessonPage extends FlameGame {
  final VoidCallback onRepeat; // repeat current/previous lesson
  final VoidCallback onNext; // go to next lesson
  final VoidCallback onMainMenu; // go to main menu

  EndLessonPage({
    required this.onRepeat,
    required this.onNext,
    required this.onMainMenu,
  });

  // Optional: expose simple triggers MyApp can call.
  void repeatLesson() => onRepeat();
  void nextLesson() => onNext();
  void goToMainMenu() => onMainMenu();

  // No components, no rendering overrides — it's intentionally blank.
}
