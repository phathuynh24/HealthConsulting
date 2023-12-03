import 'package:assist_health/others/theme.dart';
import 'package:assist_health/ui/admin_screens/add_doctor.dart';
import 'package:assist_health/ui/doctor_screens/set_schedule.dart';
import 'package:assist_health/ui/user_screens/message.dart';
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
    Container(),
    // Screen 2
    const MessageScreen(),
    // Screen 3
    const SetScheduleScreen(),
    // Screen 4
    Container(),
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
