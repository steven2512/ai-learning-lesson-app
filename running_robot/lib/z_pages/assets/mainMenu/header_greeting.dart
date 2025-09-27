// FILE: lib/z_pages/assets/common/header_greeting.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:running_robot/z_pages/assets/mainMenu/avatar.dart';
import 'package:running_robot/z_pages/assets/mainMenu/bell.dart';

class HeaderGreeting extends StatefulWidget {
  final double topOffset;
  const HeaderGreeting({super.key, this.topOffset = 60});

  @override
  State<HeaderGreeting> createState() => _HeaderGreetingState();
}

class _HeaderGreetingState extends State<HeaderGreeting> {
  String? _photoUrl;
  String _displayName = "User";

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      // Always keep displayName from Firebase
      setState(() {
        _displayName = user.displayName ?? "User";
      });

      // Try to fetch real picture from Facebook Graph API
      try {
        final userData = await FacebookAuth.instance.getUserData(
          fields:
              "id,name,email,picture.width(256).height(256){url,is_silhouette}",
        );
        final pic = userData['picture']?['data'];
        final bool isSilhouette = (pic?['is_silhouette'] ?? true) as bool;
        final String? url = isSilhouette ? null : (pic?['url'] as String?);

        if (url != null && url.isNotEmpty) {
          // Update FirebaseAuth user photo too, for consistency
          await user.updatePhotoURL(url);
          await user.reload();

          setState(() {
            _photoUrl = url;
          });
        } else {
          // fallback to Firebase photoURL (may be null or silhouette)
          setState(() {
            _photoUrl = user.photoURL;
          });
        }
      } catch (e) {
        debugPrint("⚠️ Failed to fetch Facebook picture: $e");
        setState(() {
          _photoUrl = user.photoURL;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          left: 19,
          top: widget.topOffset,
          child: ProfileAvatar(
            size: 55,
            image: (_photoUrl != null && _photoUrl!.isNotEmpty)
                ? NetworkImage(_photoUrl!)
                : const AssetImage("assets/images/default_avatar.png")
                    as ImageProvider,
            imageScale: 1.2,
            onPressed: () => debugPrint("Avatar tapped!"),
            fillColor: const Color.fromARGB(255, 228, 228, 228),
          ),
        ),
        Positioned(
          left: 86,
          right: 24,
          top: widget.topOffset + 7,
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
                      _displayName,
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
