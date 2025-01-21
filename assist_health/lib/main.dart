import 'package:flutter/material.dart';
import 'package:assist_health/src/app/my_app.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:assist_health/src/config/firebase_options.dart';

Future<void> main() async {
  // Catch global errors
  FlutterError.onError = (FlutterErrorDetails details) {
    debugPrint("Flutter Error: ${details.exception}");
  };

  try {
    // Load environment variables
    await dotenv.load(fileName: "assets/.evn");

    // Ensure proper initialization of Flutter bindings
    WidgetsFlutterBinding.ensureInitialized();

    // Initialize Firebase
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    // Initialize Firebase App Check
    await FirebaseAppCheck.instance.activate(
      androidProvider: AndroidProvider.playIntegrity,
    );

    // Set Firebase Auth language to Vietnamese
    FirebaseAuth.instance.setLanguageCode('vi');

    // Initialize date formatting
    initializeDateFormatting('vi');

    // Start the app
    runApp(
      ScreenUtilInit(
        designSize: const Size(450, 812),
        builder: (context, child) => const MyApp(),
      ),
    );
  } catch (e, stackTrace) {
    debugPrint("Main initialization error: $e");
    debugPrint("StackTrace: $stackTrace");
  }
}
