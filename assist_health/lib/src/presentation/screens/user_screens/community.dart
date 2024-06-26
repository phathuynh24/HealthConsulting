import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:assist_health/src/others/theme.dart';
import 'package:assist_health/src/models/other/question.dart';
import 'package:assist_health/src/presentation/screens/user_screens/public_questions.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CommunityScreen extends StatefulWidget {
  const CommunityScreen({Key? key}) : super(key: key);

  @override
  State<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen> {
  bool isMaleSelected = true;
  int age = 18;
  String gender = 'Nam';

  final List<String> selectedCategories = [];
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

  final List<Question> questions = [];
  final TextEditingController titleController = TextEditingController();
  final TextEditingController contentController = TextEditingController();
  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  // Validation function to check if all required fields are filled
  bool _validateFields() {
    if (titleController.text.isEmpty || contentController.text.isEmpty) {
      _showSnackBar('Vui lòng hập đầy đủ thông tin!');
      return false;
    }
    if (selectedCategories.isEmpty) {
      _showSnackBar('Vui lòng chọn chủ đề!');
      return false;
    }
    // Additional validation checks can be added if needed
    return true;
  }

  Future<void> _showCategoryDialog() async {
    List<String> selectedCategoriesCopy = List.from(selectedCategories);

    await showDialog(
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
                setState(() {
                  selectedCategories.clear();
                  selectedCategories.addAll(selectedCategoriesCopy);
                });
                Navigator.of(context).pop();
              },
              child: const Text('Xác nhận'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Themes.backgroundClr,
      appBar: AppBar(
        foregroundColor: Colors.white,
        title: const Text('Đặt câu hỏi'),
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
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Giới tính',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  _genderToggleGender(),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  const Text(
                    'Tuổi',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Expanded(
                    child: _sliderAge(),
                  ),
                  Text(
                    '${age.toString()} tuổi',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            Container(
              margin: const EdgeInsets.symmetric(
                horizontal: 15,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Chủ đề',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  ElevatedButton(
                    onPressed: _showCategoryDialog,
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          Themes.gradientLightClr, // Đặt màu nền là màu đỏ
                      foregroundColor: Colors.white,
                      // primary: Themes.gradientLightClr, // Đặt màu nền là màu đỏ
                      // onPrimary: Colors.white, // Đặt màu chữ là màu trắng
                    ),
                    child: const Text(
                      'Chọn chủ đề',
                      style: TextStyle(
                        fontSize: 18,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    children: selectedCategories.map((category) {
                      return Container(
                        margin: const EdgeInsets.only(right: 5),
                        child: Chip(
                          label: Text(category),
                          onDeleted: () {
                            setState(() {
                              selectedCategories.remove(category);
                            });
                          },
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            Container(
              margin: const EdgeInsets.symmetric(
                horizontal: 15,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Row(
                    children: [
                      Text(
                        'Tiêu đề',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        ' *',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                          color: Colors.red,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  TextFormField(
                    controller: titleController,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: "Nhập tiêu đề...",
                    ),
                    maxLines: 1,
                  ),
                ],
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            Container(
              margin: const EdgeInsets.symmetric(
                horizontal: 15,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Row(
                    children: [
                      Text(
                        'Nội dung',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        ' *',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                          color: Colors.red,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  TextFormField(
                    controller: contentController,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: "Nhập nội dung...",
                    ),
                    maxLines: 5,
                  ),
                ],
              ),
            ),
            const SizedBox(
              height: 30,
            ),
            ActionChip(
              onPressed: () async {
                if (!_validateFields()) {
                  return;
                }
                // Get the current user
                User? user = FirebaseAuth.instance.currentUser;

                if (user != null) {
                  String currentUserId = user.uid;

                  final id = DateTime.now().millisecondsSinceEpoch.toString();
                  final question = Question(
                    id: id,
                    gender: gender,
                    age: age,
                    answerCount: 0,
                    title: titleController.text,
                    content: contentController.text,
                    categories: selectedCategories,
                    questionUserId: currentUserId,
                    date: DateTime.now(),
                  );

                  await FirebaseFirestore.instance
                      .collection('questions')
                      .doc(id)
                      .set({
                    'gender': question.gender,
                    'age': question.age,
                    'title': question.title,
                    'content': question.content,
                    'categories': FieldValue.arrayUnion(question.categories),
                    'questionUserId': currentUserId,
                    'date': question.date!,
                  });

                  // ignore: use_build_context_synchronously
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const PublicQuestionsScreen()),
                  );

                  setState(() {
                    questions.add(question);
                  });

                  titleController.clear();
                  contentController.clear();
                }
              },
              avatar: const Icon(
                Icons.send,
                color: Colors.white,
              ),
              backgroundColor: Themes.gradientDeepClr,
              label: const Text(
                'Gửi',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                ),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
            const SizedBox(
              height: 20,
            ),
          ],
        ),
      ),
    );
  }

  Widget _genderToggleGender() {
    return Container(
      height: 40,
      width: 300,
      margin: const EdgeInsets.symmetric(horizontal: 50),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20.0),
        color: Colors.grey[300],
      ),
      child: Row(
        children: [
          Expanded(
            child: InkWell(
              onTap: () {
                setState(() {
                  gender = 'Nam';
                  isMaleSelected = true;
                });
              },
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(10.0),
                bottomLeft: Radius.circular(10.0),
              ),
              child: Container(
                height: 40,
                decoration: BoxDecoration(
                  color: isMaleSelected ? Colors.blue : Colors.transparent,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20.0),
                    bottomLeft: Radius.circular(20.0),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.male,
                      color: isMaleSelected ? Colors.white : Colors.black,
                    ),
                    const SizedBox(width: 4.0),
                    Text(
                      'Nam',
                      style: TextStyle(
                        color: isMaleSelected ? Colors.white : Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: InkWell(
              onTap: () {
                setState(() {
                  gender = 'Nữ';
                  isMaleSelected = false;
                });
              },
              borderRadius: const BorderRadius.only(
                topRight: Radius.circular(10.0),
                bottomRight: Radius.circular(10.0),
              ),
              child: Container(
                height: 40,
                decoration: BoxDecoration(
                  color: !isMaleSelected ? Colors.blue : Colors.transparent,
                  borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(20.0),
                    bottomRight: Radius.circular(20.0),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.female,
                      color: !isMaleSelected ? Colors.white : Colors.black,
                    ),
                    const SizedBox(width: 4.0),
                    Text(
                      'Nữ',
                      style: TextStyle(
                        color: !isMaleSelected ? Colors.white : Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sliderAge() {
    return SliderTheme(
      data: const SliderThemeData(
        trackHeight: 10,
      ),
      child: Slider(
        value: age.toDouble(),
        min: 0,
        max: 100,
        activeColor: Themes.gradientLightClr,
        divisions: 100,
        label: '${age.round().toString()} tuổi',
        onChanged: (newValue) {
          setState(() {
            age = newValue.toInt();
          });
        },
      ),
    );
  }
}
