import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:assist_health/functions/question.dart';
import 'package:assist_health/user_screens/question_detail_screen.dart';
import 'package:assist_health/user_screens/public_questions_screen.dart';
class CommunityScreen extends StatefulWidget {
  @override
  _CommunityScreenState createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen> {
  final List<Question> questions = [];

  final TextEditingController titleController = TextEditingController();
  final TextEditingController contentController = TextEditingController();
  bool isAnonymous = true;
  int age = 18;
  String gender = 'Male'; // Giá trị mặc định

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Community'),
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(16.0),
            child: Row(
              children: [
                Text('Anonymous: '),
                Checkbox(
                  value: isAnonymous,
                  onChanged: (value) {
                    setState(() {
                      isAnonymous = value!;
                    });
                  },
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.all(16.0),
            child: Row(
              children: [
                Text('Gender: '),
                Radio(
                  value: 'Male',
                  groupValue: gender,
                  onChanged: (value) {
                    setState(() {
                      gender = value.toString();
                    });
                  },
                ),
                Text('Male'),
                Radio(
                  value: 'Female',
                  groupValue: gender,
                  onChanged: (value) {
                    setState(() {
                      gender = value.toString();
                    });
                  },
                ),
                Text('Female'),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.all(16.0),
            child: Row(
              children: [
                Text('Age: '),
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
            padding: EdgeInsets.all(16.0),
            child: TextField(
              controller: titleController,
              decoration: InputDecoration(
                labelText: 'Title',
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(16.0),
            child: TextField(
              controller: contentController,
              decoration: InputDecoration(
                labelText: 'Content',
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
                isAnonymous: isAnonymous,
              );
              FirebaseFirestore.instance
                  .collection('questions')
                  .doc(id)
                  .set({
                'gender': question.gender,
                'age': question.age,
                'title': question.title,
                'content': question.content,
                'isAnonymous': question.isAnonymous,
              });

              FirebaseFirestore.instance
                  .collection('public_questions')
                  .doc(id)
                  .set({
                'gender': question.gender,
                'age': question.age,
                'title': question.title,
                'content': question.content,
                'isAnonymous': question.isAnonymous,
              });

              setState(() {
                questions.add(question);
              });

              titleController.clear();
              contentController.clear();
            },
            child: Text('Submit'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => PublicQuestionsScreen()),
              );
            },
            child: Text('Public Questions'),
          ),
        ],
      ),
    );
  }
}