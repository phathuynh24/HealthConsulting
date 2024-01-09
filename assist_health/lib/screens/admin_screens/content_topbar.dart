import 'package:assist_health/others/theme.dart';
import 'package:assist_health/screens/admin_screens/feedback_list.dart';
import 'package:assist_health/screens/admin_screens/public_questions_admin.dart';
import 'package:assist_health/screens/widgets/doctor_navbar.dart';
import 'package:flutter/material.dart';

class ContentTopBar extends StatefulWidget {
  const ContentTopBar({super.key});

  @override
  State<ContentTopBar> createState() => _ContentTopBarState();
}

class _ContentTopBarState extends State<ContentTopBar> {
  int countIndex = 0;
  final _screens = [
    // Tab 1
    const PublicQuestionsAdminScreen(),
    // Tab 2
    FeedbackList(),
  ];
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const DoctorNavBar()),
          (route) => false,
        );
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Quản lý nội dung'),
          foregroundColor: Colors.white,
          centerTitle: true,
          automaticallyImplyLeading: false,
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Themes.gradientDeepClr, Themes.gradientLightClr],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
            ),
          ),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(45),
            child: Container(
              decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border(
                      bottom: BorderSide(
                    color: Colors.grey.shade200,
                  ))),
              child: Row(
                children: [
                  Expanded(
                      child: GestureDetector(
                    onTap: () {
                      setState(() {
                        countIndex = 0;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            width: (countIndex == 0) ? 2 : 0,
                            color: Colors.blue,
                          ),
                        ),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        'Cộng đồng hỏi đáp',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: (countIndex == 0)
                              ? FontWeight.bold
                              : FontWeight.normal,
                          color: (countIndex == 0) ? Colors.blue : Colors.black,
                        ),
                      ),
                    ),
                  )),
                  Expanded(
                      child: GestureDetector(
                    onTap: () {
                      setState(() {
                        countIndex = 1;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            width: (countIndex == 1) ? 2 : 0,
                            color: Colors.blue,
                          ),
                        ),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        'Đánh giá bác sĩ',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: (countIndex == 1)
                              ? FontWeight.bold
                              : FontWeight.normal,
                          color: (countIndex == 1) ? Colors.blue : Colors.black,
                        ),
                      ),
                    ),
                  )),
                ],
              ),
            ),
          ),
        ),
        body: _screens[countIndex],
      ),
    );
  }
}
