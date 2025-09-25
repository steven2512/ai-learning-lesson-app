// lib/ui/welcome_page.dart
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart'; // ✅ Added for CupertinoPageRoute
import 'package:google_fonts/google_fonts.dart';
import 'package:running_robot/z_pages/assets/lessonAssets/helpful_tools.dart'; // LessonText
import 'package:running_robot/z_pages/assets/lessonAssets/start_button.dart'; // PillCta
import 'login_page.dart';
import 'signup_page.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  // ✅ NEW: Pure right-to-left slide (both pages move), platform-consistent.
  // Uses CupertinoPageRoute which animates incoming from right and outgoing to left.
  Route _slideRightToLeft(Widget page) {
    return CupertinoPageRoute(builder: (_) => page);
  }

  @override
  Widget build(BuildContext context) {
    // Brand purple (unique to your app)
    const Color kBrandPurple = Color(0xFF7F56D9);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final h = constraints.maxHeight;
            final topH = h * 0.80;
            final bottomH = h * 0.20;

            return Column(
              children: [
                // -------- Top 80%: Illustration --------
                SizedBox(
                  height: topH,
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.auto_awesome,
                            size: 96, color: Colors.black12),
                        const SizedBox(height: 12),
                        Text(
                          'AI Illustration Placeholder',
                          style: GoogleFonts.lato(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.black26,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // -------- Bottom 20%: CTA --------
                SizedBox(
                  height: bottomH,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // 🔁 CHANGED: Use _slideRightToLeft instead of fade route.
                      PillCta(
                        padding: EdgeInsetsDirectional.symmetric(
                            horizontal: 120, vertical: 20),
                        fontSize: 22,
                        label: 'Get Started',
                        color: kBrandPurple,
                        onTap: () => Navigator.of(context)
                            .push(_slideRightToLeft(const SignupPage())),
                      ),
                      const SizedBox(height: 18),
                      GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () => Navigator.of(context)
                            .push(_slideRightToLeft(const LoginPage())),
                        child: LessonText.sentence(
                          [
                            LessonText.word(
                              'Already existing user?',
                              Colors.black87,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                            LessonText.word(
                              'Log in',
                              Colors.black87,
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              underline: true,
                            ),
                          ],
                          alignment: WrapAlignment.center,
                          constrainWidth: false,
                        ),
                      ),
                      const SizedBox(height: 10),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
