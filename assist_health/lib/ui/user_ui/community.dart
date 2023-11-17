import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:assist_health/models/other/question.dart';
import 'package:assist_health/ui/user_ui/public_questions.dart';

class CommunityScreen extends StatefulWidget {
  const CommunityScreen({super.key});

  @override
  State<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen> {
  final List<Question> questions = [];

  final TextEditingController titleController = TextEditingController();
  final TextEditingController contentController = TextEditingController();
  int age = 18;
  String gender = 'Nam'; // Giá trị mặc định

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cộng đồng hỏi đáp'),
        centerTitle: true,
        backgroundColor: const Color(0xFF7165D6),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                const Text('Giới tính: '),
                Radio(
                  value: 'Nam',
                  groupValue: gender,
                  onChanged: (value) {
                    setState(() {
                      gender = value.toString();
                    });
                  },
                ),
                const Text('Nam'),
                Radio(
                  value: 'Nữ',
                  groupValue: gender,
                  onChanged: (value) {
                    setState(() {
                      gender = value.toString();
                    });
                  },
                ),
                const Text('Nữ'),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                const Text('Age: '),
                Expanded(
                  child: Slider(
                    value: age.toDouble(),
                    min: 0,
                    max: 100,
                    divisions: 82,
                    onChanged: (value) {
                      setState(() {
                        age = value.toInt();
                      });
                    },
                  ),
                ),
                Text(age.toString()),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: titleController,
              decoration: const InputDecoration(
                labelText: 'Tiêu đề',
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: contentController,
              decoration: const InputDecoration(
                labelText: 'Nội dung',
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              final id = DateTime.now().millisecondsSinceEpoch.toString();
              final question = Question(
                id: id,
                gender: gender,
                age: age,
                title: titleController.text,
                content: contentController.text,
              );

              FirebaseFirestore.instance.collection('questions').doc(id).set({
                'gender': question.gender,
                'age': question.age,
                'title': question.title,
                'content': question.content,
              });

              FirebaseFirestore.instance
                  .collection('public_questions')
                  .doc(id)
                  .set({
                'gender': question.gender,
                'age': question.age,
                'title': question.title,
                'content': question.content,
              });

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
            },
            child: const Text('Gửi'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => const PublicQuestionsScreen()),
              );
            },
            child: const Text('Public Questions'),
          ),
        ],
      ),
    );
  }
}
