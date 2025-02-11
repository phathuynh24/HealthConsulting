import 'dart:convert';

class Question {
  final String id;
  final String gender;
  final int age;
  final String title;
  final String content;
  final List<String> categories;
  bool isLiked;
  int likes;
  int answerCount;
  String questionUserId;
  DateTime? date;
  List<Map<String, dynamic>> answers = [];
  List<String> imageUrls;

  Question({
    required this.id,
    required this.gender,
    required this.age,
    required this.title,
    required this.content,
    this.answers = const [],
    required this.categories,
    required this.answerCount,
    this.likes = 0,
    this.isLiked = false,
    required this.questionUserId,
    this.date,
    this.imageUrls = const [],
  });

  // Initialize a default Question object
  factory Question.initial() {
    return Question(
      id: '',
      gender: '',
      age: 0,
      title: '',
      content: '',
      categories: [],
      answerCount: 0,
      questionUserId: '',
      date: DateTime.now(),
      imageUrls: [],
    );
  }

  // Convert Question object to Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'gender': gender,
      'age': age,
      'title': title,
      'content': content,
      'categories': categories,
      'isLiked': isLiked,
      'likes': likes,
      'answerCount': answerCount,
      'questionUserId': questionUserId,
      'date': date?.toIso8601String(),
      'answers': answers,
      'imageUrls': imageUrls,
    };
  }

  // Create a Question object from Map
  factory Question.fromMap(Map<String, dynamic> map) {
    return Question(
      id: map['id'] ?? '',
      gender: map['gender'] ?? '',
      age: map['age'] ?? 0,
      title: map['title'] ?? '',
      content: map['content'] ?? '',
      categories: List<String>.from(map['categories'] ?? []),
      isLiked: map['isLiked'] ?? false,
      likes: map['likes'] ?? 0,
      answerCount: map['answerCount'] ?? 0,
      questionUserId: map['questionUserId'] ?? '',
      date: map['date'] != null ? DateTime.parse(map['date']) : null,
      answers: List<Map<String, dynamic>>.from(map['answers'] ?? []),
      imageUrls: List<String>.from(map['imageUrls'] ?? []),
    );
  }

  // Update specific fields from a Map
  Question copyWith(Map<String, dynamic> updatedFields) {
    return Question(
      id: updatedFields['id'] ?? id,
      gender: updatedFields['gender'] ?? gender,
      age: updatedFields['age'] ?? age,
      title: updatedFields['title'] ?? title,
      content: updatedFields['content'] ?? content,
      categories: updatedFields['categories'] != null
          ? List<String>.from(updatedFields['categories'])
          : categories,
      isLiked: updatedFields['isLiked'] ?? isLiked,
      likes: updatedFields['likes'] ?? likes,
      answerCount: updatedFields['answerCount'] ?? answerCount,
      questionUserId: updatedFields['questionUserId'] ?? questionUserId,
      date: updatedFields['date'] != null
          ? DateTime.parse(updatedFields['date'])
          : date,
      answers: updatedFields['answers'] != null
          ? List<Map<String, dynamic>>.from(updatedFields['answers'])
          : answers,
      imageUrls: updatedFields['imageUrls'] != null
          ? List<String>.from(updatedFields['imageUrls'])
          : imageUrls,
    );
  }

  // Convert Question object to JSON
  String toJson() => json.encode(toMap());

  // Create a Question object from JSON
  factory Question.fromJson(String source) =>
      Question.fromMap(json.decode(source));
}
