import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:running_robot/auth/sign_up_flow.dart';
import 'package:running_robot/auth/start_button.dart'; // ✅ your PillCta

import 'auth_gate.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final TextEditingController _emailController = TextEditingController();
  String? _emailError;

  bool _isValidEmail(String email) {
    return RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(email);
  }

  Future<void> _onLoginSuccess(BuildContext context, User user) async {
    await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
      'uid': user.uid,
      'name': user.displayName,
      'email': user.email,
      'photoUrl': user.photoURL,
      'lastLogin': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

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
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Google sign-up failed: $e')),
      );
    }
  }

  Future<void> _signUpWithFacebook(BuildContext context) async {
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
              colors: [
                Color(0xFFF3E9FF),
                Color(0xFFFFFFFF),
              ],
            ),
          ),
          child: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(28, 20, 28, 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 70),

                  // --- Title & subtitle
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

                  // --- Google Button
                  GestureDetector(
                    onTap: () => _signUpWithGoogle(context),
                    child: Container(
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
                          Image.asset('assets/images/google_icon.png',
                              height: 32),
                          const SizedBox(width: 12),
                          Text(
                            "Continue with Google",
                            style: GoogleFonts.lato(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // --- Facebook Button
                  GestureDetector(
                    onTap: () => _signUpWithFacebook(context),
                    child: Container(
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
                        children: const [
                          Icon(Icons.facebook,
                              color: Color(0xFF1877F2), size: 34),
                          SizedBox(width: 12),
                          Text(
                            "Continue with Facebook",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 38),

                  // --- Divider
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

                  // --- Email field
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
                    decoration: InputDecoration(
                      hintText: 'Enter your email',
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

                  const SizedBox(height: 20),

                  // --- Continue button
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

                  // --- Error box (below the button)
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
}
