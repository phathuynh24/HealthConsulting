// ignore_for_file: avoid_print, file_names

import 'dart:async';

import 'package:assist_health/models/doctor/doctor_experience.dart';
import 'package:assist_health/models/doctor/doctor_info.dart';
import 'package:assist_health/models/doctor/doctor_schedule.dart';
import 'package:assist_health/models/doctor/doctor_service.dart';
import 'package:assist_health/models/doctor/doctor_study.dart';
import 'package:assist_health/models/doctor/doctor_timeline.dart';
import 'package:assist_health/models/other/appointment_schedule.dart';
import 'package:assist_health/models/user/user_bmi.dart';
import 'package:assist_health/models/user/user_profile.dart';
import 'package:assist_health/models/user/user_height.dart';
import 'package:assist_health/models/user/user_temperature.dart';
import 'package:assist_health/models/user/user_weight.dart';
import 'package:assist_health/ui/other_screens/login.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_styled_toast/flutter_styled_toast.dart';
import 'package:intl/intl.dart';

FirebaseAuth _auth = FirebaseAuth.instance;
FirebaseFirestore _firestore = FirebaseFirestore.instance;

Future<User?> createAccount(
    String name, String email, String password, String phone) async {
  try {
    UserCredential userCrendetial = await _auth.createUserWithEmailAndPassword(
        email: email, password: password);

    print("Account created Succesfull");

    userCrendetial.user!.updateDisplayName(name);

    await _firestore.collection('users').doc(_auth.currentUser!.uid).set({
      "name": name,
      "email": email,
      "phone": phone,
      "role": "user",
      "status": "unavalible",
      "uid": _auth.currentUser!.uid,
    });

    return userCrendetial.user;
  } catch (e) {
    print(e);
    return null;
  }
}

Future<User?> logIn(String email, String password) async {
  try {
    UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email, password: password);

    print("Login Sucessfull");
    _firestore
        .collection('users')
        .doc(_auth.currentUser!.uid)
        .get()
        .then((value) => userCredential.user!.updateDisplayName(value['name']));

    return userCredential.user;
  } catch (e) {
    print(e);
    return null;
  }
}

Future logOut(BuildContext context) async {
  try {
    await _auth.signOut().then((value) {
      Navigator.push(
          context, MaterialPageRoute(builder: (_) => const LoginScreen()));
    });
  } catch (e) {
    print("error");
  }
}

Future<String> getUrl(String fileName) async {
  final ref = storage.ref().child('Doctors/$fileName');
  String url = await ref.getDownloadURL();
  return url;
}

Stream<List<DoctorInfo>> getInfoDoctors() {
  return _firestore
      .collection('users')
      .where('role', isEqualTo: 'doctor')
      .snapshots()
      .map((QuerySnapshot querySnapshot) {
    final List<DoctorInfo> doctorInfos = [];

    for (var doctorDoc in querySnapshot.docs) {
      final doctorData = doctorDoc.data() as Map<String, dynamic>?;
      final DoctorInfo doctorInfo = DoctorInfo.fromJson(doctorData!);
      doctorInfos.add(doctorInfo);
    }

    return doctorInfos;
  });
}

Future<List<DoctorExperience>> getExperiencesDoctor(String uid) async {
  List<DoctorExperience> doctorExperiences = [];

  final docRef = await _firestore
      .collection('users')
      .doc(uid)
      .collection('experience')
      .get();

  final listOfExperiences = docRef.docs.map((experienceDoc) {
    if (experienceDoc.exists) {
      final data = experienceDoc.data();
      final doctorExperience = DoctorExperience.fromJson(data);
      return doctorExperience;
    } else {
      return null;
    }
  }).whereType<DoctorExperience>();

  doctorExperiences.addAll(listOfExperiences);

  return doctorExperiences;
}

Future<List<DoctorStudy>> getStudysDoctor(String uid) async {
  List<DoctorStudy> doctorStudys = [];

  final docRef =
      await _firestore.collection('users').doc(uid).collection('study').get();

  final listOfStudys = docRef.docs.map((studyDoc) {
    if (studyDoc.exists) {
      final data = studyDoc.data();
      final doctorExperience = DoctorStudy.fromJson(data);
      return doctorExperience;
    } else {
      return null;
    }
  }).whereType<DoctorStudy>();

  doctorStudys.addAll(listOfStudys);

  return doctorStudys;
}

