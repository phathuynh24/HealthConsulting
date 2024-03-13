class UserProfile {
  String name;
  String phone;
  String gender;
  String doB;
  String relationship;
  String image;
  String idDoc;
  String idProfile;

  UserProfile(this.name, this.phone, this.gender, this.doB, this.relationship,
      this.image, this.idDoc, this.idProfile);

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'phone': phone,
      'gender': gender,
      'doB': doB,
      'relationship': relationship,
      'imageURL': image,
      'idDoc': idDoc,
      'idProfile': idProfile,
    };
  }

  factory UserProfile.fromMap(Map<String, dynamic> map) {
    return UserProfile(
      map['name'] ?? '',
      map['phone'] ?? '',
      map['gender'] ?? '',
      map['doB'] ?? '',
      map['relationship'] ?? '',
      map['imageURL'] ?? '',
      map['idDoc'] ?? '',
      map['idProfile'] ?? '',
    );
  }

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      json['name'] ?? '',
      json['phone'] ?? '',
      json['gender'] ?? '',
      json['doB'] ?? '',
      json['relationship'] ?? '',
      json['imageURL'] ?? '',
      json['idDoc'] ?? '',
      json['idProfile'] ?? '',
    );
  }
}
