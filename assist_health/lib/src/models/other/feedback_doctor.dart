import 'package:cloud_firestore/cloud_firestore.dart';

class FeedbackDoctor {
  String? username;
  double? rating;
  String? content;
  DateTime? rateDate;
  String? idDoctor;
  String? idUser;
  String? idDoc;

  FeedbackDoctor({
    this.username,
    this.rating,
    this.content,
    this.rateDate,
    this.idDoctor,
    this.idUser,
    this.idDoc,
  });

  factory FeedbackDoctor.fromJson(Map<String, dynamic> json) {
    Timestamp timestampSelectedDate = json['rateDate'];
    DateTime selectedDate = timestampSelectedDate.toDate();
    return FeedbackDoctor(
      username: json['username'],
      rating: json['rating'],
      content: json['content'],
      rateDate: selectedDate,
      idDoctor: json['idDoctor'],
      idUser: json['idUser'],
      idDoc: json['idDoc'],
    );
  }
}
