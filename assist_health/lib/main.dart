import 'package:assist_health/firebase_options.dart';
import 'package:assist_health/video_call/pages/local_notifications.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:assist_health/ui/other_screens/welcome.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/date_symbol_data_local.dart';

final navigatorKey = GlobalKey<NavigatorState>();
FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await LocalNotifications.init();

  //  handle in terminated state
  var initialNotification =
      await flutterLocalNotificationsPlugin.getNotificationAppLaunchDetails();
  if (initialNotification?.didNotificationLaunchApp == true) {
    // LocalNotifications.onClickNotification.stream.listen((event) {
    Future.delayed(const Duration(seconds: 1), () {
      // print(event);
      // navigatorKey.currentState!.pushNamed('/another',
      //     arguments: initialNotification?.notificationResponse?.payload);
    });
  }
  initializeDateFormatting('en_US').then((_) {
    // Khởi chạy ứng dụng của bạn
    runApp(const MyApp());
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: false,
      home: const WelcomeScreen(),
    );
  }
}
