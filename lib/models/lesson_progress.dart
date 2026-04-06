import 'package:cloud_firestore/cloud_firestore.dart';

class LessonProgress {
  final String lessonId;
  final String courseId;
  final String chapterId;
  final int globalLessonNumber;
  final DateTime? startedAt;
  final DateTime? lastActiveAt;
  final DateTime? completedAt;
  final bool isCompleted;
  final int completedCount;

  const LessonProgress({
    required this.lessonId,
    required this.courseId,
    required this.chapterId,
    required this.globalLessonNumber,
    this.startedAt,
    this.lastActiveAt,
    this.completedAt,
    this.isCompleted = false,
    this.completedCount = 0,
  });

  Map<String, dynamic> toMap() {
    return {
      'lessonId': lessonId,
      'courseId': courseId,
      'chapterId': chapterId,
      'globalLessonNumber': globalLessonNumber,
      'startedAt': startedAt != null ? Timestamp.fromDate(startedAt!) : null,
      'lastActiveAt':
          lastActiveAt != null ? Timestamp.fromDate(lastActiveAt!) : null,
      'completedAt':
          completedAt != null ? Timestamp.fromDate(completedAt!) : null,
      'isCompleted': isCompleted,
      'completedCount': completedCount,
    };
  }

  factory LessonProgress.fromMap(Map<String, dynamic> map) {
    DateTime? parseDate(dynamic value) {
      if (value == null) return null;
      if (value is Timestamp) return value.toDate();
      return DateTime.tryParse(value.toString());
    }

    return LessonProgress(
      lessonId: map['lessonId']?.toString() ?? '',
      courseId: map['courseId']?.toString() ?? '',
      chapterId: map['chapterId']?.toString() ?? '',
      globalLessonNumber: (map['globalLessonNumber'] ?? 0) is int
          ? map['globalLessonNumber'] ?? 0
          : int.tryParse(map['globalLessonNumber'].toString()) ?? 0,
      startedAt: parseDate(map['startedAt']),
      lastActiveAt: parseDate(map['lastActiveAt']),
      completedAt: parseDate(map['completedAt']),
      isCompleted: map['isCompleted'] == true,
      completedCount: (map['completedCount'] ?? 0) is int
          ? map['completedCount'] ?? 0
          : int.tryParse(map['completedCount'].toString()) ?? 0,
    );
  }
}
