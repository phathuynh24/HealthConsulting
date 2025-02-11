class DoctorInfo {
  String uid;
  String name;
  String phone;
  String careerTitiles;
  String description;
  int count;
  String imageURL;
  int rating;
  String workplace;
  String address;
  String status;
  String role;
  String email;
  // int graduationYear;
  // int consultingTime;
  int serviceFee;
  // String? startTime;
  // String? endTime;
  List<String> specialty;
  // List<String> educations;
  // List<String> experiences;
  List<String> groupDisease;
  bool isDeleted;
  String experienceText;
  String studyText;

  DoctorInfo(
    this.uid,
    this.name,
    this.phone,
    this.careerTitiles,
    this.description,
    this.count,
    this.imageURL,
    this.rating,
    this.workplace,
    this.address,
    this.status,
    this.role,
    this.email,
    // this.graduationYear,
    // this.consultingTime,
    this.serviceFee,
    // this.startTime,
    // this.endTime,
    this.specialty,
    // this.educations,
    // this.experiences,
    this.groupDisease,
    this.isDeleted,
    this.experienceText,
    this.studyText,
  );

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'phone': phone,
      'careerTitiles': careerTitiles,
      'description': description,
      'count': count,
      'imageURL': imageURL,
      'rating': rating,
      'workplace': workplace,
      'address': address,
      'status': status,
      'role': role,
      'email': email,
      // 'graduationYear': graduationYear,
      // 'consultingTime': consultingTime,
      'serviceFee': serviceFee,
      // 'startTime': startTime,
      // 'endTime': endTime,
      'specialty': specialty,
      // 'educations': educations,
      // 'experiences': experiences,
      'groupdisease': groupDisease,
      'isDeleted': isDeleted,
      'experienceText': experienceText,
      'studyText': studyText,
    };
  }

  factory DoctorInfo.fromMap(Map<String, dynamic> map) {
    final List<dynamic>? specialtyData = map['specialty'];
    // final List<dynamic>? educationsData = map['educations'];
    // final List<dynamic>? experiencesData = map['experiences'];
    final List<dynamic>? groupDiseaseData = map['groupdisease'];

    final List<String> specialty = specialtyData?.cast<String>() ?? [];
    // final List<String> educations = educationsData?.cast<String>() ?? [];
    // final List<String> experiences = experiencesData?.cast<String>() ?? [];
    final List<String> groupDisease = groupDiseaseData?.cast<String>() ?? [];

    return DoctorInfo(
      map['uid'] ?? '',
      map['name'] ?? '',
      map['phone'] ?? '',
      map['careerTitiles'] ?? 'Bác sĩ',
      map['description'] ?? '',
      map['count'] ?? 0,
      map['imageURL'] ?? '',
      map['rating'] ?? 0,
      map['workplace'] ?? '',
      map['address'] ?? '',
      map['status'] ?? '',
      map['role'] ?? '',
      map['email'] ?? '',
      // map['graduationYear'] ?? '',
      // map['consultingTime'] ?? 0,
      map['serviceFee'] ?? 0,
      // map['startTime'] ?? '08:00',
      // map['endTime'] ?? '16:00',
      specialty,
      // educations,
      // experiences,
      groupDisease,
      map['isDeleted'] ?? false,
      map['experienceText'] ?? 'Chưa cập nhật',
      map['studyText'] ?? 'Chưa cập nhật',
    );
  }

  factory DoctorInfo.fromJson(Map<String, dynamic> json) {
    final List<dynamic>? specialtyData = json['specialty'];
    // final List<dynamic>? educationsData = json['educations'];
    // final List<dynamic>? experiencesData = json['experiences'];
    final List<dynamic>? groupDiseaseData = json['groupdisease'];

    final List<String> specialty = specialtyData?.cast<String>() ?? [];
    // final List<String> educations = educationsData?.cast<String>() ?? [];
    // final List<String> experiences = experiencesData?.cast<String>() ?? [];
    final List<String> groupDisease = groupDiseaseData?.cast<String>() ?? [];

    return DoctorInfo(
      json['uid'] ?? '',
      json['name'] ?? '',
      json['phone'] ?? '',
      json['careerTitiles'] ?? 'Bác sĩ',
      json['description'] ?? '',
      json['count'] ?? 0,
      json['imageURL'] ?? '',
      json['rating'] ?? 0,
      json['workplace'] ?? '',
      json['address'] ?? '',
      json['status'] ?? '',
      json['role'] ?? '',
      json['email'] ?? '',
      // json['graduationYear'] ?? '',
      // json['consultingTime'] ?? 0,
      json['serviceFee'] ?? 0,
      // json['startTime'] ?? '08:00',
      // json['endTime'] ?? '16:00',
      specialty,
      // educations,
      // experiences,
      groupDisease,
      json['isDeleted'] ?? false,
      json['experienceText'] ?? 'Chưa cập nhật',
      json['studyText'] ?? 'Chưa cập nhật',
    );
  }
}
