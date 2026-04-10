import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:running_robot/core/loading_skeleton.dart';
import 'package:running_robot/core/progression_scope.dart';
import 'package:running_robot/services/auth_account_service.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _isResettingPassword = false;
  bool _isRefreshingProgress = false;
  bool _isLoggingOut = false;

  Future<void> _sendPasswordReset() async {
    final user = FirebaseAuth.instance.currentUser;
    final email = user?.email;

    if (email == null || email.isEmpty) {
      _showSnackBar('No email is available for this account.');
      return;
    }

    setState(() => _isResettingPassword = true);
    try {
      await AuthAccountService.sendPasswordResetEmail(email);
      _showSnackBar('Password reset email sent to $email.');
    } on FirebaseAuthException catch (e) {
      _showSnackBar(e.message ?? 'Unable to send reset email right now.');
    } finally {
      if (mounted) {
        setState(() => _isResettingPassword = false);
      }
    }
  }

  Future<void> _refreshProgress() async {
    final progression = ProgressionScope.read(context);
    setState(() => _isRefreshingProgress = true);
    try {
      await progression.refresh();
      _showSnackBar('Progress refreshed.');
    } finally {
      if (mounted) {
        setState(() => _isRefreshingProgress = false);
      }
    }
  }

  Future<void> _logOut() async {
    setState(() => _isLoggingOut = true);
    try {
      await AuthAccountService.signOut();
    } finally {
      if (mounted) {
        setState(() => _isLoggingOut = false);
      }
    }
  }

  void _showSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  String _displayAge(int? value) {
    if (value == null || value <= 0) return 'Not set';
    return '$value years old';
  }

  @override
  Widget build(BuildContext context) {
    final progression = ProgressionScope.watch(context);
    final showSkeleton = !progression.hasSnapshot;
    final profile = progression.profile;
    final firebaseUser = FirebaseAuth.instance.currentUser;
    final effectiveProvider = profile?.provider ??
        (firebaseUser?.providerData.isNotEmpty == true
            ? firebaseUser!.providerData.first.providerId
            : null);
    final canResetPassword =
        AuthAccountService.supportsPasswordReset(effectiveProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FBFF),
      body: SafeArea(
        child: Stack(
          children: [
            Positioned.fill(
              child: Container(
                color: const Color(0xFFF8FBFF),
              ),
            ),
            if (showSkeleton)
              const _SettingsSkeletonView()
            else
              ListView(
                padding: const EdgeInsets.fromLTRB(18, 12, 18, 32),
                children: [
                  _SettingsTopBar(onClose: () => Navigator.of(context).pop()),
                  const SizedBox(height: 14),
                  _SettingsHeroCard(
                    email: profile?.email ?? firebaseUser?.email ?? 'Unknown',
                    provider:
                        AuthAccountService.providerLabel(effectiveProvider),
                    timezone: profile?.timezone ?? 'Unknown',
                  ),
                  const SizedBox(height: 18),
                  _SettingsSection(
                    title: 'Account',
                    children: [
                      _InfoTile(
                        icon: Icons.mail_outline_rounded,
                        title: 'Email',
                        value:
                            profile?.email ?? firebaseUser?.email ?? 'Unknown',
                      ),
                      _InfoTile(
                        icon: Icons.badge_outlined,
                        title: 'Sign-in Method',
                        value:
                            AuthAccountService.providerLabel(effectiveProvider),
                      ),
                      _InfoTile(
                        icon: Icons.cake_outlined,
                        title: 'Age',
                        value: _displayAge(profile?.age),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _SettingsSection(
                    title: 'Data',
                    children: [
                      _ActionTile(
                        icon: Icons.refresh_rounded,
                        title: 'Refresh Account Data',
                        subtitle:
                            'Pull the latest saved progression from Firebase.',
                        trailingLabel:
                            _isRefreshingProgress ? 'Loading...' : null,
                        enabled: !_isRefreshingProgress,
                        onTap: _refreshProgress,
                      ),
                      if (canResetPassword)
                        _ActionTile(
                          icon: Icons.password_rounded,
                          title: 'Send Password Reset Email',
                          subtitle:
                              'Email a reset link to your account address.',
                          trailingLabel:
                              _isResettingPassword ? 'Sending...' : null,
                          enabled: !_isResettingPassword,
                          onTap: _sendPasswordReset,
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _SettingsSection(
                    title: 'App',
                    children: [
                      _InfoTile(
                        icon: Icons.info_outline_rounded,
                        title: 'Version',
                        value: profile?.appVersion ??
                            AuthAccountService.appVersion,
                      ),
                        _InfoTile(
                          icon: Icons.public_rounded,
                          title: 'Timezone',
                          value: profile?.timezone ?? 'Unknown',
                        ),
                      ],
                    ),
                  const SizedBox(height: 22),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isLoggingOut ? null : _logOut,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFF4B4B),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: Text(
                        _isLoggingOut ? 'Logging Out...' : 'Log Out',
                        style: GoogleFonts.lato(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

class _SettingsTopBar extends StatelessWidget {
  final VoidCallback onClose;

  const _SettingsTopBar({
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            'Settings',
            style: GoogleFonts.lato(
              fontSize: 30,
              fontWeight: FontWeight.w900,
              color: const Color(0xFF14213D),
            ),
          ),
        ),
        InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onClose,
          child: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x10000000),
                  blurRadius: 10,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            alignment: Alignment.center,
            child: Image.asset(
              'assets/images/x_icon.png',
              width: 18,
              height: 18,
            ),
          ),
        ),
      ],
    );
  }
}

class _SettingsHeroCard extends StatelessWidget {
  final String email;
  final String provider;
  final String timezone;

  const _SettingsHeroCard({
    required this.email,
    required this.provider,
    required this.timezone,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFEAF7FF),
            Color(0xFFF3FFF1),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            email,
            style: GoogleFonts.lato(
              fontSize: 21,
              fontWeight: FontWeight.w900,
              color: const Color(0xFF14213D),
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _SettingsChip(
                icon: Icons.verified_user_rounded,
                color: const Color(0xFF1CB0F6),
                label: provider,
              ),
              _SettingsChip(
                icon: Icons.public_rounded,
                color: const Color(0xFF58CC02),
                label: timezone,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SettingsChip extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;

  const _SettingsChip({
    required this.icon,
    required this.color,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.82),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 7),
          Text(
            label,
            style: GoogleFonts.lato(
              fontSize: 12,
              fontWeight: FontWeight.w900,
              color: const Color(0xFF334155),
            ),
          ),
        ],
      ),
    );
  }
}

class _SettingsSkeletonView extends StatelessWidget {
  const _SettingsSkeletonView();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 12, 18, 32),
      children: const [
        Row(
          children: [
            Expanded(child: LoadingSkeleton(width: 120, height: 30)),
            SizedBox(width: 12),
            LoadingSkeleton(width: 44, height: 44),
          ],
        ),
        SizedBox(height: 14),
        LoadingSkeleton(height: 108),
        SizedBox(height: 18),
        _SettingsSkeletonSection(itemCount: 3),
        SizedBox(height: 16),
        _SettingsSkeletonSection(itemCount: 2),
        SizedBox(height: 16),
        _SettingsSkeletonSection(itemCount: 3),
        SizedBox(height: 22),
        LoadingSkeleton(height: 52),
      ],
    );
  }
}

class _SettingsSkeletonSection extends StatelessWidget {
  final int itemCount;

  const _SettingsSkeletonSection({
    required this.itemCount,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 8, horizontal: 4),
          child: LoadingSkeleton(width: 90, height: 12),
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22),
            boxShadow: const [
              BoxShadow(
                color: Color(0x10000000),
                blurRadius: 14,
                offset: Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            children: List.generate(
              itemCount,
              (index) => const _SettingsSkeletonTile(),
            ),
          ),
        ),
      ],
    );
  }
}

