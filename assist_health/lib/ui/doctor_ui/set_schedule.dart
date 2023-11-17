import 'package:assist_health/ui/doctor_ui/add_schedule_bar.dart';
import 'package:assist_health/ui/widgets/button.dart';
import 'package:date_picker_timeline/date_picker_timeline.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:intl/intl.dart';

class SetScheduleScreen extends StatefulWidget {
  const SetScheduleScreen({super.key});

  @override
  State<SetScheduleScreen> createState() => _SetScheduleScreen();
}

class _SetScheduleScreen extends State<SetScheduleScreen> {
  DateTime _selectedDate = DateTime.now();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cài đặt lịch khám'),
        centerTitle: true,
        backgroundColor: const Color(0xFF7165D6),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _addScheduleBar(),
            _addDateBar(),
            _showSchedule(),
          ],
        ),
      ),
    );
  }

  _addDateBar() {
    return Container(
      margin: const EdgeInsets.only(top: 20, left: 20),
      child: DatePicker(
        DateTime.now(),
        height: 100,
        width: 80,
        initialSelectedDate: DateTime.now(),
        selectionColor: Colors.purple,
        selectedTextColor: Colors.white,
        dateTextStyle: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: Colors.grey,
        ),
        onDateChange: (date) {
          _selectedDate = date;
        },
      ),
    );
  }

  _addScheduleBar() {
    return Container(
      margin: const EdgeInsets.only(left: 20, right: 20, top: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                DateFormat('dd/MM/yyyy').format(DateTime.now()),
              ),
              const Text(
                "Hôm nay",
              ),
            ],
          ),
          MyButton(
            label: "+ Add",
            onTap: () async {
              await Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const AddSchedulePage(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  _showSchedule() {
    return Container(
      height: 500,
      child: ListView.builder(
          scrollDirection: Axis.vertical,
          itemCount: 9,
          itemBuilder: (_, index) {
            return AnimationConfiguration.staggeredList(
              position: index,
              child: SlideAnimation(
                child: FadeInAnimation(
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        width: MediaQuery.of(context).size.width,
                        margin: const EdgeInsets.only(bottom: 12),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            color: Colors.amber,
                          ),
                          child: Row(children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    "Hello",
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white),
                                  ),
                                  const SizedBox(
                                    height: 12,
                                  ),
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.access_time_rounded,
                                        color: Colors.grey[200],
                                        size: 18,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        "ABC",
                                        style: TextStyle(
                                            fontSize: 13,
                                            color: Colors.grey[100]),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    "123",
                                    style: TextStyle(
                                        fontSize: 15, color: Colors.grey[100]),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              margin:
                                  const EdgeInsets.symmetric(horizontal: 10),
                              height: 60,
                              width: 0.5,
                              color: Colors.grey[200]!.withOpacity(0.7),
                            ),
                            const RotatedBox(
                              quarterTurns: 3,
                              child: Text(
                                "TODO",
                                style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white),
                              ),
                            ),
                          ]),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
    );
  }
}
