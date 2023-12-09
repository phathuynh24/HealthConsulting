import 'package:assist_health/others/theme.dart';
import 'package:assist_health/ui/user_screens/community.dart';
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
        title: const Text('Cộng đồng hỏi đáp'),
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
                leading: const CircleAvatar(
                  child: Icon(
                    Icons.person,
                    size: 30,
                  ),
                ),
                title: Text(
                  '${questions[index].gender}, ${questions[index].age} tuổi',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Text(
                  'Chủ đề: ${questions[index].title}',
                  style: const TextStyle(
                    fontSize: 16,
                    height: 1.5,
                    fontWeight: FontWeight.w400,
                  ),
                ),
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
    );
  }
}
