import 'package:assist_health/src/others/theme.dart';
import 'package:assist_health/src/presentation/screens/doctor_screens/doctor_account.dart';
import 'package:assist_health/src/presentation/screens/doctor_screens/advise_topbar.dart';
import 'package:assist_health/src/presentation/screens/doctor_screens/doctor_blog.dart';
import 'package:assist_health/src/presentation/screens/doctor_screens/home_doctor.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class DoctorNavBar extends StatefulWidget {
  const DoctorNavBar({super.key});

  @override
  State<DoctorNavBar> createState() => _DoctorNavBarState();
}

class _DoctorNavBarState extends State<DoctorNavBar> {
  int _selectedIndex = 0;
  final _screens = [
    // Screen 1
    const HomeDoctor(),
    // Screen 2
    const AdviseTopBar(),
    Doctor_Blog(),
    //Screen 3
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
              label: "Trang chủ",
            ),
            BottomNavigationBarItem(
              icon: Icon(CupertinoIcons.phone_fill),
              label: "Tư vấn",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.article_outlined),
              label: "Bài viết",
            ),
            BottomNavigationBarItem(
              icon: Icon(FontAwesomeIcons.userDoctor),
              label: "Tài khoản",
            ),
          ],
        ),
      ),
    );
  }
}
