// FILE: lib/services/lesson_service.dart
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:running_robot/core/lesson_manifest.dart';
import 'package:running_robot/models/lesson_progress.dart';

class LessonLaunchState {
  final int initialStepIndex;
  final bool isCompleted;
  final bool isCurrentProgressionLesson;

  const LessonLaunchState({
    required this.initialStepIndex,
    required this.isCompleted,
    required this.isCurrentProgressionLesson,
  });
}

class LessonCompletionResult {
  final bool firstCompletion;
  final int completedCount;
  final int xpAwarded;
  final int currentLesson;
  final int lessonsCompleted;
  final int todayLessonCount;
  final int dailyStreak;
  final int level;
  final int totalLearningSeconds;
  final String? todayKey;
  final int dayLearningSeconds;
  final int dayLessonsCompleted;

  const LessonCompletionResult({
    required this.firstCompletion,
    required this.completedCount,
    required this.xpAwarded,
    required this.currentLesson,
    required this.lessonsCompleted,
    required this.todayLessonCount,
    required this.dailyStreak,
    required this.level,
    required this.totalLearningSeconds,
    required this.todayKey,
    required this.dayLearningSeconds,
    required this.dayLessonsCompleted,
  });
}

class LessonSessionSyncResult {
  final int savedStepIndex;
  final int totalLearningSeconds;
  final String? todayKey;
  final int dayLearningSeconds;
  final int dayLessonsCompleted;

  const LessonSessionSyncResult({
    required this.savedStepIndex,
    required this.totalLearningSeconds,
    required this.todayKey,
    required this.dayLearningSeconds,
    required this.dayLessonsCompleted,
  });
}

class LessonService {
  static final _firestore = FirebaseFirestore.instance;
  static final _auth = FirebaseAuth.instance;
  static final _functions = FirebaseFunctions.instance;
  static final Map<String, Future<Map<String, dynamic>>> _inFlightCalls = {};

  static String get _uid {
    final user = _auth.currentUser;
    if (user == null) throw Exception("User not logged in");
    return user.uid;
  }

  static int get totalLessonCount =>
      chapterManifest.expand((chapter) => chapter.lessons).length;

  static DocumentReference<Map<String, dynamic>> _lessonDoc(String lessonId) {
    return _firestore
        .collection('users')
        .doc(_uid)
        .collection('lessonProgress')
        .doc(lessonId);
  }

  static Future<LessonProgress?> getLessonProgress(String lessonId) async {
    final snapshot = await _lessonDoc(lessonId).get();
    final data = snapshot.data();
    if (data == null) return null;
    return LessonProgress.fromMap(data);
  }

  static Future<LessonLaunchState> handleLesson({
    required String courseId,
    required String chapterId,
    required String lessonId,
    required int globalLessonNumber,
  }) async {
    final data = await _callProgressionFunction(
      'startLesson',
      {'lessonId': lessonId},
    );

    return LessonLaunchState(
      initialStepIndex: _readInt(data['initialStepIndex'], fallback: 0),
      isCompleted: data['isCompleted'] == true,
      isCurrentProgressionLesson: data['isCurrentProgressionLesson'] == true,
    );
  }

  static Future<LessonSessionSyncResult> saveCurrentLessonStep({
    required String lessonId,
    required int globalLessonNumber,
    required int stepIndex,
  }) async {
    final safeStepIndex = stepIndex < 0 ? 0 : stepIndex;

    final data = await _callProgressionFunction(
      'saveLessonProgress',
      {
        'lessonId': lessonId,
        'stepIndex': safeStepIndex,
      },
    );

    return LessonSessionSyncResult(
      savedStepIndex: _readInt(data['savedStepIndex'], fallback: safeStepIndex),
      totalLearningSeconds: _readInt(data['totalLearningSeconds'], fallback: 0),
      todayKey: data['todayKey']?.toString(),
      dayLearningSeconds: _readInt(data['dayLearningSeconds'], fallback: 0),
      dayLessonsCompleted: _readInt(data['dayLessonsCompleted'], fallback: 0),
    );
  }

  static Future<LessonSessionSyncResult> pauseLessonSession({
    required String lessonId,
    required int globalLessonNumber,
    required int stepIndex,
  }) async {
    final safeStepIndex = stepIndex < 0 ? 0 : stepIndex;

    final data = await _callProgressionFunction(
      'pauseLessonSession',
      {
        'lessonId': lessonId,
        'stepIndex': safeStepIndex,
      },
    );

    return LessonSessionSyncResult(
      savedStepIndex: _readInt(data['savedStepIndex'], fallback: safeStepIndex),
      totalLearningSeconds: _readInt(data['totalLearningSeconds'], fallback: 0),
      todayKey: data['todayKey']?.toString(),
      dayLearningSeconds: _readInt(data['dayLearningSeconds'], fallback: 0),
      dayLessonsCompleted: _readInt(data['dayLessonsCompleted'], fallback: 0),
    );
  }

  static Future<void> resumeLessonSession({
    required String courseId,
    required String chapterId,
    required String lessonId,
    required int globalLessonNumber,
  }) async {
    await _callProgressionFunction(
      'startLesson',
      {'lessonId': lessonId},
    );
  }

  static Future<LessonCompletionResult> completeLesson({
    required String courseId,
    required String chapterId,
    required String lessonId,
    required int globalLessonNumber,
  }) async {
    final data = await _callProgressionFunction(
      'completeLesson',
      {'lessonId': lessonId},
    );

    return LessonCompletionResult(
      firstCompletion: data['firstCompletion'] == true,
      completedCount: _readInt(data['completedCount'], fallback: 1),
      xpAwarded: _readInt(data['xpAwarded'], fallback: 0),
      currentLesson: _readInt(data['currentLesson'], fallback: 1),
      lessonsCompleted: _readInt(data['lessonsCompleted'], fallback: 0),
      todayLessonCount: _readInt(data['todayLessonCount'], fallback: 0),
      dailyStreak: _readInt(data['dailyStreak'], fallback: 0),
      level: _readInt(data['level'], fallback: 1),
      totalLearningSeconds: _readInt(data['totalLearningSeconds'], fallback: 0),
      todayKey: data['todayKey']?.toString(),
      dayLearningSeconds: _readInt(data['dayLearningSeconds'], fallback: 0),
      dayLessonsCompleted: _readInt(data['dayLessonsCompleted'], fallback: 0),
    );
  }

  static int _readInt(dynamic value, {required int fallback}) {
    if (value is int) return value;
    return int.tryParse(value?.toString() ?? '') ?? fallback;
  }

  static Future<Map<String, dynamic>> _callProgressionFunction(
    String name,
    Map<String, dynamic> payload,
  ) async {
    final key = '$name:${jsonEncode(payload)}';
    final existing = _inFlightCalls[key];
    if (existing != null) {
      return existing;
    }

    final future = () async {
      final result = await _functions
          .httpsCallable(
            name,
            options: HttpsCallableOptions(
              timeout: const Duration(seconds: 20),
            ),
          )
          .call(payload);
      final data = result.data;
      if (data is Map) {
        return Map<String, dynamic>.from(data);
      }
      throw Exception('Invalid response from $name');
    }();

    _inFlightCalls[key] = future;

    try {
      return await future;
    } finally {
      if (identical(_inFlightCalls[key], future)) {
        _inFlightCalls.remove(key);
      }
    }
  }
}
