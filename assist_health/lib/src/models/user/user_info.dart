class CollectionUsersRoleUser {
  final String email;
  final String imageURL;
  final String name;
  final String phone;
  final String role;
  final List<String> savedPosts;
  final String status;
  final String uid;

  CollectionUsersRoleUser({
    required this.email,
    required this.imageURL,
    required this.name,
    required this.phone,
    required this.role,
    required this.savedPosts,
    required this.status,
    required this.uid,
  });

  // Phương thức để chuyển từ JSON sang UserInfo
  factory CollectionUsersRoleUser.fromJson(Map<String, dynamic> json) {
    return CollectionUsersRoleUser(
      email: json['email'] as String,
      imageURL: json['imageURL'] as String,
      name: json['name'] as String,
      phone: json['phone'] as String,
      role: json['role'] as String,
      savedPosts: List<String>.from(json['savedPosts'] ?? []),
      status: json['status'] as String,
      uid: json['uid'] as String,
    );
  }

  // Phương thức để chuyển từ UserInfo sang JSON
  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'imageURL': imageURL,
      'name': name,
      'phone': phone,
      'role': role,
      'savedPosts': savedPosts,
      'status': status,
      'uid': uid,
    };
  }

  @override
  String toString() {
    return 'UserInfo(email: $email, imageURL: $imageURL, name: $name, phone: $phone, role: $role, savedPosts: $savedPosts, status: $status, uid: $uid)';
  }
}
