import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart'; // CupertinoIcons.logo_apple
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:google_fonts/google_fonts.dart';
import 'package:running_robot/auth/start_button.dart'; // PillCta

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';

import 'auth_gate.dart'; // 🔹 For navigation after login
import 'signup_page.dart'; // ✅ Added import

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  // 🔹 Save/update Firestore user document
  Future<void> _onLoginSuccess(BuildContext context, User user) async {
    await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
      'uid': user.uid,
      'name': user.displayName,
      'email': user.email,
      'photoUrl': user.photoURL,
      'lastLogin': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    Navigator.of(context).pushAndRemoveUntil(
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => const AuthGate(),
        transitionsBuilder: (_, animation, __, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 300),
      ),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    const Color kBrandPurple = Color(0xFF7F56D9);

    final TextEditingController emailController = TextEditingController();
    final TextEditingController passwordController = TextEditingController();

    const double topOffset = 40;

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          automaticallyImplyLeading: true,
          iconTheme: const IconThemeData(color: Colors.black87),
        ),
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFFF3E9FF),
                Color(0xFFFFFFFF),
              ],
            ),
          ),
          child: SafeArea(
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
                          onTap: () async => await _signInWithGoogle(context),
                          child: _socialButtonGoogle(),
                        ),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: GestureDetector(
                          onTap: () async => await _signInWithFacebook(context),
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
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 18),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(
                          color: Color(0xFFCCCCCC),
                          width: 0.8,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(
                          color: Colors.black,
                          width: 1.4,
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
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 18),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(
                          color: Color(0xFFCCCCCC),
                          width: 0.8,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(
                          color: Colors.black,
                          width: 1.4,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // --- CTA ---
                  PillCta(
                    label: 'Log In',
                    padding: const EdgeInsets.symmetric(
                        horizontal: 150, vertical: 20),
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
                          Navigator.of(context).push(
                            PageRouteBuilder(
                              pageBuilder: (_, __, ___) => const SignupPage(),
                              transitionsBuilder: (_, animation, __, child) {
                                const begin = Offset(1.0, 0.0); // 👉 from right
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

  // --- Email login ---
  Future<void> _signInWithEmail(
      BuildContext context, String email, String password) async {
    try {
      final cred = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      await _onLoginSuccess(context, cred.user!);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Logged in with Email/Password')),
      );
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.message}')),
      );
    }
  }

  // --- Google login ---
  Future<void> _signInWithGoogle(BuildContext context) async {
    try {
      final GoogleSignIn gsi = GoogleSignIn.instance;
      await gsi.initialize();

      if (gsi.supportsAuthenticate()) {
        final GoogleSignInAccount account = await gsi.authenticate();
        final GoogleSignInAuthentication authTokens =
            await account.authentication;
        final String? idToken = authTokens.idToken;

        if (idToken == null) {
          throw FirebaseAuthException(
            code: 'NO_ID_TOKEN',
            message: 'Google sign-in did not return an idToken.',
          );
        }

        final OAuthCredential credential =
            GoogleAuthProvider.credential(idToken: idToken);

        final cred =
            await FirebaseAuth.instance.signInWithCredential(credential);
        await _onLoginSuccess(context, cred.user!);
      } else if (kIsWeb) {
        final cred =
            await FirebaseAuth.instance.signInWithPopup(GoogleAuthProvider());
        await _onLoginSuccess(context, cred.user!);
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

  // --- Facebook login ---
  Future<void> _signInWithFacebook(BuildContext context) async {
    try {
      final LoginResult result = await FacebookAuth.instance.login(
        permissions: ['email', 'public_profile'],
      );

      if (result.status == LoginStatus.success) {
        final accessToken = result.accessToken!;
        final credential =
            FacebookAuthProvider.credential(accessToken.tokenString);

        final cred =
            await FirebaseAuth.instance.signInWithCredential(credential);
        await _onLoginSuccess(context, cred.user!);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Logged in with Facebook')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Facebook login failed: ${result.message}')),
        );
      }
    } on FirebaseAuthException catch (e, st) {
      debugPrint("FirebaseAuthException: $e\n$st");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Firebase error: ${e.message}')),
      );
    } catch (e, st) {
      debugPrint("Generic Facebook login error: $e\n$st");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error during Facebook login: $e')),
      );
    }
  }
}
