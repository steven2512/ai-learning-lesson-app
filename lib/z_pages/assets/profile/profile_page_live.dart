import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:running_robot/core/loading_skeleton.dart';
import 'package:running_robot/models/user_profile.dart';
import 'package:running_robot/core/progression_scope.dart';
import 'package:running_robot/services/user_profile_service.dart';
import 'package:running_robot/z_pages/assets/settings/settings_page_live.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool _isSavingProfile = false;

  Future<void> _openSettings() async {
    await Navigator.of(context).push(
      PageRouteBuilder<void>(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const SettingsPage(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          final curved = CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutCubic,
          );
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(1, 0),
              end: Offset.zero,
            ).animate(curved),
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 320),
        reverseTransitionDuration: const Duration(milliseconds: 240),
      ),
    );
  }

  Future<void> _openEditProfileSheet() async {
    final pageContext = context;
    final progression = ProgressionScope.read(context);
    final profile = progression.profile;
    if (profile == null) return;

    final nameController = TextEditingController(text: profile.name ?? '');
    DateTime? selectedDob = profile.dob;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                top: 24,
                bottom: MediaQuery.of(context).viewInsets.bottom + 18,
              ),
              child: Material(
                color: Colors.white,
                borderRadius: BorderRadius.circular(28),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 18),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Edit profile',
                        style: GoogleFonts.lato(
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          color: const Color(0xFF14213D),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Tweak the parts that make the app feel like yours.',
                        style: GoogleFonts.lato(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF64748B),
                        ),
                      ),
                      const SizedBox(height: 20),
                      TextField(
                        controller: nameController,
                        textCapitalization: TextCapitalization.words,
                        decoration: InputDecoration(
                          labelText: 'Display name',
                          labelStyle: GoogleFonts.lato(
                            fontWeight: FontWeight.w700,
                          ),
                          filled: true,
                          fillColor: const Color(0xFFF8FAFC),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 16,
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
                        ),
                      ),
                      const SizedBox(height: 14),
                      InkWell(
                        borderRadius: BorderRadius.circular(18),
                        onTap: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: selectedDob ?? DateTime(2000, 1, 1),
                            firstDate: DateTime(1950, 1, 1),
                            lastDate: DateTime.now(),
                          );
                          if (picked != null) {
                            setSheetState(() => selectedDob = picked);
                          }
                        },
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 16,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF8FAFC),
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(
                              color: const Color(0xFFE2E8F0),
                            ),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.cake_rounded,
                                color: Color(0xFF7C3AED),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Birthday',
                                      style: GoogleFonts.lato(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w800,
                                        color: const Color(0xFF64748B),
                                      ),
                                    ),
                                    const SizedBox(height: 3),
                                    Text(
                                      selectedDob == null
                                          ? 'Tap to choose a date'
                                          : _formatDate(selectedDob),
                                      style: GoogleFonts.lato(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w700,
                                        color: const Color(0xFF0F172A),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const Icon(
                                Icons.chevron_right_rounded,
                                color: Color(0xFF94A3B8),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _isSavingProfile
                              ? null
                              : () async {
                                  final messenger =
                                      ScaffoldMessenger.of(pageContext);
                                  final progressionController =
                                      ProgressionScope.read(pageContext);
                                  setState(() => _isSavingProfile = true);
                                  Navigator.of(context).pop();
                                  try {
                                    await UserProfileService
                                        .updateEditableProfile(
                                      name: nameController.text,
                                      dob: selectedDob,
                                    );
                                    await progressionController.refresh();
                                    if (!mounted) return;
                                    messenger.showSnackBar(
                                      const SnackBar(
                                        content: Text('Profile updated.'),
                                      ),
                                    );
                                  } finally {
                                    if (mounted) {
                                      setState(
                                        () => _isSavingProfile = false,
                                      );
                                    }
                                  }
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF58CC02),
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          child: Text(
                            _isSavingProfile ? 'Saving...' : 'Save changes',
                            style: GoogleFonts.lato(
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final progression = ProgressionScope.watch(context);
    final profile = progression.profile;
    final showSkeleton = !progression.hasSnapshot;
    final xp = progression.totalXp;
    final completedLessons = progression.lessonsCompleted;
    final completionStepsLeft = [
      if ((profile?.name ?? '').trim().isEmpty) 'name',
      if (profile?.dob == null) 'birthday',
    ].length;

    return Scaffold(
      backgroundColor: const Color(0xFFF7FBFF),
      body: Stack(
        children: [
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFFF7FBFF),
                    Color(0xFFF5F8FC),
                  ],
                ),
              ),
            ),
          ),
          SafeArea(
            child: showSkeleton
                ? const _ProfileSkeletonView()
                : ListView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(18, 10, 18, 96),
                    children: [
                      _ProfileHero(
                        displayName: _displayName(profile),
                        handle: _profileHandle(profile),
                        joinedYear: profile?.joinedAt.year,
                        photoUrl: profile?.photoUrl,
                        xp: xp,
                        streak: progression.dailyStreak,
                        completedLessons: completedLessons,
                        currentLesson: progression.currentLessonNumber,
                        onOpenSettings: _openSettings,
                        onEditProfile: _openEditProfileSheet,
                      ),
                      if (completionStepsLeft > 0) ...[
                        const SizedBox(height: 18),
                        _ProfileCompletionCard(
                          stepsLeft: completionStepsLeft,
                          onTap: _openEditProfileSheet,
                        ),
                      ],
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  static String _displayName(UserProfile? profile) {
    final name = profile?.name?.toString().trim();
    if (name != null && name.isNotEmpty) return name;

    final email = FirebaseAuth.instance.currentUser?.email ?? '';
    if (email.isNotEmpty) {
      return email.split('@').first;
    }
    return 'Profile';
  }

  static String _profileHandle(UserProfile? profile) {
    final email = profile?.email?.toString().trim();
    if (email != null && email.isNotEmpty) {
      return '@${email.split('@').first.toUpperCase()}';
    }
    return '@LEARNER';
  }

  static String _formatDate(DateTime? date) {
    if (date == null) return 'Not set';
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '${date.year}-$month-$day';
  }
}

class _ProfileHero extends StatelessWidget {
  final String displayName;
  final String handle;
  final int? joinedYear;
  final String? photoUrl;
  final int xp;
  final int streak;
  final int completedLessons;
  final int currentLesson;
  final VoidCallback onOpenSettings;
  final VoidCallback onEditProfile;

  const _ProfileHero({
    required this.displayName,
    required this.handle,
    required this.joinedYear,
    required this.photoUrl,
    required this.xp,
    required this.streak,
    required this.completedLessons,
    required this.currentLesson,
    required this.onOpenSettings,
    required this.onEditProfile,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFF7F0FF),
            Color(0xFFF1EBFF),
            Color(0xFFEFF7FF),
          ],
        ),
        borderRadius: BorderRadius.circular(30),
        boxShadow: const [
          BoxShadow(
            color: Color(0x147F56D9),
            blurRadius: 24,
            offset: Offset(0, 12),
          ),
          BoxShadow(
            color: Color(0x0A312E81),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
      child: Stack(
        children: [
          Positioned(
            top: 8,
            right: 8,
            child: _TopIconButton(
              icon: Icons.settings_rounded,
              backgroundColor: Colors.white,
              foregroundColor: const Color(0xFF6F52C8),
              onTap: onOpenSettings,
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  _AvatarBadge(photoUrl: photoUrl, displayName: displayName),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          displayName,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.lato(
                            fontSize: 30,
                            fontWeight: FontWeight.w900,
                            color: const Color(0xFF14213D),
                            height: 0.95,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '$handle - joined ${joinedYear ?? DateTime.now().year}',
                          style: GoogleFonts.lato(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF756A94),
                            letterSpacing: 0.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  _HeroStatPill(
                    icon: Icons.local_fire_department_rounded,
                    iconColor: const Color(0xFFFF8A00),
                    label: '$streak day streak',
                  ),
                  _HeroStatPill(
                    icon: Icons.bolt_rounded,
                    iconColor: const Color(0xFFFFB020),
                    label: '$xp XP earned',
                  ),
                  _HeroStatPill(
                    icon: Icons.menu_book_rounded,
                    iconColor: const Color(0xFF1CB0F6),
                    label: 'Lesson $currentLesson',
                  ),
                  _HeroStatPill(
                    icon: Icons.flag_rounded,
                    iconColor: const Color(0xFF58CC02),
                    label: '$completedLessons done',
                  ),
                ],
              ),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: onEditProfile,
                  icon: const Icon(Icons.edit_rounded, size: 19),
                  label: Text(
                    'Edit profile',
                    style: GoogleFonts.lato(
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF7F56D9),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AvatarBadge extends StatelessWidget {
  final String? photoUrl;
  final String displayName;

  const _AvatarBadge({
    required this.photoUrl,
    required this.displayName,
  });

  @override
  Widget build(BuildContext context) {
    final initial =
        displayName.trim().isEmpty ? 'P' : displayName.trim()[0].toUpperCase();

    return Container(
      width: 94,
      height: 94,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white,
        border: Border.all(color: Colors.white, width: 5),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 18,
            offset: Offset(0, 8),
          ),
        ],
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF8B5CF6),
            Color(0xFF5B8DEF),
          ],
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: ClipOval(
          child: photoUrl != null && photoUrl!.trim().isNotEmpty
              ? CachedNetworkImage(
                  imageUrl: photoUrl!,
                  fit: BoxFit.cover,
                  errorWidget: (_, __, ___) => _AvatarFallback(
                    initial: initial,
                  ),
                )
              : _AvatarFallback(initial: initial),
        ),
      ),
    );
  }
}

class _AvatarFallback extends StatelessWidget {
  final String initial;

  const _AvatarFallback({
    required this.initial,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF1EBFF),
      child: Center(
        child: Text(
          initial,
          style: GoogleFonts.lato(
            fontSize: 42,
            fontWeight: FontWeight.w900,
            color: const Color(0xFF41356F),
          ),
        ),
      ),
    );
  }
}

class _TopIconButton extends StatelessWidget {
  final IconData icon;
  final Color backgroundColor;
  final Color foregroundColor;
  final VoidCallback onTap;

  const _TopIconButton({
    required this.icon,
    required this.backgroundColor,
    required this.foregroundColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: backgroundColor,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Icon(icon, color: foregroundColor, size: 22),
        ),
      ),
    );
  }
}

class _HeroStatPill extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;

  const _HeroStatPill({
    required this.icon,
    required this.iconColor,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.88),
        borderRadius: BorderRadius.circular(999),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 8,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: iconColor, size: 18),
          const SizedBox(width: 8),
          Text(
            label,
            style: GoogleFonts.lato(
              fontSize: 13,
              fontWeight: FontWeight.w900,
              color: const Color(0xFF334155),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileCompletionCard extends StatelessWidget {
  final int stepsLeft;
  final VoidCallback onTap;

  const _ProfileCompletionCard({
    required this.stepsLeft,
    required this.onTap,
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
            Color(0xFFDFF4FF),
            Color(0xFFEFFFF4),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Finish your profile',
                  style: GoogleFonts.lato(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: const Color(0xFF14213D),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$stepsLeft ${stepsLeft == 1 ? 'step' : 'steps'} left',
                  style: GoogleFonts.lato(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF64748B),
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: onTap,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1CB0F6),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 14,
                    ),
                  ),
                  child: Text(
                    'Continue',
                    style: GoogleFonts.lato(
                      fontSize: 15,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Container(
            width: 74,
            height: 74,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.72),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.verified_user_rounded,
              size: 34,
              color: Color(0xFF58CC02),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileSkeletonView extends StatelessWidget {
  const _ProfileSkeletonView();

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(18, 10, 18, 96),
      children: [
        Container(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(30),
            boxShadow: const [
              BoxShadow(
                color: Color(0x12000000),
                blurRadius: 18,
                offset: Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Align(
                alignment: Alignment.topRight,
                child: LoadingSkeleton(width: 42, height: 42),
              ),
              Row(
                children: const [
                  LoadingSkeleton.circle(size: 94),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        LoadingSkeleton(width: 170, height: 30),
                        SizedBox(height: 8),
                        LoadingSkeleton(width: 148, height: 14),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              const Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  LoadingSkeleton(width: 110, height: 38),
                  LoadingSkeleton(width: 110, height: 38),
                  LoadingSkeleton(width: 94, height: 38),
                  LoadingSkeleton(width: 102, height: 38),
                ],
              ),
              const SizedBox(height: 18),
              const LoadingSkeleton(height: 48),
            ],
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}
