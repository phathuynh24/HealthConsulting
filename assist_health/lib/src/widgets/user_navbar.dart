import 'package:assist_health/src/others/theme.dart';
import 'package:assist_health/src/presentation/screens/user_screens/blog_list.dart';
import 'package:assist_health/src/presentation/screens/user_screens/home.dart';
import 'package:assist_health/src/presentation/screens/user_screens/meals/meal.dart';
import 'package:assist_health/src/presentation/screens/user_screens/meals/meal_home.dart';
import 'package:assist_health/src/presentation/screens/user_screens/meals/product_scan.dart';
import 'package:assist_health/src/presentation/screens/user_screens/message.dart';
import 'package:assist_health/src/presentation/screens/user_screens/public_questions.dart';
import 'package:assist_health/src/presentation/screens/user_screens/schedule.dart';
import 'package:assist_health/src/presentation/screens/user_screens/account.dart';
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
    // Schedule Screen
    const ScheduleScreen(),
    //Product Scan Screen
    ProductScanScreen(),
    // Public Chat Screen
    const PublicQuestionsScreen(),
    // Messages Screen
    const MessageScreen(),
    //
    BlogListPage(),
    //
    const AccountScreen(),
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
              label: "Trang chủ",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.calendar_month),
              label: "Lịch khám",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.restaurant_menu),
              label: "Dinh duỡng",
            ),
            BottomNavigationBarItem(
              icon: Icon(CupertinoIcons.person_3_fill),
              label: "Cộng đồng",
            ),
            BottomNavigationBarItem(
              icon: Icon(CupertinoIcons.chat_bubble_text_fill),
              label: "Tin nhắn",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.article_outlined),
              label: "Bài viết",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: "Tài khoản",
            ),
          ],
        ),
      ),
    );
  }
}
