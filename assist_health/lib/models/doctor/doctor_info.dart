import 'package:firebase_storage/firebase_storage.dart';

final FirebaseStorage storage = FirebaseStorage.instance;

class DoctorInfo {
  String uid = '';
  String name;
  String desc;
  int avgTime;
  int count;
  String expert;
  String image;
  int rating;
  String workplace;
  String address;

  DoctorInfo(this.name, this.desc, this.avgTime, this.count, this.expert,
      this.image, this.rating, this.workplace, this.address);

  factory DoctorInfo.fromJson(Map<String, dynamic> json) {
    return DoctorInfo(
      json['name'],
      json['desc'],
      json['avgTime'],
      json['count'],
      json['expert'],
      json['image'],
      json['rating'],
      json['workplace'],
      json['address'],
    );
  }
}
