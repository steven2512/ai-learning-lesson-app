import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'welcome_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MaterialApp(home: WelcomePage()));
}
