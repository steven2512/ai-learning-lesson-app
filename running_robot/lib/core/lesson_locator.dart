import 'package:running_robot/core/lesson_manifest.dart';

class LessonLocator {
  final String courseId;
  final String chapterId;
  final String lessonId;

  final int courseIndex;
  final int chapterIndex;
  final int lessonIndex;
  final int globalIndex;

  const LessonLocator({
    required this.courseId,
    required this.chapterId,
    required this.lessonId,
    required this.courseIndex,
    required this.chapterIndex,
    required this.lessonIndex,
    required this.globalIndex,
  });

  // Build locator from lessonId
  static LessonLocator fromLessonId(String lessonId) {
    int global = 0;
    for (int ci = 0; ci < courseManifest.length; ci++) {
      final course = courseManifest[ci];
      for (int chi = 0; chi < course.chapters.length; chi++) {
        final chapter = course.chapters[chi];
        for (int li = 0; li < chapter.lessons.length; li++) {
          final lesson = chapter.lessons[li];
          global++;
          if (lesson.id == lessonId) {
            return LessonLocator(
              courseId: course.id,
              chapterId: chapter.id,
              lessonId: lesson.id,
              courseIndex: ci,
              chapterIndex: chi,
              lessonIndex: li,
              globalIndex: global,
            );
          }
        }
      }
    }
    throw Exception("Lesson $lessonId not found in manifest");
  }
}
