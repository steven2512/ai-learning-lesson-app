// FILE: lib/core/lesson/lesson_order.dart
// Single Source of Truth for lesson order and a tiny API for working with it.

import 'package:flutter/widgets.dart';

/// Navigation callback used by lesson builders.
/// Pass your route object here (e.g., an AppRoute from core/app_router.dart).
typedef LessonNav = void Function(Object route);

/// A function that builds a lesson widget at a given registry index.
/// - [onNavigate] is the callback to push navigation routes.
/// - [index] is the position of this lesson in the global ordered list.
typedef LessonBuilder = Widget Function(LessonNav onNavigate, int index);

/// Ordered list of all lessons in the course.
/// Insert new lessons by adding ONE line here at the desired position.
/// Example:
///   (nav, i) => DataIntroLesson(onNavigate: nav, index: i),
final List<LessonBuilder> lessons = <LessonBuilder>[
  // TODO: Register your lessons here, in order.
  // Example entries (uncomment and adjust to your actual lesson widgets):
  // (nav, i) => DataIntroLesson(onNavigate: nav, index: i),
  // (nav, i) => BinaryLesson(onNavigate: nav, index: i),
  // (nav, i) => QualQuantLesson(onNavigate: nav, index: i),
];

/// Convenience: true if there is a lesson after [index].
bool hasNextLesson(int index) => index + 1 < lessons.length;

/// Convenience: true if there is a lesson before [index].
bool hasPrevLesson(int index) => index - 1 >= 0;
