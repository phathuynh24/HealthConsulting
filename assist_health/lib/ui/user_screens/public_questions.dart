import 'package:assist_health/others/theme.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:assist_health/models/other/question.dart';
import 'package:assist_health/ui/user_screens/question_detail.dart';

class PublicQuestionsScreen extends StatelessWidget {
  const PublicQuestionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Themes.backgroundClr,
      appBar: AppBar(
        title: const Text('Public Questions'),
        backgroundColor: Themes.hearderClr,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('public_questions')
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          final List<Question> questions = [];
          final List<DocumentSnapshot> documents = snapshot.data!.docs;

          for (var document in documents) {
            final question = Question(
              id: document.id,
              gender: document['gender'],
              age: document['age'],
              title: document['title'],
              content: document['content'],
            );

            questions.add(question);
          }

          return ListView.builder(
            itemCount: questions.length,
            itemBuilder: (context, index) {
              return ListTile(
                title: Text(
                    'Tuổi: ${questions[index].age} - Giới tính: ${questions[index].gender}'),
                subtitle: Text('Chủ đề: ${questions[index].title}'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => QuestionDetailScreen(
                        question: questions[index],
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