Future<List<DoctorService>> getServicesDoctor(String uid) async {
  List<DoctorService> doctorServices = [];

  final docRef =
      await _firestore.collection('users').doc(uid).collection('service').get();

  final listOfStudys = docRef.docs.map((serviceDoc) {
    if (serviceDoc.exists) {
      final data = serviceDoc.data();
      final doctorService = DoctorService.fromJson(data);
      return doctorService;
    } else {
      return null;
    }
  }).whereType<DoctorService>();

  doctorServices.addAll(listOfStudys);

  return doctorServices;
}

Future<DoctorSchedule> getSchedulesDoctor(
    String uid, DateTime selectedDate) async {
  DoctorSchedule doctorSchedule = DoctorSchedule();
  List<DoctorTimeLine> timeLineList = [];
  String date = DateFormat('dd-MM-yyyy').format(selectedDate);

  final docRef = await _firestore
      .collection('users')
      .doc(uid)
      .collection('schedule')
      .doc(date)
      .get();

  final scheduleData = docRef.data();

  Map<String, dynamic>? timeLineData = scheduleData?['time_line'];
  doctorSchedule.date = scheduleData?['date'];

  if (timeLineData != null) {
    DoctorTimeLine timeLine = DoctorTimeLine();
    timeLineData.forEach((key, value) {
      timeLine.duration = key;

      Map<String, dynamic>? t = timeLineData[key];
      if (t != null) {
        t.forEach((key, value) {
          timeLine.shifts.add(key);

          timeLine.shiftTimes.add(t[key]?.cast<String>() ?? []);
        });
      }
    });

    timeLineList.add(timeLine);
  }

  doctorSchedule.timeLine = timeLineList;

  return doctorSchedule;
}

Stream<List<UserProfile>> getProfileUsers(String uid) async* {
  List<UserProfile> userProfiles = [];

  final docSnapshot = await _firestore
      .collection('users')
      .doc(uid)
      .collection('health_profiles')
      .get();

  final listOfProfiles = docSnapshot.docs.map((healthProfileDoc) {
    if (healthProfileDoc.exists) {
      final data = healthProfileDoc.data();
      final doctorProfile = UserProfile.fromJson(data);
      return doctorProfile;
    } else {
      return null;
    }
  }).whereType<UserProfile>();

  userProfiles.addAll(listOfProfiles);

  yield userProfiles.reversed.toList();
}

Stream<UserProfile> getMainProfileUsers(String uid) async* {
  UserProfile userProfile = UserProfile('', '', '', '', '', '', '', '');

  final docSnapshot = await FirebaseFirestore.instance
      .collection('users')
      .doc(uid)
      .collection('health_profiles')
      .doc('main_profile')
      .get();

  if (docSnapshot.exists) {
    final data = docSnapshot.data();
    userProfile = UserProfile.fromJson(data!);
  }

  yield userProfile;
}

Future<List<UserHeight>> getHeightDataUser(String uid, String idDoc) async {
  List<UserHeight> heightDataList = [];

  final docHeight = await _firestore
      .collection('users')
      .doc(uid)
      .collection('health_profiles')
      .doc(idDoc)
      .collection('health_metrics')
      .doc('height')
      .get();

  if (docHeight.exists) {
    List<dynamic> data = docHeight.data()!['data'];
    for (var value in data) {
      UserHeight height = UserHeight.fromJson(value);
      heightDataList.add(height);
    }
  }

  return heightDataList;
}

Future<List<UserWeight>> getWeightDataUser(String uid, String idDoc) async {
  List<UserWeight> weightDataList = [];

  final docWeight = await _firestore
      .collection('users')
      .doc(uid)
      .collection('health_profiles')
      .doc(idDoc)
      .collection('health_metrics')
      .doc('weight')
      .get();

  if (docWeight.exists) {
    List<dynamic> data = docWeight.data()!['data'];
    for (var value in data) {
      UserWeight weight = UserWeight.fromJson(value);
      weightDataList.add(weight);
    }
  }

  return weightDataList;
}

