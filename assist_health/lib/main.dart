import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:assist_health/src/config/firebase_options.dart';
import 'package:assist_health/src/app/my_app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}
