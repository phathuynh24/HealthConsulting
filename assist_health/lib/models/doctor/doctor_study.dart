class DoctorStudy {
  String place;
  String desc;

  DoctorStudy(this.place, this.desc);

  factory DoctorStudy.fromJson(Map<String, dynamic> json) {
    return DoctorStudy(
      json['place'],
      json['desc'],
    );
  }
}
