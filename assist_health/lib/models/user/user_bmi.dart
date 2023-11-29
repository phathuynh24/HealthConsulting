class UserBMI {
  final String date;
  final String height;
  final String weight;
  final String bmi;

  UserBMI(this.date, this.height, this.weight, this.bmi);

  factory UserBMI.fromJson(Map<String, dynamic> json) {
    return UserBMI(
      json['date'],
      json['height'],
      json['weight'],
      json['bmi'],
    );
  }
}
