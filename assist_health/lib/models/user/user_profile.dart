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

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      json['name'],
      json['phone'],
      json['gender'],
      json['doB'],
      json['relationship'],
      json['imageURL'],
      json['idDoc'],
      json['idProfile'],
    );
  }
}
