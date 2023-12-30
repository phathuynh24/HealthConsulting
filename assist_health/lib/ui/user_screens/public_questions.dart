// ignore_for_file: avoid_print

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:assist_health/models/other/question.dart';
import 'package:assist_health/others/theme.dart';
import 'package:assist_health/ui/user_screens/community.dart';
import 'package:assist_health/ui/user_screens/question_detail.dart';

class PublicQuestionsScreen extends StatefulWidget {
  const PublicQuestionsScreen({Key? key}) : super(key: key);

  @override
  State<PublicQuestionsScreen> createState() => _PublicQuestionsScreenState();
}

class _PublicQuestionsScreenState extends State<PublicQuestionsScreen> {
  List<bool> isLikedList = [];
  List<String> selectedFilterCategories = [];
  final List<String> categories = [
    "Tay mũi họng",
    "Bệnh nhiệt đới",
    "Nội thần kinh",
    "Mắt",
    "Nha khoa",
    "Chấn thương chỉnh hình",
    "Tim mạch",
    "Tiêu hóa",
    "Hô hấp",
    "Huyết học",
    "Nội tiết",
  ];
  late String currentUserId;
  bool showUserQuestions = false;

  void toggleLikeStatus(Question question) {
    FirebaseFirestore.instance.collection('questions').doc(question.id).update({
      'isLiked': question.isLiked,
    });
  }

  Future<void> _deleteQuestion(String questionId) async {
    try {
      await FirebaseFirestore.instance
          .collection('questions')
          .doc(questionId)
          .delete();
    } catch (e) {
      print('Error deleting question: $e');
    }
  }

  Future<bool> _currentUserIsAdmin() async {
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      try {
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();
        String? userRole = userDoc['role'];

        return userRole != null && userRole.toLowerCase() == 'admin';
      } catch (e) {
        print('Error getting user role: $e');
      }
    }

