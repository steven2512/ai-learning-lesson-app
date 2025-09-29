import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:running_robot/auth/sign_up_flow.dart';
import 'package:running_robot/auth/start_button.dart';
import 'package:running_robot/services/user_profile_service.dart';
import 'auth_gate.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final TextEditingController _emailController = TextEditingController();
  String? _emailError;

  bool _isValidEmail(String email) =>
      RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(email);

  Future<void> _onLoginSuccess(
    BuildContext context,
    User user, {
    required String provider,
  }) async {
    await UserProfileService.createOrUpdateUserProfile(
      user,
      provider: provider, // ✅ track signup method
      lastDevice: _detectPlatform(context), // ✅ iOS/Android/Web
      appVersion: "1.0.0+1", // ✅ replace with package_info_plus
    );

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const AuthGate()),
      (route) => false,
    );
  }

  Future<void> _signUpWithGoogle(BuildContext context) async {
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
          GoogleAuthProvider.credential(idToken: idToken),
        );
        await _onLoginSuccess(context, cred.user!, provider: "google");
      } else if (kIsWeb) {
        final cred =
            await FirebaseAuth.instance.signInWithPopup(GoogleAuthProvider());
        await _onLoginSuccess(context, cred.user!, provider: "google");
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Google sign-up failed: $e')),
      );
    }
  }

  Future<void> _signUpWithFacebook(BuildContext context) async {
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
          SnackBar(content: Text('Facebook sign-up failed: ${result.message}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Facebook error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color kBrandPurple = Color(0xFF7F56D9);

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          automaticallyImplyLeading: true,
          iconTheme: const IconThemeData(color: Colors.black87),
        ),
        extendBodyBehindAppBar: true,
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFFF3E9FF), Color(0xFFFFFFFF)],
            ),
          ),
          child: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(28, 20, 28, 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 70),
                  Center(
                    child: Column(
                      children: [
                        Text(
                          "Sign Up",
                          style: GoogleFonts.lato(
                            fontSize: 36,
                            fontWeight: FontWeight.w900,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "Start learning AI today✨",
                          style: GoogleFonts.lato(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.black54,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),

                  // Google
                  GestureDetector(
                    onTap: () => _signUpWithGoogle(context),
                    child: _socialButton(
                      icon: Image.asset('assets/images/google_icon.png',
                          height: 32),
                      text: "Continue with Google",
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Facebook
                  GestureDetector(
                    onTap: () => _signUpWithFacebook(context),
                    child: _socialButton(
                      icon: const Icon(Icons.facebook,
                          color: Color(0xFF1877F2), size: 34),
                      text: "Continue with Facebook",
                    ),
                  ),
                  const SizedBox(height: 38),

                  Row(
                    children: [
                      const Expanded(child: Divider(thickness: .6)),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Text(
                          'or continue with',
                          style: GoogleFonts.lato(
                            color: Colors.black54,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const Expanded(child: Divider(thickness: .6)),
                    ],
                  ),
                  const SizedBox(height: 28),

                  TextField(
                    controller: _emailController,
                    onChanged: (value) {
                      setState(() {
                        if (value.isEmpty || _isValidEmail(value)) {
                          _emailError = null;
                        } else {
                          _emailError = "Invalid email format";
                        }
                      });
                    },
                    decoration: _inputDecoration("Enter your email"),
                  ),
                  const SizedBox(height: 20),

                  PillCta(
                    label: "Continue",
                    color: kBrandPurple,
                    expand: true,
                    fontSize: 20,
                    onTap: () {
                      final email = _emailController.text.trim();
                      if (email.isEmpty || !_isValidEmail(email)) {
                        setState(() {
                          _emailError = "Invalid email format";
                        });
                        return;
                      }
                      Navigator.of(context).push(
                        PageRouteBuilder(
                          pageBuilder: (_, __, ___) =>
                              SignupFlow(initialEmail: email),
                          transitionsBuilder: (_, animation, __, child) {
                            const begin = Offset(1.0, 0.0);
                            const end = Offset.zero;
                            const curve = Curves.easeInOut;
                            var tween = Tween(begin: begin, end: end)
                                .chain(CurveTween(curve: curve));
                            return SlideTransition(
                              position: animation.drive(tween),
                              child: child,
                            );
                          },
                        ),
                      );
                    },
                  ),

                  if (_emailError != null) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.red.shade300,
                          width: 1.2,
                        ),
                      ),
                      child: Text(
                        _emailError!,
                        style: GoogleFonts.lato(
                          color: Colors.red.shade700,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _socialButton({required Widget icon, required String text}) {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          icon,
          const SizedBox(width: 12),
          Text(
            text,
            style: GoogleFonts.lato(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: Colors.black87,
            ),
          ),
        ],
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

  // ✅ Detect platform for lastDevice
  String _detectPlatform(BuildContext context) {
    if (Theme.of(context).platform == TargetPlatform.iOS) return "ios";
    if (Theme.of(context).platform == TargetPlatform.android) return "android";
    return "web";
  }
}
