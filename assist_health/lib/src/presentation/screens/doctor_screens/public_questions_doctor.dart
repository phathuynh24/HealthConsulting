// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:assist_health/src/models/other/question.dart';
import 'package:assist_health/src/widgets/doctor_navbar.dart';
import 'package:assist_health/src/others/theme.dart';
import 'package:assist_health/src/presentation/screens/user_screens/question_detail.dart';
import 'package:intl/intl.dart';

class PublicQuestionsDoctorScreen extends StatefulWidget {
  const PublicQuestionsDoctorScreen({super.key});

  @override
  State<PublicQuestionsDoctorScreen> createState() =>
      _PublicQuestionsDoctorScreenState();
}

class _PublicQuestionsDoctorScreenState
    extends State<PublicQuestionsDoctorScreen> {
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
    } catch (error) {
      print('Failed to load answers: $error');
    }
    return count;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const DoctorNavBar()),
          (route) => false,
        );
        return true;
      },
      child: Scaffold(
        backgroundColor: Themes.backgroundClr,
        appBar: AppBar(
          foregroundColor: Colors.white,
          title: const Text(
            'Hỏi đáp cộng đồng',
            style: TextStyle(fontSize: 20),
          ),
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
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 5, horizontal: 15),
                decoration: BoxDecoration(
                    border: Border(
                  bottom: BorderSide(color: Colors.blueGrey.shade100),
                )),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            showUserQuestions = false;
                            User? user = FirebaseAuth.instance.currentUser;
                            currentUserId = user?.uid ?? '';
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            color: !showUserQuestions
                                ? Themes.gradientDeepClr
                                : Colors.white,
                          ),
                          child: Center(
                            child: Text(
                              'Tất cả',
                              style: TextStyle(
                                fontSize: 16,
                                color: !showUserQuestions
                                    ? Colors.white
                                    : Colors.grey.shade600,
                                fontWeight: !showUserQuestions
                                    ? FontWeight.w500
                                    : FontWeight.w400,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            showUserQuestions = true;
                            User? user = FirebaseAuth.instance.currentUser;
                            currentUserId = user?.uid ?? '';
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            color: showUserQuestions
                                ? Themes.gradientDeepClr
                                : Colors.white,
                          ),
                          child: Center(
                            child: Text(
                              'Câu hỏi xử lý',
                              style: TextStyle(
                                fontSize: 16,
                                color: showUserQuestions
                                    ? Colors.white
                                    : Colors.grey.shade600,
                                fontWeight: showUserQuestions
                                    ? FontWeight.w500
                                    : FontWeight.w400,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
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
                    bool isDoctor = !showUserQuestions ||
                        (showUserQuestions &&
                            question.answers.any((element) =>
                                element['userId'] ==
                                FirebaseAuth.instance.currentUser!.uid));

                    bool hasSelectedCategories =
                        selectedFilterCategories.isEmpty ||
                            question.categories.any((category) =>
                                selectedFilterCategories.contains(category));

                    return isDoctor && hasSelectedCategories;
                  }).toList();

                  filteredQuestions.sort((a, b) => b.date!.compareTo(a.date!));
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
              Container(
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
}
