class DoctorExperience {
  String workplace;
  String desc;

  DoctorExperience(this.workplace, this.desc);

  factory DoctorExperience.fromJson(Map<String, dynamic> json) {
    return DoctorExperience(
      json['workplace'],
      json['desc'],
    );
  }
}
