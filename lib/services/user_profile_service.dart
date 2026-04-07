// FILE: lib/services/user_profile_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:running_robot/models/user_profile.dart';

class UserProfileService {
  static final _firestore = FirebaseFirestore.instance;
  static const _requiredProfileKeys = <String>{
    'uid',
    'name',
    'email',
    'photoUrl',
    'joinedAt',
    'lastLogin',
    'provider',
    'dob',
    'currentLesson',
    'currentLessonStepIndex',
    'xp',
    'lessonsCompleted',
    'todayLessonCount',
    'todayLessonCountDate',
    'dailyStreak',
    'lastDailyLessonDate',
    'lastDevice',
    'appVersion',
    'timezone',
    'timezoneOffsetMinutes',
    'updatedAt',
  };

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
    final resolvedPhotoUrl = user.photoURL ?? data?['photoUrl']?.toString();
    final resolvedLastDevice = lastDevice ?? data?['lastDevice']?.toString();
    final resolvedAppVersion = appVersion ?? data?['appVersion']?.toString();
    final resolvedDob = dob ??
        (data != null && data['dob'] != null
            ? (data['dob'] is Timestamp
                ? (data['dob'] as Timestamp).toDate()
                : DateTime.tryParse(data['dob'].toString()))
            : null);

    final metadata = _profileMetadataMap(
      user: user,
      name: name ?? user.displayName ?? data?['name']?.toString(),
      photoUrl: resolvedPhotoUrl,
      dob: resolvedDob,
      provider: resolvedProvider,
      lastDevice: resolvedLastDevice,
      appVersion: resolvedAppVersion,
      timezoneNow: timezoneNow,
    );

    if (data == null) {
      final profile = UserProfile(
        uid: user.uid,
        email: user.email,
        name: metadata['name']?.toString(),
        photoUrl: resolvedPhotoUrl,
        joinedAt: existingJoinedAt,
        currentLesson: 1,
        currentLessonStepIndex: 0,
        xp: 0,
        lessonsCompleted: 0,
        todayLessonCount: 0,
        todayLessonCountDate: null,
        dailyStreak: 0,
        lastDailyLessonDate: null,
        dob: resolvedDob,
        provider: resolvedProvider,
        lastDevice: resolvedLastDevice,
        appVersion: resolvedAppVersion,
        timezone: timezoneNow.timeZoneName,
        timezoneOffsetMinutes: timezoneNow.timeZoneOffset.inMinutes,
      );

      await doc.set({
        ...profile.toMap(),
        'lastLogin': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      return;
    }

    if (!_hasCanonicalProfileShape(data)) {
      final profile = UserProfile(
        uid: user.uid,
        email: user.email ?? data['email']?.toString(),
        name: metadata['name']?.toString(),
        photoUrl: resolvedPhotoUrl,
        joinedAt: existingJoinedAt,
        currentLesson: _readLegacyInt(data['currentLesson'], fallback: 1),
        currentLessonStepIndex:
            _readLegacyInt(data['currentLessonStepIndex'], fallback: 0),
        xp: _readLegacyInt(data['xp'], fallback: 0),
        lessonsCompleted: _readLegacyInt(data['lessonsCompleted'], fallback: 0),
        todayLessonCount: _readLegacyInt(data['todayLessonCount'], fallback: 0),
        todayLessonCountDate: data['todayLessonCountDate']?.toString(),
        dailyStreak: _readLegacyInt(data['dailyStreak'], fallback: 0),
        lastDailyLessonDate: data['lastDailyLessonDate']?.toString(),
        dob: resolvedDob,
        provider: resolvedProvider,
        lastDevice: resolvedLastDevice,
        appVersion: resolvedAppVersion,
        timezone: timezoneNow.timeZoneName,
        timezoneOffsetMinutes: timezoneNow.timeZoneOffset.inMinutes,
      );

      await doc.set({
        ...profile.toMap(),
        'lastLogin': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return;
    }

    await doc.set({
      ...metadata,
      'lastLogin': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  static Map<String, dynamic> _profileMetadataMap({
    required User user,
    required String? name,
    required String? photoUrl,
    required DateTime? dob,
    required String? provider,
    required String? lastDevice,
    required String? appVersion,
    required DateTime timezoneNow,
  }) {
    return {
      'uid': user.uid,
      'email': user.email,
      'name': name,
      'photoUrl': photoUrl,
      'provider': provider,
      'dob': dob != null ? Timestamp.fromDate(dob) : null,
      'lastDevice': lastDevice,
      'appVersion': appVersion,
      'timezone': timezoneNow.timeZoneName,
      'timezoneOffsetMinutes': timezoneNow.timeZoneOffset.inMinutes,
    };
  }

  static bool _hasCanonicalProfileShape(Map<String, dynamic> data) {
    return data.keys.toSet().containsAll(_requiredProfileKeys) &&
        data['joinedAt'] is Timestamp &&
        data['currentLesson'] is int &&
        data['currentLessonStepIndex'] is int &&
        data['xp'] is int &&
        data['lessonsCompleted'] is int &&
        data['todayLessonCount'] is int &&
        data['dailyStreak'] is int;
  }

  static int _readLegacyInt(dynamic value, {required int fallback}) {
    if (value is int) return value;
    return int.tryParse(value?.toString() ?? '') ?? fallback;
  }
}
