/// FILE: lib/core/lesson_registry.dart
import 'package:running_robot/core/app_router.dart';
import 'package:running_robot/z_pages/lessons/lesson1/lesson1.dart';
import 'package:running_robot/z_pages/lessons/lesson2/lesson2.dart';
import 'package:running_robot/z_pages/lessons/lesson3/lesson3.dart';

import '../z_pages/lessons/lesson4/lesson4.dart';

typedef LessonBuilder = dynamic Function(AppNavigate onNavigate);

/// 🔹 Registry of all lessons.
///   Key = global lesson number (1-based)
final Map<int, LessonBuilder> lessonRegistry = {
  1: (onNavigate) => LessonOne(onNavigate: onNavigate),
  2: (onNavigate) => LessonTwo(onNavigate: onNavigate),
  3: (onNavigate) => LessonThree(onNavigate: onNavigate),
  4: (onNavigate) => LessonFour(onNavigate: onNavigate),

  // In future:
  // 10: (onNavigate) => LessonTen(onNavigate: onNavigate),
};
