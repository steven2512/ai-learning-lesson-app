import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:running_robot/auth/auth_gate.dart';
import 'package:running_robot/auth/sign_up_flow_live.dart';
import 'package:running_robot/auth/start_button.dart';
import 'package:running_robot/services/auth_account_service.dart';
import 'package:running_robot/services/user_profile_service.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final TextEditingController _emailController = TextEditingController();
  String? _emailError;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(email);
  }

  Future<void> _runAuthAction(Future<void> Function() action) async {
    if (_isSubmitting) return;

    setState(() => _isSubmitting = true);
    try {
      await action();
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  Future<void> _onSignupSuccess(User user, {required String provider}) async {
    await UserProfileService.createOrUpdateUserProfile(
      user,
      provider: provider,
      lastDevice: _detectPlatform(context),
      appVersion: AuthAccountService.appVersion,
    );

    if (!mounted) return;

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const AuthGate()),
      (route) => false,
    );
  }

  Future<void> _signUpWithGoogle() async {
    await _runAuthAction(() async {
      try {
        final GoogleSignIn gsi = GoogleSignIn.instance;
        await gsi.initialize();

        if (gsi.supportsAuthenticate()) {
          final account = await gsi.authenticate();
          final authTokens = account.authentication;
          final String? idToken = authTokens.idToken;

          if (idToken == null) {
            throw FirebaseAuthException(
              code: 'NO_ID_TOKEN',
              message: 'Google sign-in did not return an id token.',
            );
          }

          final cred = await FirebaseAuth.instance.signInWithCredential(
            GoogleAuthProvider.credential(idToken: idToken),
          );
          await _onSignupSuccess(cred.user!, provider: 'google');
          return;
        }

        if (kIsWeb) {
          final cred =
              await FirebaseAuth.instance.signInWithPopup(GoogleAuthProvider());
          await _onSignupSuccess(cred.user!, provider: 'google');
        }
      } catch (e) {
        _showSnackBar('Google sign-up failed: $e');
      }
    });
  }

  Future<void> _signUpWithFacebook() async {
    await _runAuthAction(() async {
      try {
        final result = await FacebookAuth.instance.login(
          permissions: ['email', 'public_profile'],
        );
        if (result.status != LoginStatus.success) {
          _showSnackBar(
            'Facebook sign-up failed: ${result.message ?? 'Try again later.'}',
          );
          return;
        }

        final cred = await FirebaseAuth.instance.signInWithCredential(
          FacebookAuthProvider.credential(result.accessToken!.tokenString),
        );
        await _onSignupSuccess(cred.user!, provider: 'facebook');
      } catch (e) {
        _showSnackBar('Facebook error: $e');
      }
    });
  }

  void _showSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
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

  String _detectPlatform(BuildContext context) {
    if (Theme.of(context).platform == TargetPlatform.iOS) return 'ios';
    if (Theme.of(context).platform == TargetPlatform.android) return 'android';
    return 'web';
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    final overlay = const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarIconBrightness: Brightness.dark,
    );

    const Color kBrandPurple = Color(0xFF7F56D9);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: overlay,
      child: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Scaffold(
          backgroundColor: Colors.transparent,
          resizeToAvoidBottomInset: true,
          extendBodyBehindAppBar: true,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            scrolledUnderElevation: 0,
            surfaceTintColor: Colors.transparent,
            automaticallyImplyLeading: true,
            iconTheme: const IconThemeData(color: Colors.black87),
            systemOverlayStyle: overlay,
          ),
          body: Stack(
            children: [
              const _GradientBackground(),
              SafeArea(
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
                              'Sign Up',
                              style: GoogleFonts.lato(
                                fontSize: 36,
                                fontWeight: FontWeight.w900,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Start learning AI today',
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
                      GestureDetector(
                        onTap: _isSubmitting ? null : _signUpWithGoogle,
                        child: Opacity(
                          opacity: _isSubmitting ? 0.55 : 1,
                          child: _socialButton(
                            icon: Image.asset(
                              'assets/images/google_icon.png',
                              height: 32,
                            ),
                            text: 'Continue with Google',
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      GestureDetector(
                        onTap: _isSubmitting ? null : _signUpWithFacebook,
                        child: Opacity(
                          opacity: _isSubmitting ? 0.55 : 1,
                          child: _socialButton(
                            icon: const Icon(
                              Icons.facebook,
                              color: Color(0xFF1877F2),
                              size: 34,
                            ),
                            text: 'Continue with Facebook',
                          ),
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
                            _emailError = value.isEmpty || _isValidEmail(value)
                                ? null
                                : 'Invalid email format';
                          });
                        },
                        keyboardType: TextInputType.emailAddress,
                        decoration: _inputDecoration('Enter your email'),
                      ),
                      const SizedBox(height: 20),
                      PillCta(
                        label: _isSubmitting ? 'Working...' : 'Continue',
                        color: kBrandPurple,
                        expand: true,
                        fontSize: 20,
                        onTap: () {
                          if (_isSubmitting) return;

                          final email = _emailController.text.trim();
                          if (email.isEmpty || !_isValidEmail(email)) {
                            setState(() {
                              _emailError = 'Invalid email format';
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
                                final tween = Tween(begin: begin, end: end)
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
            ],
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
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 6,
            offset: Offset(0, 3),
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
}

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
