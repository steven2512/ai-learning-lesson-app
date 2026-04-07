// FILE: lib/z_pages/assets/common/header_greeting.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cached_network_image/cached_network_image.dart'; // ✅ for local caching
import 'package:running_robot/core/progression_scope.dart';
import 'package:running_robot/z_pages/assets/mainMenu/avatar.dart';
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

    ImageProvider<Object> avatarProvider;
    if (photoUrl != null && photoUrl.isNotEmpty) {
      avatarProvider = CachedNetworkImageProvider(photoUrl);
    } else {
      avatarProvider = const AssetImage("assets/images/robot_family1.jpg");
    }

    return Stack(
      children: [
        Positioned(
          left: 19,
          top: topOffset,
          child: ProfileAvatar(
            size: 55,
            image: avatarProvider,
            imageScale: 1.2,
            onPressed: () => debugPrint("Avatar tapped!"),
            fillColor: const Color.fromARGB(255, 228, 228, 228),
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
