import 'package:flutter/material.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart'; // 🔹 Added for logout
import 'package:google_sign_in/google_sign_in.dart';
import 'package:running_robot/z_pages/assets/mainMenu/header_greeting.dart'; // 👈 Reuse header

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          const Positioned.fill(child: ColoredBox(color: Colors.white)),

          // === Reusable HeaderGreeting (avatar + name + bell) ===
          const HeaderGreeting(),

          // === Settings list content (starts below header) ===
          Positioned.fill(
            top: 140, // same drop as Home’s main content start
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              children: [
                _SettingsSection(
                  title: "General",
                  children: [
                    _SettingsTile(
                      icon: Icons.language,
                      title: "Language",
                      subtitle: "(in development 🛠️)",
                      onTap: () {},
                    ),
                    _SettingsTile(
                      icon: Icons.dark_mode_outlined,
                      title: "Dark Mode",
                      subtitle: "(in development 🛠️)",
                      trailing: Switch(
                        value: false,
                        onChanged: (v) {}, // TODO: hook into theme
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _SettingsSection(
                  title: "Account",
                  children: [
                    _SettingsTile(
                      icon: Icons.person_outline,
                      title: "Profile",
                      subtitle: "(in development 🛠️)",
                      onTap: () {},
                    ),
                    _SettingsTile(
                      icon: Icons.lock_outline,
                      title: "Privacy",
                      subtitle: "(in development 🛠️)",
                      onTap: () {},
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _SettingsSection(
                  title: "About",
                  children: [
                    _SettingsTile(
                      icon: Icons.info_outline,
                      title: "About App",
                      subtitle: "(in development 🛠️)",
                      onTap: () {},
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // === Log Out Button (red text) ===
                Center(
                  child: TextButton(
                    onPressed: () async {
                      await FirebaseAuth.instance.signOut();
                      await FacebookAuth.instance.logOut();
                      await GoogleSignIn.instance.signOut();
                    },
                    child: Text(
                      "Log Out",
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

/// Section wrapper with title
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
          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
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

/// Individual tile
class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;

  const _SettingsTile({
    required this.icon,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
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
      subtitle: subtitle != null
          ? Text(
              subtitle!,
              style: GoogleFonts.lato(
                fontSize: 13,
                fontWeight: FontWeight.w400,
                color: Colors.black54,
              ),
            )
          : null,
      trailing:
          trailing ?? const Icon(Icons.chevron_right, color: Colors.black26),
      onTap: onTap,
    );
  }
}
