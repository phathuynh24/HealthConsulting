// ignore_for_file: avoid_print

import 'dart:io';

import 'package:assist_health/src/models/doctor/doctor_info.dart';
import 'package:assist_health/src/models/user/user_profile.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

class AppointmentSchedule {
  DoctorInfo? doctorInfo;
  UserProfile? userProfile;
  String? idDocUser;
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
  String? statusReasonCanceled;
  String? paymentStatus;
  String? idDoc;
  String? idFeedback;
  bool? isExamined;
  bool? isResult;

  AppointmentSchedule({
    this.doctorInfo,
    this.userProfile,
    this.idDocUser,
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
    this.statusReasonCanceled,
    this.paymentStatus,
    this.idDoc,
    this.idFeedback,
    this.isExamined,
    this.isResult,
  });

  Future<void> saveAppointmentToFirestore() async {
    try {
      String idDocUser = FirebaseAuth.instance.currentUser!.uid;
      // Upload files and get URLs
      List<String> fileUrls =
          await uploadFilesToStorage(listOfHealthInformationFiles!);

      // Lưu thông tin vào Firestore
      await FirebaseFirestore.instance
          .collection('appointment_schedule')
          .doc(idDoc)
          .set(
        {
          'doctorInfo': doctorInfo?.toMap(),
          'userProfile': userProfile?.toMap(),
          'idDocUser': idDocUser,
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
          'statusReasonCanceled': statusReasonCanceled,
          'paymentStatus': paymentStatus,
          'idDoc': idDoc,
          'isExamined': false,
          'isResult': false,
        },
      );
    } catch (e) {
      print('Error saving appointment to Firestore: $e');
    }
  }

  Future<void> updateAppointmentInFirestore(String idDoc) async {
    try {
      // Upload files and get URLs
      List<String> fileUrls =
          await uploadFilesToStorage(listOfHealthInformationFiles!);

      // Cập nhật thông tin trong Firestore
      await FirebaseFirestore.instance
          .collection('appointment_schedule')
          .doc(idDoc)
          .update({
        'doctorInfo': doctorInfo?.toMap(),
        'userProfile': userProfile?.toMap(),
        'idDocUser': idDocUser,
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
        'statusReasonCanceled': statusReasonCanceled,
        'paymentStatus': paymentStatus,
        'isExamined': isExamined ?? false,
        'isResult': isResult ?? false,
      });

      print('Appointment updated in Firestore successfully.');
    } catch (e) {
      print('Error updating appointment in Firestore: $e');
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
      SettableMetadata metadata = SettableMetadata(
        contentType: 'image/jpeg',
      );
      UploadTask uploadTask = storageReference.putFile(file, metadata);

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

    Timestamp timestampPaymentStartTime = json['paymentStartTime'];
    DateTime paymentStartTime = timestampPaymentStartTime.toDate();

    return AppointmentSchedule(
      doctorInfo: DoctorInfo.fromJson(json['doctorInfo']),
      userProfile: UserProfile.fromJson(json['userProfile']),
      idDocUser: json['idDocUser'],
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
      statusReasonCanceled: json['statusReasonCanceled'] ?? '',
      paymentStatus: json['paymentStatus'],
      idDoc: json['idDoc'],
      idFeedback: json['idFeedback'] ?? '',
      isExamined: json['isExamined'] ?? false,
      isResult: json['isResult'] ?? false,
    );
  }

  void updatePaymentStatus(String newStatus) {
    CollectionReference appointmentScheduleCollection =
        FirebaseFirestore.instance.collection('appointment_schedule');

    appointmentScheduleCollection.doc(idDoc!).update({
      'paymentStatus': newStatus,
    }).then((value) {
      print('Cập nhật thành công');
    }).catchError((error) {
      print('Cập nhật thất bại: $error');
    });
  }

  void updateAppointmentStatus(String newStatus) {
    CollectionReference appointmentScheduleCollection =
        FirebaseFirestore.instance.collection('appointment_schedule');

    appointmentScheduleCollection.doc(idDoc!).update({
      'status': newStatus,
    }).then((value) {
      print('Cập nhật thành công');
    }).catchError((error) {
      print('Cập nhật thất bại: $error');
    });
  }

  void updateAppointmentStatusReasonCanceled(String newStatus) {
    CollectionReference appointmentScheduleCollection =
        FirebaseFirestore.instance.collection('appointment_schedule');

    appointmentScheduleCollection.doc(idDoc!).update({
      'statusReasonCanceled': newStatus,
    }).then((value) {
      print('Cập nhật thành công');
    }).catchError((error) {
      print('Cập nhật thất bại: $error');
    });
  }

  void updateAppointmentIsExaminated() {
    CollectionReference appointmentScheduleCollection =
        FirebaseFirestore.instance.collection('appointment_schedule');

    appointmentScheduleCollection.doc(idDoc).update({
      'isExamined': true,
    }).then((value) {
      print('Cập nhật thành công');
    }).catchError((error) {
      print('Cập nhật thất bại: $error');
    });
  }

  void updateAppointmentIsResult() {
    CollectionReference appointmentScheduleCollection =
        FirebaseFirestore.instance.collection('appointment_schedule');

    appointmentScheduleCollection.doc(idDoc).update({
      'isResult': true,
    }).then((value) {
      print('Cập nhật thành công');
    }).catchError((error) {
      print('Cập nhật thất bại: $error');
    });
  }

  Future<void> updateAppointmentFeedback(String idFeedback) async {
    try {
      DocumentReference appointmentRef = FirebaseFirestore.instance
          .collection('appointment_schedule')
          .doc(idDoc);

      await appointmentRef.update({
        'idFeedback': idFeedback,
      });

      print('Appointment feedback updated successfully!');
    } catch (e) {
      print('Error updating appointment feedback: $e');
    }
  }

  // Hàm tạo phiếu khám mới từ phiếu cũ
  static AppointmentSchedule createNewFromOld(AppointmentSchedule oldSchedule) {
    return AppointmentSchedule(
      doctorInfo: oldSchedule.doctorInfo,
      userProfile: oldSchedule.userProfile,
      reasonForExamination: oldSchedule.reasonForExamination,
      listOfHealthInformationFiles: oldSchedule.listOfHealthInformationFiles,
      selectedDate: oldSchedule.selectedDate,
      time: oldSchedule.time,
      isMorning: oldSchedule.isMorning,
      status: 'Chờ duyệt', // Đặt lại trạng thái ban đầu
      paymentStatus: 'Chờ xác nhận', // Đặt lại trạng thái thanh toán
      appointmentCode: generateNewCode(), // Tạo mã phiếu mới
      idDoc: FirebaseFirestore.instance
          .collection('appointment_schedule')
          .doc()
          .id, // Tạo ID mới
    );
  }

  // Hàm tạo mã phiếu khám mới (mã ngẫu nhiên)
  static String generateNewCode() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    return 'MDK$timestamp';
  }
}
