import 'package:assist_health/others/theme.dart';
import 'package:assist_health/screens/doctor_screens/message_doctor.dart';
import 'package:assist_health/screens/doctor_screens/public_questions_doctor.dart';
import 'package:assist_health/screens/doctor_screens/schedule_doctor.dart';
import 'package:assist_health/screens/widgets/doctor_navbar.dart';
import 'package:flutter/material.dart';

class AdviseTopBar extends StatefulWidget {
  const AdviseTopBar({super.key});

  @override
  State<AdviseTopBar> createState() => _AdviseTopBarState();
}

class _AdviseTopBarState extends State<AdviseTopBar> {
  int countIndex = 0;
  final _screens = [
    // Tab 1
    const ScheduleDoctor(),
    // Tab 2
    const MessageDoctorScreen(),
    // Tab 3
    const PublicQuestionsDoctorScreen(),
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
          title: const Text('Tư vấn trực tuyến'),
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
                        'Lịch tư vấn',
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
                        'Tin nhắn',
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
                  Expanded(
                      child: GestureDetector(
                    onTap: () {
                      setState(() {
                        countIndex = 2;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            width: (countIndex == 2) ? 2 : 0,
                            color: Colors.blue,
                          ),
                        ),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        'Cộng đồng',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: (countIndex == 2)
                              ? FontWeight.bold
                              : FontWeight.normal,
                          color: (countIndex == 2) ? Colors.blue : Colors.black,
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
