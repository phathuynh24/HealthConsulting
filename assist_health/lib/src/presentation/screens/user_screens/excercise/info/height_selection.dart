import 'package:assist_health/src/others/theme.dart';
import 'package:assist_health/src/presentation/screens/user_screens/excercise/info/weight_change_selection.dart';
import 'package:flutter/material.dart';

class HeightSelectionScreen extends StatefulWidget {
  final String selectedGender;
  final int selectedAge;

  const HeightSelectionScreen({
    Key? key,
    required this.selectedGender,
    required this.selectedAge,
  }) : super(key: key);

  @override
  _HeightSelectionScreenState createState() => _HeightSelectionScreenState();
}

class _HeightSelectionScreenState extends State<HeightSelectionScreen> {
  int _selectedHeight = 170;

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
      body: Column(
        children: [
          const SizedBox(height: 20),
          const Text(
            "Chiều cao của bạn là bao nhiêu?",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 10),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              "Chúng tôi cần thông tin này để tối ưu hóa việc đánh giá chỉ số cơ thể và các bài tập phù hợp cho bạn.",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
                height: 1.5,
              ),
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: Center(
              child: ListWheelScrollView.useDelegate(
                itemExtent: 60,
                diameterRatio: 1.4,
                controller: FixedExtentScrollController(
                  initialItem: _selectedHeight - 100,
                ),
                onSelectedItemChanged: (index) {
                  setState(() {
                    _selectedHeight = index + 100;
                  });
                },
                childDelegate: ListWheelChildBuilderDelegate(
                  builder: (context, index) {
                    return AnimatedDefaultTextStyle(
                      duration: const Duration(milliseconds: 200),
                      style: TextStyle(
                        fontSize: index + 100 == _selectedHeight ? 36 : 28,
                        fontWeight: index + 100 == _selectedHeight
                            ? FontWeight.bold
                            : FontWeight.normal,
                        color: index + 100 == _selectedHeight
                            ? Colors.green
                            : Colors.grey,
                      ),
                      child: Text("${index + 100} cm"),
                    );
                  },
                  childCount: 151, // Chiều cao từ 100 cm đến 250 cm
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => WeightChangeSelectionScreen(
                      selectedGender: widget.selectedGender,
                      selectedAge: widget.selectedAge,
                      selectedHeight: _selectedHeight,
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                minimumSize: const Size(double.infinity, 50),
                elevation: 5,
              ),
              child: const Text(
                "Tiếp tục",
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
