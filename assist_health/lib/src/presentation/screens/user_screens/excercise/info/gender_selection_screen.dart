import 'package:assist_health/src/others/theme.dart';
import 'package:assist_health/src/presentation/screens/user_screens/excercise/info/age_selection_screen.dart';
import 'package:flutter/material.dart';

class GenderSelectionScreen extends StatefulWidget {
  const GenderSelectionScreen({super.key});

  @override
  _GenderSelectionScreenState createState() => _GenderSelectionScreenState();
}

class _GenderSelectionScreenState extends State<GenderSelectionScreen> {
  String _selectedGender = "";

  void _selectGender(String gender) {
    setState(() {
      _selectedGender = gender;
    });
  }

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
            "Giới tính của bạn",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              "Chúng tôi chỉ sử dụng dữ liệu của bạn để cải thiện trải nghiệm và tính năng ước tính calo.",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
          ),
          const SizedBox(height: 30),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: () => _selectGender("Nam"),
                    child: Container(
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        border: Border.all(
                            color: _selectedGender == "Nam"
                                ? Colors.greenAccent
                                : Colors.grey.shade200,
                            width: 2),
                        borderRadius: BorderRadius.circular(10),
                        color: _selectedGender == "Nam"
                            ? Colors.green[100]
                            : Colors.grey[200],
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.male, size: 40, color: Colors.blue),
                          SizedBox(width: 20),
                          Text(
                            "Nam",
                            style: TextStyle(
                              fontSize: 16,
                              color: _selectedGender == "Nam"
                                  ? Colors.green
                                  : Colors.black,
                              fontWeight: _selectedGender == "Nam"
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  GestureDetector(
                    onTap: () => _selectGender("Nữ"),
                    child: Container(
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        border: Border.all(
                            color: _selectedGender == "Nữ"
                                ? Colors.greenAccent
                                : Colors.grey.shade200,
                            width: 2),
                        borderRadius: BorderRadius.circular(10),
                        color: _selectedGender == "Nữ"
                            ? Colors.green[100]
                            : Colors.grey[200],
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.female, size: 40, color: Colors.pink),
                          SizedBox(width: 20),
                          Text(
                            "Nữ",
                            style: TextStyle(
                              fontSize: 16,
                              color: _selectedGender == "Nữ"
                                  ? Colors.green
                                  : Colors.black,
                              fontWeight: _selectedGender == "Nữ"
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Text.rich(
              TextSpan(
                text: "Bằng cách nhấn Tiếp theo, bạn đã đọc và đồng ý với ",
                style: TextStyle(color: Colors.grey),
                children: [
                  TextSpan(
                    text: "Điều khoản sử dụng",
                    style: TextStyle(color: Colors.blue),
                  ),
                  TextSpan(text: " và "),
                  TextSpan(
                    text: "Chính sách bảo mật",
                    style: TextStyle(color: Colors.blue),
                  ),
                  TextSpan(text: "."),
                ],
              ),
              textAlign: TextAlign.center,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: ElevatedButton(
              onPressed: () {
                if (_selectedGender.isNotEmpty) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AgeSelectionScreen(
                        selectedGender: _selectedGender,
                      ),
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Vui lòng chọn giới tính"),
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                minimumSize: const Size(double.infinity, 50),
              ),
              child: const Text(
                "Tiếp theo",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
