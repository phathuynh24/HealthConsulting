class UserProfile {
  String place;
  String desc;

  UserProfile(this.place, this.desc);

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      json['place'] as String,
      json['desc'] as String,
    );
  }
}
