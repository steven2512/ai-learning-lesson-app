// FILE: lib/services/lesson_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:running_robot/core/lesson_manifest.dart';
import 'package:running_robot/models/lesson_progress.dart';
import 'package:running_robot/services/user_profile_service.dart';

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

class LessonService {
  static final _firestore = FirebaseFirestore.instance;
  static final _auth = FirebaseAuth.instance;
  static const int lessonXpReward = 50;

  static String get _uid {
    final user = _auth.currentUser;
    if (user == null) throw Exception("User not logged in");
    return user.uid;
  }

  static int get totalLessonCount =>
      chapterManifest.expand((chapter) => chapter.lessons).length;

  static DocumentReference<Map<String, dynamic>> _userDoc() {
    return UserProfileService.userDoc(_uid);
  }

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
    final doc = _lessonDoc(lessonId);
    final userDoc = _userDoc();

    final userSnap = await userDoc.get();
    final userData = userSnap.data() ?? <String, dynamic>{};
    final snap = await doc.get();
    final progressData = snap.data() ?? <String, dynamic>{};
    final currentLesson = _readInt(userData['currentLesson'], fallback: 1);
    final currentLessonStepIndex =
        _readInt(userData['currentLessonStepIndex'], fallback: 0);
    final isCompleted = progressData['isCompleted'] == true;
    final isCurrentProgressionLesson =
        currentLesson == globalLessonNumber && !isCompleted;

    if (!snap.exists) {
      await doc.set(
        _newLessonProgressPayload(
          lessonId: lessonId,
          courseId: courseId,
          chapterId: chapterId,
          globalLessonNumber: globalLessonNumber,
        ),
      );
    } else {
      await doc.update({
        'lastActiveAt': FieldValue.serverTimestamp(),
      });
    }

