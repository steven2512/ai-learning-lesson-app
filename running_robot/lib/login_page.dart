// lib/ui/login_page.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:running_robot/z_pages/assets/lessonAssets/start_button.dart'; // PillCta

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    const Color kBrandPurple = Color(0xFF7F56D9);

    final media = MediaQuery.of(context);
    final double appBarTotal = kToolbarHeight + media.padding.top;
    final double delta = appBarTotal - media.padding.bottom;

    final Widget topExtra =
        delta < 0 ? SizedBox(height: -delta) : const SizedBox.shrink();
    final Widget bottomExtra =
        delta > 0 ? SizedBox(height: delta) : const SizedBox.shrink();

    // 👇 NEW: nudge the whole block lower by this much
    const double topOffset = 40; // adjust to taste

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: .5,
        title: Text(
          'Log In',
          style: GoogleFonts.lato(
            fontWeight: FontWeight.w800,
            color: Colors.black,
          ),
        ),
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 28),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        topExtra,
                        SizedBox(height: topOffset), // 👈 NEW

                        const Spacer(),

                        // --- Header ---
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Welcome back",
                                style: GoogleFonts.lato(
                                  fontSize: 35,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                "Please log in to continue",
                                style: GoogleFonts.lato(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w400,
                                  color: Colors.black54,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 28),

                        // --- Email ---
                        TextField(
                          decoration: InputDecoration(
                            hintText: 'Email',
                            hintStyle: GoogleFonts.lato(color: Colors.black45),
                            filled: true,
                            fillColor: Colors.grey.shade100,
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 18),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // --- Password ---
                        TextField(
                          obscureText: true,
                          decoration: InputDecoration(
                            hintText: 'Password',
                            hintStyle: GoogleFonts.lato(color: Colors.black45),
                            filled: true,
                            fillColor: Colors.grey.shade100,
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 18),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                        const SizedBox(height: 28),

                        // --- CTA ---
                        PillCta(
                          label: 'Log In',
                          color: kBrandPurple,
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Login tapped')),
                            );
                          },
                        ),
                        const SizedBox(height: 28),

                        // --- Divider ---
                        Row(
                          children: [
                            const Expanded(child: Divider(thickness: .6)),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 12),
                              child: Text(
                                'Or login with',
                                style: GoogleFonts.lato(color: Colors.black54),
                              ),
                            ),
                            const Expanded(child: Divider(thickness: .6)),
                          ],
                        ),
                        const SizedBox(height: 24),

                        // --- Socials ---
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _socialButtonGoogle(),
                            const SizedBox(width: 20),
                            _socialButtonFacebook(),
                          ],
                        ),

                        const Spacer(),

                        bottomExtra,
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  // Google
  Widget _socialButtonGoogle() {
    return Container(
      width: 90,
      height: 56,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black12, width: 1),
        color: Colors.white,
      ),
      child: Center(
        child: Image.asset(
          'assets/images/google_icon.png',
          height: 28,
        ),
      ),
    );
  }

  // Facebook
  Widget _socialButtonFacebook() {
    return Container(
      width: 90,
      height: 56,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black12, width: 1),
        color: Colors.white,
      ),
      child: const Icon(Icons.facebook, size: 38, color: Color(0xFF1877F2)),
    );
  }
}
