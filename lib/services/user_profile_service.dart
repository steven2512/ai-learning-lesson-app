// FILE: lib/services/user_profile_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:running_robot/models/user_profile.dart';

class UserProfileService {
  static final _firestore = FirebaseFirestore.instance;

  static DocumentReference<Map<String, dynamic>> userDoc(String uid) {
    return _firestore.collection('users').doc(uid);
  }

  static Future<UserProfile?> getCurrentUserProfile() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return null;

    final snapshot = await userDoc(user.uid).get();
    final data = snapshot.data();
    if (data == null) return null;
    return UserProfile.fromMap(data);
  }

  static Future<void> createOrUpdateUserProfile(
    User user, {
    String? name,
    DateTime? dob,
    String? provider,
    String? lastDevice,
    String? appVersion,
  }) async {
    final doc = userDoc(user.uid);
    final snapshot = await doc.get();
    final data = snapshot.data();

    DateTime existingJoinedAt = DateTime.now();
    if (data != null && data['joinedAt'] != null) {
      if (data['joinedAt'] is Timestamp) {
        existingJoinedAt = (data['joinedAt'] as Timestamp).toDate();
      } else {
        existingJoinedAt =
            DateTime.tryParse(data['joinedAt'].toString()) ?? DateTime.now();
      }
    }

    final timezoneNow = DateTime.now();
    final resolvedProvider = provider ??
        data?['provider']?.toString() ??
        (user.providerData.isNotEmpty
            ? user.providerData.first.providerId
            : "unknown");
    final resolvedLastDevice = lastDevice ?? data?['lastDevice']?.toString();
    final resolvedAppVersion = appVersion ?? data?['appVersion']?.toString();
    final profile = UserProfile(
      uid: user.uid,
      email: user.email,
      name: name ?? user.displayName ?? data?['name']?.toString(),
      photoUrl: user.photoURL ?? data?['photoUrl']?.toString(),
      joinedAt: existingJoinedAt,
      currentLesson: _readInt(data, 'currentLesson', fallback: 1),
      currentLessonStepIndex:
          _readInt(data, 'currentLessonStepIndex', fallback: 0),
      xp: _readInt(data, 'xp', fallback: 0),
      lessonsCompleted: _readInt(data, 'lessonsCompleted', fallback: 0),
      todayLessonCount: _readInt(data, 'todayLessonCount', fallback: 0),
      todayLessonCountDate: data?['todayLessonCountDate']?.toString(),
      dailyStreak: _readInt(data, 'dailyStreak', fallback: 0),
      lastDailyLessonDate: data?['lastDailyLessonDate']?.toString(),
      dob: dob ??
          (data != null && data['dob'] != null
              ? (data['dob'] is Timestamp
                  ? (data['dob'] as Timestamp).toDate()
                  : DateTime.tryParse(data['dob'].toString()))
              : null),
      provider: resolvedProvider,
      lastDevice: resolvedLastDevice,
      appVersion: resolvedAppVersion,
      // Keep day-based progression aligned with the current device timezone.
      timezone: timezoneNow.timeZoneName,
      timezoneOffsetMinutes: timezoneNow.timeZoneOffset.inMinutes,
    );

    await doc.set({
      ...profile.toMap(),
      'lastLogin': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  static int _readInt(
    Map<String, dynamic>? data,
    String key, {
    required int fallback,
  }) {
    if (data == null) return fallback;
    final value = data[key];
    if (value is int) return value;
    return int.tryParse(value?.toString() ?? '') ?? fallback;
  }
}