class _SettingsSkeletonTile extends StatelessWidget {
  const _SettingsSkeletonTile();

  @override
  Widget build(BuildContext context) {
    return const ListTile(
      leading: LoadingSkeleton(width: 24, height: 24),
      title: Padding(
        padding: EdgeInsets.only(bottom: 8),
        child: LoadingSkeleton(width: 120, height: 16),
      ),
      subtitle: LoadingSkeleton(width: 160, height: 13),
      trailing: LoadingSkeleton(width: 18, height: 18),
    );
  }
}

class _SettingsSection extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _SettingsSection({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
          child: Text(
            title.toUpperCase(),
            style: GoogleFonts.lato(
              fontSize: 12,
              fontWeight: FontWeight.w900,
              color: const Color(0xFF94A3B8),
              letterSpacing: 1.2,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22),
            boxShadow: const [
              BoxShadow(
                color: Color(0x10000000),
                blurRadius: 14,
                offset: Offset(0, 8),
              ),
            ],
          ),
          child: Column(children: children),
        ),
      ],
    );
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const _InfoTile({
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFF334155)),
      title: Text(
        title,
        style: GoogleFonts.lato(
          fontSize: 16,
          fontWeight: FontWeight.w800,
          color: const Color(0xFF0F172A),
        ),
      ),
      subtitle: Text(
        value,
        style: GoogleFonts.lato(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: const Color(0xFF64748B),
        ),
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool enabled;
  final String? trailingLabel;

  const _ActionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    required this.enabled,
    this.trailingLabel,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      enabled: enabled,
      leading: Icon(icon, color: const Color(0xFF334155)),
      title: Text(
        title,
        style: GoogleFonts.lato(
          fontSize: 16,
          fontWeight: FontWeight.w800,
          color: const Color(0xFF0F172A),
        ),
      ),
      subtitle: Text(
        subtitle,
        style: GoogleFonts.lato(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: const Color(0xFF64748B),
        ),
      ),
      trailing: trailingLabel != null
          ? Text(
              trailingLabel!,
              style: GoogleFonts.lato(
                fontSize: 12,
                fontWeight: FontWeight.w900,
                color: const Color(0xFF94A3B8),
              ),
            )
          : const Icon(Icons.chevron_right_rounded, color: Color(0xFFCBD5E1)),
      onTap: enabled ? onTap : null,
    );
  }
}
