// ignore_for_file: avoid_print

import 'package:firebase_storage/firebase_storage.dart';

final FirebaseStorage storage = FirebaseStorage.instance;

class DoctorInfo {
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
      json['name'] as String,
      json['desc'] as String,
      json['avgTime'] as int,
      json['count'] as int,
      json['expert'] as String,
      json['image'] as String,
      json['rating'] as int,
      json['workplace'] as String,
      json['address'] as String,
    );
  }
}
