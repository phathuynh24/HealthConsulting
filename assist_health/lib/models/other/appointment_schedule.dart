import 'dart:io';

import 'package:assist_health/models/doctor/doctor_info.dart';
import 'package:assist_health/models/user/user_profile.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

class AppointmentSchedule {
  DoctorInfo? doctorInfo;
  UserProfile? userProfile;
  String? reasonForExamination;
  List<File>? listOfHealthInformationFiles;
  List<String>? listOfHealthInformationURLs;
  DateTime? selectedDate;
  String? time;
  bool? isMorning;
  String? transferContent;
  String? appointmentCode;
  String? linkQRCode;
  DateTime? paymentStartTime;
  String? receivedAppointmentTime;
  String? status;

  AppointmentSchedule({
    this.doctorInfo,
    this.userProfile,
    this.reasonForExamination,
    this.listOfHealthInformationFiles,
    this.listOfHealthInformationURLs,
    this.selectedDate,
    this.time,
    this.isMorning,
    this.transferContent,
    this.appointmentCode,
    this.linkQRCode,
    this.paymentStartTime,
    this.receivedAppointmentTime,
    this.status,
  });

  Future<void> saveAppointmentToFirestore() async {
    try {
      // Upload files and get URLs
      List<String> fileUrls =
          await uploadFilesToStorage(listOfHealthInformationFiles!);

      // Lưu thông tin vào Firestore
      await FirebaseFirestore.instance.collection('appointment_schedule').add(
        {
          'doctorInfo': doctorInfo?.toMap(),
          'userProfile': userProfile?.toMap(),
          'reasonForExamination': reasonForExamination,
          'listOfHealthInformationFiles': fileUrls,
          'selectedDate': selectedDate,
          'time': time,
          'isMorning': isMorning,
          'transferContent': transferContent,
          'appointmentCode': appointmentCode,
          'linkQRCode': linkQRCode,
          'paymentStartTime': paymentStartTime,
          'receivedAppointmentTime': receivedAppointmentTime,
          'status': status,
        },
      );
    } catch (e) {
      print('Error saving appointment to Firestore: $e');
    }
  }

  Future<List<String>> uploadFilesToStorage(List<File> files) async {
    List<String> fileUrls = [];

    for (var file in files) {
      // Tạo đường dẫn duy nhất cho file trên Storage
      String filePath =
          'appointment_schedule_files/${DateTime.now().millisecondsSinceEpoch}_${file.path.split('/').last}';
      // Tạo tham chiếu đến file trên Storage
      Reference storageReference =
          FirebaseStorage.instance.ref().child(filePath);

      // Upload file lên Storage
      UploadTask uploadTask = storageReference.putFile(file);

      // Đợi quá trình upload hoàn thành và lấy URL
      TaskSnapshot taskSnapshot = await uploadTask.whenComplete(() => null);
      String fileUrl = await taskSnapshot.ref.getDownloadURL();

      fileUrls.add(fileUrl);
    }

    return fileUrls;
  }

  factory AppointmentSchedule.fromJson(Map<String, dynamic> json) {
    Timestamp timestampSelectedDate = json['selectedDate'];
    DateTime selectedDate = timestampSelectedDate.toDate();

    Timestamp timestampPaymentStartTime = json['selectedDate'];
    DateTime paymentStartTime = timestampPaymentStartTime.toDate();

    return AppointmentSchedule(
      doctorInfo: DoctorInfo.fromJson(json['doctorInfo']),
      userProfile: UserProfile.fromJson(json['userProfile']),
      reasonForExamination: json['reasonForExamination'] ?? '',
      listOfHealthInformationFiles: [],
      listOfHealthInformationURLs:
          json['listOfHealthInformationFiles']?.cast<String>() ?? [],
      selectedDate: selectedDate,
      time: json['time'],
      isMorning: json['isMorning'],
      transferContent: json['transferContent'],
      appointmentCode: json['appointmentCode'],
      linkQRCode: json['linkQRCode'],
      paymentStartTime: paymentStartTime,
      receivedAppointmentTime: json['receivedAppointmentTime'],
      status: json['status'],
    );
  }
}
