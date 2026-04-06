import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart'; // ✅ Added for CupertinoPageRoute
import 'package:google_fonts/google_fonts.dart';
import 'package:running_robot/z_pages/assets/lessonAssets/helpful_tools.dart'; // LessonText
import 'package:running_robot/auth/start_button.dart'; // PillCta
import 'login_page_live.dart';
import 'signup_page_live.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  // ✅ NEW: Pure right-to-left slide
  Route _slideRightToLeft(Widget page) {
    return CupertinoPageRoute(builder: (_) => page);
  }

  @override
  Widget build(BuildContext context) {
    const Color kBrandPurple = Color(0xFF7F56D9);
    final screenWidth = MediaQuery.of(context).size.width;
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
                SizedBox(
                  height: topH,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(28, 24, 28, 0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF7F1FF),
                            borderRadius: BorderRadius.circular(32),
                          ),
                          child: Image.asset(
                            'assets/images/ai_learning.png',
                            fit: BoxFit.contain,
                            height: topH * 0.48,
                            errorBuilder: (_, __, ___) => const Icon(
                              Icons.smart_toy_outlined,
                              size: 96,
                              color: Colors.black26,
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          'Learn AI through short, interactive lessons.',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.lato(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Build intuition with guided activities, not just long explanations.',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.lato(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: Colors.black54,
                            height: 1.35,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  height: bottomH,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      PillCta(
                        fontSize: 24,
                        width: screenWidth / 1.5,
                        height: 60,
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
