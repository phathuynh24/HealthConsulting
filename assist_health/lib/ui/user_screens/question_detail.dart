import 'package:assist_health/others/theme.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:assist_health/models/other/question.dart';

class QuestionDetailScreen extends StatefulWidget {
  final Question question;

  const QuestionDetailScreen({Key? key, required this.question}) : super(key: key);

  @override
  State<QuestionDetailScreen> createState() => _QuestionDetailScreenState();
}

class _QuestionDetailScreenState extends State<QuestionDetailScreen> {
  List<Map<String, dynamic>> answers = [];
  late User currentUser;
  late String? currentUserRole; 
  @override
  void initState() {
    super.initState();
    _loadAnswers();
    _loadCurrentUserRole(); 
    currentUserRole = '';
    currentUser = FirebaseAuth.instance.currentUser!;
  }
  void _loadCurrentUserRole() {
  User? user = FirebaseAuth.instance.currentUser;
  if (user != null) {
    FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get()
        .then((docSnapshot) {
      if (docSnapshot.exists) {
        setState(() {
          currentUserRole = docSnapshot.data()?['role'] ?? '';
        });
      }
    }).catchError((error) {
      print('Failed to load user role: $error');
    });
  }
}

  void _loadAnswers() {
    FirebaseFirestore.instance
        .collection('questions')
        .doc(widget.question.id)
        .get()
        .then((docSnapshot) {
      if (docSnapshot.exists) {
        setState(() {
          answers = List<Map<String, dynamic>>.from(docSnapshot.data()?['answers'] ?? []);
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
        title: const Text('Câu hỏi'),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Themes.gradientDeepClr, Themes.gradientLightClr],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
          ),
        ),
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
                      fontSize: 20,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tuổi: ${widget.question.age} - Giới tính: ${widget.question.gender}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Nội dung: ${widget.question.content}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      height: 1.5,
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
                Map<String, dynamic> answerData = answers[index];
                String answer = answerData['answer'];
                String userId = answerData['userId'];

                return ListTile(
                  contentPadding: const EdgeInsets.all(16.0),
                  tileColor: Colors.grey[100],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  title: FutureBuilder<DocumentSnapshot>(
                    future: FirebaseFirestore.instance.collection('users').doc(userId).get(),
                    builder: (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
                      if (snapshot.hasError) {
                        return Text('Error loading user data');
                      }

                      if (snapshot.connectionState == ConnectionState.done) {
                        Map<String, dynamic> userData = snapshot.data!.data() as Map<String, dynamic>;
                        String imageUrl = userData['imageURL'];

                        // Check if the current user is the author of the question
                        // bool isCurrentUserAuthor = currentUser.uid == userId;
                        bool isAnswererAuthor = widget.question.questionUserId == userId;

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                isAnswererAuthor
                                    ? CircleAvatar(
                                        child: Icon(
                                          Icons.person,
                                          size: 30,
                                        ),
                                      )
                                    : CircleAvatar(
                                        backgroundImage: NetworkImage(imageUrl) as ImageProvider<Object>,
                                      ),
                                const SizedBox(width: 8),
                                Text(
                                  isAnswererAuthor
                                      ? '${widget.question.gender}, ${widget.question.age} tuổi'
                                      : '${userData['name']}', // Display 'You' for the author
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Answer: $answer',
                              style: const TextStyle(fontSize: 16),
                            ),
                          ],
                        );
                      }

                      return CircularProgressIndicator(); // While waiting for the data, show a loading indicator
                    },
                  ),
                );
              },
            ),
      if (widget.question.questionUserId == currentUser.uid||currentUserRole == "doctor")
           Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton(
                onPressed: () {
                  _showAnswerDialog(context);
                },
                style: ElevatedButton.styleFrom(
                  primary: Colors.pink, // Change the button color
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12), // Adjust the padding
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20), // Adjust the border radius
                  ),
                  textStyle: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                child: const Text('Thêm câu trả lời'),
              ),
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
                  _saveAnswerToFirebase(answer);
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
    String currentUserId = currentUser.uid;
    FirebaseFirestore.instance
        .collection('questions')
        .doc(widget.question.id)
        .update({
          'answers': FieldValue.arrayUnion([
            {
              'answer': answer,
              'userId': currentUserId,
            }
          ])
        })
        .then((_) {
      print('Answer saved to Firestore');
      _loadAnswers();
    }).catchError((error) {
      print('Failed to save answer: $error');
    });
  }
}
