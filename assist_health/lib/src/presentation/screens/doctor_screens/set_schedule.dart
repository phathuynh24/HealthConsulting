import 'package:assist_health/src/models/doctor/doctor_schedule.dart';
import 'package:assist_health/src/others/methods.dart';
import 'package:assist_health/src/others/theme.dart';
import 'package:assist_health/src/presentation/screens/doctor_screens/add_schedule.dart';
import 'package:assist_health/src/widgets/button.dart';
import 'package:assist_health/src/widgets/doctor_navbar.dart';
import 'package:date_picker_timeline/date_picker_timeline.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:intl/intl.dart';

class SetScheduleScreen extends StatefulWidget {
  const SetScheduleScreen({super.key});

  @override
  State<SetScheduleScreen> createState() => _SetScheduleScreen();
}

class _SetScheduleScreen extends State<SetScheduleScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool _isInitialized = false;

  @override
  initState() {
    super.initState();
    _initialize().then((_) {
      setState(() {
        _isInitialized = true;
      });
    });
  }

  // ignore: unused_field
  String? _uid;
  DoctorSchedule _doctorSchedule = DoctorSchedule();

  // ignore: unused_field
  DateTime _selectedDate = DateTime.now();
  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return WillPopScope(
        onWillPop: () async {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const DoctorNavBar()),
            (route) => false,
          );
          return true;
        },
        child: const SizedBox(
          height: double.infinity,
          child: Center(
            child: SizedBox(
              height: 40,
              width: 40,
              child: CircularProgressIndicator(),
            ),
          ),
        ),
      );
    }

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
        backgroundColor: Themes.backgroundClr,
        appBar: AppBar(
          foregroundColor: Colors.white,
          title: const Text('Đặt lịch khám'),
          centerTitle: true,
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Themes.gradientDeepClr, Themes.gradientLightClr],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
            ),
          ),
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
      ),
    );
  }

  _initialize() async {
    String? uid = _auth.currentUser!.uid;
    _doctorSchedule = await getSchedulesDoctor(uid, _selectedDate);
    // for (var element in _doctorSchedule.timeLine!) {
    //   for (var shiftTimes in element.shiftTimes) {
    //     shiftTimes = shiftTimes.reversed.toList();
    //   }
    //   element.shifts = element.shifts.reversed.toList();
    // }
    setState(() {
      _uid = uid;
    });
  }

  _addDateBar() {
    return Container(
      margin: const EdgeInsets.only(
        top: 20,
        left: 20,
        bottom: 20,
      ),
      child: DatePicker(
        DateTime.now(),
        height: 100,
        width: 80,
        initialSelectedDate: DateTime.now(),
        selectionColor: Themes.selectedClr,
        selectedTextColor: Colors.white,
        dateTextStyle: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: Colors.grey,
        ),
        onDateChange: (date) {
          _selectedDate = date;
          setState(() {
            _initialize();
          });
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
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Themes.buttonClr, // Set the color based on your theme
                ),
              ),
              const SizedBox(height: 5),
              const Text(
                "Hôm nay",
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.grey, // Set the color based on your theme
                ),
              ),
            ],
          ),
          MyButton(
            label: "+ Thêm lịch khám",
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
      margin: const EdgeInsets.only(
        bottom: 20,
      ),
      child: ListView.builder(
        scrollDirection: Axis.vertical,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: _doctorSchedule.timeLine!.length,
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
                          color: Themes.buttonClr,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Text(
                              _doctorSchedule.timeLine![index].duration,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            ListView.builder(
                              scrollDirection: Axis.vertical,
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: _doctorSchedule
                                  .timeLine![index].shiftTimes.length,
                              itemBuilder: (_, subIndex) {
                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      _doctorSchedule
                                          .timeLine![index].shifts[subIndex],
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color:
                                            Color.fromARGB(255, 255, 255, 255),
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 10,
                                    ),
                                    SizedBox(
                                      height: 45,
                                      child: ListView.builder(
                                        scrollDirection: Axis.horizontal,
                                        shrinkWrap: true,
                                        itemCount: _doctorSchedule
                                            .timeLine![index]
                                            .shiftTimes[subIndex]
                                            .length,
                                        itemBuilder: (_, i) {
                                          return Column(
                                            children: [
                                              Container(
                                                width: 50,
                                                margin:
                                                    const EdgeInsets.symmetric(
                                                  horizontal: 5,
                                                ),
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                  vertical: 5,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: const Color.fromARGB(
                                                      255, 255, 255, 255),
                                                  borderRadius:
                                                      BorderRadius.circular(6),
                                                ),
                                                child: Center(
                                                  child: Text(
                                                    _doctorSchedule
                                                            .timeLine![index]
                                                            .shiftTimes[
                                                        subIndex][i],
                                                    style: const TextStyle(
                                                      fontSize: 16,
                                                      color: Color.fromARGB(
                                                          255, 0, 0, 0),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(
                                                height: 10,
                                              )
                                            ],
                                          );
                                        },
                                      ),
                                    ),
                                  ],
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
