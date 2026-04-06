import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:running_robot/services/app_progression_controller.dart';

class AuthAccountService {
  static const String appVersion = '1.0.0+1';

  static Future<void> sendPasswordResetEmail(String email) async {
    await FirebaseAuth.instance.sendPasswordResetEmail(email: email.trim());
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
}
