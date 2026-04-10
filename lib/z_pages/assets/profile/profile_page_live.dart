import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
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
    int selectedAge = profile.age ?? 18;

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
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
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
                                    'Age',
                                    style: GoogleFonts.lato(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w800,
                                      color: const Color(0xFF64748B),
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  SizedBox(
                                    height: 120,
                                    child: CupertinoPicker(
                                      itemExtent: 36,
                                      scrollController:
                                          FixedExtentScrollController(
                                        initialItem: selectedAge - 13,
                                      ),
                                      onSelectedItemChanged: (index) {
                                        setSheetState(
                                          () => selectedAge = index + 13,
                                        );
                                      },
                                      children: List.generate(
                                        88,
                                        (index) => Center(
                                          child: Text(
                                            '${index + 13}',
                                            style: GoogleFonts.lato(
                                              fontSize: 20,
                                              fontWeight: FontWeight.w700,
                                              color: const Color(0xFF0F172A),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
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
                                      age: selectedAge,
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
    final totalLearningSeconds = progression.totalLearningSeconds;
    final completionStepsLeft = [
      if ((profile?.name ?? '').trim().isEmpty) 'name',
      if (profile?.age == null) 'age',
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
                        streak: progression.activityStreak,
                        completedLessons: completedLessons,
                        currentLesson: progression.currentLessonNumber,
                        onOpenSettings: _openSettings,
                      ),
                      const SizedBox(height: 18),
                      _WeeklyStreakHeatCard(
                        activityStreak: progression.activityStreak,
                        activeDateKeys: progression.weeklyActivityDateKeys,
                      ),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          Expanded(
                            child: _ProfileStatCard(
                              icon: Icons.schedule_rounded,
                              iconColor: const Color(0xFF1E96FF),
                              badgeColor: const Color(0xFFCDE9FF),
                              title: 'Total time',
                              value: _formatDurationLabel(
                                totalLearningSeconds,
                              ),
                              subtitle: 'learning',
                              gradient: const [
                                Color(0xFFEAF7FF),
                                Color(0xFFCDE9FF),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _ProfileStatCard(
                              icon: Icons.flag_rounded,
                              iconColor: const Color(0xFFF59A23),
                              badgeColor: const Color(0xFFFFE7C9),
                              title: 'Total lessons',
                              value: completedLessons.toString(),
                              subtitle: 'completed',
                              gradient: const [
                                Color(0xFFFFF8EF),
                                Color(0xFFFFF0DF),
                              ],
                            ),
                          ),
                        ],
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

  static String _formatDurationLabel(int totalSeconds) {
    if (totalSeconds <= 0) return '0m';
    final totalMinutes = totalSeconds ~/ 60;
    final hours = totalMinutes ~/ 60;
    final minutes = totalMinutes % 60;
    if (hours == 0) return '${totalMinutes}m';
    return '${hours}h ${minutes}m';
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
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFFFFFFF),
            Color(0xFFFCFDFF),
          ],
        ),
        borderRadius: BorderRadius.circular(30),
        boxShadow: const [
          BoxShadow(
            color: Color(0x110F172A),
            blurRadius: 22,
            offset: Offset(0, 12),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
      child: Stack(
        children: [
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
                          handle,
                          style: GoogleFonts.lato(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF756A94),
                            letterSpacing: 0.3,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Color(0xFFFFE7F3),
                                Color(0xFFF4ECFF),
                                Color(0xFFFFF0DE),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(999),
                            border: Border.all(
                              color: const Color(0xFFE8D7FF),
                              width: 1,
                            ),
                          ),
                          child: Text(
                            '- joined ${joinedYear ?? DateTime.now().year}',
                            style: GoogleFonts.lato(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w900,
                              color: const Color(0xFF7A5A96),
                              letterSpacing: 0.15,
                            ),
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
            ],
          ),
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
          boxShadow: const [
            BoxShadow(
              color: Color(0x14000000),
            blurRadius: 18,
            offset: Offset(0, 8),
          ),
        ],
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFFF472B6),
            Color(0xFF9B5CF7),
            Color(0xFFFF8A3D),
          ],
          stops: [0.0, 0.58, 1.0],
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
                fontSize: 15,
                fontWeight: FontWeight.w900,
                color: const Color(0xFF334155),
              ),
          ),
        ],
      ),
    );
  }
}

class _WeeklyStreakHeatCard extends StatelessWidget {
  final int activityStreak;
  final Set<String> activeDateKeys;

  const _WeeklyStreakHeatCard({
    required this.activityStreak,
    required this.activeDateKeys,
  });

  static const List<String> _dayLabels = [
    'Mon',
    'Tue',
    'Wed',
    'Thu',
    'Fri',
    'Sat',
    'Sun',
  ];

  static const List<double> _barHeights = [
    52,
    82,
    62,
    44,
    76,
    56,
    68,
  ];

