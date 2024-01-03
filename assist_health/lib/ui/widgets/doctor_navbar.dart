import 'package:assist_health/models/doctor/doctor_info.dart';
import 'package:assist_health/others/theme.dart';
import 'package:assist_health/ui/doctor_screens/doctor_account.dart';
import 'package:assist_health/ui/doctor_screens/doctor_chart.dart';
import 'package:assist_health/ui/doctor_screens/doctor_info.dart';
import 'package:assist_health/ui/doctor_screens/message_doctor.dart';
import 'package:assist_health/ui/doctor_screens/set_schedule.dart';
import 'package:assist_health/ui/user_screens/home.dart';
import 'package:assist_health/ui/user_screens/public_questions.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class DoctorNavBar extends StatefulWidget {
  const DoctorNavBar({super.key});

  @override
  State<DoctorNavBar> createState() => _DoctorNavBarState();
}

class _DoctorNavBarState extends State<DoctorNavBar> {
  int _selectedIndex = 0;
  final _screens = [
    // Screen 1
    const PublicQuestionsScreen(),
    // Screen 2
    const MessageDoctorScreen(),
    // Screen 3
    const DoctorChartScreen(),
    // Screen 4
    DoctorInfoScreen(),
    //Screen 5 
    const DoctorAccountScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: _screens[_selectedIndex],
      bottomNavigationBar: SizedBox(
        height: 80,
        child: BottomNavigationBar(
          backgroundColor: Colors.white,
          type: BottomNavigationBarType.fixed,
          selectedItemColor: Themes.selectedClr,
          unselectedItemColor: Colors.black26,
          selectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 15,
          ),
          currentIndex: _selectedIndex,
          onTap: (index) {
            setState(() {
              _selectedIndex = index;
            });
          },
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_filled),
              label: "Home",
            ),
            BottomNavigationBarItem(
              icon: Icon(CupertinoIcons.chat_bubble_text_fill),
              label: "Messages",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.bar_chart_outlined),
              label: "Thống kê",
            ),
              BottomNavigationBarItem(
              icon: Icon(Icons.info),
              label: "Thông tin",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings),
              label: "Tài khoản",
            ),
          ],
        ),
      ),
    );
  }
}
