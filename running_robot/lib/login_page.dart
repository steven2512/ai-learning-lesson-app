// lib/ui/login_page.dart

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart'; // CupertinoIcons.logo_apple
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:google_fonts/google_fonts.dart';
import 'package:running_robot/start_button.dart'; // PillCta

import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    const Color kBrandPurple = Color(0xFF7F56D9);
    const Color kDarkNavy = Color.fromARGB(255, 87, 87, 87);

    final TextEditingController emailController = TextEditingController();
    final TextEditingController passwordController = TextEditingController();

    const double topOffset = 60;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(height: topOffset),

              // --- Big Header ---
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

              // --- Social Icons Row (Google + Facebook) ---
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () async {
                        await _signInWithGoogle(context);
                      },
                      child: _socialButtonGoogle(),
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: GestureDetector(
                      onTap: () async {
                        await _signInWithFacebook(context);
                      },
                      child: _socialButtonFacebook(),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // --- Divider ---
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

              // --- Email ---
              TextField(
                controller: emailController,
                decoration: InputDecoration(
                  hintText: 'Email',
                  hintStyle: GoogleFonts.lato(color: Colors.black45),
                  filled: true,
                  fillColor: Colors.grey.shade100,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: Colors.transparent),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(
                      color: kDarkNavy,
                      width: 2,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // --- Password ---
              TextField(
                controller: passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  hintText: 'Password',
                  hintStyle: GoogleFonts.lato(color: Colors.black45),
                  filled: true,
                  fillColor: Colors.grey.shade100,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: Colors.transparent),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(
                      color: kDarkNavy,
                      width: 2,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // --- CTA ---
              PillCta(
                label: 'Log In',
                padding:
                    const EdgeInsets.symmetric(horizontal: 150, vertical: 20),
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

              // --- Forgot Password ---
              Center(
                child: TextButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Forgot password tapped')),
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

              // --- Sign Up Prompt ---
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
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Sign up tapped')),
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
    );
  }

  // --- Google Button ---
  Widget _socialButtonGoogle() {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black, width: 1),
        color: Colors.white,
      ),
      child: Center(
        child: Image.asset(
          'assets/images/google_icon.png',
          height: 28,
        ),
      ),
    );
  }

  // --- Facebook Button ---
  Widget _socialButtonFacebook() {
    return Container(
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
  }

  // --- Firebase Email/Password login ---
  Future<void> _signInWithEmail(
      BuildContext context, String email, String password) async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Logged in with Email/Password')),
      );
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.message}')),
      );
    }
  }

  // --- Google sign-in (google_sign_in 7.x) ---
  Future<void> _signInWithGoogle(BuildContext context) async {
    try {
      final GoogleSignIn gsi = GoogleSignIn.instance;
      await gsi.initialize();

      if (gsi.supportsAuthenticate()) {
        final GoogleSignInAccount account = await gsi.authenticate();
        final GoogleSignInAuthentication authTokens = account.authentication;
        final String? idToken = authTokens.idToken;

        if (idToken == null) {
          throw FirebaseAuthException(
            code: 'NO_ID_TOKEN',
            message: 'Google sign-in did not return an idToken.',
          );
        }

        final OAuthCredential credential =
            GoogleAuthProvider.credential(idToken: idToken);

        await FirebaseAuth.instance.signInWithCredential(credential);
      } else if (kIsWeb) {
        await FirebaseAuth.instance.signInWithPopup(GoogleAuthProvider());
      } else {
        throw FirebaseAuthException(
          code: 'UNSUPPORTED_PLATFORM',
          message:
              'GoogleSignIn.authenticate() not supported on this platform.',
        );
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Logged in with Google')),
      );
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Google sign-in error: ${e.message}')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Google sign-in failed: $e')),
      );
    }
  }

  // --- Facebook sign-in ---
  Future<void> _signInWithFacebook(BuildContext context) async {
    try {
      final LoginResult result = await FacebookAuth.instance.login(
        permissions: ['email', 'public_profile'],
      );

      print("Facebook login result: ${result.status} ${result.message}");

      if (result.status == LoginStatus.success) {
        final accessToken = result.accessToken!;
        print("Got FB access token: ${accessToken.tokenString}");

        final credential =
            FacebookAuthProvider.credential(accessToken.tokenString);
        await FirebaseAuth.instance.signInWithCredential(credential);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Logged in with Facebook')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Facebook login failed: ${result.message}')),
        );
      }
    } on FirebaseAuthException catch (e, st) {
      print("FirebaseAuthException: $e\n$st");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Firebase error: ${e.message}')),
      );
    } catch (e, st) {
      print("Generic Facebook login error: $e\n$st");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error during Facebook login: $e')),
      );
    }
  }

  // --- Apple sign-in (if you plan to support later) ---
  Future<void> _signInWithApple(BuildContext context) async {
    try {
      final apple = AppleAuthProvider()
        ..addScope('email')
        ..addScope('name');

      if (kIsWeb) {
        await FirebaseAuth.instance.signInWithPopup(apple);
      } else {
        await FirebaseAuth.instance.signInWithProvider(apple);
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Logged in with Apple')),
      );
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Apple sign-in error: ${e.message}')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Apple sign-in failed: $e')),
      );
    }
  }
}