    return LessonLaunchState(
      initialStepIndex: isCurrentProgressionLesson ? currentLessonStepIndex : 0,
      isCompleted: isCompleted,
      isCurrentProgressionLesson: isCurrentProgressionLesson,
    );
  }

  static Future<void> saveCurrentLessonStep({
    required String lessonId,
    required int globalLessonNumber,
    required int stepIndex,
  }) async {
    final doc = _lessonDoc(lessonId);
    final userDoc = _userDoc();
    final userSnap = await userDoc.get();
    final userData = userSnap.data() ?? <String, dynamic>{};
    final currentLesson = _readInt(userData['currentLesson'], fallback: 1);
    final safeStepIndex = stepIndex < 0 ? 0 : stepIndex;

    await doc.set({
      'lastActiveAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    if (currentLesson == globalLessonNumber) {
      await userDoc.set({
        'currentLessonStepIndex': safeStepIndex,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    }
  }

  static Future<void> completeLesson({
    required String courseId,
    required String chapterId,
    required String lessonId,
    required int globalLessonNumber,
  }) async {
    final lessonDoc = _lessonDoc(lessonId);
    final userDoc = _userDoc();

    await _firestore.runTransaction((transaction) async {
      final lessonSnap = await transaction.get(lessonDoc);
      final userSnap = await transaction.get(userDoc);

      final lessonData = lessonSnap.data() ?? <String, dynamic>{};
      final userData = userSnap.data() ?? <String, dynamic>{};
      final todayKey = _dateKeyForUser(userData);
      final alreadyCompleted = lessonData['isCompleted'] == true;
      final completedCount =
          _readInt(lessonData['completedCount'], fallback: 0);

      transaction.set(
          lessonDoc,
          _lessonCompletionPayload(
            lessonData: lessonData,
            lessonId: lessonId,
            courseId: courseId,
            chapterId: chapterId,
            globalLessonNumber: globalLessonNumber,
            completedCount: completedCount,
            alreadyCompleted: alreadyCompleted,
          ),
          SetOptions(merge: true));

      if (!alreadyCompleted) {
        final nextLesson = globalLessonNumber < totalLessonCount
            ? globalLessonNumber + 1
            : globalLessonNumber;
        final currentLesson = _readInt(userData['currentLesson'], fallback: 1);
        final lessonsCompleted =
            _readInt(userData['lessonsCompleted'], fallback: 0);
        final xp = _readInt(userData['xp'], fallback: 0);
        final todayLessonCount =
            _readInt(userData['todayLessonCount'], fallback: 0);
        final todayLessonCountDate =
            userData['todayLessonCountDate']?.toString();
        final dailyStreak = _readInt(userData['dailyStreak'], fallback: 0);
        final lastDailyLessonDate = userData['lastDailyLessonDate']?.toString();

        final isSameDay = todayLessonCountDate == todayKey;
        final nextTodayLessonCount = isSameDay ? todayLessonCount + 1 : 1;
        final nextDailyStreak =
            _computeNextDailyStreak(lastDailyLessonDate, todayKey, dailyStreak);

        transaction.set(
            userDoc,
            _userCompletionSummaryPayload(
              lessonsCompleted: lessonsCompleted,
              xp: xp,
              todayLessonCount: nextTodayLessonCount,
              todayKey: todayKey,
              dailyStreak: nextDailyStreak,
              currentLesson:
                  currentLesson < nextLesson ? nextLesson : currentLesson,
            ),
            SetOptions(merge: true));
      }
    });
  }

  static Map<String, dynamic> _newLessonProgressPayload({
    required String lessonId,
    required String courseId,
    required String chapterId,
    required int globalLessonNumber,
  }) {
    return {
      'lessonId': lessonId,
      'courseId': courseId,
      'chapterId': chapterId,
      'globalLessonNumber': globalLessonNumber,
      'startedAt': FieldValue.serverTimestamp(),
      'lastActiveAt': FieldValue.serverTimestamp(),
      'isCompleted': false,
      'completedAt': null,
      'completedCount': 0,
    };
  }

  static Map<String, dynamic> _lessonCompletionPayload({
    required Map<String, dynamic> lessonData,
    required String lessonId,
    required String courseId,
    required String chapterId,
    required int globalLessonNumber,
    required int completedCount,
    required bool alreadyCompleted,
  }) {
    return {
      'lessonId': lessonId,
      'courseId': courseId,
      'chapterId': chapterId,
      'globalLessonNumber': globalLessonNumber,
      'startedAt': lessonData['startedAt'] ?? FieldValue.serverTimestamp(),
      'lastActiveAt': FieldValue.serverTimestamp(),
      'completedCount': completedCount + 1,
      if (!alreadyCompleted) 'isCompleted': true,
      if (!alreadyCompleted) 'completedAt': FieldValue.serverTimestamp(),
    };
  }

  static Map<String, dynamic> _userCompletionSummaryPayload({
    required int lessonsCompleted,
    required int xp,
    required int todayLessonCount,
    required String todayKey,
    required int dailyStreak,
    required int currentLesson,
  }) {
    return {
      'lessonsCompleted': lessonsCompleted + 1,
      'xp': xp + lessonXpReward,
      'todayLessonCount': todayLessonCount,
      'todayLessonCountDate': todayKey,
      'dailyStreak': dailyStreak,
      'lastDailyLessonDate': todayKey,
      'currentLesson': currentLesson,
      'currentLessonStepIndex': 0,
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  static String _dateKeyForUser(Map<String, dynamic> userData) {
    final offsetMinutes =
        _readInt(userData['timezoneOffsetMinutes'], fallback: 0);
    final local = DateTime.now().toUtc().add(Duration(minutes: offsetMinutes));
    final month = local.month.toString().padLeft(2, '0');
    final day = local.day.toString().padLeft(2, '0');
    return '${local.year}-$month-$day';
  }

  static int _computeNextDailyStreak(
    String? lastDailyLessonDate,
    String todayKey,
    int currentDailyStreak,
  ) {
    if (lastDailyLessonDate == todayKey) {
      return currentDailyStreak;
    }

    if (lastDailyLessonDate == null) {
      return 1;
    }

    final lastDate = DateTime.tryParse(lastDailyLessonDate);
    final currentDate = DateTime.tryParse(todayKey);
    if (lastDate == null || currentDate == null) {
      return 1;
    }

    final difference = currentDate.difference(lastDate).inDays;
    if (difference == 1) {
      return currentDailyStreak + 1;
    }
    if (difference == 0) {
      return currentDailyStreak;
    }
    return 1;
  }

  static int _readInt(dynamic value, {required int fallback}) {
    if (value is int) return value;
    return int.tryParse(value?.toString() ?? '') ?? fallback;
  }
}
