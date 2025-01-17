import 'package:assist_health/src/others/theme.dart';
import 'package:assist_health/src/presentation/screens/user_screens/excercise/info/height_selection.dart';
import 'package:flutter/material.dart';

class AgeSelectionScreen extends StatefulWidget {
  final String selectedGender;

  const AgeSelectionScreen({Key? key, required this.selectedGender})
      : super(key: key);

  @override
  _AgeSelectionScreenState createState() => _AgeSelectionScreenState();
}

class _AgeSelectionScreenState extends State<AgeSelectionScreen> {
  int _selectedAge = 21;

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
          const SizedBox(height: 30),
          const Text(
            "Bạn bao nhiêu tuổi?",
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
              "Chúng tôi sử dụng dữ liệu của bạn chỉ nhằm mục đích cải thiện trải nghiệm và nâng cao độ chính xác của chức năng ước tính calo.",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
                height: 1.5,
              ),
            ),
          ),
          const SizedBox(height: 30),
          Expanded(
            child: Center(
              child: ListWheelScrollView.useDelegate(
                itemExtent: 60,
                perspective: 0.005,
                diameterRatio: 1.4,
                controller: FixedExtentScrollController(
                  initialItem: _selectedAge - 18,
                ),
                onSelectedItemChanged: (index) {
                  setState(() {
                    _selectedAge = index + 18;
                  });
                },
                childDelegate: ListWheelChildBuilderDelegate(
                  builder: (context, index) {
                    return AnimatedDefaultTextStyle(
                      duration: const Duration(milliseconds: 200),
                      style: TextStyle(
                        fontSize: index + 18 == _selectedAge ? 36 : 28,
                        fontWeight: index + 18 == _selectedAge
                            ? FontWeight.bold
                            : FontWeight.normal,
                        color: index + 18 == _selectedAge
                            ? Colors.green
                            : Colors.grey,
                      ),
                      child: Text("${index + 18}"),
                    );
                  },
                  childCount: 83,
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
                    builder: (context) => HeightSelectionScreen(
                      selectedGender: widget.selectedGender,
                      selectedAge: _selectedAge,
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
