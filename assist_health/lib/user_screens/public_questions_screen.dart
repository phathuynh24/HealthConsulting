import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:assist_health/functions/question.dart';
import 'package:assist_health/user_screens/question_detail_screen.dart';

class PublicQuestionsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Public Questions'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('public_questions').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(
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
              isAnonymous: document['isAnonymous'],
            );

            questions.add(question);
          }

          return ListView.builder(
            itemCount: questions.length,
            itemBuilder: (context, index) {
              return ListTile(
                title: Text('Question: ${questions[index].title}'),
                subtitle: Text(
                  'Anonymous: ${questions[index].isAnonymous ? "Yes" : "No"}'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => QuestionDetailScreen(
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