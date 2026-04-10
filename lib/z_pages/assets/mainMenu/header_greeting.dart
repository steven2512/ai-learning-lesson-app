// FILE: lib/z_pages/assets/common/header_greeting.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cached_network_image/cached_network_image.dart'; // ✅ for local caching
import 'package:running_robot/core/progression_scope.dart';
import 'package:running_robot/z_pages/assets/mainMenu/bell.dart';

class HeaderGreeting extends StatelessWidget {
  final double topOffset;
  const HeaderGreeting({super.key, this.topOffset = 60});

  @override
  Widget build(BuildContext context) {
    final progression = ProgressionScope.watch(context);
    final profile = progression.profile;
    final user = FirebaseAuth.instance.currentUser;
    final displayName = (profile?.name?.trim().isNotEmpty ?? false)
        ? profile!.name!.trim()
        : (user?.displayName?.trim().isNotEmpty ?? false)
            ? user!.displayName!.trim()
            : "User";
    final photoUrl = (profile?.photoUrl?.trim().isNotEmpty ?? false)
        ? profile!.photoUrl!.trim()
        : user?.photoURL;
    final initial = displayName.trim().isEmpty
        ? 'U'
        : displayName.trim()[0].toUpperCase();

    ImageProvider<Object>? avatarProvider;
    if (photoUrl != null && photoUrl.isNotEmpty) {
      avatarProvider = CachedNetworkImageProvider(photoUrl);
    } else {
      avatarProvider = null;
    }

    return Stack(
      children: [
        Positioned(
          left: 19,
          top: topOffset,
          child: _HeaderAvatarBadge(
            size: 60,
            image: avatarProvider,
            initial: initial,
            onPressed: () => debugPrint("Avatar tapped!"),
          ),
        ),
        Positioned(
          left: 86,
          right: 24,
          top: topOffset + 7,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Welcome back!",
                      style: GoogleFonts.lato(
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                        color: Colors.black87,
                        height: 0.9,
                        letterSpacing: 0.1,
                      ),
                    ),
                    Text(
                      displayName,
                      style: GoogleFonts.lato(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: Colors.black,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Container(
                padding: const EdgeInsets.only(top: 3, right: 8),
                child: const Bell(),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _HeaderAvatarBadge extends StatelessWidget {
  final double size;
  final ImageProvider<Object>? image;
  final String initial;
  final VoidCallback onPressed;

  const _HeaderAvatarBadge({
    required this.size,
    required this.image,
    required this.initial,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      shape: const CircleBorder(),
      child: InkWell(
        onTap: onPressed,
        customBorder: const CircleBorder(),
        child: Container(
          width: size,
          height: size,
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
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF8B5CF6),
                Color(0xFF5B8DEF),
                ],
              ),
            ),
          child: Padding(
            padding: const EdgeInsets.all(3),
            child: ClipOval(
              child: image != null
                  ? Image(
                      image: image!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _fallback(),
                    )
                  : _fallback(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _fallback() {
    return Container(
      color: const Color(0xFFF1EBFF),
      alignment: Alignment.center,
      child: Text(
        initial,
        style: GoogleFonts.lato(
          fontSize: 24,
          fontWeight: FontWeight.w900,
          color: const Color(0xFF41356F),
        ),
      ),
    );
  }
}
