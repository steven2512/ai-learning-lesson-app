// lib/core/lesson_steps.dart
final Map<String, int> _steps = {};

class LessonStepRegistry {
  static void register(String id, int steps) {
    _steps[id] = steps;
  }

  static int stepsFor(String id) => _steps[id] ?? 1;
}
