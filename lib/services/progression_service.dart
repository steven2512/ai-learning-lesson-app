import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:running_robot/models/activity_day_metrics.dart';
import 'package:running_robot/models/lesson_progress.dart';
import 'package:running_robot/models/user_profile.dart';
import 'package:running_robot/services/user_profile_service.dart';

class _WeekBounds {
  final String startKey;
  final String endKey;

  const _WeekBounds({
    required this.startKey,
    required this.endKey,
  });
}

class ProgressionSnapshot {
  final UserProfile profile;
  final Map<String, LessonProgress> lessonProgressById;
  final Set<String> weeklyActivityDateKeys;
  final Map<String, ActivityDayMetrics> weeklyActivityByDateKey;

  const ProgressionSnapshot({
    required this.profile,
    required this.lessonProgressById,
    required this.weeklyActivityDateKeys,
    required this.weeklyActivityByDateKey,
  });
}

class ProgressionService {
  static final _firestore = FirebaseFirestore.instance;
  static final _functions = FirebaseFunctions.instance;

  static Future<ProgressionSnapshot?> loadCurrentProgression() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return null;

    await _markDailyActivitySafely();

    final profile = await UserProfileService.getCurrentUserProfile();
    if (profile == null) return null;

    final weekBounds = _currentWeekBounds();
    final lessonSnapshotsFuture = _firestore
        .collection('users')
        .doc(user.uid)
        .collection('lessonProgress')
        .get();
    final activitySnapshotsFuture = _firestore
        .collection('users')
        .doc(user.uid)
        .collection('activityDays')
        .where('dateKey', isGreaterThanOrEqualTo: weekBounds.startKey)
        .where('dateKey', isLessThanOrEqualTo: weekBounds.endKey)
        .orderBy('dateKey')
        .get();

    final lessonSnapshots = await lessonSnapshotsFuture;
    final activitySnapshots = await activitySnapshotsFuture;

    final lessonProgressById = <String, LessonProgress>{};
    for (final doc in lessonSnapshots.docs) {
      lessonProgressById[doc.id] = LessonProgress.fromMap(doc.data());
    }

    final weeklyActivityDateKeys = <String>{};
    final weeklyActivityByDateKey = <String, ActivityDayMetrics>{};
    for (final doc in activitySnapshots.docs) {
      final dayMetrics = ActivityDayMetrics.fromMap(doc.id, doc.data());
      weeklyActivityByDateKey[dayMetrics.dateKey] = dayMetrics;
      if (dayMetrics.hasActivity) {
        weeklyActivityDateKeys.add(dayMetrics.dateKey);
      }
    }

    return ProgressionSnapshot(
      profile: profile,
      lessonProgressById: lessonProgressById,
      weeklyActivityDateKeys: weeklyActivityDateKeys,
      weeklyActivityByDateKey: weeklyActivityByDateKey,
    );
  }

  static Future<void> _markDailyActivitySafely() async {
    try {
      await _functions
          .httpsCallable(
            'markDailyActivity',
            options: HttpsCallableOptions(
              timeout: const Duration(seconds: 20),
            ),
          )
          .call();
    } catch (_) {
      // Keep the app usable even if the new function is not deployed yet.
    }
  }

  static _WeekBounds _currentWeekBounds() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final monday = today.subtract(Duration(days: today.weekday - 1));
    final sunday = monday.add(const Duration(days: 6));
    return _WeekBounds(
      startKey: _dateKey(monday),
      endKey: _dateKey(sunday),
    );
  }

  static String _dateKey(DateTime date) {
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '${date.year}-$month-$day';
  }
}
