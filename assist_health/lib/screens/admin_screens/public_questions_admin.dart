// ignore_for_file: avoid_print

import 'package:assist_health/screens/widgets/admin_navbar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:assist_health/models/other/question.dart';
import 'package:assist_health/others/theme.dart';
import 'package:assist_health/screens/user_screens/question_detail.dart';
import 'package:intl/intl.dart';

class PublicQuestionsAdminScreen extends StatefulWidget {
  const PublicQuestionsAdminScreen({super.key});

  @override
  State<PublicQuestionsAdminScreen> createState() =>
      _PublicQuestionsAdminScreenState();
}

class _PublicQuestionsAdminScreenState
    extends State<PublicQuestionsAdminScreen> {
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
    } catch (e) {}
  }

  Future<int> _countAnswers(String questionId) async {
    int count = 0;
    try {
      DocumentSnapshot docSnapshot = await FirebaseFirestore.instance
          .collection('questions')
          .doc(questionId)
          .get();
      if (docSnapshot.exists) {
        List<Map<String, dynamic>> answers =
            List<Map<String, dynamic>>.from(docSnapshot.get('answers') ?? []);
        count = answers.length;
      }
    } catch (error) {}
    return count;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const AdminNavBar()),
          (route) => false,
        );
        return true;
      },
      child: Scaffold(
        backgroundColor: Themes.backgroundClr,
        body: SingleChildScrollView(
          child: Column(
            children: [
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('questions')
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const SizedBox(
                      width: double.infinity,
                      height: double.infinity,
                      child: Center(
                        child: CircularProgressIndicator(),
                      ),
                    );
                  }

                  final List<Question> questions = [];
                  final List<DocumentSnapshot> documents = snapshot.data!.docs;
                  User? user = FirebaseAuth.instance.currentUser;
                  currentUserId = user?.uid ?? '';

                  for (var document in documents) {
                    Timestamp timestampDate = document['date'];
                    DateTime date = timestampDate.toDate();

                    final List<dynamic> categories = document['categories'];

                    List<Map<String, dynamic>> tempAnswers = [];
                    try {
                      tempAnswers = List<Map<String, dynamic>>.from(
                          document.get('answers'));
                    } catch (e) {}

                    final question = Question(
                      id: document.id,
                      gender: document['gender'],
                      age: document['age'],
                      title: document['title'],
                      content: document['content'],
                      categories: categories.cast<String>().toList(),
                      answerCount: 0,
                      questionUserId: document['questionUserId'],
                      date: date,
                      answers: tempAnswers,
                    );
                    questions.add(question);
                    isLikedList.add(false);
                  }

                  List<Question> filteredQuestions = [];
                  filteredQuestions = questions.where((question) {
                    bool hasSelectedCategories =
                        selectedFilterCategories.isEmpty ||
                            question.categories.any((category) =>
                                selectedFilterCategories.contains(category));

                    return hasSelectedCategories;
                  }).toList();

                  filteredQuestions.sort((a, b) => b.date!.compareTo(a.date!));

                  // Nếu trống
                  if (filteredQuestions.isEmpty) {
                    return Center(
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 20),
                        height: 500,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset(
                              'assets/empty-box.png',
                              width: 250,
                              height: 250,
                              fit: BoxFit.contain,
                            ),
                            const SizedBox(
                              height: 12,
                            ),
                            const Text(
                              'Không có câu hỏi',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.blueGrey,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(
                              height: 6,
                            ),
                            const Text(
                              'Các câu hỏi sẽ được hiển thị tại đây.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.blueGrey,
                                height: 1.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }
                  //--------------------------------

                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: filteredQuestions.length,
                    itemBuilder: (context, index) {
                      String formattedDate = DateFormat('dd/MM/yyyy')
                          .format(filteredQuestions[index].date!);
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
                            Row(
                              children: [
                                Expanded(
                                  child: ListTile(
                                    leading: CircleAvatar(
                                      child: Icon(
                                        Icons.person,
                                        size: 30,
                                        color: Colors.purple.withOpacity(0.5),
                                      ),
                                    ),
                                    title: Text(
                                      '${filteredQuestions[index].gender}, ${filteredQuestions[index].age} tuổi',
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
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(
                                      right: 16, bottom: 8),
                                  child: Row(
                                    children: [
                                      const Icon(
                                        CupertinoIcons.chat_bubble_text,
                                        color: Colors.blue,
                                      ),
                                      const SizedBox(width: 4),
                                      FutureBuilder<int>(
                                        future: _countAnswers(
                                            filteredQuestions[index].id),
                                        builder: (BuildContext context,
                                            AsyncSnapshot<int> snapshot) {
                                          if (snapshot.connectionState ==
                                              ConnectionState.waiting) {
                                            return const Text('...');
                                          } else if (snapshot.hasError) {
                                            return Text(
                                                'Lỗi: ${snapshot.error}');
                                          } else {
                                            return Text(
                                                snapshot.data.toString());
                                          }
                                        },
                                      ),
                                      const SizedBox(width: 5),
                                      IconButton(
                                        icon: const Icon(Icons.delete),
                                        color: Colors.red,
                                        onPressed: () async {
                                          bool confirmDelete =
                                              await _showDeleteConfirmationDialog(
                                                  context);
                                          if (confirmDelete) {
                                            await _deleteQuestion(
                                                filteredQuestions[index].id);
                                          }
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            Container(
                              width: double.infinity,
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 20),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Chủ đề: ${filteredQuestions[index].title}',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      height: 1.5,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    maxLines: 2,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Nội dung câu hỏi: ${filteredQuestions[index].content}',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      height: 1.5,
                                      fontWeight: FontWeight.w400,
                                    ),
                                    maxLines: 3,
                                  ),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,
                                    child: Row(
                                      children: filteredQuestions[index]
                                          .categories
                                          .map((category) => Padding(
                                                padding: const EdgeInsets.only(
                                                    right: 8),
                                                child: Container(
                                                  padding:
                                                      const EdgeInsets.all(8),
                                                  decoration: BoxDecoration(
                                                    color:
                                                        Themes.gradientLightClr,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            5),
                                                  ),
                                                  child: Text(
                                                    category,
                                                    style: const TextStyle(
                                                        fontSize: 14,
                                                        color: Colors.white),
                                                  ),
                                                ),
                                              ))
                                          .toList(),
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 5,
                                  ),
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
              const SizedBox(
                height: 80,
              ),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton.extended(
          icon: const Icon(
            Icons.filter_list,
            color: Colors.white,
          ),
          backgroundColor: Themes.gradientDeepClr,
          label: const Text(
            'Lọc theo chủ đề',
            style: TextStyle(
              fontSize: 18,
              color: Colors.white,
            ),
          ),
          onPressed: () async {
            List<String>? result = await _showCategoryFilterDialog(context);
            if (result != null) {
              setState(() {
                selectedFilterCategories = result;
              });
            }
          },
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      ),
    );
  }

  Future<List<String>?> _showCategoryFilterDialog(BuildContext context) async {
    List<String> selectedCategoriesCopy = List.from(selectedFilterCategories);

    return await showDialog<List<String>>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            'Chọn chủ đề',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
          content: SizedBox(
            height: 400,
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
                            SizedBox(width: 160, child: Text(category)),
                            const SizedBox(
                              width: 5,
                            ),
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

  Future<bool> _showDeleteConfirmationDialog(BuildContext context) async {
    return await showDialog<bool>(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Xác nhận xóa'),
              content: const Text('Bạn có muốn xóa câu hỏi này không?'),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(false);
                  },
                  child: const Text('Hủy'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(true);
                  },
                  child: const Text('Xóa'),
                ),
              ],
            );
          },
        ) ??
        false;
  }
}
