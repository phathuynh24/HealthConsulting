import 'package:flutter/material.dart';
import 'package:assist_health/ui/widgets/upcoming_schedule.dart';

class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({super.key});

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  int _buttonIndex = 0;

  final _scheduleWidgets = [
    // Chưa xong
    const UpcomingSchedule(),
    Container(),
    Container(),
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
          child: Padding(
        padding: const EdgeInsets.only(top: 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 15),
              child: Text(
                "Lịch khám",
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(5),
              margin: const EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                color: const Color(0xFFF4F6FA),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  InkWell(
                    onTap: () {
                      setState(() {
                        _buttonIndex = 0;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 12, horizontal: 20),
                      decoration: BoxDecoration(
                        color: _buttonIndex == 0
                            ? const Color(0xFF7165D6)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        "Lịch sắp tới",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color:
                              _buttonIndex == 0 ? Colors.white : Colors.black38,
                        ),
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      setState(() {
                        _buttonIndex = 1;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 12, horizontal: 20),
                      decoration: BoxDecoration(
                        color: _buttonIndex == 1
                            ? const Color(0xFF7165D6)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        "Đã khám",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color:
                              _buttonIndex == 1 ? Colors.white : Colors.black38,
                        ),
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      setState(() {
                        _buttonIndex = 2;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 12, horizontal: 20),
                      decoration: BoxDecoration(
                        color: _buttonIndex == 2
                            ? const Color(0xFF7165D6)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        "Đã hủy",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color:
                              _buttonIndex == 2 ? Colors.white : Colors.black38,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            // Widgets According to buttons
            _scheduleWidgets[_buttonIndex]
          ],
        ),
      )),
    );
  }
}
