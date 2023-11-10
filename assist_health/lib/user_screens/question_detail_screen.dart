
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:assist_health/functions/question.dart';

class QuestionDetailScreen extends StatefulWidget {
  final Question question;

  QuestionDetailScreen({required this.question});

  @override
  _QuestionDetailScreenState createState() => _QuestionDetailScreenState();
}

class _QuestionDetailScreenState extends State<QuestionDetailScreen> {
  List<String> answers = [];
  @override
  void initState(){
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
      appBar: AppBar(
        title: Text('Question Detail'),
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
                    'Title: ${widget.question.title}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text('Content: ${widget.question.content}'),
                  SizedBox(height: 8),
                  Text(
                    'Anonymous: ${widget.question.isAnonymous ? "Yes" : "No"}',
                    style: TextStyle(
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Answers (${answers.length}):',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
            ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: answers.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text('Answer ${index + 1}:'),
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
                child: Text('Add Answer'),
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
        title: Text('Add Answer'),
        content: TextField(
          controller: answerController,
          decoration: InputDecoration(
            labelText: 'Answer',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              String answer = answerController.text.trim();
              if (answer.isNotEmpty) {
                setState(() {
                  answers.add(answer);
                });
                _saveAnswerToFirebase(answer); // Lưu câu trả lời vào Firestore
              }
              Navigator.pop(context);
            },
            child: Text('Submit'),
          ),
        ],
      );
    },
  );
}
  void _saveAnswerToFirebase(String answer) {
    FirebaseFirestore.instance
        .collection('questions')
        .doc(widget.question.id) // Giả sử có trường "id" trong đối tượng Question để xác định câu hỏi cần lưu câu trả lời
        .update({
      'answers': FieldValue.arrayUnion([answer])
    }).then((_) {
      print('Answer saved to Firestore');
    }).catchError((error) {
      print('Failed to save answer: $error');
    });
  }
}
