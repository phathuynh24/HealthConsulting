import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:assist_health/src/config/firebase_options.dart';
import 'package:assist_health/src/app/my_app.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  await dotenv.load(fileName: "assets/.evn");

  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}
