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
  final int lessonsCompleted;
  final int todayLessonCount;
  final String? todayLessonCountDate;
  final int dailyStreak;
  final String? lastDailyLessonDate;
  final DateTime? dob;
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
    this.lessonsCompleted = 0,
    this.todayLessonCount = 0,
    this.todayLessonCountDate,
    this.dailyStreak = 0,
    this.lastDailyLessonDate,
    this.dob,
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
      'lessonsCompleted': lessonsCompleted,
      'todayLessonCount': todayLessonCount,
      'todayLessonCountDate': todayLessonCountDate,
      'dailyStreak': dailyStreak,
      'lastDailyLessonDate': lastDailyLessonDate,
      'dob': dob != null ? Timestamp.fromDate(dob!) : null,
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
      lessonsCompleted: (map['lessonsCompleted'] ?? 0) is int
          ? map['lessonsCompleted'] ?? 0
          : int.tryParse(map['lessonsCompleted'].toString()) ?? 0,
      todayLessonCount: (map['todayLessonCount'] ?? 0) is int
          ? map['todayLessonCount'] ?? 0
          : int.tryParse(map['todayLessonCount'].toString()) ?? 0,
      todayLessonCountDate: map['todayLessonCountDate'],
      dailyStreak: (map['dailyStreak'] ?? 0) is int
          ? map['dailyStreak'] ?? 0
          : int.tryParse(map['dailyStreak'].toString()) ?? 0,
      lastDailyLessonDate: map['lastDailyLessonDate'],
      dob: map['dob'] != null
          ? (map['dob'] is Timestamp
              ? (map['dob'] as Timestamp).toDate()
              : DateTime.tryParse(map['dob'].toString()))
          : null,
      provider: map['provider'],
      lastDevice: map['lastDevice'],
      appVersion: map['appVersion'],
      timezone: map['timezone'],
      timezoneOffsetMinutes: (map['timezoneOffsetMinutes'] is int)
          ? map['timezoneOffsetMinutes']
          : int.tryParse(map['timezoneOffsetMinutes']?.toString() ?? ''),
    );
  }
}
