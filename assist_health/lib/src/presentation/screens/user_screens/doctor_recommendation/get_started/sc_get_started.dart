import 'package:assist_health/src/others/theme.dart';
import 'package:assist_health/src/presentation/screens/user_screens/doctor_recommendation/enter_symptoms/sc_enter_symptoms.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class GetStartedScreen extends StatefulWidget {
  @override
  _GetStartedScreenState createState() => _GetStartedScreenState();
}

class _GetStartedScreenState extends State<GetStartedScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        foregroundColor: Colors.white,
        backgroundColor: Themes.gradientDeepClr,
        toolbarHeight: 50,
        title: const Text('Đề xuất bác sĩ từ triệu chứng'),
        titleTextStyle: const TextStyle(fontSize: 16),
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Themes.gradientDeepClr,
              Color(0xff5729b9).withOpacity(0.8),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Container(
              height: 350.h,
              child: Image.asset(
                'assets/recommendation/get_started.png',
                fit: BoxFit.contain,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: const Text(
                'Hãy chia sẻ triệu chứng bệnh của bạn!',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(
              height: 16.0,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 34.0),
              child: const Text(
                'Các mô tả triệu chứng chi tiết của bạn sẽ giúp chúng tôi đưa ra đánh giá và gợi ý bác sĩ phù hợp nhất cho bạn!',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white,
                  height: 1.8,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(
              height: 100.h,
            ),
            GestureDetector(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => EnterSymptoms()),
                );
              },
              child: Container(
                width: 250.w,
                height: 80.h,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(50),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 14,
                        spreadRadius: 8,
                        offset: Offset(0, 3)),
                  ],
                  gradient: LinearGradient(
                    colors: [
                      Color.fromARGB(255, 149, 103, 246),
                      Color.fromARGB(255, 168, 130, 250),
                      Color(0xffbb9bff),
                    ],
                    begin: Alignment.bottomRight,
                    end: Alignment.topLeft,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Container(
                      height: 60.h,
                      width: 60.w,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            spreadRadius: 1,
                            blurRadius: 5,
                          ),
                        ],
                        color: Color.fromARGB(255, 91, 62, 221),
                      ),
                      child: Icon(
                        Icons.arrow_forward_rounded,
                        color: Colors.white,
                        size: 30,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        'Bắt đầu chia sẻ',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 16.0),
          ],
        ),
      ),
    );
  }
}
