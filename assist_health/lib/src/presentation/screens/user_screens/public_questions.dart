// ignore_for_file: avoid_print
import 'package:assist_health/src/presentation/screens/user_screens/meals/widgets/loading_indicator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:assist_health/src/widgets/user_navbar.dart';
import 'package:assist_health/src/models/other/question.dart';
import 'package:assist_health/src/others/theme.dart';
import 'package:assist_health/src/presentation/screens/user_screens/community.dart';
import 'package:assist_health/src/presentation/screens/user_screens/question_detail.dart';
import 'package:intl/intl.dart';

class PublicQuestionsScreen extends StatefulWidget {
  const PublicQuestionsScreen({super.key});

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
  bool isSaving = false;

  // Load more
  int itemsPerPage = 5;
  int currentPage = 1;
  bool isLoadingMore = false;

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
            return Container(); // Return an empty container for non-admin users
          }
        },
      );
    }

    return Container(); // Return an empty container for unauthenticated users
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
                  child: const Text('Delete'),
                ),
              ],
            );
          },
        ) ??
        false;
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

  Widget _buildUserActionButton(Question question) {
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null && user.uid == question.questionUserId) {
      return Row(
        children: [
          IconButton(
            icon: const Icon(Icons.edit),
            color: Colors.green,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => CommunityScreen(questionToEdit: question),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            color: Colors.red,
            onPressed: () async {
              bool confirmDelete = await _showDeleteConfirmationDialog(context);
              if (confirmDelete) {
                await _deleteQuestion(question.id);
                setState(() {}); // Cập nhật lại giao diện sau khi xóa
              }
            },
          ),
        ],
      );
    }
    return Container();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const UserNavBar()),
          (route) => false,
        );
        return true;
      },
      child: Stack(
        children: [
          Scaffold(
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
              actions: [
                IconButton(
                  icon: const Icon(Icons.filter_list),
                  onPressed: () async {
                    List<String>? result =
                        await _showCategoryFilterDialog(context);
                    if (result != null) {
                      setState(() {
                        selectedFilterCategories = result;
                      });
                    }
                  },
                ),
              ],
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
                                  'Câu hỏi của tôi',
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
                      final List<DocumentSnapshot> documents =
                          snapshot.data!.docs;
                      User? user = FirebaseAuth.instance.currentUser;
                      currentUserId = user?.uid ?? '';

                      for (var document in documents) {
                        final data = document.data() as Map<String, dynamic>?;

                        if (data != null) {
                          Timestamp timestampDate = data['date'];
                          DateTime date = timestampDate.toDate();
                          final List<dynamic> categories = data['categories'];

                          final question = Question(
                            id: document.id,
                            gender: data['gender'],
                            age: data['age'],
                            title: data['title'],
                            content: data['content'],
                            categories: categories.cast<String>().toList(),
                            answerCount: 0,
                            questionUserId: data['questionUserId'],
                            date: date,
                            imageUrls: data.containsKey('imageUrls')
                                ? List<String>.from(data['imageUrls'])
                                : [],
                          );

                          questions.add(question);
                          isLikedList.add(false);
                        }
                      }
                      final filteredQuestions = questions
                          .where((question) =>
                              (!showUserQuestions ||
                                  (showUserQuestions &&
                                      question.questionUserId ==
                                          currentUserId)) &&
                              (selectedFilterCategories.isEmpty ||
                                  question.categories.any((category) =>
                                      selectedFilterCategories
                                          .contains(category))))
                          .toList();

                      filteredQuestions
                          .sort((a, b) => b.date!.compareTo(a.date!));

                      // Load more
                      final displayedQuestions = filteredQuestions
                          .take(currentPage * itemsPerPage)
                          .toList();

                      return Column(
                        children: [
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: displayedQuestions.length,
                            itemBuilder: (context, index) {
                              String formattedDate = DateFormat('dd/MM/yyyy')
                                  .format(displayedQuestions[index].date!);

                              return InkWell(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => QuestionDetailScreen(
                                        question: displayedQuestions[index],
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
                                                color: Colors.purple
                                                    .withOpacity(0.5),
                                              ),
                                            ),
                                            title: Text(
                                              '${displayedQuestions[index].gender}, ${displayedQuestions[index].age} tuổi',
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
                                                    displayedQuestions[index]
                                                        .id),
                                                builder: (BuildContext context,
                                                    AsyncSnapshot<int>
                                                        snapshot) {
                                                  if (snapshot
                                                          .connectionState ==
                                                      ConnectionState.waiting) {
                                                    return const Text('...');
                                                  } else if (snapshot
                                                      .hasError) {
                                                    return Text(
                                                        'Lỗi: ${snapshot.error}');
                                                  } else {
                                                    return Text(snapshot.data
                                                        .toString());
                                                  }
                                                },
                                              ),
                                              const SizedBox(width: 5),
                                              _buildActionButton(
                                                  displayedQuestions[index],
                                                  index),
                                              _buildUserActionButton(
                                                  displayedQuestions[index]),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 20),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Chủ đề: ${displayedQuestions[index].title}',
                                            style: const TextStyle(
                                              fontSize: 16,
                                              height: 1.5,
                                              fontWeight: FontWeight.bold,
                                            ),
                                            maxLines: 2,
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            'Nội dung câu hỏi: ${displayedQuestions[index].content}',
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
                                              children: displayedQuestions[
                                                      index]
                                                  .categories
                                                  .map((category) => Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .only(right: 8),
                                                        child: Container(
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(8),
                                                          decoration:
                                                              BoxDecoration(
                                                            color: Themes
                                                                .gradientLightClr,
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        5),
                                                          ),
                                                          child: Text(
                                                            category,
                                                            style:
                                                                const TextStyle(
                                                                    fontSize:
                                                                        14,
                                                                    color: Colors
                                                                        .white),
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
                          ),
                          if (displayedQuestions.length <
                              filteredQuestions.length)
                            isLoadingMore
                                ? const Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: CircularProgressIndicator(),
                                  )
                                : ElevatedButton(
                                    onPressed: () async {
                                      setState(() => isLoadingMore = true);
                                      await Future.delayed(
                                          const Duration(seconds: 1));
                                      setState(() {
                                        currentPage++;
                                        isLoadingMore = false;
                                      });
                                    },
                                    child: const Text('Tải thêm'),
                                  ),
                        ],
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
                Icons.add,
                color: Colors.white,
              ),
              backgroundColor: Themes.gradientDeepClr,
              label: const Text(
                'Đặt câu hỏi',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.white,
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
          ),
          if (isSaving)
            Container(
              color: Colors.black.withOpacity(0.3),
              child: const Center(
                child: LoadingIndicator(),
              ),
            ),
        ],
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