Future<List<UserTemperature>> getTemperatureDataUser(
    String uid, String idDoc) async {
  List<UserTemperature> temperatureDataList = [];

  final docTemperature = await _firestore
      .collection('users')
      .doc(uid)
      .collection('health_profiles')
      .doc(idDoc)
      .collection('health_metrics')
      .doc('temperature')
      .get();

  if (docTemperature.exists) {
    List<dynamic> data = docTemperature.data()!['data'];
    for (var value in data) {
      UserTemperature temperature = UserTemperature.fromJson(value);
      temperatureDataList.add(temperature);
    }
  }

  return temperatureDataList;
}

Future<List<UserBMI>> getBMIDataUser(String uid, String idDoc) async {
  List<UserBMI> bmiDataList = [];

  final docBMI = await _firestore
      .collection('users')
      .doc(uid)
      .collection('health_profiles')
      .doc(idDoc)
      .collection('health_metrics')
      .doc('bmi')
      .get();

  if (docBMI.exists) {
    List<dynamic> data = docBMI.data()!['data'];
    for (var value in data) {
      UserBMI bmi = UserBMI.fromJson(value);
      bmiDataList.add(bmi);
    }
  }

  return bmiDataList;
}

String calculateBirthdayToSelectedDate(String doB, String selectedDate) {
  List<String> datePartsOfDoB = doB.split('/');
  List<String> datePartsOfSelectedDate = selectedDate.split('/');

  int dayOfDoB = int.parse(datePartsOfDoB[0]);
  int monthOfDoB = int.parse(datePartsOfDoB[1]);
  int yearOfDoB = int.parse(datePartsOfDoB[2]);

  int dayOfSelectedDate = int.parse(datePartsOfSelectedDate[0]);
  int monthOfSelectedDate = int.parse(datePartsOfSelectedDate[1]);
  int yearOfSelectedDate = int.parse(datePartsOfSelectedDate[2]);

  DateTime birthDateTime = DateTime(yearOfDoB, monthOfDoB, dayOfDoB);
  DateTime selectedDateTime =
      DateTime(yearOfSelectedDate, monthOfSelectedDate, dayOfSelectedDate);

  Duration ageDuration = selectedDateTime.difference(birthDateTime);

  int years = ageDuration.inDays ~/ 365;
  int months = (ageDuration.inDays % 365) ~/ 30;
  int days = (ageDuration.inDays % 365) % 30;

  String birthdayToNowaday = '$years năm $months tháng $days ngày';

  return birthdayToNowaday;
}

String getAbbreviatedName(String text) {
  List<String> partOfName = text.split(' ');
  String firstCharacterFromStart = partOfName[0].substring(0, 1);
  if (partOfName.length - 1 > 0) {
    String firstCharacterFromEnd =
        partOfName[partOfName.length - 1].substring(0, 1);
    return '$firstCharacterFromStart$firstCharacterFromEnd'.toUpperCase();
  }

  return firstCharacterFromStart.toUpperCase();
}

String getAllOfSpecialties(List<String> specialties) {
  String allOfSpecialties = '';
  for (int i = 0; i < specialties.length; i++) {
    if (i == 0) {
      allOfSpecialties = specialties[i];
    } else {
      allOfSpecialties = '$allOfSpecialties, ${specialties[i]}';
    }
  }
  return allOfSpecialties;
}

Stream<List<AppointmentSchedule>> getAppointmentSchdedules() {
  return _firestore
      .collection('appointment_schedule')
      .where('idDocUser', isEqualTo: _auth.currentUser!.uid)
      .snapshots()
      .map((QuerySnapshot querySnapshot) {
    final List<AppointmentSchedule> appointmentSchedules = [];

    for (var appointmentScheduleDoc in querySnapshot.docs) {
      final appointmentScheduleData =
          appointmentScheduleDoc.data() as Map<String, dynamic>?;
      final AppointmentSchedule appointmentSchedule =
          AppointmentSchedule.fromJson(appointmentScheduleData!);
      appointmentSchedules.add(appointmentSchedule);
    }

    return appointmentSchedules;
  });
}

