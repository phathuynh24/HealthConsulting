import 'package:assist_health/src/others/theme.dart';
import 'package:assist_health/src/presentation/screens/user_screens/excercise/info/calories_plan_screen.dart';
import 'package:flutter/material.dart';

class ActivityLevelScreen extends StatefulWidget {
  final String selectedGender;
  final String selectedWeightChange;
  final int selectedAge;
  final int selectedHeight;
  final double selectedCurrentWeight;
  final double selectedGoalWeight;
  const ActivityLevelScreen({
    Key? key,
    required this.selectedWeightChange,
    required this.selectedGender,
    required this.selectedAge,
    required this.selectedHeight,
    required this.selectedCurrentWeight,
    required this.selectedGoalWeight,
  }) : super(key: key);
  @override
  _ActivityLevelScreenState createState() => _ActivityLevelScreenState();
}

class _ActivityLevelScreenState extends State<ActivityLevelScreen> {
  String selectedActivityLevel = ""; // Lưu trữ mức độ vận động được chọn

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Thông tin sức khoẻ'),
        centerTitle: true,
        foregroundColor: Colors.white,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Themes.gradientDeepClr, Themes.gradientLightClr],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: Container(
        padding: EdgeInsets.all(16.0),
        color: Colors.green[50],
        child: SingleChildScrollView(
          // Thêm SingleChildScrollView để cuộn được khi nội dung dài
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 20),
              // Tiêu đề
              Text(
                "Mức độ vận động của bạn là gì?",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),

              // Danh sách các mức độ vận động
              buildActivityOption("Ít vận động",
                  "Hầu như ngồi một chỗ, giống như nhân viên văn phòng hoặc lập trình viên."),
              buildActivityOption("Một chút vận động",
                  "Di chuyển nhẹ hàng ngày, thường xuyên đứng, giống như nhân viên bán lẻ hoặc y tá."),
              buildActivityOption("Vận động trung bình",
                  "Công việc bình thường trong ngày, đi lại nhiều hoặc phải làm nhiều công việc nhà."),
              buildActivityOption("Vận động cao",
                  "Vận động nhiều trong ngày, giống như nhân viên kho hoặc nhân viên giao hàng."),
              buildActivityOption("Vận động cực kỳ cao",
                  "Hầu hết thời gian là lao động nặng, giống như công nhân xây dựng."),
              SizedBox(height: 20), // Thêm khoảng cách dưới danh sách mức độ

              // Nút Next
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: selectedActivityLevel.isEmpty
                      ? null
                      : () {
                          // Chuyển sang màn hình tính toán calories
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => CaloriePlanScreen(
                                activityLevel: selectedActivityLevel,
                                gender: widget.selectedGender,
                                age: widget.selectedAge,
                                height: widget.selectedHeight,
                                targetWeight: widget.selectedGoalWeight,
                                weight: widget.selectedCurrentWeight,
                                goal: widget.selectedWeightChange,
                              ),
                            ),
                          );
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: selectedActivityLevel.isEmpty
                        ? Colors.grey
                        : Colors.green,
                    padding: EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: Text(
                    "Tiếp theo",
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
              ),
              SizedBox(height: 20), // Thêm khoảng cách dưới nút
            ],
          ),
        ),
      ),
    );
  }

  // Widget hiển thị từng mức độ vận động
  Widget buildActivityOption(String title, String description) {
    final isSelected = selectedActivityLevel == title;
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedActivityLevel = title;
        });
      },
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 8),
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? Colors.green[100] : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? Colors.green : Colors.grey,
            width: 2,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isSelected ? Colors.green : Colors.black,
              ),
            ),
            SizedBox(height: 4),
            Text(
              description,
              style: TextStyle(
                fontSize: 14,
                color: isSelected ? Colors.green : Colors.grey[700],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
