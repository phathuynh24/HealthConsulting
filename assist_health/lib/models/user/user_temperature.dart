class UserTemperature {
  final String date;
  final String time;
  final String temperature;

  UserTemperature(this.temperature, this.date, this.time);

  factory UserTemperature.fromJson(Map<String, dynamic> json) {
    return UserTemperature(
      json['temperature'],
      json['date'],
      json['time'],
    );
  }
}
