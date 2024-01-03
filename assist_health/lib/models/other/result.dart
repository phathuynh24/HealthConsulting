import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

class Result {
  String? diagnose;
  String? note;
  String? idDoctor;
  String? doctorName;
  String? idSchedule;
  String? idUser;
  String? idProfile;
  String? nameProfile;
  String? idAppointment;
  String? timeExamination;
  DateTime? dateExamination;
  DateTime? timeResult;
  List<File>? listFiles = [];
  List<String>? listUrls = [];

  Result({
    this.diagnose,
    this.note,
    this.idDoctor,
    this.doctorName,
    this.idSchedule,
    this.idUser,
    this.idProfile,
    this.nameProfile,
    this.idAppointment,
    this.timeExamination,
    this.dateExamination,
    this.timeResult,
    this.listFiles,
    this.listUrls,
  });

  factory Result.fromJson(Map<String, dynamic> json) {
    Timestamp timestampDateExamination = json['dateExamination'];
    DateTime dateExamination = timestampDateExamination.toDate();

    Timestamp timestamptimeResult = json['timeResult'];
    DateTime timeResult = timestamptimeResult.toDate();
    return Result(
      diagnose: json['diagnose'] ?? '',
      note: json['note'] ?? '',
      idDoctor: json['idDoctor'],
      doctorName: json['doctorName'],
      idSchedule: json['idSchedule'],
      idUser: json['idUser'],
      idProfile: json['idProfile'],
      nameProfile: json['nameProfile'],
      idAppointment: json['appointmentCode'],
      timeExamination: json['timeExamination'],
      listUrls: json['fileUrls']?.cast<String>() ?? [],
      listFiles: [],
      dateExamination: dateExamination,
      timeResult: timeResult,
    );
  }

  Future<void> saveResultToFirebase() async {
    // Lấy ngày giờ hiện tại làm ID document
    DateTime now = DateTime.now();
    String documentId = now.toString();

    // Tạo một document mới trong collection "examination_result" với ID là ngày giờ hiện tại
    DocumentReference documentReference = FirebaseFirestore.instance
        .collection('examination_result')
        .doc(documentId);

    // Lưu 2 đoạn văn bản vào document
    await documentReference.set({
      'diagnose': diagnose,
      'note': note,
      'idDoctor': idDoctor,
      'doctorName': doctorName,
      'idSchedule': idSchedule,
      'idUser': idUser,
      'idProfile': idProfile,
      'nameProfile': nameProfile,
      'idAppointment': idAppointment,
      'dateExamination': dateExamination,
      'timeExamination': timeExamination,
      'timeResult': timeResult,
      'idDoc': documentId,
    });

    // Lưu danh sách các tệp lên Firebase Storage và lấy URL của từng tệp
    for (int i = 0; i < listFiles!.length; i++) {
      String fileName = '${documentId}_file_$i';
      Reference storageReference =
          FirebaseStorage.instance.ref().child('result_image').child(fileName);
      UploadTask uploadTask = storageReference.putFile(listFiles![i]);
      TaskSnapshot taskSnapshot = await uploadTask;
      String fileUrl = await taskSnapshot.ref.getDownloadURL();
      listUrls!.add(fileUrl);
    }

    // Lưu danh sách các URL của tệp vào document
    await documentReference.update({
      'fileUrls': listUrls,
    });
  }
}
