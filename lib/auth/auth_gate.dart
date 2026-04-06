import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:running_robot/my_app.dart';
import 'package:running_robot/services/app_progression_controller.dart';
import 'package:running_robot/auth/welcome_page.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (snapshot.hasData) {
          AppProgressionController.instance.load();
          return const MyApp(); // ✅ Logged in → main app
        }
        AppProgressionController.instance.clear();
        return const WelcomePage(); // ❌ Not logged in → landing
      },
    );
  }
}
