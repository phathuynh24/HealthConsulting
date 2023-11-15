class Question {
  final String id;
  final String gender;
  final int age;
  final String title;
  final String content;
  List<String> answers; // Trường mới

  Question({
    required this.id,
    required this.gender,
    required this.age,
    required this.title,
    required this.content,
    this.answers = const [], // Giá trị mặc định là danh sách rỗng
  });
}