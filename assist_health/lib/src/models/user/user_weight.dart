class UserWeight {
  final String date;
  final String weight;

  UserWeight(this.weight, this.date);

  factory UserWeight.fromJson(Map<String, dynamic> json) {
    return UserWeight(
      json['weight'],
      json['date'],
    );
  }
}
