/// FILE: lib/ui/root_nav_scaffold.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:running_robot/core/app_router.dart';
import 'package:running_robot/z_pages/assets/lessonPage/lesson_page.dart';
import 'package:running_robot/z_pages/assets/mainMenu/main_menu.dart';
import 'package:running_robot/z_pages/assets/settings/setting.dart';

/// RootNavScaffold
/// - Hosts a bottom NavigationBar (Material 3)
/// - Switches tabs instantly via IndexedStack (no router, no flicker)
/// - Preserves tab state & scroll positions with PageStorage
class RootNavScaffold extends StatefulWidget {
  final AppNavigate onNavigate;
  final int initialIndex; // 0=Home, 1=Lessons, 2=Puzzles, 3=Settings

  const RootNavScaffold({
    super.key,
    required this.onNavigate,
    this.initialIndex = 0,
  });

  @override
  State<RootNavScaffold> createState() => _RootNavScaffoldState();
}

class _RootNavScaffoldState extends State<RootNavScaffold> {
  late int _index = widget.initialIndex;
  final PageStorageBucket _bucket = PageStorageBucket();

  late final List<Widget> _tabs = <Widget>[
    // HOME
    MainMenuPage(onNavigate: widget.onNavigate),

    // LESSONS
    LessonPage(
      onNavigate: widget.onNavigate,
      key: const PageStorageKey('lessons_tab'),
    ),

    // PUZZLES
    const _SimpleScaffold(
      title: 'Puzzles',
      body: Center(child: Text('Puzzle-solving games will appear here')),
      storageKey: PageStorageKey('puzzles_tab'),
    ),

    // SETTINGS (now a full SettingsPage)
    const SettingsPage(),
  ];

  @override
  void initState() {
    super.initState();
    _precacheTabAssets();
  }

  Future<void> _precacheTabAssets() async {
    final ctx = context;
    // Example assets — replace with real ones you use in each tab
    precacheImage(const AssetImage("assets/images/home_banner.png"), ctx);
    precacheImage(const AssetImage("assets/images/robot.png"), ctx);
    precacheImage(const AssetImage("assets/images/lesson_cover.png"), ctx);
    precacheImage(const AssetImage("assets/images/book.png"), ctx);
    precacheImage(const AssetImage("assets/images/settings_icon.png"), ctx);
    precacheImage(
        const AssetImage("assets/images/puzzle_placeholder.png"), ctx);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageStorage(
        bucket: _bucket,
        child: IndexedStack(index: _index, children: _tabs),
      ),
      bottomNavigationBar: NavigationBarTheme(
        data: NavigationBarThemeData(
          height: 64,
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.transparent,
          elevation: 2,
          indicatorColor: Colors.black.withOpacity(0.06),
          indicatorShape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          labelTextStyle: WidgetStateProperty.resolveWith<TextStyle?>(
            (states) => GoogleFonts.lato(
              fontSize: 12,
              fontWeight: states.contains(WidgetState.selected)
                  ? FontWeight.w700
                  : FontWeight.w600,
              letterSpacing: 0.1,
              color: Colors.black87,
            ),
          ),
          iconTheme: WidgetStateProperty.resolveWith<IconThemeData?>(
            (states) => IconThemeData(
              size: 24,
              color: states.contains(WidgetState.selected)
                  ? Colors.black87
                  : Colors.black54,
            ),
          ),
        ),
        child: NavigationBar(
          selectedIndex: _index,
          onDestinationSelected: (i) => setState(() => _index = i),
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home_rounded),
              label: 'Home',
            ),
            NavigationDestination(
              icon: Icon(Icons.menu_book_outlined),
              selectedIcon: Icon(Icons.menu_book_rounded),
              label: 'Lessons',
            ),
            NavigationDestination(
              icon: Icon(Icons.interests_outlined), // 🧩 puzzles vibe
              selectedIcon: Icon(Icons.interests),
              label: 'Puzzles',
            ),
            NavigationDestination(
              icon: Icon(Icons.settings_outlined),
              selectedIcon: Icon(Icons.settings_rounded),
              label: 'Settings',
            ),
          ],
        ),
      ),
    );
  }
}

/// Still used for stub tabs (like Puzzles until you build it out)
class _SimpleScaffold extends StatelessWidget {
  final String title;
  final Widget body;
  final PageStorageKey storageKey;

  const _SimpleScaffold({
    required this.title,
    required this.body,
    required this.storageKey,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: storageKey,
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0.5,
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        title: Text(
          title,
          style: GoogleFonts.lato(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: Colors.black,
            letterSpacing: 0.2,
          ),
        ),
        centerTitle: false,
      ),
      body: body,
    );
  }
}