    return false;
  }

  Widget _buildActionButton(Question question, int index) {
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      return FutureBuilder<bool>(
        future: _currentUserIsAdmin(),
        builder: (context, snapshot) {
          if (snapshot.hasData && snapshot.data == true) {
            return IconButton(
              icon: const Icon(Icons.delete),
              color: Colors.blue,
              onPressed: () async {
                bool confirmDelete =
                    await _showDeleteConfirmationDialog(context);
                if (confirmDelete) {
                  await _deleteQuestion(question.id);
                }
              },
            );
          } else {
            bool isLiked =
                isLikedList.length > index ? isLikedList[index] : false;
            return IconButton(
              icon: Icon(
                isLiked ? Icons.favorite : Icons.favorite_border,
                color: isLiked ? Colors.red : Colors.grey,
              ),
              onPressed: () {
                setState(() {
                  isLikedList[index] = !isLikedList[index];
                  question.isLiked = isLikedList[index];
                  toggleLikeStatus(question);
                });
              },
            );
          }
        },
      );
    }

    return Container();
  }

  Future<bool> _showDeleteConfirmationDialog(BuildContext context) async {
    return await showDialog<bool>(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Confirm Delete'),
              content:
                  const Text('Are you sure you want to delete this question?'),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(false);
                  },
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(true);
                  },
                  child: const Text('Delete'),
                ),
              ],
            );
          },
        ) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Themes.backgroundClr,
      appBar: AppBar(
        title:
            Text(showUserQuestions ? 'Câu hỏi của bạn' : 'Hỏi đáp cộng đồng'),
        centerTitle: true,
        automaticallyImplyLeading: false,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Themes.gradientDeepClr, Themes.gradientLightClr],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () async {
              List<String>? result = await _showCategoryFilterDialog(context);

              if (result != null) {
                setState(() {
                  selectedFilterCategories = result;
                });
              }
            },
          ),
          Switch(
            value: showUserQuestions,
            onChanged: (value) {
              setState(() {
                showUserQuestions = value;
                User? user = FirebaseAuth.instance.currentUser;
                currentUserId = user?.uid ?? '';
                print('showUserQuestions: $showUserQuestions');
              });
            },
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('questions').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          final List<Question> questions = [];
          final List<DocumentSnapshot> documents = snapshot.data!.docs;
          User? user = FirebaseAuth.instance.currentUser;
          currentUserId = user?.uid ?? '';

          for (var document in documents) {
            final List<dynamic> categories = document['categories'];

            final question = Question(
              id: document.id,
              gender: document['gender'],
              age: document['age'],
              title: document['title'],
              content: document['content'],
              categories: categories.cast<String>().toList(),
              answerCount: 0,
              questionUserId: document['questionUserId'],
            );
            questions.add(question);
            isLikedList.add(false);
          }
          final filteredQuestions = questions
              .where((question) =>
                  (!showUserQuestions ||
                      (showUserQuestions &&
                          question.questionUserId == currentUserId)) &&
                  (selectedFilterCategories.isEmpty ||
                      question.categories.any((category) =>
                          selectedFilterCategories.contains(category))))
              .toList();

          return ListView.builder(
            itemCount: filteredQuestions.length,
            itemBuilder: (context, index) {
              return InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => QuestionDetailScreen(
                        question: filteredQuestions[index],
                      ),
                    ),
                  );
                },
                child: Column(
                  children: [
                    ListTile(
                      leading: const CircleAvatar(
                        child: Icon(
                          Icons.person,
                          size: 30,
                        ),
                      ),
                      title: Text(
                        '${filteredQuestions[index].gender}, ${filteredQuestions[index].age} tuổi',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Chủ đề: ${filteredQuestions[index].title}',
                            style: const TextStyle(
                              fontSize: 16,
                              height: 1.5,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Nội dung câu hỏi: ${filteredQuestions[index].content}',
                            style: const TextStyle(
                              fontSize: 16,
                              height: 1.5,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: filteredQuestions[index]
                                  .categories
                                  .map((category) => Padding(
                                        padding:
                                            const EdgeInsets.only(right: 8.0),
                                        child: Chip(
                                          label: Text(category),
                                          backgroundColor: Themes.selectedClr,
                                          labelStyle: TextStyle(
                                            color: Colors.white,
                                          ),
                                        ),
                                      ))
                                  .toList(),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(right: 16, bottom: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          const Icon(
                            Icons.chat,
                            color: Colors.blue,
                          ),
                          SizedBox(width: 10),
                          _buildActionButton(filteredQuestions[index], index),
                        ],
                      ),
                    ),
                    const Divider(),
                  ],
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.add),
        backgroundColor: Themes.selectedClr,
        label: const Text(
          'Đặt câu hỏi',
          style: TextStyle(
            fontSize: 18,
          ),
        ),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const CommunityScreen(),
            ),
          );
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  Future<List<String>?> _showCategoryFilterDialog(BuildContext context) async {
    List<String> selectedCategoriesCopy = List.from(selectedFilterCategories);

    return await showDialog<List<String>>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Chọn chuyên khoa thẩm mĩ'),
          content: Container(
            height: 300,
            width: 400,
            child: SingleChildScrollView(
              child: StatefulBuilder(
                builder: (BuildContext context, StateSetter setState) {
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: categories.map((category) {
                      final isSelected =
                          selectedCategoriesCopy.contains(category);
                      return CheckboxListTile(
                        title: Row(
                          children: [
                            Text(category),
                            if (isSelected) const Icon(Icons.check),
                          ],
                        ),
                        value: isSelected,
                        onChanged: (bool? value) {
                          setState(() {
                            if (value != null) {
                              if (value) {
                                selectedCategoriesCopy.add(category);
                              } else {
                                selectedCategoriesCopy.remove(category);
                              }
                            }
                          });
                        },
                      );
                    }).toList(),
                  );
                },
              ),
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Hủy'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(selectedCategoriesCopy);
              },
              child: const Text('Xác nhận'),
            ),
          ],
        );
      },
    );
  }
}
