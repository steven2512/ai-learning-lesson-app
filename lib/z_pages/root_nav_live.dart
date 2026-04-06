library root_nav_scaffold;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:running_robot/core/app_router.dart';
import 'package:running_robot/z_pages/assets/lessonPage/lesson_page.dart';
import 'package:running_robot/z_pages/assets/mainMenu/main_menu.dart';
import 'package:running_robot/z_pages/assets/settings/settings_page_live.dart';

class RootNavScaffold extends StatefulWidget {
  final AppNavigate onNavigate;
  final int initialIndex; // 0=Home, 1=Lessons, 2=Settings

  const RootNavScaffold({
    super.key,
    required this.onNavigate,
    this.initialIndex = 0,
  });

  @override
  State<RootNavScaffold> createState() => _RootNavScaffoldState();
}

class _RootNavScaffoldState extends State<RootNavScaffold> {
  late int _index = widget.initialIndex.clamp(0, 2);
  final PageStorageBucket _bucket = PageStorageBucket();

  late final List<Widget> _tabs = <Widget>[
    MainMenuPage(onNavigate: widget.onNavigate),
    LessonPage(
      onNavigate: widget.onNavigate,
      key: const PageStorageKey('lessons_tab'),
    ),
    const SettingsPage(),
  ];

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
          indicatorColor: Colors.black.withValues(alpha: 0.06),
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
