// FILE: lib/services/lesson_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LessonService {
  static final _firestore = FirebaseFirestore.instance;
  static final _auth = FirebaseAuth.instance;

  static String get _uid {
    final user = _auth.currentUser;
    if (user == null) throw Exception("User not logged in");
    return user.uid;
  }

  /// Get the path to a lesson doc
  static DocumentReference<Map<String, dynamic>> _lessonDoc(
    String courseId,
    String chapterId,
    String lessonId,
  ) {
    return _firestore
        .collection('users')
        .doc(_uid)
        .collection('progress')
        .doc(courseId)
        .collection(chapterId)
        .doc(lessonId);
  }

  /// 🔹 Unified entry point when user opens a lesson
  static Future<void> handleLesson({
    required String courseId,
    required String chapterId,
    required String lessonId,
    required int globalLessonNumber,
  }) async {
    final doc = _lessonDoc(courseId, chapterId, lessonId);
    final snap = await doc.get();

    if (!snap.exists) {
      // First time → initialize
      await doc.set({
        'lessonId': lessonId,
        'courseId': courseId,
        'chapterId': chapterId,
        'startedAt': FieldValue.serverTimestamp(),
        'lastActiveAt': FieldValue.serverTimestamp(),
        'completedAt': null,
        'timeSpentToFirstCompletion': 0,
        'timeSpentTotal': 0,
        'completedCount': 0,
        'lastStepIndex': 0,
      });

      // ✅ Update profile.currentLesson if this is further than before
      final userDoc = _firestore.collection('users').doc(_uid);
      final userSnap = await userDoc.get();
      final currentLesson = (userSnap.data()?['currentLesson'] ?? 0) as int;
      if (globalLessonNumber > currentLesson) {
        await userDoc.update({'currentLesson': globalLessonNumber});
      }
    } else {
      // Existing doc → only refresh lastActiveAt
      await doc.update({
        'lastActiveAt': FieldValue.serverTimestamp(),
      });
    }
  }

  /// 🔹 Update lesson fields (safe merge)
  static Future<void> updateLesson({
    required String courseId,
    required String chapterId,
    required String lessonId,
    required Map<String, dynamic> fields,
  }) async {
    final doc = _lessonDoc(courseId, chapterId, lessonId);
    await doc.set({
      ...fields,
      'lastActiveAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  /// 🔹 Mark lesson as completed
  static Future<void> completeLesson({
    required String courseId,
    required String chapterId,
    required String lessonId,
    required int globalLessonNumber,
  }) async {
    final doc = _lessonDoc(courseId, chapterId, lessonId);
    final snap = await doc.get();

    final alreadyCompleted = snap.data()?['completedAt'] != null;

    await doc.update({
      'completedAt': FieldValue.serverTimestamp(),
      'completedCount': FieldValue.increment(1),
      'lastActiveAt': FieldValue.serverTimestamp(),
    });

    // ✅ If first-time completion → bump lessonsCompleted in user profile
    final userDoc = _firestore.collection('users').doc(_uid);
    if (!alreadyCompleted) {
      await userDoc.update({
        'lessonsCompleted': FieldValue.increment(1),
      });
    }

    // ✅ Ensure profile.currentLesson is always at least this lesson number
    final userSnap = await userDoc.get();
    final currentLesson = (userSnap.data()?['currentLesson'] ?? 0) as int;
    if (globalLessonNumber > currentLesson) {
      await userDoc.update({'currentLesson': globalLessonNumber});
    }
  }
}
