import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:running_robot/core/loading_skeleton.dart';
import 'package:running_robot/core/progression_scope.dart';
import 'package:running_robot/services/auth_account_service.dart';
import 'package:running_robot/z_pages/assets/mainMenu/header_greeting.dart';

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

  String _displayDate(DateTime? value) {
    if (value == null) return 'Not set';
    final month = value.month.toString().padLeft(2, '0');
    final day = value.day.toString().padLeft(2, '0');
    return '${value.year}-$month-$day';
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
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          const Positioned.fill(child: ColoredBox(color: Colors.white)),
          if (showSkeleton) const AppHeaderSkeleton() else const HeaderGreeting(),
          if (showSkeleton)
            const _SettingsSkeletonView()
          else
            Positioned.fill(
              top: 140,
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                children: [
                  _SettingsSection(
                    title: 'Account',
                    children: [
                      _InfoTile(
                        icon: Icons.mail_outline,
                        title: 'Email',
                        value: profile?.email ?? firebaseUser?.email ?? 'Unknown',
                      ),
                      _InfoTile(
                        icon: Icons.badge_outlined,
                        title: 'Sign-in Method',
                        value:
                            AuthAccountService.providerLabel(effectiveProvider),
                      ),
                      _InfoTile(
                        icon: Icons.cake_outlined,
                        title: 'Date of Birth',
                        value: _displayDate(profile?.dob),
                      ),
                      _ActionTile(
                        icon: Icons.refresh,
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
                          icon: Icons.password_outlined,
                          title: 'Send Password Reset Email',
                          subtitle: 'Email a reset link to your account address.',
                          trailingLabel:
                              _isResettingPassword ? 'Sending...' : null,
                          enabled: !_isResettingPassword,
                          onTap: _sendPasswordReset,
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _SettingsSection(
                    title: 'Learning Progress',
                    children: [
                      _InfoTile(
                        icon: Icons.auto_stories_outlined,
                        title: 'Current Lesson',
                        value: 'Lesson ${progression.currentLessonNumber}',
                      ),
                      _InfoTile(
                        icon: Icons.flag_outlined,
                        title: 'Lessons Completed',
                        value: progression.lessonsCompleted.toString(),
                      ),
                      _InfoTile(
                        icon: Icons.bolt_outlined,
                        title: 'XP',
                        value: progression.totalXp.toString(),
                      ),
                      _InfoTile(
                        icon: Icons.local_fire_department_outlined,
                        title: 'Daily Streak',
                        value: progression.dailyStreak.toString(),
                      ),
                      _InfoTile(
                        icon: Icons.today_outlined,
                        title: 'Lessons Today',
                        value: progression.todayLessonCount.toString(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _SettingsSection(
                    title: 'App',
                    children: [
                      _InfoTile(
                        icon: Icons.info_outline,
                        title: 'Version',
                        value:
                            profile?.appVersion ?? AuthAccountService.appVersion,
                      ),
                      _InfoTile(
                        icon: Icons.public_outlined,
                        title: 'Timezone',
                        value: profile?.timezone ?? 'Unknown',
                      ),
                      _InfoTile(
                        icon: Icons.phone_android_outlined,
                        title: 'Last Device',
                        value: profile?.lastDevice ?? 'Unknown',
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Center(
                    child: TextButton(
                      onPressed: _isLoggingOut ? null : _logOut,
                      child: Text(
                        _isLoggingOut ? 'Logging Out...' : 'Log Out',
                        style: GoogleFonts.lato(
                          color: Colors.red,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
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
    return Positioned.fill(
      top: 140,
      child: ListView(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        children: const [
          _SettingsSkeletonSection(itemCount: 5),
          SizedBox(height: 16),
          _SettingsSkeletonSection(itemCount: 5),
          SizedBox(height: 16),
          _SettingsSkeletonSection(itemCount: 3),
          SizedBox(height: 24),
          Center(child: LoadingSkeleton(width: 96, height: 18)),
          SizedBox(height: 24),
        ],
      ),
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
          child: LoadingSkeleton(width: 74, height: 12),
        ),
        Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 1,
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
              fontWeight: FontWeight.w700,
              color: Colors.black54,
              letterSpacing: 1.2,
            ),
          ),
        ),
        Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 1,
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
      leading: Icon(icon, color: Colors.black87),
      title: Text(
        title,
        style: GoogleFonts.lato(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Colors.black,
        ),
      ),
      subtitle: Text(
        value,
        style: GoogleFonts.lato(
          fontSize: 13,
          fontWeight: FontWeight.w400,
          color: Colors.black54,
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
      leading: Icon(icon, color: Colors.black87),
      title: Text(
        title,
        style: GoogleFonts.lato(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Colors.black,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: GoogleFonts.lato(
          fontSize: 13,
          fontWeight: FontWeight.w400,
          color: Colors.black54,
        ),
      ),
      trailing: trailingLabel != null
          ? Text(
              trailingLabel!,
              style: GoogleFonts.lato(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: Colors.black45,
              ),
            )
          : const Icon(Icons.chevron_right, color: Colors.black26),
      onTap: enabled ? onTap : null,
    );
  }
}
