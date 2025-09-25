import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:running_robot/my_app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(); // silently connects to Firebase
  runApp(const MyApp());
}
