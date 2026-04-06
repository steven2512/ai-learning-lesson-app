// FILE: lib/services/lesson_service.dart
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

  const LessonCompletionResult({
    required this.firstCompletion,
    required this.completedCount,
    required this.xpAwarded,
    required this.currentLesson,
    required this.lessonsCompleted,
    required this.todayLessonCount,
    required this.dailyStreak,
  });
}

class LessonService {
  static final _firestore = FirebaseFirestore.instance;
  static final _auth = FirebaseAuth.instance;
  static final _functions = FirebaseFunctions.instance;

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

  static Future<void> saveCurrentLessonStep({
    required String lessonId,
    required int globalLessonNumber,
    required int stepIndex,
  }) async {
    final safeStepIndex = stepIndex < 0 ? 0 : stepIndex;

    await _callProgressionFunction(
      'saveLessonProgress',
      {
        'lessonId': lessonId,
        'stepIndex': safeStepIndex,
      },
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
    final result = await _functions.httpsCallable(name).call(payload);
    final data = result.data;
    if (data is Map) {
      return Map<String, dynamic>.from(data);
    }
    throw Exception('Invalid response from $name');
  }
}
