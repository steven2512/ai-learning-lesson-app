// FILE: lib/models/lesson_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class LessonModel {
  final String lessonId;
  final String courseId;
  final String chapterId;

  final DateTime startedAt;
  final DateTime? lastActiveAt;
  final DateTime? completedAt;

  // Progress tracking
  final int timeSpentToFirstCompletion; // 🔹 frozen once first completed
  final int timeSpentTotal; // 🔹 cumulative across all replays
  final int completedCount; // 🔹 total number of completions
  final int lastStepIndex; // 🔹 resume point (reset on new attempt)

  LessonModel({
    required this.lessonId,
    required this.courseId,
    required this.chapterId,
    required this.startedAt,
    this.lastActiveAt,
    this.completedAt,
    this.timeSpentToFirstCompletion = 0,
    this.timeSpentTotal = 0,
    this.completedCount = 0,
    this.lastStepIndex = 0,
  });

  /// 🔹 Convert to Firestore map
  Map<String, dynamic> toMap() {
    return {
      'lessonId': lessonId,
      'courseId': courseId,
      'chapterId': chapterId,
      'startedAt': Timestamp.fromDate(startedAt),
      'lastActiveAt':
          lastActiveAt != null ? Timestamp.fromDate(lastActiveAt!) : null,
      'completedAt':
          completedAt != null ? Timestamp.fromDate(completedAt!) : null,
      'timeSpentToFirstCompletion': timeSpentToFirstCompletion,
      'timeSpentTotal': timeSpentTotal,
      'completedCount': completedCount,
      'lastStepIndex': lastStepIndex,
    };
  }

  /// 🔹 Factory from Firestore map
  factory LessonModel.fromMap(Map<String, dynamic> map) {
    return LessonModel(
      lessonId: map['lessonId'],
      courseId: map['courseId'],
      chapterId: map['chapterId'],
      startedAt: (map['startedAt'] is Timestamp)
          ? (map['startedAt'] as Timestamp).toDate()
          : DateTime.tryParse(map['startedAt'].toString()) ?? DateTime.now(),
      lastActiveAt: map['lastActiveAt'] != null
          ? (map['lastActiveAt'] is Timestamp
              ? (map['lastActiveAt'] as Timestamp).toDate()
              : DateTime.tryParse(map['lastActiveAt'].toString()))
          : null,
      completedAt: map['completedAt'] != null
          ? (map['completedAt'] is Timestamp
              ? (map['completedAt'] as Timestamp).toDate()
              : DateTime.tryParse(map['completedAt'].toString()))
          : null,
      timeSpentToFirstCompletion: map['timeSpentToFirstCompletion'] ?? 0,
      timeSpentTotal: map['timeSpentTotal'] ?? 0,
      completedCount: map['completedCount'] ?? 0,
      lastStepIndex: map['lastStepIndex'] ?? 0,
    );
  }
}
