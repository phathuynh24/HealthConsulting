import 'package:assist_health/others/theme.dart';
import 'package:assist_health/ui/admin_screens/doctor_profile_add.dart';
import 'package:assist_health/ui/admin_screens/doctor_profile_list.dart';
import 'package:assist_health/ui/admin_screens/message_admin.dart';
import 'package:assist_health/ui/user_screens/public_questions.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:assist_health/ui/admin_screens/revenue_chart.dart';
class AdminNavBar extends StatefulWidget {
  const AdminNavBar({super.key});

  @override
  State<AdminNavBar> createState() => _AdminNavBarState();
}

class _AdminNavBarState extends State<AdminNavBar> {
  int _selectedIndex = 0;
  final _screens = [
    // Screen 1
    const PublicQuestionsScreen(),
    // Screen 2
    const RevenueChartScreen(),
    // Screen 3
    DoctorProfileList(),
    // Screen 4
      const MessageAdminScreen(),
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
              icon: Icon(Icons.calendar_month),
              label: "Schedule",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings),
              label: "Settings",
            ),
          ],
        ),
      ),
    );
  }
}
