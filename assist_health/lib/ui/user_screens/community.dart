import 'package:assist_health/others/theme.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:assist_health/models/other/question.dart';
import 'package:assist_health/ui/user_screens/public_questions.dart';

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
    'Health', 'Fitness', 'Nutrition', 'Mental Health', 'Other'
    ];

  final List<Question> questions = [];
  final TextEditingController titleController = TextEditingController();
  final TextEditingController contentController = TextEditingController();

  // Method to show the category selection dialog
  Future<void> _showCategoryDialog() async {
  List<String> selectedCategoriesCopy = List.from(selectedCategories);

  await showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Chọn chuyên khoa thẩm mĩ'),
        content: StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: categories.map((category) {
                final isSelected = selectedCategoriesCopy.contains(category);
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
                    'Giới tính:',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                      color: Colors.black54,
                    ),
                  ),
                  const SizedBox(
                    height: 20,
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
                    'Tuổi:',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                      color: Colors.black54,
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
                    'Chuyên khoa:',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                      color: Colors.black54,
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Wrap(
                    children: selectedCategories.map((category) {
                      return Chip(
                        label: Text(category),
                        onDeleted: () {
                          setState(() {
                            selectedCategories.remove(category);
                          });
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 5),
                  ElevatedButton(
                    onPressed: _showCategoryDialog,
                    child: const Text('Chọn chuyên khoa'),
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
                  const Text(
                    'Tiêu đề:',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                      color: Colors.black54,
                    ),
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
                  const Text(
                    'Nội dung:',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                      color: Colors.black54,
                    ),
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
                    maxLines: 10,
                  ),
                ],
              ),
            ),
            const SizedBox(
              height: 30,
            ),
            ActionChip(
              onPressed: () {
                final id = DateTime.now().millisecondsSinceEpoch.toString();
                final question = Question(
                  id: id,
                  gender: gender,
                  age: age,
                  answerCount: 0,
                  title: titleController.text,
                  content: contentController.text,
                  categories: selectedCategories,
                );

                FirebaseFirestore.instance.collection('questions').doc(id).set({
                  'gender': question.gender,
                  'age': question.age,
                  'title': question.title,
                  'content': question.content,
                  'categories': FieldValue.arrayUnion(question.categories),
                });

                FirebaseFirestore.instance.collection('public_questions').doc(id).set({
                  'gender': question.gender,
                  'age': question.age,
                  'title': question.title,
                  'content': question.content,
                  'categories': FieldValue.arrayUnion(question.categories),
                });

                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const PublicQuestionsScreen()),
                );

                setState(() {
                  questions.add(question);
                });

                titleController.clear();
                contentController.clear();
              },
              avatar: const Icon(
                Icons.send,
                color: Colors.white,
              ),
              backgroundColor: Themes.buttonClr,
              label: const Text(
                'Gửi',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                ),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 18),
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
        activeColor: Themes.selectedClr,
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
