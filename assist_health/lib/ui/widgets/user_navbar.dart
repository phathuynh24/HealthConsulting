import 'package:assist_health/ui/user_ui/community.dart';
import 'package:assist_health/ui/user_ui/home.dart';
import 'package:assist_health/ui/user_ui/message.dart';
import 'package:assist_health/ui/user_ui/schedule.dart';
import 'package:assist_health/ui/user_ui/settings.dart';
import 'package:assist_health/ui/user_ui/health_profile.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class UserNavBar extends StatefulWidget {
  const UserNavBar({super.key});

  @override
  State<UserNavBar> createState() => _UserNavBarState();
}

class _UserNavBarState extends State<UserNavBar> {
  int _selectedIndex = 0;
  final _screens = [
    // Home Screen
    const HomeScreen(),
    // Messages Screen
    const MessageScreen(),
    // Public Chat Screen
    const CommunityScreen(),
    // Schedule Screen
    const ScheduleScreen(),
    //Profile
    const HealthProfileScreen(),
    //Setting Screen
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
              label: "Trang chủ",
            ),
            BottomNavigationBarItem(
              icon: Icon(CupertinoIcons.chat_bubble_text_fill),
              label: "Nhắn tin",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_3),
              label: "Cộng đồng",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.calendar_month),
              label: "Lịch khám",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.health_and_safety),
              label: "Hồ sơ",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings),
              label: "Cài đặt",
            ),
          ],
        ),
      ),
    );
  }
}