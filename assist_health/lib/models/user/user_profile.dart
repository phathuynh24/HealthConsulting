class UserProfile {
  String name;
  String gender;
  String doB;
  String relationship;
  String image;
  String idDoc;

  UserProfile(this.name, this.gender, this.doB, this.relationship, this.image,
      this.idDoc);

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      json['name'],
      json['gender'],
      json['doB'],
      json['relationship'],
      json['imageURL'],
      json['idDoc'],
    );
  }
}
