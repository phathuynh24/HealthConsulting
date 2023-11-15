class DoctorService {
  String name;
  int price;
  String status;
  int time;

  DoctorService(this.name, this.price, this.status, this.time);

  factory DoctorService.fromJson(Map<String, dynamic> json) {
    return DoctorService(
      json['name'] as String,
      json['price'] as int,
      json['status'] as String,
      json['time'] as int,
    );
  }
}
