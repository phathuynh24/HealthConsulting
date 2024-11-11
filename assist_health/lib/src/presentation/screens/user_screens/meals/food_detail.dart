import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class FoodDetailScreen extends StatefulWidget {
  @override
  _FoodDetailScreenState createState() => _FoodDetailScreenState();
}

class _FoodDetailScreenState extends State<FoodDetailScreen> {
  String _selectedNutriScore = 'C'; // Nutri-Score ban đầu

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.bookmark_border, color: Colors.black),
            onPressed: () {},
          ),
          IconButton(
            icon: Icon(Icons.share, color: Colors.black),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Section
            Container(
              width: double.infinity,
              height: 300.h, // Sử dụng .h để thay đổi chiều cao
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/slider1.jpg'), // Your image
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(16.w), // Sử dụng .w cho padding
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title and Portion Control
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Pho',
                        style: TextStyle(
                          fontSize: 28.sp, // Sử dụng .sp cho kích thước chữ
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Row(
                        children: [
                          IconButton(
                            icon: Icon(Icons.remove_circle_outline),
                            onPressed: () {},
                          ),
                          Text(
                            '1',
                            style: TextStyle(fontSize: 20.sp), // Sử dụng .sp
                          ),
                          IconButton(
                            icon: Icon(Icons.add_circle_outline),
                            onPressed: () {},
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: 16.h), // Sử dụng .h cho khoảng cách

                  // Nutrition Info
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      buildNutritionInfo(Icons.local_fire_department,
                          '350\nCalories', Colors.red),
                      buildNutritionInfo(
                          Icons.fitness_center, '25g\nProtein', Colors.pink),
                      buildNutritionInfo(
                          Icons.bakery_dining, '40g\nCarbs', Colors.amber),
                      buildNutritionInfo(
                          Icons.local_dining, '10g\nFats', Colors.green),
                    ],
                  ),
                  SizedBox(height: 16.h),

                  // Nutri-Score Section
                  Text(
                    'NUTRI-SCORE',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18.sp), // Sử dụng .sp
                  ),
                  SizedBox(height: 8.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      NutriScoreBox(
                        letter: 'A',
                        color: Colors.green,
                        isSelected: _selectedNutriScore == 'A',
                        onTap: () => _onNutriScoreSelected('A'),
                      ),
                      NutriScoreBox(
                        letter: 'B',
                        color: Colors.lightGreen,
                        isSelected: _selectedNutriScore == 'B',
                        onTap: () => _onNutriScoreSelected('B'),
                      ),
                      NutriScoreBox(
                        letter: 'C',
                        color: Colors.yellow,
                        isSelected: _selectedNutriScore == 'C',
                        onTap: () => _onNutriScoreSelected('C'),
                      ),
                      NutriScoreBox(
                        letter: 'D',
                        color: Colors.orange,
                        isSelected: _selectedNutriScore == 'D',
                        onTap: () => _onNutriScoreSelected('D'),
                      ),
                      NutriScoreBox(
                        letter: 'E',
                        color: Colors.red,
                        isSelected: _selectedNutriScore == 'E',
                        onTap: () => _onNutriScoreSelected('E'),
                      ),
                    ],
                  ),
                  SizedBox(height: 16.h),

                  // Daily Goals Section
                  Text(
                    'Daily Goals',
                    style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold), // Sử dụng .sp
                  ),
                  SizedBox(height: 8.h),
                  Column(
                    children: [
                      GoalProgress(
                          label: 'CAL', percentage: 0.14, color: Colors.orange),
                      GoalProgress(
                          label: 'PROT', percentage: 0.41, color: Colors.pink),
                      GoalProgress(
                          label: 'CARBS',
                          percentage: 0.11,
                          color: Colors.yellow),
                      GoalProgress(
                          label: 'FATS', percentage: 0.12, color: Colors.green),
                    ],
                  ),
                  SizedBox(height: 16.h),

                  // Fix Results Button
                  OutlinedButton.icon(
                    onPressed: () {},
                    icon: Icon(Icons.refresh, color: Colors.grey),
                    label: Text(
                      'Fix Results',
                      style: TextStyle(color: Colors.grey),
                    ),
                    style: OutlinedButton.styleFrom(
                      minimumSize: Size(double.infinity, 50.h), // Sử dụng .h
                    ),
                  ),
                  SizedBox(height: 16.h),

                  // Save Button
                  ElevatedButton(
                    onPressed: () {},
                    child: Text('Save',
                        style: TextStyle(fontSize: 18.sp)), // Sử dụng .sp
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.yellow.shade700,
                      minimumSize: Size(double.infinity, 50.h), // Sử dụng .h
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Hàm xử lý khi chọn một Nutri-Score
  void _onNutriScoreSelected(String letter) {
    setState(() {
      _selectedNutriScore = letter;
    });
  }

  Widget buildNutritionInfo(IconData icon, String text, Color color) {
    return Column(
      children: [
        Icon(icon, color: color),
        SizedBox(height: 4.h), // Sử dụng .h
        Text(
          text,
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16.sp), // Sử dụng .sp
        ),
      ],
    );
  }
}

class NutriScoreBox extends StatelessWidget {
  final String letter;
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;

  const NutriScoreBox({
    required this.letter,
    required this.color,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final double size =
        isSelected ? 80.w : 70.w; // Kích thước thay đổi khi được chọn

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: Duration(milliseconds: 300),
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(8.w), // Sử dụng .w
        ),
        child: Center(
          child: Text(
            letter,
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 18.sp, // Sử dụng .sp
            ),
          ),
        ),
      ),
    );
  }
}

class GoalProgress extends StatelessWidget {
  final String label;
  final double percentage;
  final Color color;

  const GoalProgress({
    required this.label,
    required this.percentage,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.h), // Sử dụng .h cho padding
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: TextStyle(color: Colors.grey)),
              Text('${(percentage * 100).toStringAsFixed(0)}%',
                  style: TextStyle(color: color, fontWeight: FontWeight.bold)),
            ],
          ),
          SizedBox(height: 4.h), // Sử dụng .h
          LinearProgressIndicator(
            value: percentage,
            color: color,
            backgroundColor: Colors.grey.shade300,
          ),
        ],
      ),
    );
  }
}
