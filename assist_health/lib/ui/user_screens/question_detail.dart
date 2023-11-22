// ignore_for_file: avoid_print

import 'package:assist_health/others/theme.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:assist_health/models/other/question.dart';

class QuestionDetailScreen extends StatefulWidget {
  final Question question;

  const QuestionDetailScreen({super.key, required this.question});

  @override
  State<QuestionDetailScreen> createState() => _QuestionDetailScreenState();
}

class _QuestionDetailScreenState extends State<QuestionDetailScreen> {
  List<String> answers = [];
  @override
  void initState() {
    super.initState();
    _loadAnswers();
  }

  void _loadAnswers() {
    FirebaseFirestore.instance
        .collection('questions')
        .doc(widget.question.id)
        .get()
        .then((docSnapshot) {
      if (docSnapshot.exists) {
        setState(() {
          answers = List<String>.from(docSnapshot.data()?['answers'] ?? []);
        });
      }
    }).catchError((error) {
      print('Failed to load answers: $error');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Themes.backgroundClr,
      appBar: AppBar(
        title: const Text('Question Detail'),
        backgroundColor: Themes.hearderClr,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Chủ đề: ${widget.question.title}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text('Nội dung: ${widget.question.content}'),
                  const SizedBox(height: 8),
                  Text(
                    'Tuổi: ${widget.question.age} - Giới tính: ${widget.question.gender}',
                    style: const TextStyle(
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Câu trả lời (${answers.length}):',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: answers.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text('Câu ${index + 1}:'),
                  subtitle: Text(answers[index]),
                );
              },
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton(
                onPressed: () {
                  _showAnswerDialog(context);
                },
                child: const Text('Thêm câu trả lời'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAnswerDialog(BuildContext context) {
    TextEditingController answerController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Thêm câu trả lời'),
          content: TextField(
            controller: answerController,
            decoration: const InputDecoration(
              labelText: 'Câu trả lời',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Hủy'),
            ),
            ElevatedButton(
              onPressed: () {
                String answer = answerController.text.trim();
                if (answer.isNotEmpty) {
                  setState(() {
                    answers.add(answer);
                  });
                  _saveAnswerToFirebase(
                      answer); // Lưu câu trả lời vào Firestore
                }
                Navigator.pop(context);
              },
              child: const Text('Thêm'),
            ),
          ],
        );
      },
    );
  }

  void _saveAnswerToFirebase(String answer) {
    FirebaseFirestore.instance
        .collection('questions')
        .doc(widget.question
            .id) // Giả sử có trường "id" trong đối tượng Question để xác định câu hỏi cần lưu câu trả lời
        .update({
      'answers': FieldValue.arrayUnion([answer])
    }).then((_) {
      print('Answer saved to Firestore');
    }).catchError((error) {
      print('Failed to save answer: $error');
    });
  }
}
