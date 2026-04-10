import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:running_robot/services/app_progression_controller.dart';

class AuthVerificationStatus {
  final String provider;
  final bool requiresEmailOtp;
  final bool isVerified;
  final String? email;

  const AuthVerificationStatus({
    required this.provider,
    required this.requiresEmailOtp,
    required this.isVerified,
    required this.email,
  });
}

class AuthAccountService {
  static const String appVersion = '1.0.0+1';
  static final _functions = FirebaseFunctions.instance;

  static Future<void> sendPasswordResetEmail(String email) async {
    await FirebaseAuth.instance.sendPasswordResetEmail(email: email.trim());
  }

  static bool isValidEmailFormat(String email) {
    return RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(email.trim());
  }

  static String? validatePassword(String password) {
    final value = password.trim();
    if (value.length < 8) {
      return 'Password must be at least 8 characters.';
    }
    if (!RegExp(r'[A-Z]').hasMatch(value)) {
      return 'Password must include an uppercase letter.';
    }
    if (!RegExp(r'[a-z]').hasMatch(value)) {
      return 'Password must include a lowercase letter.';
    }
    if (!RegExp(r'[0-9]').hasMatch(value)) {
      return 'Password must include a number.';
    }
    return null;
  }

  static Future<AuthVerificationStatus> loadVerificationStatus(
    User user, {
    bool forceRefresh = false,
  }) async {
    if (forceRefresh) {
      await user.reload();
    }

    final refreshedUser = FirebaseAuth.instance.currentUser ?? user;
    final tokenResult = await refreshedUser.getIdTokenResult(forceRefresh);
    final provider =
        tokenResult.signInProvider ?? _providerIdForUser(refreshedUser);
    final requiresEmailOtp = provider == 'password';
    final verifiedByOtp = tokenResult.claims?['verified_email_otp'] == true;
    final isVerified =
        !requiresEmailOtp || refreshedUser.emailVerified || verifiedByOtp;

    return AuthVerificationStatus(
      provider: provider,
      requiresEmailOtp: requiresEmailOtp,
      isVerified: isVerified,
      email: refreshedUser.email,
    );
  }

  static Future<int> sendEmailOtp() async {
    final result = await _functions
        .httpsCallable(
          'sendEmailOtp',
          options: HttpsCallableOptions(
            timeout: const Duration(seconds: 20),
          ),
        )
        .call();

    final data = Map<String, dynamic>.from(result.data as Map);
    return _readInt(data['cooldownSeconds'], fallback: 60);
  }

  static Future<int> startSignupEmailOtp(String email) async {
    final result = await _functions
        .httpsCallable(
          'startSignupEmailOtp',
          options: HttpsCallableOptions(
            timeout: const Duration(seconds: 20),
          ),
        )
        .call({
      'email': email.trim(),
    });

    final data = Map<String, dynamic>.from(result.data as Map);
    return _readInt(data['cooldownSeconds'], fallback: 60);
  }

  static Future<void> verifyEmailOtp(String code) async {
    await _functions
        .httpsCallable(
      'verifyEmailOtp',
      options: HttpsCallableOptions(
        timeout: const Duration(seconds: 20),
      ),
    )
        .call({
      'code': code.trim(),
    });

    await FirebaseAuth.instance.currentUser?.getIdToken(true);
    await FirebaseAuth.instance.currentUser?.reload();
  }

  static Future<String> verifySignupEmailOtp({
    required String email,
    required String code,
  }) async {
    final result = await _functions
        .httpsCallable(
          'verifySignupEmailOtp',
          options: HttpsCallableOptions(
            timeout: const Duration(seconds: 20),
          ),
        )
        .call({
      'email': email.trim(),
      'code': code.trim(),
    });

    final data = Map<String, dynamic>.from(result.data as Map);
    return data['verificationToken']?.toString() ?? '';
  }

  static Future<void> claimVerifiedSignupEmail(
    String verificationToken,
  ) async {
    await _functions
        .httpsCallable(
          'claimVerifiedSignupEmail',
          options: HttpsCallableOptions(
            timeout: const Duration(seconds: 20),
          ),
        )
        .call({
      'verificationToken': verificationToken,
    });

    await FirebaseAuth.instance.currentUser?.getIdToken(true);
    await FirebaseAuth.instance.currentUser?.reload();
  }

  static Future<void> signOut() async {
    try {
      await GoogleSignIn.instance.signOut();
    } catch (_) {
      // Ignore if Google was not active on this device/session.
    }

    try {
      await FacebookAuth.instance.logOut();
    } catch (_) {
      // Ignore if Facebook was not active/configured for this session.
    }

    await FirebaseAuth.instance.signOut();
    AppProgressionController.instance.clear();
  }

  static bool supportsPasswordReset(String? provider) {
    return provider == 'password';
  }

  static String maskEmail(String? email) {
    final normalized = email?.trim() ?? '';
    final parts = normalized.split('@');
    if (parts.length != 2) return normalized;

    final local = parts[0];
    final domain = parts[1];
    if (local.length <= 2) {
      return '${local.isEmpty ? '*' : local[0]}***@$domain';
    }

    return '${local[0]}***${local[local.length - 1]}@$domain';
  }

  static String providerLabel(String? provider) {
    switch (provider) {
      case 'password':
        return 'Email & Password';
      case 'google':
      case 'google.com':
        return 'Google';
      case 'facebook':
      case 'facebook.com':
        return 'Facebook';
      default:
        return 'Unknown';
    }
  }

  static String _providerIdForUser(User user) {
    if (user.providerData.isEmpty) {
      return 'unknown';
    }

    return user.providerData.first.providerId;
  }

  static int _readInt(dynamic value, {required int fallback}) {
    if (value is int) return value;
    return int.tryParse(value?.toString() ?? '') ?? fallback;
  }
}
