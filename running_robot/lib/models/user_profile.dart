// FILE: lib/models/user_profile.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class UserProfile {
  final String uid;
  final String? name;
  final String? email;
  final String? photoUrl;
  final DateTime joinedAt;
  final String? currentLesson;
  final int streak;
  final int xp;
  final DateTime? dob;
  final String? provider; // ✅ NEW
  final String? lastDevice; // ✅ NEW
  final String? appVersion; // ✅ NEW

  UserProfile({
    required this.uid,
    this.name,
    this.email,
    this.photoUrl,
    required this.joinedAt,
    this.currentLesson,
    this.streak = 0,
    this.xp = 0,
    this.dob,
    this.provider,
    this.lastDevice,
    this.appVersion,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'photoUrl': photoUrl,
      'joinedAt': Timestamp.fromDate(joinedAt),
      'currentLesson': currentLesson,
      'streak': streak,
      'xp': xp,
      'dob': dob != null ? Timestamp.fromDate(dob!) : null,
      'provider': provider,
      'lastDevice': lastDevice,
      'appVersion': appVersion,
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
      currentLesson: map['currentLesson'],
      streak: map['streak'] ?? 0,
      xp: map['xp'] ?? 0,
      dob: map['dob'] != null
          ? (map['dob'] is Timestamp
              ? (map['dob'] as Timestamp).toDate()
              : DateTime.tryParse(map['dob'].toString()))
          : null,
      provider: map['provider'],
      lastDevice: map['lastDevice'],
      appVersion: map['appVersion'],
    );
  }
}
