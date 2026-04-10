import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:running_robot/auth/email_otp_verification_page.dart';
import 'package:running_robot/my_app.dart';
import 'package:running_robot/services/app_progression_controller.dart';
import 'package:running_robot/services/auth_account_service.dart';
import 'package:running_robot/auth/welcome_page.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.idTokenChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        final user = snapshot.data;
        if (user != null) {
          return _AuthenticatedSessionGate(user: user);
        }
        AppProgressionController.instance.clear();
        return const WelcomePage();
      },
    );
  }
}

class _AuthenticatedSessionGate extends StatefulWidget {
  final User user;

  const _AuthenticatedSessionGate({
    required this.user,
  });

  @override
  State<_AuthenticatedSessionGate> createState() =>
      _AuthenticatedSessionGateState();
}

class _AuthenticatedSessionGateState extends State<_AuthenticatedSessionGate> {
  late Future<AuthVerificationStatus> _verificationFuture;

  @override
  void initState() {
    super.initState();
    _verificationFuture = AuthAccountService.loadVerificationStatus(
      widget.user,
      forceRefresh: true,
    );
  }

  @override
  void didUpdateWidget(covariant _AuthenticatedSessionGate oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.user.uid != widget.user.uid ||
        oldWidget.user.email != widget.user.email) {
      _verificationFuture = AuthAccountService.loadVerificationStatus(
        widget.user,
        forceRefresh: true,
      );
    }
  }

  Future<void> _refreshVerification() async {
    final future = AuthAccountService.loadVerificationStatus(
      FirebaseAuth.instance.currentUser ?? widget.user,
      forceRefresh: true,
    );
    if (mounted) {
      setState(() => _verificationFuture = future);
    }
    await future;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<AuthVerificationStatus>(
      future: _verificationFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError) {
          AppProgressionController.instance.clear();
          return _VerificationGateError(
            onRetry: _refreshVerification,
          );
        }

        final status = snapshot.data;
        if (status == null) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (status.requiresEmailOtp && !status.isVerified) {
          AppProgressionController.instance.clear();
          return EmailOtpVerificationPage(
            email: status.email ?? '',
            onVerified: _refreshVerification,
          );
        }

        AppProgressionController.instance.load();
        return const MyApp();
      },
    );
  }
}

class _VerificationGateError extends StatelessWidget {
  final Future<void> Function() onRetry;

  const _VerificationGateError({
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    const brandPurple = Color(0xFF7F56D9);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F5FF),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x120F172A),
                      blurRadius: 24,
                      offset: Offset(0, 12),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.shield_outlined,
                      size: 34,
                      color: brandPurple,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'We could not confirm your account yet.',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF14213D),
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Check your connection and try again. If the problem keeps happening, sign out and log back in.',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF64748B),
                        height: 1.45,
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () async {
                          await onRetry();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: brandPurple,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                        ),
                        child: const Text(
                          'Try again',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () async {
                          await AuthAccountService.signOut();
                        },
                        child: const Text(
                          'Sign out',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: brandPurple,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
