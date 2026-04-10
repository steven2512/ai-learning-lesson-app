// FILE: lib/models/user_profile.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class UserProfile {
  final String uid;
  final String? name;
  final String? email;
  final String? photoUrl;
  final DateTime joinedAt;
  final int currentLesson;
  final int currentLessonStepIndex;
  final int xp;
  final int level;
  final int lessonsCompleted;
  final int totalLearningSeconds;
  final int totalSessionSeconds;
  final int todayLessonCount;
  final String? todayLessonCountDate;
  final int dailyStreak;
  final String? lastDailyLessonDate;
  final int activityStreak;
  final String? lastActivityDateKey;
  final int? age;
  final String? provider;
  final String? lastDevice;
  final String? appVersion;
  final String? timezone;
  final int? timezoneOffsetMinutes;

  UserProfile({
    required this.uid,
    this.name,
    this.email,
    this.photoUrl,
    required this.joinedAt,
    this.currentLesson = 1,
    this.currentLessonStepIndex = 0,
    this.xp = 0,
    this.level = 1,
    this.lessonsCompleted = 0,
    this.totalLearningSeconds = 0,
    this.totalSessionSeconds = 0,
    this.todayLessonCount = 0,
    this.todayLessonCountDate,
    this.dailyStreak = 0,
    this.lastDailyLessonDate,
    this.activityStreak = 0,
    this.lastActivityDateKey,
    this.age,
    this.provider,
    this.lastDevice,
    this.appVersion,
    this.timezone,
    this.timezoneOffsetMinutes,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'photoUrl': photoUrl,
      'joinedAt': Timestamp.fromDate(joinedAt),
      'currentLesson': currentLesson,
      'currentLessonStepIndex': currentLessonStepIndex,
      'xp': xp,
      'level': level,
      'lessonsCompleted': lessonsCompleted,
      'totalLearningSeconds': totalLearningSeconds,
      'totalSessionSeconds': totalSessionSeconds,
      'todayLessonCount': todayLessonCount,
      'todayLessonCountDate': todayLessonCountDate,
      'dailyStreak': dailyStreak,
      'lastDailyLessonDate': lastDailyLessonDate,
      'activityStreak': activityStreak,
      'lastActivityDateKey': lastActivityDateKey,
      'age': age,
      'provider': provider,
      'lastDevice': lastDevice,
      'appVersion': appVersion,
      'timezone': timezone,
      'timezoneOffsetMinutes': timezoneOffsetMinutes,
    };
  }

  factory UserProfile.fromMap(Map<String, dynamic> map) {
    return UserProfile(
      uid: map['uid'],
      name: map['name'],
      email: map['email'],
      photoUrl: map['photoUrl'],
      joinedAt: (map['joinedAt'] is Timestamp)
          ? (map['joinedAt'] as Timestamp).toDate()
          : DateTime.tryParse(map['joinedAt'].toString()) ?? DateTime.now(),
      currentLesson: (map['currentLesson'] ?? 1) is int
          ? map['currentLesson'] ?? 1
          : int.tryParse(map['currentLesson'].toString()) ?? 1,
      currentLessonStepIndex: (map['currentLessonStepIndex'] ?? 0) is int
          ? map['currentLessonStepIndex'] ?? 0
          : int.tryParse(map['currentLessonStepIndex'].toString()) ?? 0,
      xp: (map['xp'] ?? 0) is int
          ? map['xp'] ?? 0
          : int.tryParse(map['xp'].toString()) ?? 0,
      level: (map['level'] ?? _levelFromXp(map['xp'])) is int
          ? map['level'] ?? _levelFromXp(map['xp'])
          : int.tryParse(map['level'].toString()) ?? _levelFromXp(map['xp']),
      lessonsCompleted: (map['lessonsCompleted'] ?? 0) is int
          ? map['lessonsCompleted'] ?? 0
          : int.tryParse(map['lessonsCompleted'].toString()) ?? 0,
      totalLearningSeconds: (map['totalLearningSeconds'] ?? 0) is int
          ? map['totalLearningSeconds'] ?? 0
          : int.tryParse(map['totalLearningSeconds'].toString()) ?? 0,
      totalSessionSeconds: (map['totalSessionSeconds'] ?? 0) is int
          ? map['totalSessionSeconds'] ?? 0
          : int.tryParse(map['totalSessionSeconds'].toString()) ?? 0,
      todayLessonCount: (map['todayLessonCount'] ?? 0) is int
          ? map['todayLessonCount'] ?? 0
          : int.tryParse(map['todayLessonCount'].toString()) ?? 0,
      todayLessonCountDate: map['todayLessonCountDate'],
      dailyStreak: (map['dailyStreak'] ?? 0) is int
          ? map['dailyStreak'] ?? 0
          : int.tryParse(map['dailyStreak'].toString()) ?? 0,
      lastDailyLessonDate: map['lastDailyLessonDate'],
      activityStreak: (map['activityStreak'] ?? 0) is int
          ? map['activityStreak'] ?? 0
          : int.tryParse(map['activityStreak'].toString()) ?? 0,
      lastActivityDateKey: map['lastActivityDateKey'],
      age: _readAge(map),
      provider: map['provider'],
      lastDevice: map['lastDevice'],
      appVersion: map['appVersion'],
      timezone: map['timezone'],
      timezoneOffsetMinutes: (map['timezoneOffsetMinutes'] is int)
          ? map['timezoneOffsetMinutes']
          : int.tryParse(map['timezoneOffsetMinutes']?.toString() ?? ''),
    );
  }

  static int _levelFromXp(dynamic rawXp) {
    final xp =
        (rawXp is int) ? rawXp : int.tryParse(rawXp?.toString() ?? '') ?? 0;
    final normalizedXp = xp < 0 ? 0 : xp;
    return (normalizedXp ~/ 200) + 1;
  }

  static int? _readAge(Map<String, dynamic> map) {
    final rawAge = map['age'];
    if (rawAge is int) return rawAge;

    final parsedAge = int.tryParse(rawAge?.toString() ?? '');
    if (parsedAge != null) return parsedAge;

    final rawDob = map['dob'];
    final dob = rawDob is Timestamp
        ? rawDob.toDate()
        : DateTime.tryParse(rawDob?.toString() ?? '');
    if (dob == null) return null;

    final now = DateTime.now();
    var age = now.year - dob.year;
    final birthdayPassed =
        now.month > dob.month || (now.month == dob.month && now.day >= dob.day);
    if (!birthdayPassed) {
      age -= 1;
    }
    return age < 0 ? null : age;
  }
}
