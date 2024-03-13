// ignore_for_file: avoid_print

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:assist_health/src/others/theme.dart';
import 'package:assist_health/src/models/other/question.dart';
import 'package:intl/intl.dart';

class QuestionDetailScreen extends StatefulWidget {
  final Question question;

  const QuestionDetailScreen({super.key, required this.question});

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
          answers = List<Map<String, dynamic>>.from(
              docSnapshot.data()?['answers'] ?? []);
        });
      }
    }).catchError((error) {
      print('Failed to load answers: $error');
    });
  }

  @override
  Widget build(BuildContext context) {
    String formattedDate =
        DateFormat('dd/MM/yyyy').format(widget.question.date!);
    return Scaffold(
      backgroundColor: Themes.backgroundClr,
      appBar: AppBar(
        foregroundColor: Colors.white,
        title: const Text(
          'Chi tiết câu hỏi',
          style: TextStyle(fontSize: 20),
        ),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
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
            ListTile(
              leading: CircleAvatar(
                child: Icon(
                  Icons.person,
                  size: 30,
                  color: Colors.purple.withOpacity(0.5),
                ),
              ),
              title: Text(
                '${widget.question.gender}, ${widget.question.age} tuổi',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: Text(
                formattedDate,
                style: const TextStyle(
                  fontSize: 15,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
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
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: widget.question.categories
                    .map((category) => Padding(
                          padding: const EdgeInsets.only(left: 16),
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Themes.gradientLightClr,
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: Text(
                              category,
                              style: const TextStyle(
                                  fontSize: 14, color: Colors.white),
                            ),
                          ),
                        ))
                    .toList(),
              ),
            ),
            const SizedBox(
              height: 5,
            ),
            const Divider(
              color: Colors.grey,
              thickness: 0.5,
              height: 10,
            ),
            Padding(
              padding: const EdgeInsets.all(16),
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
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                  ),
                  tileColor: Colors.grey[100],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  title: FutureBuilder<DocumentSnapshot>(
                    future: FirebaseFirestore.instance
                        .collection('users')
                        .doc(userId)
                        .get(),
                    builder: (BuildContext context,
                        AsyncSnapshot<DocumentSnapshot> snapshot) {
                      if (snapshot.hasError) {
                        return const Text('Error loading user data');
                      }

                      if (snapshot.connectionState == ConnectionState.done) {
                        Map<String, dynamic> userData =
                            snapshot.data!.data() as Map<String, dynamic>;
                        String imageUrl = userData['imageURL'];

                        // Check if the current user is the author of the question
                        bool isAnswererAuthor =
                            widget.question.questionUserId == userId;

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
                                          color: Colors.purple.withOpacity(0.5),
                                        ),
                                      )
                                    : CircleAvatar(
                                        backgroundImage: NetworkImage(imageUrl),
                                      ),
                                const SizedBox(width: 8),
                                Text(
                                  isAnswererAuthor
                                      ? '${widget.question.gender}, ${widget.question.age} tuổi'
                                      : currentUserRole == 'admin'
                                          ? 'Quản trị viên'
                                          : 'Bác sĩ ${userData['name']}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                const Spacer(),
                                if (currentUserRole == 'admin')
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      IconButton(
                                        onPressed: () {
                                          _showDeleteConfirmationDialog(
                                              answerData);
                                        },
                                        icon: const Icon(Icons.delete),
                                        color: Colors.red,
                                      ),
                                    ],
                                  ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Container(
                              width: double.infinity,
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 6),
                              child: Text(
                                answer,
                                style: const TextStyle(fontSize: 16),
                              ),
                            ),
                          ],
                        );
                      }
                      return const Center(
                          child:
                              CircularProgressIndicator()); // While waiting for the data, show a loading indicator
                    },
                  ),
                );
              },
            ),
          ],
        ),
      ),
      bottomNavigationBar: (widget.question.questionUserId == currentUser.uid ||
              currentUserRole == "doctor")
          ? Container(
              height: 70,
              padding: const EdgeInsets.symmetric(
                vertical: 8,
                horizontal: 10,
              ),
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(
                  top: BorderSide(
                    color: Colors.blueGrey,
                    width: 0.2,
                  ),
                ),
              ),
              child: GestureDetector(
                onTap: () {
                  _showAnswerDialog(context);
                },
                child: Container(
                  padding: const EdgeInsets.all(13),
                  margin: const EdgeInsets.symmetric(horizontal: 5),
                  decoration: BoxDecoration(
                    color: Themes.gradientDeepClr,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  alignment: Alignment.center,
                  child: const Text(
                    'Thêm tin nhắn',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            )
          : null,
    );
  }

  void _showDeleteConfirmationDialog(Map<String, dynamic> answerData) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Xác nhận xóa câu trả lời'),
          content: const Text('Bạn có chắc chắn muốn xóa câu trả lời này?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Hủy'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _deleteAnswerFromFirebase(answerData);
              },
              style: ElevatedButton.styleFrom(
                primary: Colors.red,
                textStyle: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              child: const Text('Xóa'),
            ),
          ],
        );
      },
    );
  }

  void _deleteAnswerFromFirebase(Map<String, dynamic> answerData) {
    FirebaseFirestore.instance
        .collection('questions')
        .doc(widget.question.id)
        .update({
      'answers': FieldValue.arrayRemove([answerData])
    }).then((_) {
      print('Answer deleted from Firestore');
      _loadAnswers();
    }).catchError((error) {
      print('Failed to delete answer: $error');
    });
  }

  void _showAnswerDialog(BuildContext context) {
    TextEditingController answerController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            'Thêm câu trả lời',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              height: 2,
            ),
            textAlign: TextAlign.center,
          ),
          content: SizedBox(
            width: 300,
            child: TextField(
              controller: answerController,
              maxLines: 5,
              decoration: const InputDecoration(
                  border: OutlineInputBorder(), hintText: 'Nhập câu trả lời'),
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
    }).then((_) {
      print('Answer saved to Firestore');
      _loadAnswers();
    }).catchError((error) {
      print('Failed to save answer: $error');
    });
  }
}
