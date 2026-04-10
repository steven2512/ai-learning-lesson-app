import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:running_robot/auth/start_button.dart';
import 'package:running_robot/services/auth_account_service.dart';

class EmailOtpVerificationPage extends StatefulWidget {
  final String email;
  final Future<void> Function()? onVerified;
  final Future<void> Function(String verificationToken)? onSignupVerified;
  final bool isSignupFlow;

  const EmailOtpVerificationPage({
    super.key,
    required this.email,
    required Future<void> Function() onVerified,
  })  : onSignupVerified = null,
        onVerified = onVerified,
        isSignupFlow = false;

  const EmailOtpVerificationPage.forSignup({
    super.key,
    required this.email,
    required Future<void> Function(String verificationToken) onVerified,
  })  : onSignupVerified = onVerified,
        onVerified = null,
        isSignupFlow = true;

  Future<void> handleVerified(String? verificationToken) async {
    if (isSignupFlow) {
      final callback = onSignupVerified;
      if (callback == null || verificationToken == null) return;
      await callback(verificationToken);
      return;
    }

    final callback = onVerified;
    if (callback == null) return;
    await callback();
  }

  @override
  State<EmailOtpVerificationPage> createState() =>
      _EmailOtpVerificationPageState();
}

class _EmailOtpVerificationPageState extends State<EmailOtpVerificationPage> {
  final TextEditingController _codeController = TextEditingController();
  final FocusNode _codeFocusNode = FocusNode();
  bool _isSending = false;
  bool _isVerifying = false;
  bool _verificationCompleted = false;
  int _cooldownSeconds = 0;
  String _lastAttemptedCode = '';

  @override
  void initState() {
    super.initState();
    _codeController.addListener(_handleCodeChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _codeFocusNode.requestFocus();
      _sendCode();
    });
  }

  @override
  void dispose() {
    _codeController.removeListener(_handleCodeChanged);
    _codeController.dispose();
    _codeFocusNode.dispose();
    super.dispose();
  }

  void _handleCodeChanged() {
    if (!mounted) return;
    setState(() {});

    final code = _codeController.text.trim();
    if (code.length == 6 &&
        code != _lastAttemptedCode &&
        !_isVerifying &&
        !_verificationCompleted) {
      _verifyCode(autoTriggered: true);
    }
  }

  Future<void> _sendCode() async {
    if (_isSending || _cooldownSeconds > 0) return;

    setState(() => _isSending = true);
    try {
      final cooldownSeconds = widget.isSignupFlow
          ? await AuthAccountService.startSignupEmailOtp(widget.email)
          : await AuthAccountService.sendEmailOtp();
      _startCooldown(cooldownSeconds);
    } on FirebaseFunctionsException catch (error) {
      _showSnackBar(error.message ?? 'Unable to send a verification code.');
    } catch (_) {
      _showSnackBar('Unable to send a verification code.');
    } finally {
      if (mounted) {
        setState(() => _isSending = false);
      }
    }
  }

  Future<void> _verifyCode({bool autoTriggered = false}) async {
    if (_isVerifying || _verificationCompleted) return;

    final code = _codeController.text.trim();
    if (!RegExp(r'^\d{6}$').hasMatch(code)) {
      if (!autoTriggered) {
        _showSnackBar('Enter the 6-digit code from your email.');
      }
      return;
    }

    _lastAttemptedCode = code;
    setState(() => _isVerifying = true);

    String? verificationToken;
    try {
      if (widget.isSignupFlow) {
        verificationToken = await AuthAccountService.verifySignupEmailOtp(
          email: widget.email,
          code: code,
        );
      } else {
        await AuthAccountService.verifyEmailOtp(code);
      }
    } on FirebaseFunctionsException catch (error) {
      if (mounted) {
        _showSnackBar(error.message ?? 'Unable to verify that code.');
      }
      if (mounted) {
        setState(() => _isVerifying = false);
      }
      return;
    } catch (_) {
      if (mounted) {
        _showSnackBar('Unable to verify that code.');
      }
      if (mounted) {
        setState(() => _isVerifying = false);
      }
      return;
    }

    _verificationCompleted = true;
    if (mounted) {
      setState(() => _isVerifying = false);
    }

    await widget.handleVerified(verificationToken);
  }

  void _startCooldown(int seconds) {
    if (!mounted) return;

    setState(() => _cooldownSeconds = seconds);
    Future.doWhile(() async {
      await Future<void>.delayed(const Duration(seconds: 1));
      if (!mounted || _cooldownSeconds <= 0) {
        return false;
      }

      setState(() => _cooldownSeconds -= 1);
      return _cooldownSeconds > 0;
    });
  }

  void _showSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    const brandPurple = Color(0xFF7F56D9);

    return GestureDetector(
      onTap: () => _codeFocusNode.requestFocus(),
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F5FF),
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 40),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 40),
                    Text(
                      'Check your email',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.lato(
                        fontSize: 34,
                        fontWeight: FontWeight.w900,
                        color: const Color(0xFF14213D),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      'We have sent you a code to ${AuthAccountService.maskEmail(widget.email)}',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.lato(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF64748B),
                        height: 1.45,
                      ),
                    ),
                    const SizedBox(height: 28),
                    SizedBox(
                      height: 60,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Positioned.fill(
                            child: Opacity(
                              opacity: 0.01,
                              child: TextField(
                                controller: _codeController,
                                focusNode: _codeFocusNode,
                                autofocus: true,
                                keyboardType: TextInputType.number,
                                maxLength: 6,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                ],
                                style: const TextStyle(
                                  color: Colors.transparent,
                                ),
                                cursorColor: Colors.transparent,
                                decoration: const InputDecoration(
                                  counterText: '',
                                  border: InputBorder.none,
                                ),
                              ),
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: List.generate(6, (index) {
                              final hasValue =
                                  index < _codeController.text.length;
                              final digit =
                                  hasValue ? _codeController.text[index] : '';
                              final isActive = !_verificationCompleted &&
                                  (index == _codeController.text.length ||
                                      (_codeController.text.length == 6 &&
                                          index == 5));

                              return _OtpDigitCell(
                                digit: digit,
                                isActive: isActive,
                              );
                            }),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      _isSending ? 'Sending your code...' : 'Code expires in 10 minutes.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.lato(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF7B8799),
                      ),
                    ),
                    const SizedBox(height: 30),
                    PillCta(
                      label: _isVerifying ? 'Verifying...' : 'Continue',
                      color: brandPurple,
                      expand: true,
                      fontSize: 20,
                      onTap: () {
                        if (_isVerifying) return;
                        _verifyCode();
                      },
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

class _OtpDigitCell extends StatelessWidget {
  final String digit;
  final bool isActive;

  const _OtpDigitCell({
    required this.digit,
    required this.isActive,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOut,
      width: 48,
      height: 60,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isActive
              ? const Color(0xFF7F56D9)
              : const Color(0xFFE3E8F1),
          width: isActive ? 1.8 : 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF7F56D9).withValues(alpha: isActive ? 0.10 : 0),
            blurRadius: 14,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Text(
        digit,
        style: GoogleFonts.lato(
          fontSize: 24,
          fontWeight: FontWeight.w900,
          color: const Color(0xFF14213D),
        ),
      ),
    );
  }
}
