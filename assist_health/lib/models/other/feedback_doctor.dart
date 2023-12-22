class FeedbackDoctor {
  String? username;
  double? rating;
  String? content;
  DateTime? rateDate;
  String? idDoctor;
  String? idUser;
  String? idDoc;

  FeedbackDoctor({
    this.username,
    this.rating,
    this.content,
    this.rateDate,
    this.idDoctor,
    this.idUser,
    this.idDoc,
  });

  factory FeedbackDoctor.fromJson(Map<String, dynamic> json) {
    return FeedbackDoctor(
      username: json['username'],
      rating: json['rating'],
      content: json['content'],
      rateDate:
          json['rateDate'] != null ? DateTime.parse(json['rateDate']) : null,
      idDoctor: json['idDoctor'],
      idUser: json['idUser'],
      idDoc: json['idDoc'],
    );
  }
}
