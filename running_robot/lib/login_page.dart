import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: .5,
        title: Text('Log In',
            style: GoogleFonts.lato(
                fontWeight: FontWeight.w800, color: Colors.black)),
      ),
      body: Center(
        child:
            Text('Login UI coming next', style: GoogleFonts.lato(fontSize: 16)),
      ),
    );
  }
}
