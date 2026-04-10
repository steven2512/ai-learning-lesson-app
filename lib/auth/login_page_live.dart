import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:running_robot/auth/auth_gate.dart';
import 'package:running_robot/auth/signup_page_live.dart';
import 'package:running_robot/auth/start_button.dart';
import 'package:running_robot/services/auth_account_service.dart';
import 'package:running_robot/services/user_profile_service.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
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

  Future<void> _onLoginSuccess(User user, {required String provider}) async {
    try {
      await UserProfileService.createOrUpdateUserProfile(
        user,
        lastDevice: _detectPlatform(context),
        appVersion: AuthAccountService.appVersion,
        provider: provider,
      );
    } catch (error) {
      debugPrint('Profile sync failed after sign-in: $error');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Signed in. Finishing profile sync in the background...',
            ),
          ),
        );
      }
    }

    if (!mounted) return;

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

  Future<void> _signInWithEmail() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      _showSnackBar('Enter both email and password.');
      return;
    }

    if (!AuthAccountService.isValidEmailFormat(email)) {
      _showSnackBar('Enter a valid email address.');
      return;
    }

    await _runAuthAction(() async {
      try {
        final cred = await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: email,
          password: password,
        );
        await _onLoginSuccess(cred.user!, provider: 'password');
      } on FirebaseAuthException catch (e) {
        _showSnackBar(e.message ?? 'Unable to sign in right now.');
      }
    });
  }

  Future<void> _signInWithGoogle() async {
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
          await _onLoginSuccess(cred.user!, provider: 'google');
          return;
        }

        if (kIsWeb) {
          final cred =
              await FirebaseAuth.instance.signInWithPopup(GoogleAuthProvider());
          await _onLoginSuccess(cred.user!, provider: 'google');
          return;
        }

        throw FirebaseAuthException(
          code: 'UNSUPPORTED_PLATFORM',
          message: 'Google sign-in is not supported on this platform.',
        );
      } catch (e) {
        _showSnackBar('Google sign-in failed: $e');
      }
    });
  }

  Future<void> _signInWithFacebook() async {
    await _runAuthAction(() async {
      try {
        final result = await FacebookAuth.instance.login(
          permissions: ['email', 'public_profile'],
        );
        if (result.status != LoginStatus.success) {
          _showSnackBar(
            'Facebook login failed: ${result.message ?? 'Try again later.'}',
          );
          return;
        }

        final cred = await FirebaseAuth.instance.signInWithCredential(
          FacebookAuthProvider.credential(result.accessToken!.tokenString),
        );
        await _onLoginSuccess(cred.user!, provider: 'facebook');
      } catch (e) {
        _showSnackBar('Facebook error: $e');
      }
    });
  }

  Future<void> _showForgotPasswordDialog() async {
    final TextEditingController emailController = TextEditingController(
      text: _emailController.text.trim(),
    );
    bool isSending = false;

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            Future<void> sendReset() async {
              final email = emailController.text.trim();
              if (email.isEmpty) {
                ScaffoldMessenger.of(dialogContext).showSnackBar(
                  const SnackBar(content: Text('Enter your email first.')),
                );
                return;
              }

              if (!AuthAccountService.isValidEmailFormat(email)) {
                ScaffoldMessenger.of(dialogContext).showSnackBar(
                  const SnackBar(
                    content: Text('Enter a valid email address.'),
                  ),
                );
                return;
              }

              setDialogState(() => isSending = true);
              try {
                await AuthAccountService.sendPasswordResetEmail(email);
                if (!dialogContext.mounted) return;
                Navigator.of(dialogContext).pop();
                _showSnackBar('Password reset email sent.');
              } on FirebaseAuthException catch (e) {
                ScaffoldMessenger.of(dialogContext).showSnackBar(
                  SnackBar(
                    content: Text(
                        e.message ?? 'Unable to send reset email right now.'),
                  ),
                );
              } finally {
                if (dialogContext.mounted) {
                  setDialogState(() => isSending = false);
                }
              }
            }

            return AlertDialog(
              title: const Text('Reset Password'),
              content: TextField(
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  hintText: 'Email address',
                ),
              ),
              actions: [
                TextButton(
                  onPressed: isSending
                      ? null
                      : () => Navigator.of(dialogContext).pop(),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: isSending ? null : sendReset,
                  child: Text(isSending ? 'Sending...' : 'Send Reset Link'),
                ),
              ],
            );
          },
        );
      },
    );

    emailController.dispose();
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

  String _detectPlatform(BuildContext context) {
    if (Theme.of(context).platform == TargetPlatform.iOS) return 'ios';
    if (Theme.of(context).platform == TargetPlatform.android) return 'android';
    return 'web';
  }

  @override
  Widget build(BuildContext context) {
    const Color kBrandPurple = Color(0xFF7F56D9);
    final overlay = const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarIconBrightness: Brightness.dark,
    );

    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: overlay,
      child: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Scaffold(
          backgroundColor: Colors.transparent,
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
                  padding:
                      const EdgeInsets.symmetric(horizontal: 28, vertical: 40),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 40),
                      Center(
                        child: Text(
                          'Sign in',
                          style: GoogleFonts.lato(
                            fontSize: 36,
                            fontWeight: FontWeight.w800,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),
                      Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: _isSubmitting ? null : _signInWithGoogle,
                              child: Opacity(
                                opacity: _isSubmitting ? 0.55 : 1,
                                child: _socialButtonGoogle(),
                              ),
                            ),
                          ),
                          const SizedBox(width: 20),
                          Expanded(
                            child: GestureDetector(
                              onTap: _isSubmitting ? null : _signInWithFacebook,
                              child: Opacity(
                                opacity: _isSubmitting ? 0.55 : 1,
                                child: _socialButtonFacebook(),
                              ),
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
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: _inputDecoration('Email'),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _passwordController,
                        obscureText: true,
                        decoration: _inputDecoration('Password'),
                      ),
                      const SizedBox(height: 24),
                      PillCta(
                        label: _isSubmitting ? 'Working...' : 'Log In',
                        color: kBrandPurple,
                        onTap: () {
                          if (_isSubmitting) return;
                          _signInWithEmail();
                        },
                      ),
                      const SizedBox(height: 16),
                      Center(
                        child: TextButton(
                          onPressed:
                              _isSubmitting ? null : _showForgotPasswordDialog,
                          child: Text(
                            'Forgot Password?',
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
                            "Don't have an account?",
                            style: GoogleFonts.lato(
                              color: Colors.black54,
                              fontSize: 16,
                            ),
                          ),
                          TextButton(
                            onPressed: _isSubmitting
                                ? null
                                : () {
                                    Navigator.of(context).push(
                                      PageRouteBuilder(
                                        pageBuilder: (_, __, ___) =>
                                            const SignupPage(),
                                        transitionsBuilder:
                                            (_, animation, __, child) {
                                          const begin = Offset(1.0, 0.0);
                                          const end = Offset.zero;
                                          const curve = Curves.easeInOut;
                                          final tween =
                                              Tween(begin: begin, end: end)
                                                  .chain(
                                            CurveTween(curve: curve),
                                          );
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
                              'Sign Up',
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
