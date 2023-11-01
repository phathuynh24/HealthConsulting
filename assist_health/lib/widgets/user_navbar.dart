import 'package:assist_health/user_screens/home_screen.dart';
import 'package:assist_health/user_screens/message_screen.dart';
import 'package:assist_health/user_screens/schedule_screen.dart';
import 'package:assist_health/user_screens/settings_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class UserNavBar extends StatefulWidget {
  const UserNavBar({super.key});

  @override
  State<StatefulWidget> createState() => _UserNavBarState();
}

class _UserNavBarState extends State<UserNavBar> {
  int _selectedIndex = 0;
  final _screens = [
    // Home Screen
    const HomeScreen(),
    // Messages Screen
    const MessageScreen(),
    // Schedule Screen
    const ScheduleScreen(),
    // Settings Screen
    const SettingScreen(),
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
          selectedItemColor: const Color(0xFF7165D6),
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
