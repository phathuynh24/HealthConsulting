import 'dart:io';
// import 'dart:ui';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
//import 'package:flutter_push_notifications/utils/download_util.dart';
import 'package:rxdart/subjects.dart';
//import 'package:timezone/data/latest_all.dart' as tz;
//import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  NotificationService();

  final _localNotifications = FlutterLocalNotificationsPlugin();
  final BehaviorSubject<String> behaviorSubject = BehaviorSubject();

  Future<void> initializePlatformNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('Health Care');

    // final IOSInitializationSettings initializationSettingsIOS =
    //     IOSInitializationSettings(
    //         requestSoundPermission: true,
    //         requestBadgePermission: true,
    //         requestAlertPermission: true,
    //         onDidReceiveLocalNotification: onDidReceiveLocalNotification);

    final InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      //iOS: initializationSettingsIOS,
    );

    await _localNotifications.initialize(
      initializationSettings, /*onDidReceiveNotificationResponse: selectNotification()*/
    );
  }

  // void onDidReceiveLocalNotification(
  //     int id, String? title, String? body, String? payload) {
  //   print('id $id');
  // }

  // void selectNotification(String? payload) {
  //   if (payload != null && payload.isNotEmpty) {
  //     behaviorSubject.add(payload);
  //   }
  // }

  Future<NotificationDetails> _notificationDetails() async {
    // final bigPicture = await DownloadUtil.downloadAndSaveFile(
    //     "https://images.unsplash.com/photo-1624948465027-6f9b51067557?ixlib=rb-1.2.1&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=1470&q=80",
    //     "drinkwater");

    AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'channel id',
      'channel name',
      //groupKey: 'com.example.assist_health',
      //channelDescription: 'channel description',
      importance: Importance.max,
      priority: Priority.max,
      // playSound: true,
      // ticker: 'ticker',
      //largeIcon: const DrawableResourceAndroidBitmap('assets/lined heart.png'),
      // styleInformation: BigPictureStyleInformation(
      //   FilePathAndroidBitmap(bigPicture),
      //   hideExpandedLargeIcon: false,
      // ),
      // color: const Color(0xff2196f3),
    );

    // IOSNotificationDetails iosNotificationDetails = IOSNotificationDetails(
    //     threadIdentifier: "thread1",
    //     attachments: <IOSNotificationAttachment>[
    //       IOSNotificationAttachment(bigPicture)
    //     ]);

    // final details = await _localNotifications.getNotificationAppLaunchDetails();
    // if (details != null && details.didNotificationLaunchApp) {
    //   behaviorSubject.add('123abc');
    // }
    NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics, /*iOS: iosNotificationDetails*/
    );

    return platformChannelSpecifics;
  }

  Future<void> showLocalNotification({
    required int id,
    required String title,
    required String body,
  }) async {
    final platformChannelSpecifics = await _notificationDetails();

    await _localNotifications.show(
      id,
      title,
      body,
      platformChannelSpecifics,
    );
  }
}

class DownloadUtil {
  static Future<String> downloadAndSaveFile(String url, String fileName) async {
    final Directory directory = await getApplicationDocumentsDirectory();
    final String filePath = '${directory.path}/$fileName.png';
    final http.Response response = await http.get(Uri.parse(url));
    final File file = File(filePath);
    await file.writeAsBytes(response.bodyBytes);
    return filePath;
  }
}
