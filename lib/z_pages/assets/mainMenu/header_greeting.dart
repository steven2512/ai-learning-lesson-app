// FILE: lib/z_pages/assets/common/header_greeting.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart'; // ✅ for local caching
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
      // Load profile basics
      setState(() {
        _displayName = user.displayName ?? "User";
      });

      try {
        // 🔹 Fetch latest photoUrl from Firestore (faster + more consistent)
        final doc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        if (doc.exists && doc.data()?['photoUrl'] != null) {
          setState(() {
            _photoUrl = doc.data()!['photoUrl'] as String;
          });
        } else {
          // fallback to FirebaseAuth photoURL
          setState(() {
            _photoUrl = user.photoURL;
          });
        }
      } catch (e) {
        debugPrint("⚠️ Failed to fetch Firestore user photo: $e");
        setState(() {
          _photoUrl = user.photoURL;
        });
      }
    }
  }

  // ✅ Helper: always returns an ImageProvider<Object>
  ImageProvider<Object> _getAvatarProvider() {
    if (_photoUrl != null && _photoUrl!.isNotEmpty) {
      return CachedNetworkImageProvider(_photoUrl!); // cached locally
    }
    return const AssetImage("assets/images/robot_family1.jpg");
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
            image: _getAvatarProvider(),
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
