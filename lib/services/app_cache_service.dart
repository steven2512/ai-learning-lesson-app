import 'dart:convert';

import 'package:running_robot/models/lesson_progress.dart';
import 'package:running_robot/models/user_profile.dart';
import 'package:running_robot/services/progression_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppCacheService {
  static const int _schemaVersion = 2;
  static const String _snapshotPrefix = 'app_shell_snapshot_';

  static String _snapshotKey(String uid) => '$_snapshotPrefix$uid';

  static Future<ProgressionSnapshot?> readProgressionSnapshot(
      String uid) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_snapshotKey(uid));
    if (raw == null || raw.isEmpty) return null;

    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map) return null;

      final schemaVersion = decoded['schemaVersion'];
      if (schemaVersion != _schemaVersion) return null;

      final data = decoded['data'];
      if (data is! Map) return null;

      final profileMap = data['profile'];
      if (profileMap is! Map) return null;

      final lessonProgressRaw = data['lessonProgressById'];
      final lessonProgressById = <String, LessonProgress>{};
      if (lessonProgressRaw is Map) {
        for (final entry in lessonProgressRaw.entries) {
          final key = entry.key?.toString();
          final value = entry.value;
          if (key == null || value is! Map) continue;
          lessonProgressById[key] =
              LessonProgress.fromMap(Map<String, dynamic>.from(value));
        }
      }

      return ProgressionSnapshot(
        profile: UserProfile.fromMap(Map<String, dynamic>.from(profileMap)),
        lessonProgressById: lessonProgressById,
        weeklyActivityDateKeys: _decodeWeeklyActivityDateKeys(
          data['weeklyActivityDateKeys'],
        ),
      );
    } catch (_) {
      return null;
    }
  }

  static Future<void> writeProgressionSnapshot(
    String uid,
    ProgressionSnapshot snapshot,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final payload = {
      'schemaVersion': _schemaVersion,
      'cachedAt': DateTime.now().toIso8601String(),
      'data': {
        'profile': _encodeUserProfile(snapshot.profile),
        'lessonProgressById': {
          for (final entry in snapshot.lessonProgressById.entries)
            entry.key: _encodeLessonProgress(entry.value),
        },
        'weeklyActivityDateKeys': snapshot.weeklyActivityDateKeys.toList()
          ..sort(),
      },
    };
    await prefs.setString(_snapshotKey(uid), jsonEncode(payload));
  }

  static Future<void> clearProgressionSnapshot(String uid) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_snapshotKey(uid));
  }

  static Map<String, dynamic> _encodeUserProfile(UserProfile profile) {
    return {
      'uid': profile.uid,
      'name': profile.name,
      'email': profile.email,
      'photoUrl': profile.photoUrl,
      'joinedAt': profile.joinedAt.toIso8601String(),
      'currentLesson': profile.currentLesson,
      'currentLessonStepIndex': profile.currentLessonStepIndex,
      'xp': profile.xp,
      'level': profile.level,
      'lessonsCompleted': profile.lessonsCompleted,
      'totalLearningSeconds': profile.totalLearningSeconds,
      'todayLessonCount': profile.todayLessonCount,
      'todayLessonCountDate': profile.todayLessonCountDate,
      'dailyStreak': profile.dailyStreak,
      'lastDailyLessonDate': profile.lastDailyLessonDate,
      'activityStreak': profile.activityStreak,
      'lastActivityDateKey': profile.lastActivityDateKey,
      'age': profile.age,
      'provider': profile.provider,
      'lastDevice': profile.lastDevice,
      'appVersion': profile.appVersion,
      'timezone': profile.timezone,
      'timezoneOffsetMinutes': profile.timezoneOffsetMinutes,
    };
  }

  static Map<String, dynamic> _encodeLessonProgress(LessonProgress progress) {
    return {
      'lessonId': progress.lessonId,
      'courseId': progress.courseId,
      'chapterId': progress.chapterId,
      'globalLessonNumber': progress.globalLessonNumber,
      'startedAt': progress.startedAt?.toIso8601String(),
      'lastActiveAt': progress.lastActiveAt?.toIso8601String(),
      'completedAt': progress.completedAt?.toIso8601String(),
      'isCompleted': progress.isCompleted,
      'completedCount': progress.completedCount,
    };
  }

  static Set<String> _decodeWeeklyActivityDateKeys(dynamic raw) {
    if (raw is! List) return <String>{};

    final values = <String>{};
    for (final entry in raw) {
      final value = entry?.toString();
      if (value != null && value.isNotEmpty) {
        values.add(value);
      }
    }
    return values;
  }
}
