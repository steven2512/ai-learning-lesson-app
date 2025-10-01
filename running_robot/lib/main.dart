import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:running_robot/auth/auth_gate.dart'; // 🔹 New file

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MaterialApp(home: AuthGate()));
}
