import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:running_robot/auth/auth_gate.dart';
import 'package:running_robot/auth/start_button.dart';
import 'package:running_robot/services/auth_account_service.dart';
import 'package:running_robot/services/user_profile_service.dart';

class SignupFlow extends StatefulWidget {
  final String initialEmail;
  final String signupVerificationToken;

  const SignupFlow({
    super.key,
    required this.initialEmail,
    required this.signupVerificationToken,
  });

  @override
  State<SignupFlow> createState() => _SignupFlowState();
}

class _SignupFlowState extends State<SignupFlow> {
  final PageController _pageController = PageController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  int _selectedAge = 18;
  int _currentPage = 0;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _pageController.dispose();
    _nameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _onSignupSuccess(User user) async {
    await UserProfileService.createOrUpdateUserProfile(
      user,
      name: _nameController.text.trim(),
      age: _selectedAge,
      lastDevice: _detectPlatform(),
      appVersion: AuthAccountService.appVersion,
      provider: 'password',
    );

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

  Future<void> _finishSignup() async {
    final email = widget.initialEmail.trim();
    final password = _passwordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();
    final name = _nameController.text.trim();

    if (name.length < 2) {
      _showSnackBar('Enter your name first.');
      return;
    }

    final passwordError = AuthAccountService.validatePassword(password);
    if (passwordError != null) {
      _showSnackBar(passwordError);
      return;
    }

    if (password != confirmPassword) {
      _showSnackBar('Passwords do not match.');
      return;
    }

    if (_isSubmitting) return;

    setState(() => _isSubmitting = true);
    try {
      final cred = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      await AuthAccountService.claimVerifiedSignupEmail(
        widget.signupVerificationToken,
      );
      await _waitForVerifiedSignupClaim();
      await cred.user!.updateDisplayName(name);
      await cred.user!.reload();
      await _onSignupSuccess(FirebaseAuth.instance.currentUser ?? cred.user!);
    } on FirebaseAuthException catch (e) {
      _showSnackBar(e.message ?? 'Unable to create account right now.');
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  void _showSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> _waitForVerifiedSignupClaim() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    for (var attempt = 0; attempt < 3; attempt++) {
      final status = await AuthAccountService.loadVerificationStatus(
        user,
        forceRefresh: true,
      );
      if (status.isVerified) {
        return;
      }

      await Future<void>.delayed(const Duration(milliseconds: 350));
    }
  }

  void _nextPage() {
    if (_currentPage < 2) {
      setState(() => _currentPage++);
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      return;
    }

    _finishSignup();
  }

  void _prevPage() {
    if (_currentPage > 0) {
      setState(() => _currentPage--);
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      return;
    }

    Navigator.pop(context);
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

  String _detectPlatform() {
    if (Theme.of(context).platform == TargetPlatform.iOS) return 'ios';
    if (Theme.of(context).platform == TargetPlatform.android) return 'android';
    return 'web';
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black87),
            onPressed: _isSubmitting ? null : _prevPage,
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
                _pageContent(
                  'What is your name?',
                  TextField(
                    controller: _nameController,
                    decoration: _inputDecoration('Your name'),
                  ),
                  'Continue',
                ),
                _pageContent(
                  'How old are you?',
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'This helps us tailor the app to your experience.',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.lato(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.black54,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Expanded(
                        child: CupertinoPicker(
                          itemExtent: 48,
                          scrollController: FixedExtentScrollController(
                            initialItem: _selectedAge - 13,
                          ),
                          onSelectedItemChanged: (index) {
                            setState(() => _selectedAge = index + 13);
                          },
                          children: List.generate(
                            88,
                            (index) => Center(
                              child: Text(
                                '${index + 13}',
                                style: GoogleFonts.lato(
                                  fontSize: 26,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.black87,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  'Continue',
                ),
                _pageContent(
                  'Set your password',
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextField(
                        controller: _passwordController,
                        obscureText: true,
                        decoration: _inputDecoration('Password'),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _confirmPasswordController,
                        obscureText: true,
                        decoration: _inputDecoration('Repeat password'),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Use 8+ characters with an uppercase letter, lowercase letter, and number.',
                        style: GoogleFonts.lato(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Colors.black54,
                          height: 1.35,
                        ),
                      ),
                    ],
                  ),
                  _isSubmitting ? 'Creating...' : 'Finish',
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
            onTap: () {
              if (_isSubmitting) return;
              _nextPage();
            },
          ),
        ],
      ),
    );
  }
}
