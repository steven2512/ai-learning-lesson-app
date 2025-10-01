// FILE: lib/auth/sign_up_flow.dart
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:running_robot/auth/start_button.dart';
import 'package:running_robot/services/user_profile_service.dart';
import 'auth_gate.dart';

class SignupFlow extends StatefulWidget {
  final String initialEmail;
  const SignupFlow({super.key, required this.initialEmail});

  @override
  State<SignupFlow> createState() => _SignupFlowState();
}

class _SignupFlowState extends State<SignupFlow> {
  final PageController _pageController = PageController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  // ✅ Default DOB so it’s never null
  DateTime? _selectedDob = DateTime(2000, 1, 1);

  int _currentPage = 0;

  Future<void> _onSignupSuccess(BuildContext context, User user) async {
    await UserProfileService.createOrUpdateUserProfile(
      user,
      name: _nameController.text.trim(),
      dob: _selectedDob, // ✅ keep dob
      lastDevice: _detectPlatform(), // ✅ new
      appVersion: "1.0.0+1", // ✅ replace with real app version
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

  Future<void> _finishSignup() async {
    final email = widget.initialEmail.trim();
    final password = _passwordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();

    if (password != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Passwords do not match")),
      );
      return;
    }

    try {
      final cred = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);

      await cred.user!.updateDisplayName(_nameController.text.trim());
      await cred.user!.reload();

      await _onSignupSuccess(context, cred.user!);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Account created successfully")),
      );
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Signup error: ${e.message}")),
      );
    }
  }

  void _nextPage() {
    if (_currentPage < 2) {
      setState(() => _currentPage++);
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _finishSignup();
    }
  }

  void _prevPage() {
    if (_currentPage > 0) {
      setState(() => _currentPage--);
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      Navigator.pop(context);
    }
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

  @override
  Widget build(BuildContext context) {
    const Color kBrandPurple = Color(0xFF7F56D9);

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black87),
            onPressed: _prevPage,
          ),
        ),
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFFF3E9FF), Color(0xFFFFFFFF)],
            ),
          ),
          child: SafeArea(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                // Page 1: Name
                _pageContent(
                  "What is your name?",
                  TextField(
                    controller: _nameController,
                    decoration: _inputDecoration("Your name"),
                  ),
                  "Continue",
                ),
                // Page 2: DOB
                _pageContent(
                  "What is your Date of Birth?",
                  Expanded(
                    child: CupertinoDatePicker(
                      mode: CupertinoDatePickerMode.date,
                      maximumDate: DateTime.now(),
                      initialDateTime: _selectedDob,
                      onDateTimeChanged: (val) =>
                          setState(() => _selectedDob = val),
                    ),
                  ),
                  "Continue",
                ),
                // Page 3: Password
                _pageContent(
                  "Set your password",
                  Column(
                    children: [
                      TextField(
                        controller: _passwordController,
                        obscureText: true,
                        decoration: _inputDecoration("Password"),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _confirmPasswordController,
                        obscureText: true,
                        decoration: _inputDecoration("Repeat password"),
                      ),
                    ],
                  ),
                  "Finish",
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _pageContent(String title, Widget input, String ctaLabel) {
    const Color kBrandPurple = Color(0xFF7F56D9);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 40),
          Center(
            child: Text(
              title,
              style: GoogleFonts.lato(
                fontSize: 28,
                fontWeight: FontWeight.w800,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 28),
          input,
          const Spacer(),
          PillCta(
            label: ctaLabel,
            color: kBrandPurple,
            expand: true,
            onTap: _nextPage,
          ),
        ],
      ),
    );
  }

  // ✅ detect platform for lastDevice
  String _detectPlatform() {
    if (Theme.of(context).platform == TargetPlatform.iOS) return "ios";
    if (Theme.of(context).platform == TargetPlatform.android) return "android";
    return "web";
  }
}
