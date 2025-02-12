import 'dart:async';

import 'package:assist_health/src/models/other/appointment_schedule.dart';
import 'package:assist_health/src/others/methods.dart';
import 'package:assist_health/src/others/theme.dart';
import 'package:assist_health/src/presentation/screens/doctor_screens/doctor_chart.dart';
import 'package:assist_health/src/presentation/screens/doctor_screens/schedule_doctor.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dots_indicator/dots_indicator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class HomeDoctor extends StatefulWidget {
  const HomeDoctor({super.key});

  @override
  State<HomeDoctor> createState() => _HomeDoctorState();
}

class _HomeDoctorState extends State<HomeDoctor> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  String name = '...';
  String imageURL = '';
  int currentIndex = 0;

  bool _isSwitched = false;

  StreamController<List<AppointmentSchedule>>? _appointmentScheduleController =
      StreamController<List<AppointmentSchedule>>.broadcast();
  List<DateTime> dateList = [];

  final items = [
    Image.asset('assets/slider1.jpg', fit: BoxFit.cover),
    Image.asset('assets/slider2.jpg', fit: BoxFit.cover),
  ];

  @override
  void initState() {
    super.initState();
    getDoctorData(_auth.currentUser!.uid);
    _appointmentScheduleController!
        .addStream(getAppointmentSchdedulesForDocotr());
  }

  bool compareDates(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  bool isDateInCurrentMonth(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year && date.month == now.month;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Bạn có muốn thoát ứng dụng?'),
            actions: [
              Padding(
                padding: const EdgeInsets.only(left: 15, right: 15, bottom: 5),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    InkWell(
                      child: Padding(
                        padding: const EdgeInsets.all(8),
                        child: Text(
                          'Không',
                          style: TextStyle(
                            color: Colors.greenAccent.shade700.withOpacity(0.7),
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      onTap: () => Navigator.of(context).pop(false),
                    ),
                    InkWell(
                      child: const Padding(
                        padding: EdgeInsets.all(8),
                        child: Text(
                          'Thoát',
                          style: TextStyle(
                            color: Colors.red,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      onTap: () => Navigator.of(context).pop(true),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          foregroundColor: Colors.white,
          toolbarHeight: 70,
          elevation: 0,
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
          title: Column(
            children: [
              Row(
                children: [
                  SizedBox(
                    width: 50,
                    height: 50,
                    child: ClipOval(
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Themes.gradientLightClr.withOpacity(0.4),
                              Themes.gradientLightClr
                            ],
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 5,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: (imageURL != '')
                            ? Image.network(imageURL, fit: BoxFit.cover,
                                errorBuilder: (BuildContext context,
                                    Object exception, StackTrace? stackTrace) {
                                return const Center(
                                  child: Icon(
                                    FontAwesomeIcons.userDoctor,
                                    size: 40,
                                    color: Colors.white,
                                  ),
                                );
                              })
                            : const Center(
                                child: CircleAvatar(
                                  radius: 25,
                                  backgroundColor: Colors.transparent,
                                  child: Icon(
                                    Icons.person,
                                    size: 25,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                      ),
                    ),
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Bác sĩ",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: Colors.white,
                          letterSpacing: 1.1,
                          wordSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(
                        height: 2,
                      ),
                      Text(
                        name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                          letterSpacing: 1.1,
                          wordSpacing: 1.2,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(
                height: 8,
              ),
            ],
          ),
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(
                height: 10,
              ),
              Stack(
                children: [
                  CarouselSlider(
                    items: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: AspectRatio(
                            aspectRatio: 3 / 1,
                            child: items[0],
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: AspectRatio(
                            aspectRatio: 3 / 1,
                            child: items[1],
                          ),
                        ),
                      ),
                      // Padding(
                      //   padding: const EdgeInsets.symmetric(
                      //     horizontal: 12,
                      //   ),
                      //   child: ClipRRect(
                      //     borderRadius: BorderRadius.circular(10),
                      //     child: AspectRatio(
                      //       aspectRatio: 3 / 1,
                      //       child: items[2],
                      //     ),
                      //   ),
                      // ),
                    ],
                    options: CarouselOptions(
                      height: 200,
                      viewportFraction: 1,
                      autoPlay: true,
                      onPageChanged: (index, reason) {
                        setState(() {
                          currentIndex = index;
                        });
                      },
                    ),
                  ),
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 3,
                    child: DotsIndicator(
                      dotsCount: items.length,
                      position: currentIndex,
                      decorator: DotsDecorator(
                        color: Colors.black.withOpacity(0.3),
                        activeColor: Colors.white,
                        size: const Size(14, 3),
                        activeSize: const Size(14, 3),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5)),
                        activeShape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5)),
                      ),
                    ),
                  )
                ],
              ),
              const SizedBox(
                height: 10,
              ),
              Padding(
                padding: const EdgeInsets.all(1),
                child: StreamBuilder<List<AppointmentSchedule>>(
                    stream: _appointmentScheduleController!.stream,
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        return Text('Đã xảy ra lỗi: ${snapshot.error}');
                      }

                      if (snapshot.hasData) {
                        int countAppointment = 0;
                        int total = 0;
                        DateTime now = DateTime.now();
                        int currentMonth = now.month;
                        int currentYear = now.year;

                        for (var element in snapshot.data!) {
                          // ✅ Chỉ tính phiếu có trạng thái "Đã khám" và nằm trong tháng hiện tại
                          if (element.status == 'Đã khám' &&
                              element.selectedDate!.month == currentMonth &&
                              element.selectedDate!.year == currentYear) {
                            total += element.doctorInfo!.serviceFee;
                            countAppointment++;
                          }
                        }

                        // ✅ Không cần lọc lại danh sách, countAppointment đã được tính chính xác

                        return Container(
                          margin: const EdgeInsets.symmetric(horizontal: 10),
                          child: GridView.count(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            crossAxisCount: 1,
                            childAspectRatio: 1.7,
                            children: List.generate(2, (index) {
                              return GestureDetector(
                                onTap: () {
                                  if (index == 0) {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                          builder: (_) =>
                                              const ScheduleDoctor()),
                                    );
                                  }
                                  if (index == 1) {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                          builder: (_) =>
                                              const DoctorChartScreen()),
                                    );
                                  }
                                },
                                child: Container(
                                  height: 100,
                                  margin: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(),
                                  ),
                                  padding: const EdgeInsets.all(20),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Container(
                                            width: 40,
                                            height: 40,
                                            decoration: const BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: Colors.blue,
                                            ),
                                            child: Icon(
                                              getIcon(index),
                                              color: Colors.white,
                                              size: 20,
                                            ),
                                          ),
                                          const Spacer(),
                                          if (index == 0)
                                            Switch(
                                              value: _isSwitched,
                                              activeColor: Colors.white,
                                              activeTrackColor:
                                                  Colors.greenAccent.shade400,
                                              onChanged: (value) {
                                                setState(() {
                                                  _isSwitched = value;
                                                  updateDocumentStatus(
                                                      _isSwitched);
                                                });
                                              },
                                            ),
                                        ],
                                      ),
                                      Expanded(
                                        child: Center(
                                          child: Text(
                                            (index == 0)
                                                ? countAppointment.toString()
                                                : formatNumber(total),
                                            style: TextStyle(
                                              fontSize: (index == 1) ? 35 : 60,
                                              color: Themes.gradientDeepClr,
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                      ),
                                      Row(
                                        children: [
                                          Text(
                                            getTitle(index),
                                            style: const TextStyle(
                                              fontSize: 16,
                                            ),
                                          ),
                                          const SizedBox(
                                            width: 5,
                                          ),
                                          const Spacer(),
                                          const Icon(
                                            Icons.arrow_circle_right_outlined,
                                            color: Themes.gradientDeepClr,
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }),
                          ),
                        );
                      }
                      return const SizedBox();
                    }),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> getDoctorData(String uid) async {
    try {
      DocumentSnapshot snapshot =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();

      if (snapshot.exists) {
        setState(() {
          imageURL = snapshot.get('imageURL');
          name = snapshot.get('name');
        });
      } else {
        print('User does not exist');
      }
    } catch (error) {
      print('Failed to fetch user data: $error');
    }
  }

  String getTitle(int index) {
    switch (index) {
      case 0:
        return 'Lịch hôm nay';
      case 1:
        return 'Thống kê tháng này';
      default:
        return 'Trống';
    }
  }

  getIcon(int index) {
    switch (index) {
      case 0:
        return FontAwesomeIcons.phone;
      case 1:
        return FontAwesomeIcons.chartLine;
      default:
        return FontAwesomeIcons.a;
    }
  }

  String formatNumber(int number) {
    if (number < 1000) {
      return number.toString();
    } else if (number < 1000000) {
      double result = number / 1000;
      return '${result.toStringAsFixed(1)} nghìn VNĐ';
    } else if (number < 1000000000) {
      double result = number / 1000000;
      return '${result.toStringAsFixed(1)} triệu VNĐ';
    } else {
      double result = number / 1000000000;
      return '${result.toStringAsFixed(1)} tỷ VNĐ';
    }
  }

  Future<void> updateDocumentStatus(bool isOnline) async {
    String status;
    if (isOnline) {
      status = 'online';
    } else {
      status = 'offline';
    }
    final collection = FirebaseFirestore.instance.collection('users');
    final document = collection.doc(_auth.currentUser!.uid);

    await document.update({'status': status});
  }
}
