import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:google_fonts/google_fonts.dart';
import 'package:running_robot/auth/start_button.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:running_robot/services/user_profile_service.dart';
import 'auth_gate.dart';
import 'signup_page.dart';
import 'package:flutter/services.dart'; // ★ CHANGED: for system UI styling

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  Future<void> _onLoginSuccess(
    BuildContext context,
    User user, {
    required String provider,
  }) async {
    await UserProfileService.createOrUpdateUserProfile(
      user,
      lastDevice: _detectPlatform(context), // ✅ track platform
      appVersion: "1.0.0+1", // ✅ replace with package_info_plus later
      provider: provider, // ✅ google / facebook / password
    );

    Navigator.of(context).pushAndRemoveUntil(
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => const AuthGate(),
        transitionsBuilder: (_, animation, __, child) =>
            FadeTransition(opacity: animation, child: child),
        transitionDuration: const Duration(milliseconds: 300),
      ),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    const Color kBrandPurple = Color(0xFF7F56D9);
    final TextEditingController emailController = TextEditingController();
    final TextEditingController passwordController = TextEditingController();

    // ★ CHANGED: go fully edge-to-edge and make system bars transparent
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    final overlay = const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent, // no top scrim
      statusBarIconBrightness: Brightness.dark, // Android icons
      statusBarBrightness: Brightness.light, // iOS text
      systemNavigationBarColor: Colors.transparent, // clean bottom bar
      systemNavigationBarIconBrightness: Brightness.dark,
    );

    return AnnotatedRegion<SystemUiOverlayStyle>(
      // ★ CHANGED
      value: overlay,
      child: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Scaffold(
          backgroundColor: Colors.transparent, // ★ CHANGED: avoid white flashes
          extendBodyBehindAppBar: true, // ★ CHANGED: draw under status bar
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            scrolledUnderElevation: 0, // ★ CHANGED: kill M3 tint
            surfaceTintColor: Colors.transparent, // ★ CHANGED
            automaticallyImplyLeading: true,
            iconTheme: const IconThemeData(color: Colors.black87),
            systemOverlayStyle: overlay, // ★ CHANGED: enforce per-page
          ),
          body: Stack(
            // ★ CHANGED: stack gradient behind content
            children: [
              const _GradientBackground(), // ★ CHANGED: full-screen gradient
              SafeArea(
                child: SingleChildScrollView(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 28, vertical: 40),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 40),
                      Center(
                        child: Text(
                          "Sign in",
                          style: GoogleFonts.lato(
                            fontSize: 36,
                            fontWeight: FontWeight.w800,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Social buttons
                      Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () async =>
                                  await _signInWithGoogle(context),
                              child: _socialButtonGoogle(),
                            ),
                          ),
                          const SizedBox(width: 20),
                          Expanded(
                            child: GestureDetector(
                              onTap: () async =>
                                  await _signInWithFacebook(context),
                              child: _socialButtonFacebook(),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      Row(
                        children: [
                          const Expanded(child: Divider(thickness: .6)),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            child: Text(
                              'Or sign in with',
                              style: GoogleFonts.lato(color: Colors.black54),
                            ),
                          ),
                          const Expanded(child: Divider(thickness: .6)),
                        ],
                      ),
                      const SizedBox(height: 28),

                      TextField(
                        controller: emailController,
                        decoration: _inputDecoration("Email"),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: passwordController,
                        obscureText: true,
                        decoration: _inputDecoration("Password"),
                      ),
                      const SizedBox(height: 24),

                      PillCta(
                        label: 'Log In',
                        color: kBrandPurple,
                        onTap: () async {
                          await _signInWithEmail(
                            context,
                            emailController.text.trim(),
                            passwordController.text.trim(),
                          );
                        },
                      ),
                      const SizedBox(height: 16),

                      Center(
                        child: TextButton(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text('Forgot password tapped')),
                            );
                          },
                          child: Text(
                            "Forgot Password?",
                            style: GoogleFonts.lato(
                              color: kBrandPurple,
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Don’t have an account?",
                            style: GoogleFonts.lato(
                              color: Colors.black54,
                              fontSize: 16,
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).push(
                                PageRouteBuilder(
                                  pageBuilder: (_, __, ___) =>
                                      const SignupPage(),
                                  transitionsBuilder:
                                      (_, animation, __, child) {
                                    const begin = Offset(1.0, 0.0);
                                    const end = Offset.zero;
                                    const curve = Curves.easeInOut;
                                    final tween = Tween(begin: begin, end: end)
                                        .chain(CurveTween(curve: curve));
                                    return SlideTransition(
                                      position: animation.drive(tween),
                                      child: child,
                                    );
                                  },
                                  transitionDuration:
                                      const Duration(milliseconds: 400),
                                ),
                              );
                            },
                            child: Text(
                              "Sign Up",
                              style: GoogleFonts.lato(
                                color: kBrandPurple,
                                fontWeight: FontWeight.w700,
                                fontSize: 18,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) => InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.lato(color: Colors.black45),
        filled: true,
        fillColor: Colors.grey.shade100,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFFCCCCCC), width: 0.8),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Colors.black, width: 1.4),
        ),
      );

  Widget _socialButtonGoogle() => Container(
        height: 56,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.black, width: 1),
          color: Colors.white,
        ),
        child: Center(
          child: Image.asset('assets/images/google_icon.png', height: 28),
        ),
      );

  Widget _socialButtonFacebook() => Container(
        height: 56,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.black, width: 1),
          color: Colors.white,
        ),
        child: const Center(
          child: Icon(Icons.facebook, size: 32, color: Color(0xFF1877F2)),
        ),
      );

  Future<void> _signInWithEmail(
      BuildContext context, String email, String password) async {
    try {
      final cred = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);
      await _onLoginSuccess(context, cred.user!, provider: "password");
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.message}')),
      );
    }
  }

  Future<void> _signInWithGoogle(BuildContext context) async {
    try {
      final GoogleSignIn gsi = GoogleSignIn.instance;
      await gsi.initialize();

      if (gsi.supportsAuthenticate()) {
        final account = await gsi.authenticate();
        final authTokens = await account.authentication;
        final String? idToken = authTokens.idToken;

        if (idToken == null) {
          throw FirebaseAuthException(
            code: 'NO_ID_TOKEN',
            message: 'Google sign-in did not return an idToken.',
          );
        }

        final cred = await FirebaseAuth.instance.signInWithCredential(
            GoogleAuthProvider.credential(idToken: idToken));
        await _onLoginSuccess(context, cred.user!, provider: "google");
      } else if (kIsWeb) {
        final cred =
            await FirebaseAuth.instance.signInWithPopup(GoogleAuthProvider());
        await _onLoginSuccess(context, cred.user!, provider: "google");
      } else {
        throw FirebaseAuthException(
          code: 'UNSUPPORTED_PLATFORM',
          message:
              'GoogleSignIn.authenticate() not supported on this platform.',
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Google sign-in failed: $e')),
      );
    }
  }

  Future<void> _signInWithFacebook(BuildContext context) async {
    try {
      final result = await FacebookAuth.instance
          .login(permissions: ['email', 'public_profile']);
      if (result.status == LoginStatus.success) {
        final cred = await FirebaseAuth.instance.signInWithCredential(
          FacebookAuthProvider.credential(result.accessToken!.tokenString),
        );
        await _onLoginSuccess(context, cred.user!, provider: "facebook");
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Facebook login failed: ${result.message}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Facebook error: $e')),
      );
    }
  }

  // ✅ Helper to detect device platform
  String _detectPlatform(BuildContext context) {
    if (Theme.of(context).platform == TargetPlatform.iOS) return "ios";
    if (Theme.of(context).platform == TargetPlatform.android) return "android";
    return "web";
  }
}

// ★ CHANGED: dedicated background to ensure full-bleed gradient
class _GradientBackground extends StatelessWidget {
  const _GradientBackground();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFF3E9FF), Color(0xFFFFFFFF)],
        ),
      ),
    );
  }
}
