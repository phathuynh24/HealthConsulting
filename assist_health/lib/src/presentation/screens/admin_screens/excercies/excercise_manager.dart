import 'package:assist_health/src/others/theme.dart';
import 'package:assist_health/src/presentation/screens/admin_screens/excercies/create_exercise.dart';
import 'package:assist_health/src/presentation/screens/admin_screens/excercies/excercise.dart';
import 'package:assist_health/src/presentation/screens/admin_screens/excercies/excercise_detail.dart';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ExerciseManagerScreen extends StatefulWidget {
  const ExerciseManagerScreen({super.key});

  @override
  _ExerciseManagerScreenState createState() => _ExerciseManagerScreenState();
}

class _ExerciseManagerScreenState extends State<ExerciseManagerScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        foregroundColor: Colors.white,
        title: const Text(
          'Quản lý bài tập',
          style: TextStyle(fontSize: 20),
        ),
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
      body: StreamBuilder(
        stream: _firestore.collection('exercises').orderBy('name').snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData) {
            return const Center(child: Text('Không có dữ liệu'));
          }
          final exercises = snapshot.data!.docs.map((doc) {
            return Exercise.fromMap(doc.id, doc.data() as Map<String, dynamic>);
          }).toList();

          return ListView.builder(
            padding: const EdgeInsets.all(10),
            itemCount: exercises.length,
            itemBuilder: (context, index) {
              final exercise = exercises[index];
              return Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(10),
                  leading: exercise.imageUrl.isNotEmpty
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(exercise.imageUrl,
                              width: 60, height: 60, fit: BoxFit.cover),
                        )
                      : const Icon(Icons.image_not_supported, size: 50),
                  title: Text(exercise.name,
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(
                      "Calo: ${exercise.calories}, Thời gian: ${exercise.duration}s\nLoại: ${exercise.types.join(', ')}"),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _confirmDelete(exercise.id),
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            ExerciseDetailScreen(exercise: exercise),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const ExerciseFormScreen(),
          ),
        ),
        backgroundColor: Themes.gradientLightClr,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
    );
  }

  void _confirmDelete(String exerciseId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Xác nhận xóa"),
        content: const Text("Bạn có chắc muốn xóa bài tập này không?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context), // Đóng hộp thoại
            child: const Text("Hủy"),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context); // Đóng hộp thoại trước khi xóa
              await _deleteExercise(exerciseId);
            },
            child: const Text("Xóa", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteExercise(String exerciseId) async {
    try {
      await _firestore.collection('exercises').doc(exerciseId).delete();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Đã xóa bài tập")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Lỗi khi xóa: $e")),
      );
    }
  }
}