  static const List<Color> _dayColors = [
    Color(0xFF63D471),
    Color(0xFF4CCB63),
    Color(0xFF57D06B),
    Color(0xFF72D97E),
    Color(0xFF2FC653),
    Color(0xFF66D57A),
    Color(0xFF8AE39A),
  ];

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final todayIndex = now.weekday - 1;
    final monday = DateTime(now.year, now.month, now.day)
        .subtract(Duration(days: now.weekday - 1));
    final activeDayIndexes = <int>{};

    for (var index = 0; index < _dayLabels.length; index++) {
      final day = monday.add(Duration(days: index));
      if (activeDateKeys.contains(_dateKey(day))) {
        activeDayIndexes.add(index);
      }
    }

    return Container(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFF3F8FF),
            Color(0xFFF9F4FF),
          ],
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: const [
          BoxShadow(
            color: Color(0x120F172A),
            blurRadius: 18,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.82),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.auto_graph_rounded,
                      size: 17,
                      color: Color(0xFF6D5DF6),
                    ),
                    const SizedBox(width: 7),
                    Text(
                      'Streak flow',
                      style: GoogleFonts.lato(
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                        color: const Color(0xFF22304A),
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              Text(
                activityStreak == 1 ? '1 day' : '$activityStreak days',
                style: GoogleFonts.lato(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  color: const Color(0xFF6F52C8),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            'A quick look at your weekly rhythm.',
            style: GoogleFonts.lato(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF64748B),
            ),
          ),
          const SizedBox(height: 18),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(_dayLabels.length, (index) {
              final isToday = index == todayIndex;
              final isActive = activeDayIndexes.contains(index);
              return _StreakBarDay(
                label: _dayLabels[index],
                height: _barHeights[index],
                color: _dayColors[index],
                isToday: isToday,
                isActive: isActive,
              );
            }),
          ),
        ],
      ),
    );
  }

  static String _dateKey(DateTime date) {
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '${date.year}-$month-$day';
  }
}

class _StreakBarDay extends StatelessWidget {
  final String label;
  final double height;
  final Color color;
  final bool isToday;
  final bool isActive;

  const _StreakBarDay({
    required this.label,
    required this.height,
    required this.color,
    required this.isToday,
    required this.isActive,
  });

  @override
  Widget build(BuildContext context) {
    final outerGlow = isToday
        ? color.withValues(alpha: isActive ? 0.30 : 0.14)
        : Colors.transparent;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 38,
          height: 92,
          alignment: Alignment.bottomCenter,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 350),
            curve: Curves.easeOutCubic,
            width: 30,
            height: height,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(999),
              border: Border.all(
                color: isToday
                    ? color.withValues(alpha: 0.95)
                    : isActive
                        ? Colors.transparent
                        : const Color(0xFFD9E2F2),
                width: isToday ? 2.0 : 1.2,
              ),
              gradient: isActive
                  ? LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        color.withValues(alpha: isToday ? 1.0 : 0.92),
                        color.withValues(alpha: isToday ? 0.78 : 0.68),
                      ],
                    )
                  : LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: isToday
                          ? [
                              const Color(0xFFEAE3FF),
                              const Color(0xFFF5F1FF),
                            ]
                          : [
                              const Color(0xFFF6F8FC),
                              const Color(0xFFEDF2F8),
                            ],
                    ),
              boxShadow: outerGlow == Colors.transparent
                  ? null
                  : [
                      BoxShadow(
                        color: outerGlow,
                        blurRadius: 14,
                        offset: const Offset(0, 8),
                      ),
                    ],
            ),
          ),
        ),
        const SizedBox(height: 10),
        Text(
          label,
          style: GoogleFonts.lato(
            fontSize: 13.8,
            fontWeight: FontWeight.w900,
            color: isToday ? const Color(0xFF1F2937) : const Color(0xFF7B8799),
          ),
        ),
      ],
    );
  }
}

class _ProfileStatCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color badgeColor;
  final String title;
  final String value;
  final String subtitle;
  final List<Color> gradient;

  const _ProfileStatCard({
    required this.icon,
    required this.iconColor,
    required this.badgeColor,
    required this.title,
    required this.value,
    required this.subtitle,
    required this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: gradient,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0F0F172A),
            blurRadius: 14,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
            decoration: BoxDecoration(
              color: badgeColor,
              borderRadius: BorderRadius.circular(999),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 17, color: iconColor),
                const SizedBox(width: 6),
                Text(
                  title,
                  style: GoogleFonts.lato(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w900,
                    color: const Color(0xFF24324A),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 22),
          Text(
            value,
            style: GoogleFonts.lato(
              fontSize: 32,
              fontWeight: FontWeight.w900,
              color: const Color(0xFF0F172A),
              height: 1,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            style: GoogleFonts.lato(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF758296),
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
        const LoadingSkeleton(height: 186),
        const SizedBox(height: 14),
        const Row(
          children: [
            Expanded(child: LoadingSkeleton(height: 150)),
            SizedBox(width: 12),
            Expanded(child: LoadingSkeleton(height: 150)),
          ],
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}
