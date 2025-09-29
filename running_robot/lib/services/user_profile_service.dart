import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:running_robot/models/user_profile.dart';

class UserProfileService {
  static Future<void> createOrUpdateUserProfile(
    User user, {
    String? name,
    DateTime? dob,
    String? provider, // ✅ NEW (explicit override)
    String? lastDevice, // ✅ NEW
    String? appVersion, // ✅ NEW
  }) async {
    final doc = FirebaseFirestore.instance.collection('users').doc(user.uid);
    final snapshot = await doc.get();
    final data = snapshot.data();

    // Preserve joinedAt if exists
    DateTime existingJoinedAt = DateTime.now();
    if (data != null && data['joinedAt'] != null) {
      if (data['joinedAt'] is Timestamp) {
        existingJoinedAt = (data['joinedAt'] as Timestamp).toDate();
      } else {
        existingJoinedAt =
            DateTime.tryParse(data['joinedAt'].toString()) ?? DateTime.now();
      }
    }

    final profile = UserProfile(
      uid: user.uid,
      email: user.email,
      name: name ?? user.displayName,
      photoUrl: user.photoURL,
      joinedAt: existingJoinedAt,
      streak: data != null ? (data['streak'] ?? 0) : 0,
      xp: data != null ? (data['xp'] ?? 0) : 0,
      dob: dob ??
          (data != null && data['dob'] != null
              ? (data['dob'] is Timestamp
                  ? (data['dob'] as Timestamp).toDate()
                  : DateTime.tryParse(data['dob'].toString()))
              : null),
      provider: provider ??
          (user.providerData.isNotEmpty
              ? user.providerData.first.providerId
              : "unknown"),
      lastDevice: lastDevice,
      appVersion: appVersion,
    );

    await doc.set({
      ...profile.toMap(),
      'lastLogin': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }
}
