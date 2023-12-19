class Question {
  final String id;
  final String gender;
  final int age;
  final String title;
  final String content;
  final List<String> categories;
  int likes; // Added this line
  int answerCount;
  List<String> answers;

  Question({
    required this.id,
    required this.gender,
    required this.age,
    required this.title,
    required this.content,
    this.answers = const [],
    required this.categories, 
    required this.answerCount,
    this.likes = 0, // Added this line with a default value of 0

  });
}
