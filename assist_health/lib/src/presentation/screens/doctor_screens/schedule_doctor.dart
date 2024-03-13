import 'dart:async';

import 'package:assist_health/src/models/other/appointment_schedule.dart';
import 'package:assist_health/src/others/methods.dart';
import 'package:assist_health/src/presentation/screens/doctor_screens/schedule_doctor_detail.dart';
import 'package:assist_health/src/widgets/doctor_schedule_card.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class ScheduleDoctor extends StatefulWidget {
  const ScheduleDoctor({super.key});

  @override
  State<ScheduleDoctor> createState() => _ScheduleDoctorState();
}

class _ScheduleDoctorState extends State<ScheduleDoctor> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime _firstDay = DateTime.utc(2018, 10, 16);
  DateTime _lastDay = DateTime.utc(2030, 3, 14);
  DateTime? _selectedDay;

  Map<DateTime, List<Event>> events = {};
  late final ValueNotifier<List<Event>> _selectedEvents;

  StreamController<List<AppointmentSchedule>>? _appointmentScheduleController =
      StreamController<List<AppointmentSchedule>>.broadcast();

  List<DateTime> dateList = [];

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    _selectedEvents = ValueNotifier(_getEventsForDay(_selectedDay!));

    _appointmentScheduleController!
        .addStream(getAppointmentSchdedulesForDocotr());

    Future.delayed(const Duration(milliseconds: 500), () {
      flagAllDate(dateList);
    });
  }

  @override
  void dispose() {
    _selectedEvents.dispose();
    super.dispose();
  }

  List<Event> _getEventsForDay(DateTime day) {
    return events[day] ?? [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            TableCalendar(
                firstDay: _firstDay,
                lastDay: _lastDay,
                focusedDay: _focusedDay,
                calendarFormat: _calendarFormat,
                locale: 'vi_VN',
                headerStyle: const HeaderStyle(
                    formatButtonVisible: false, titleCentered: true),
                calendarStyle: const CalendarStyle(outsideDaysVisible: false),
                selectedDayPredicate: (day) {
                  return isSameDay(_selectedDay, day);
                },
                eventLoader: _getEventsForDay,
                onDaySelected: (selectedDay, focusedDay) {
                  if (!isSameDay(_selectedDay, selectedDay)) {
                    setState(() {
                      _selectedDay = selectedDay;
                      _focusedDay = focusedDay;
                      _selectedEvents.value = _getEventsForDay(_selectedDay!);
                    });
                  }
                },
                onFormatChanged: (format) {
                  if (_calendarFormat != format) {
                    setState(() {
                      _calendarFormat = format;
                    });
                  }
                },
                onPageChanged: (focusedDay) {
                  _focusedDay = focusedDay;
                },
                calendarBuilders: CalendarBuilders(
                  markerBuilder: (context, day, events) => events.isNotEmpty
                      ? Container(
                          width: 20,
                          height: 20,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                              color: Colors.greenAccent.shade400,
                              borderRadius: BorderRadius.circular(10)),
                          child: Text(
                            countOccurrences(dateList, day).toString(),
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold),
                          ),
                        )
                      : null,
                )),
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 8),
                Container(
                  margin: const EdgeInsets.only(left: 4, right: 4, bottom: 4),
                  child: StreamBuilder<List<AppointmentSchedule>>(
                    stream: _appointmentScheduleController!.stream,
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        // Xử lý lỗi nếu có
                        return Text('Đã xảy ra lỗi: ${snapshot.error}');
                      }

                      if (snapshot.hasData) {
                        dateList.clear();

                        List<AppointmentSchedule> appointmentSchedules =
                            snapshot.data!.where((element) {
                          if (element.status != 'Đã hủy' &&
                              element.status != 'Chờ duyệt') {
                            dateList.add(element.selectedDate!);

                            return true;
                          }
                          return false;
                        }).toList();

                        // Lọc theo mục
                        List<AppointmentSchedule>
                            tempAppointmentSchedulesStatus =
                            appointmentSchedules
                                .where((element) => compareDates(
                                    element.selectedDate!, _selectedDay!))
                                .toList()
                                .reversed
                                .toList();

                        // Nếu mục trống
                        if (tempAppointmentSchedulesStatus.isEmpty) {
                          return Center(
                            child: Container(
                              margin:
                                  const EdgeInsets.symmetric(horizontal: 20),
                              height: 400,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Image.asset(
                                    'assets/empty-box.png',
                                    width: 250,
                                    height: 250,
                                    fit: BoxFit.contain,
                                  ),
                                  const SizedBox(
                                    height: 12,
                                  ),
                                  const Text(
                                    'Chưa có lịch tư vấn trong ngày này.',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.blueGrey,
                                      fontSize: 16,
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 6,
                                  ),
                                  const Text(
                                    'Lịch tư vấn của bạn sẽ được hiển thị tại đây.',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.blueGrey,
                                      height: 1.5,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }
                        //--------------------------------

                        if (tempAppointmentSchedulesStatus.isEmpty) {
                          return Center(
                            child: Container(
                              margin:
                                  const EdgeInsets.symmetric(horizontal: 20),
                              height: 500,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Image.asset(
                                    'assets/empty-box.png',
                                    width: 250,
                                    height: 250,
                                    fit: BoxFit.contain,
                                  ),
                                  const SizedBox(
                                    height: 12,
                                  ),
                                  const Text(
                                    'Bạn chưa có lịch khám ở mục này',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.blueGrey,
                                      fontSize: 16,
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 6,
                                  ),
                                  const Text(
                                    'Lịch khám của bạn sẽ được hiển thị tại đây.',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.blueGrey,
                                      height: 1.5,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }

                        //Hiển thị danh sách cuộc hẹn
                        return ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: tempAppointmentSchedulesStatus.length,
                          itemBuilder: (context, index) {
                            final appointmentSchedule =
                                tempAppointmentSchedulesStatus[index];
                            // Hiển thị thông tin cuộc hẹn trong một widget
                            return Container(
                              margin: const EdgeInsets.only(
                                bottom: 4,
                              ),
                              child: GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          ScheduleDoctorDetail(
                                              appointmentSchedule:
                                                  appointmentSchedule),
                                    ),
                                  );
                                },
                                child: DoctorScheduleCard(
                                    appointmentSchedule: appointmentSchedule),
                              ),
                            );
                          },
                        );
                      } else {
                        return const SizedBox(
                            height: 600,
                            child: Center(child: CircularProgressIndicator()));
                      }
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  bool compareDates(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  void flagAllDate(List<DateTime> dateList) {
    for (var date in dateList) {
      date = getconvertedDateTime(date);
      events.addAll({
        date: [Event(DateTime.now().toString())]
      });
      setState(() {
        _selectedEvents.value = _getEventsForDay(date);
      });
    }
  }
}

int countOccurrences(List<DateTime> dateList, DateTime targetDate) {
  int count = 0;

  for (DateTime date in dateList) {
    if (date.year == targetDate.year &&
        date.month == targetDate.month &&
        date.day == targetDate.day) {
      count++;
    }
  }

  return count;
}

DateTime getconvertedDateTime(DateTime desiredDateTime) {
  DateTime convertedDateTime = DateTime.utc(
    desiredDateTime.year,
    desiredDateTime.month,
    desiredDateTime.day,
    0,
    0,
    0,
    0,
    0,
  );
  return convertedDateTime;
}

class Event {
  final String title;

  Event(this.title);
}
