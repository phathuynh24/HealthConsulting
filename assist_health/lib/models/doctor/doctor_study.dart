class DoctorStudy {
  String place;
  String desc;

  DoctorStudy(this.place, this.desc);

  factory DoctorStudy.fromJson(Map<String, dynamic> json) {
    return DoctorStudy(
      json['desc'] as String,
      json['place'] as String,
    );
  }
}
