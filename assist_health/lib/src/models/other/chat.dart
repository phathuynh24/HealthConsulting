class Chat {
  String? idDoc;
  String? idUser;
  String? idDoctor;
  String? idProfile;

  Chat({
    this.idProfile,
    this.idDoctor,
    this.idUser,
    this.idDoc,
  });

  factory Chat.fromJson(Map<String, dynamic> json) {
    return Chat(
      idProfile: json['idProfile'],
      idDoctor: json['idDoctor'],
      idUser: json['idUser'],
      idDoc: json['idDoc'],
    );
  }
}
