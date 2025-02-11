import 'package:cloud_firestore/cloud_firestore.dart'; // Thêm thư viện Firestore
import 'package:flutter/material.dart';
import 'package:assist_health/src/others/theme.dart';
import 'package:assist_health/src/presentation/screens/user_screens/excercise/excercise.dart';
import 'package:assist_health/src/presentation/screens/user_screens/excercise/excercise_detail_screen.dart';

class ExerciseListScreen extends StatelessWidget {
  final String filterType;
  const ExerciseListScreen({super.key, required this.filterType});

  // Hàm để lấy dữ liệu từ Firestore
  Future<List<Exercise>> _fetchExercises() async {
    try {
      // Truy vấn collection 'exercises' từ Firestore
      QuerySnapshot querySnapshot =
          await FirebaseFirestore.instance.collection('exercises').get();

      // Chuyển đổi dữ liệu từ Firestore thành danh sách các đối tượng Exercise
      return querySnapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return Exercise(
          calories: data['calories'] ?? 0.0,
          name: data['name'] ?? '',
          description: data['description'] ?? '',
          duration: data['duration'] ?? 0,
          imageUrl: data['imageUrl'] ?? '',
          youtubeUrl: data['youtubeUrl'] ?? '',
          types: List<String>.from(data['types'] ?? []),
        );
      }).toList();
    } catch (e) {
      print("Lỗi khi lấy dữ liệu từ Firestore: $e");
      return []; // Trả về danh sách rỗng nếu có lỗi
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        foregroundColor: Colors.white,
        title: const Text('Danh sách bài tập'),
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
      body: FutureBuilder<List<Exercise>>(
        future: _fetchExercises(), // Gọi hàm lấy dữ liệu từ Firestore
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // Hiển thị loading indicator khi đang tải dữ liệu
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            // Hiển thị thông báo lỗi nếu có lỗi xảy ra
            return Center(child: Text('Lỗi: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            // Hiển thị thông báo nếu không có dữ liệu
            return const Center(child: Text('Không có bài tập nào.'));
          } else {
            // Lọc danh sách bài tập dựa trên filterType
            final filteredExercises = snapshot.data!
                .where((exercise) => exercise.types.contains(filterType))
                .toList();

            // Hiển thị danh sách bài tập
            return ListView.builder(
              itemCount: filteredExercises.length,
              itemBuilder: (context, index) {
                final exercise = filteredExercises[index];
                return ListTile(
                  leading: const Icon(Icons.fitness_center,
                      color: Colors.blueAccent),
                  title: Text(exercise.name,
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(exercise.description),
                  trailing: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Colors.blue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                    ),
                    child: const Text(
                      'Bắt đầu',
                      style: TextStyle(fontSize: 14),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ExerciseDetailScreen(
                            exercise: exercise,
                            exercises: filteredExercises,
                            currentIndex: index,
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}
