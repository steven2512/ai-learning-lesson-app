/// FILE: lib/z_pages/assets/settings/settings_page.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:running_robot/ui/buttons/avatar.dart';
import 'package:running_robot/z_pages/assets/mainMenu/bell.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          const Positioned.fill(child: ColoredBox(color: Colors.white)),

          // === Avatar (exact same position as Home) ===
          Positioned(
            left: 19,
            top: 60,
            child: ProfileAvatar(
              size: 55,
              image: const AssetImage("assets/images/default_avatar.png"),
              imageScale: 1.2,
              onPressed: () => print("Avatar tapped!"),
              fillColor: const Color.fromARGB(255, 228, 228, 228),
            ),
          ),

          // === Greeting + Name + Bell (exact same offset as Home) ===
          Positioned(
            left: 86,
            right: 24,
            top: 67,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Good afternoon!",
                        style: GoogleFonts.lato(
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                          color: Colors.black87,
                          height: 0.9,
                          letterSpacing: 0.1,
                        ),
                      ),
                      Text(
                        "Steven Duong",
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
                      subtitle: "English (US)",
                      onTap: () {},
                    ),
                    _SettingsTile(
                      icon: Icons.dark_mode_outlined,
                      title: "Dark Mode",
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
                      onTap: () {},
                    ),
                    _SettingsTile(
                      icon: Icons.lock_outline,
                      title: "Privacy",
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
                      subtitle: "Version 1.0.0",
                      onTap: () {},
                    ),
                  ],
                ),
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
