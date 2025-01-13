import 'package:assist_health/src/presentation/screens/user_screens/meals/calorie_tracker_home.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CaloriePlanScreen extends StatelessWidget {
  final String gender;
  final int height;
  final double weight;
  final int age;
  final double targetWeight;
  final String activityLevel;
  final String goal;

  const CaloriePlanScreen({
    super.key,
    required this.gender,
    required this.height,
    required this.weight,
    required this.age,
    required this.targetWeight,
    required this.activityLevel,
    required this.goal,
  });

  @override
  Widget build(BuildContext context) {
    final double bmr = calculateBMR();
    final double tdee = calculateTDEE(bmr);
    final double adjustedCalories = adjustCalories(tdee);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green[100],
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Container(
        padding: const EdgeInsets.all(16.0),
        color: Colors.green[50],
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),

            // Tiêu đề
            const Text(
              "Kế hoạch bữa ăn của bạn đã sẵn sàng",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),

            // Tổng calo
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.orange[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.local_fire_department, color: Colors.orange),
                      SizedBox(width: 8),
                      Text(
                        "Tổng Calo",
                        style: TextStyle(fontSize: 16, color: Colors.orange),
                      ),
                    ],
                  ),
                  Text(
                    "${adjustedCalories.toStringAsFixed(0)} Cal",
                    style: const TextStyle(
                        fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Danh sách các bữa ăn
            Expanded(
              child: ListView(
                children: [
                  buildMealItem("Bữa sáng", "", ""),
                  buildMealItem("Bữa trưa", "", ""),
                  buildMealItem("Bữa tối", "", ""),
                  buildMealItem("Bữa phụ", "", ""),
                ],
              ),
            ),

            // Nút Hoàn thành
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  await saveUserPlanToFirebase(adjustedCalories);
                  Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => CalorieTrackerHome()));
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: const Text(
                  "Hoàn thành",
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Tính BMR
  double calculateBMR() {
    if (gender == "Nam") {
      return 88.362 + (13.397 * weight) + (4.799 * height) - (5.677 * age);
    } else {
      return 447.593 + (9.247 * weight) + (3.098 * height) - (4.330 * age);
    }
  }

  // Tính TDEE
  double calculateTDEE(double bmr) {
    double multiplier;
    switch (activityLevel) {
      case "Ít vận động":
        multiplier = 1;
        break;
      case "Một chút vận động":
        multiplier = 1.375;
        break;
      case "Vận động trung bình":
        multiplier = 1.55;
        break;
      case "Vận động cao":
        multiplier = 1.725;
        break;
      case "Vận động cực kỳ cao":
        multiplier = 1.9;
        break;
      default: // Ít vận động
        multiplier = 1.2;
    }
    return bmr * multiplier;
  }

  // Điều chỉnh calo theo mục tiêu
  double adjustCalories(double tdee) {
    if (goal == "Giảm cân") {
      return tdee - 500;
    } else if (goal == "Tăng cân") {
      return tdee + 500;
    } else {
      return tdee;
    }
  }

  // Widget cho từng bữa ăn
  Widget buildMealItem(String title, String food, String calories) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.fastfood, color: Colors.orange),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(food.isEmpty ? "Chưa quyết định" : food),
              ],
            ),
          ),
          Text(calories.isEmpty ? "" : "$calories Cal"),
        ],
      ),
    );
  }

  Future<void> saveUserPlanToFirebase(double adjustedCalories) async {
    try {
      // Lấy userId từ Firebase Authentication
      User? user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        print("Người dùng chưa đăng nhập.");
        return;
      }

      String userId = user.uid;

      // Lấy thời gian hiện tại và chuyển thành chuỗi theo định dạng dd/MM/yyyy
      DateTime currentTime = DateTime.now();
      String formattedDate = DateFormat('dd/MM/yyyy').format(currentTime);

      final userDoc =
          FirebaseFirestore.instance.collection('user_goal_plans').doc(userId);

      await userDoc.set({
        'gender': gender,
        'height': height,
        'weight': weight,
        'age': age,
        'targetWeight': targetWeight,
        'activityLevel': activityLevel,
        'goal': goal,
        'adjustedCalories': adjustedCalories,
        'userId': userId, // Lưu userId
        'timestamp': formattedDate,
      });
      SetOptions(merge: true);

      print("Kế hoạch dinh dưỡng đã được lưu vào Firebase.");
    } catch (e) {
      print("Lỗi khi lưu kế hoạch dinh dưỡng: $e");
    }
  }
}
