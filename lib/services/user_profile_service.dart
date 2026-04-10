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
    'age',
    'currentLesson',
    'currentLessonStepIndex',
    'xp',
    'level',
    'lessonsCompleted',
    'totalLearningSeconds',
    'todayLessonCount',
    'todayLessonCountDate',
    'dailyStreak',
    'lastDailyLessonDate',
    'activityStreak',
    'lastActivityDateKey',
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
    int? age,
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
    final resolvedAge = age ?? _readLegacyAge(data);

    final metadata = _profileMetadataMap(
      user: user,
      name: name ?? user.displayName ?? data?['name']?.toString(),
      photoUrl: resolvedPhotoUrl,
      age: resolvedAge,
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
        level: 1,
        lessonsCompleted: 0,
        totalLearningSeconds: 0,
        todayLessonCount: 0,
        todayLessonCountDate: null,
        dailyStreak: 0,
        lastDailyLessonDate: null,
        activityStreak: 0,
        lastActivityDateKey: null,
        age: resolvedAge,
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
        level: _levelFromXp(_readLegacyInt(data['xp'], fallback: 0)),
        lessonsCompleted: _readLegacyInt(data['lessonsCompleted'], fallback: 0),
        totalLearningSeconds:
            _readLegacyInt(data['totalLearningSeconds'], fallback: 0),
        todayLessonCount: _readLegacyInt(data['todayLessonCount'], fallback: 0),
        todayLessonCountDate: data['todayLessonCountDate']?.toString(),
        dailyStreak: _readLegacyInt(data['dailyStreak'], fallback: 0),
        lastDailyLessonDate: data['lastDailyLessonDate']?.toString(),
        activityStreak: _readLegacyInt(data['activityStreak'], fallback: 0),
        lastActivityDateKey: data['lastActivityDateKey']?.toString(),
        age: resolvedAge,
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
      'dob': FieldValue.delete(),
      'lastLogin': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  static Future<void> updateEditableProfile({
    required String? name,
    required int? age,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    await userDoc(user.uid).set({
      'name': name?.trim().isNotEmpty == true ? name!.trim() : null,
      'age': age,
      'dob': FieldValue.delete(),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  static Map<String, dynamic> _profileMetadataMap({
    required User user,
    required String? name,
    required String? photoUrl,
    required int? age,
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
      'age': age,
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
        data['level'] is int &&
        data['lessonsCompleted'] is int &&
        data['totalLearningSeconds'] is int &&
        data['todayLessonCount'] is int &&
        data['dailyStreak'] is int &&
        data['activityStreak'] is int &&
        (data['age'] == null || data['age'] is int);
  }

  static int _levelFromXp(int xp) {
    final safeXp = xp < 0 ? 0 : xp;
    return (safeXp ~/ 200) + 1;
  }

  static int _readLegacyInt(dynamic value, {required int fallback}) {
    if (value is int) return value;
    return int.tryParse(value?.toString() ?? '') ?? fallback;
  }

  static int? _readLegacyAge(Map<String, dynamic>? data) {
    if (data == null) return null;

    final ageValue = data['age'];
    if (ageValue is int) return ageValue;

    final parsedAge = int.tryParse(ageValue?.toString() ?? '');
    if (parsedAge != null) return parsedAge;

    final rawDob = data['dob'];
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
