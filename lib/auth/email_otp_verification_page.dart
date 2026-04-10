import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:running_robot/services/auth_account_service.dart';

class EmailOtpVerificationPage extends StatefulWidget {
  final String email;
  final Future<void> Function() onVerified;

  const EmailOtpVerificationPage({
    super.key,
    required this.email,
    required this.onVerified,
  });

  @override
  State<EmailOtpVerificationPage> createState() =>
      _EmailOtpVerificationPageState();
}

class _EmailOtpVerificationPageState extends State<EmailOtpVerificationPage> {
  final TextEditingController _codeController = TextEditingController();
  bool _isSending = false;
  bool _isVerifying = false;
  int _cooldownSeconds = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _sendCode(showSuccessMessage: false);
    });
  }

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _sendCode({required bool showSuccessMessage}) async {
    if (_isSending || _cooldownSeconds > 0) return;

    setState(() => _isSending = true);
    try {
      final cooldownSeconds = await AuthAccountService.sendEmailOtp();
      _startCooldown(cooldownSeconds);
      if (showSuccessMessage && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Verification code sent to ${AuthAccountService.maskEmail(widget.email)}.',
            ),
          ),
        );
      }
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

  Future<void> _verifyCode() async {
    if (_isVerifying) return;

    final code = _codeController.text.trim();
    if (!RegExp(r'^\d{6}$').hasMatch(code)) {
      _showSnackBar('Enter the 6-digit code from your email.');
      return;
    }

    setState(() => _isVerifying = true);
    try {
      await AuthAccountService.verifyEmailOtp(code);
      await widget.onVerified();
    } on FirebaseFunctionsException catch (error) {
      _showSnackBar(error.message ?? 'Unable to verify that code.');
    } catch (_) {
      _showSnackBar('Unable to verify that code.');
    } finally {
      if (mounted) {
        setState(() => _isVerifying = false);
      }
    }
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

    return Scaffold(
      backgroundColor: const Color(0xFFF8F5FF),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Container(
                padding: const EdgeInsets.fromLTRB(22, 24, 22, 22),
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF3EDFF),
                        borderRadius: BorderRadius.circular(22),
                      ),
                      child: const Icon(
                        Icons.mark_email_read_rounded,
                        color: brandPurple,
                        size: 32,
                      ),
                    ),
                    const SizedBox(height: 18),
                    Text(
                      'Verify your email',
                      style: GoogleFonts.lato(
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                        color: const Color(0xFF14213D),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Enter the 6-digit code we sent to ${AuthAccountService.maskEmail(widget.email)} before using the app.',
                      style: GoogleFonts.lato(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF64748B),
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 22),
                    TextField(
                      controller: _codeController,
                      keyboardType: TextInputType.number,
                      maxLength: 6,
                      inputFormatters: const [
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                      decoration: InputDecoration(
                        counterText: '',
                        hintText: '6-digit code',
                        filled: true,
                        fillColor: const Color(0xFFF8FAFC),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 18,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(18),
                          borderSide: const BorderSide(
                            color: Color(0xFFE2E8F0),
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(18),
                          borderSide: const BorderSide(
                            color: Color(0xFFE2E8F0),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(18),
                          borderSide: const BorderSide(
                            color: brandPurple,
                            width: 1.4,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isVerifying ? null : _verifyCode,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: brandPurple,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: Text(
                          _isVerifying ? 'Verifying...' : 'Verify and continue',
                          style: GoogleFonts.lato(
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: (_isSending || _cooldownSeconds > 0)
                                ? null
                                : () => _sendCode(showSuccessMessage: true),
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: Color(0xFFD8DCE8)),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 15),
                            ),
                            child: Text(
                              _cooldownSeconds > 0
                                  ? 'Resend in ${_cooldownSeconds}s'
                                  : (_isSending ? 'Sending...' : 'Resend code'),
                              style: GoogleFonts.lato(
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                                color: const Color(0xFF334155),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        TextButton(
                          onPressed: () async {
                            await AuthAccountService.signOut();
                          },
                          child: Text(
                            'Sign out',
                            style: GoogleFonts.lato(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFF7F56D9),
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
      ),
    );
  }
}
