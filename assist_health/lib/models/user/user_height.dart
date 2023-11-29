class UserHeight {
  final String date;
  final String height;

  UserHeight(this.height, this.date);

  factory UserHeight.fromJson(Map<String, dynamic> json) {
    return UserHeight(
      json['height'],
      json['date'],
    );
  }
}