Stream<List<AppointmentSchedule>> getAllAppointmentSchdedules() {
  return _firestore
      .collection('appointment_schedule')
      .snapshots()
      .map((QuerySnapshot querySnapshot) {
    final List<AppointmentSchedule> appointmentSchedules = [];

    for (var appointmentScheduleDoc in querySnapshot.docs) {
      final appointmentScheduleData =
          appointmentScheduleDoc.data() as Map<String, dynamic>?;
      final AppointmentSchedule appointmentSchedule =
          AppointmentSchedule.fromJson(appointmentScheduleData!);
      appointmentSchedules.add(appointmentSchedule);
    }

    return appointmentSchedules;
  });
}
Stream<List<AppointmentSchedule>> getAppointmentSchedulesByDoctor(String doctorId) {
    return _firestore
      .collection('appointment_schedule')
      // .where('doctorid', isEqualTo: doctorId)
      .snapshots()
      .map((QuerySnapshot querySnapshot) {
    final List<AppointmentSchedule> appointmentSchedules = [];

    for (var appointmentScheduleDoc in querySnapshot.docs) {
      final appointmentScheduleData = appointmentScheduleDoc.data() as Map<String, dynamic>?;
      final AppointmentSchedule appointmentSchedule = AppointmentSchedule.fromJson(appointmentScheduleData!);
      appointmentSchedules.add(appointmentSchedule);
    }

    return appointmentSchedules;
  });
  }

showToastMessage(BuildContext context, String message) {
  showToast(message,
      context: context,
      animation: StyledToastAnimation.slideFromBottomFade,
      reverseAnimation: StyledToastAnimation.slideToBottomFade,
      startOffset: const Offset(0, 3),
      reverseEndOffset: const Offset(0, 3),
      position: StyledToastPosition.bottom,
      duration: const Duration(seconds: 4),
      animDuration: const Duration(seconds: 1),
      curve: Curves.elasticOut,
      reverseCurve: Curves.fastOutSlowIn);
}

Color getStatusColor(String status) {
  Map<String, Color> statusColors = {
    'Chờ duyệt': Colors.orange,
    'Đã duyệt': Colors.green,
    'Đã khám': Colors.blue,
    'Quá hẹn': Colors.purple,
    'Đã hủy': Colors.red,
  };

  return statusColors[status] ?? Colors.black;
}

Color getPaymentStatusColor(String status) {
  Map<String, Color> statusColors = {
    'Chờ xác nhận': Colors.orange,
    'Thanh toán thành công': Colors.green,
    'Thanh toán thất bại': Colors.red,
    'Hết hạn thanh toán': Colors.grey,
  };

  return statusColors[status] ?? Colors.black;
}

int calculateSecondsFromNow(DateTime dateTime) {
  DateTime now = DateTime.now();
  Duration difference = now.difference(dateTime);
  int seconds = difference.inSeconds;
  // 1 giờ thanh toán + 30 phút chờ
  return 3600 - seconds;
}

bool isWithinTimeRange(String time, DateTime selectedDate) {
  // Chuyển đổi chuỗi thời gian thành đối tượng DateTime
  List<String> timeParts = time.split('-');
  String startTimeString = timeParts[0].trim();
  String endTimeString = timeParts[1].trim();
  List<int> startTimeParts = startTimeString.split(':').map(int.parse).toList();
  List<int> endTimeParts = endTimeString.split(':').map(int.parse).toList();

  selectedDate = DateTime(
      selectedDate.year, selectedDate.month, selectedDate.day, 0, 0, 0);

  DateTime startTime = selectedDate
      .add(Duration(hours: startTimeParts[0], minutes: startTimeParts[1]));
  DateTime endTime = selectedDate
      .add(Duration(hours: endTimeParts[0], minutes: endTimeParts[1]));

  // Lấy thời gian hiện tại
  DateTime now = DateTime.now();

  // Kiểm tra xem thời gian hiện tại có nằm trong khoảng thời gian đã cho hay không
  return now.isAfter(startTime) && now.isBefore(endTime);
}

bool isAfterEndTime(String time, DateTime selectedDate) {
  // Chuyển đổi chuỗi thời gian thành đối tượng DateTime
  List<String> timeParts = time.split('-');
  String endTimeString = timeParts[1].trim();
  List<int> endTimeParts = endTimeString.split(':').map(int.parse).toList();
  selectedDate = DateTime(
      selectedDate.year, selectedDate.month, selectedDate.day, 0, 0, 0);
  DateTime endTime = selectedDate
      .add(Duration(hours: endTimeParts[0], minutes: endTimeParts[1]));
  // Lấy thời gian hiện tại
  DateTime now = DateTime.now();

  // Kiểm tra xem thời gian hiện tại có sau endTime hay không
  return now.isAfter(endTime);
}
