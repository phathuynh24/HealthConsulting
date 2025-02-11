import 'dart:async';
import 'dart:io';

import 'package:assist_health/src/models/doctor/doctor_info.dart';
import 'package:assist_health/src/models/other/appointment_schedule.dart';
import 'package:assist_health/src/models/user/user_profile.dart';
import 'package:assist_health/src/others/methods.dart';
import 'package:assist_health/src/others/theme.dart';
import 'package:assist_health/src/presentation/screens/user_screens/health_profile_add_edit.dart';
import 'package:assist_health/src/presentation/screens/user_screens/register_call_step2.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:date_picker_timeline/date_picker_timeline.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:open_file/open_file.dart';

class RegisterCallStep1 extends StatefulWidget {
  final DoctorInfo doctorInfo;
  final DateTime? selectedDate;
  final String? time;
  final bool? isMorning;
  final bool isEdit;
  final AppointmentSchedule? appointmentSchedule;
  final bool skipPayment;

  const RegisterCallStep1(
      {super.key,
      this.appointmentSchedule,
      required this.isEdit,
      required this.doctorInfo,
      this.selectedDate,
      this.time,
      this.isMorning,
      this.skipPayment = false});

  @override
  State<RegisterCallStep1> createState() => _RegisterCallStep1();
}

class _RegisterCallStep1 extends State<RegisterCallStep1> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String? _uid;
  UserProfile? _userProfile;
  String? _idDoc;

  int _currentYear = DateTime.now().year;
  int _currentMonth = DateTime.now().month;
  DateTime _selectedDate = DateTime.now();
  DateTime _initialSelectedDate = DateTime.now();
  bool _shouldReloadDatePicker = true;
  String? _selectedTime;
  String? _startTime;
  String? _endTime;
  int? endHour;
  int? endMinute;
  int? startHour;
  int? startMinute;
  bool isMorning = true;
  int? initDate;
  List<File>? _selectedFiles;
  TextEditingController? _reasonForExaminationController;

  DoctorInfo? _doctorInfo;

  StreamController<DocumentSnapshot>? _userProfileStreamController;

  AppointmentSchedule? _appointmentSchedule;

  late Stream<List<AppointmentSchedule>> scheduleStream;
  List<AppointmentSchedule> scheduleData = [];

  int countSlot = 0;

  @override
  initState() {
    super.initState();
    _uid = _auth.currentUser!.uid;
    _startTime = '08:00';
    _endTime = '16:00';
    _updateStartTimeAndEndTime();
    _reasonForExaminationController = TextEditingController();
    _userProfileStreamController = StreamController<DocumentSnapshot>();

    if (widget.isEdit) {
      _appointmentSchedule = widget.appointmentSchedule!;
      _idDoc = _appointmentSchedule!.userProfile!.idDoc;
      _selectedFiles = _appointmentSchedule!.listOfHealthInformationFiles;
      _doctorInfo = _appointmentSchedule!.doctorInfo;
      _reasonForExaminationController!.text =
          _appointmentSchedule!.reasonForExamination!;
      _selectedFiles = _appointmentSchedule!.listOfHealthInformationFiles;
    } else {
      _idDoc = 'main_profile';
      _selectedFiles = [];
      _doctorInfo = widget.doctorInfo;
    }
    if (widget.time != null) {
      isMorning = widget.isMorning!;
      _initialSelectedDate = widget.selectedDate!;

      _selectedDate = _initialSelectedDate;

      initDate = _isCurrentMonthOfCurrentYear() ? _initialSelectedDate.day : 1;

      _selectedTime = widget.time!;
    } else {
      _initialSelectedDate = _isNotEmptySlot()
          ? DateTime.now()
          : DateTime.now().add(const Duration(days: 1));

      _selectedDate = _initialSelectedDate;

      initDate = _isCurrentMonthOfCurrentYear() ? _initialSelectedDate.day : 1;
    }

    scheduleStream = getScheduleData();
    scheduleStream.listen((data) {
      setState(() {
        scheduleData = data;
      });
    });
    Future.delayed(const Duration(milliseconds: 500), () {
      calculateCountSlot(startHour!, startMinute!, endHour!, endMinute!);
    });
  }

  void calculateCountSlot(
      int startHour, int startMinute, int endHour, int endMinute) {
    int totalStartMinutes = startHour * 60 + startMinute;
    int totalEndMinutes = endHour * 60 + endMinute;
    int count = (totalEndMinutes - totalStartMinutes) ~/ 15;
    DateTime now = DateTime.now();
    int minutes = 0;
    int countFull = 0;

    for (var element in scheduleData) {
      String timeRange = element.time!;
      List<String> timeParts = timeRange.split("-");

      String startTimeString = timeParts[0];
      List<String> startTimeParts = startTimeString.split(":");
      int tempStartHour = int.parse(startTimeParts[0]);
      int tempStartMinute = int.parse(startTimeParts[1]);
      if (element.doctorInfo!.uid == _doctorInfo!.uid &&
          _isSameDate(element.selectedDate!) &&
          !_isPastTime(tempStartHour, tempStartMinute)) {
        countFull++;
      }
    }

    if (_isCurrentDate()) {
      DateTime zeroTime =
          DateTime(now.year, now.month, now.day, startHour, endMinute);

      Duration difference = now.difference(zeroTime);
      minutes = difference.inMinutes.abs();
    }

    setState(() {
      countSlot = count - (minutes / 15).ceil() - countFull;
    });
  }

  @override
  void dispose() {
    _reasonForExaminationController!.dispose();
    _userProfileStreamController!.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _firestore
        .collection('users')
        .doc(_uid!)
        .collection('health_profiles')
        .doc(_idDoc!)
        .snapshots()
        .listen((snapshot) {
      _userProfileStreamController!.add(snapshot);
    });

    List<String> appointmentFull = [];
    for (var element in scheduleData) {
      if (element.doctorInfo!.uid == _doctorInfo!.uid) {
        String formattedDate =
            DateFormat('dd/MM/yyyy').format(element.selectedDate!);
        String timeFull = '$formattedDate/${element.time!}';
        appointmentFull.add(timeFull);
      }
    }

    List<Widget> buildStepIndicators(
        {required bool skipPayment, required int currentStep}) {
      List<Map<String, String>> steps = [
        {'number': '1', 'label': 'Chọn lịch tư vấn'},
        {'number': '2', 'label': 'Xác nhận'},
      ];

      if (!skipPayment) {
        steps.add({'number': '3', 'label': 'Thanh toán'});
        steps.add({'number': '4', 'label': 'Nhận lịch hẹn'});
      } else {
        steps.add({'number': '3', 'label': 'Nhận lịch hẹn'});
      }

      return List.generate(steps.length * 2 - 1, (index) {
        if (index.isOdd) {
          return const Icon(
            Icons.arrow_right_alt_outlined,
            size: 30,
            color: Colors.blueGrey,
          );
        } else {
          final stepIndex = index ~/ 2;
          final step = steps[stepIndex];

          // Xác định màu sắc của bước
          Color circleColor;
          Color textColor;

          if (stepIndex < currentStep) {
            // Bước đã hoàn thành
            circleColor = Colors.greenAccent.shade700;
            textColor = Colors.greenAccent.shade700;
          } else if (stepIndex == currentStep) {
            // Bước hiện tại
            circleColor = Colors.blueAccent.shade700;
            textColor = Colors.blueAccent.shade700;
          } else {
            // Bước chưa đến
            circleColor = Colors.blueGrey;
            textColor = Colors.blueGrey;
          }

          return Row(
            children: [
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: circleColor,
                ),
                child: Text(
                  step['number']!,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 5),
              Text(
                step['label']!,
                style: TextStyle(
                  fontSize: 13,
                  color: textColor,
                ),
              ),
              const SizedBox(width: 5),
            ],
          );
        }
      });
    }

    return Scaffold(
      backgroundColor: Themes.backgroundClr,
      appBar: AppBar(
        foregroundColor: Colors.white,
        toolbarHeight: 50,
        title: const Text('Đặt lịch tư vấn'),
        titleTextStyle: const TextStyle(fontSize: 16),
        elevation: 0,
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
            width: double.infinity,
            height: 45,
            color: Colors.white,
            child: Container(
              height: 45,
              padding: const EdgeInsets.symmetric(
                horizontal: 10,
              ),
              color: Colors.blueAccent.withOpacity(0.1),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: buildStepIndicators(
                    skipPayment: widget.skipPayment,
                    currentStep: 0, // Truyền thêm currentStep để xác định bước hiện tại
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Container(
          color: Colors.blueAccent.withOpacity(0.1),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Thông tin bác sĩ
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 15),
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15)),
                child: Row(
                  children: [
                    Container(
                      margin: const EdgeInsets.only(
                        right: 15,
                      ),
                      child: SizedBox(
                        width: 70,
                        height: 70,
                        child: ClipOval(
                          child: Container(
                            decoration: const BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Themes.gradientDeepClr,
                                  Themes.gradientLightClr
                                ],
                                begin: Alignment.bottomCenter,
                                end: Alignment.topCenter,
                              ),
                            ),
                            child: (_doctorInfo!.imageURL != '')
                                ? Image.network(_doctorInfo!.imageURL,
                                    fit: BoxFit.cover, errorBuilder:
                                        (BuildContext context, Object exception,
                                            StackTrace? stackTrace) {
                                    return const Center(
                                      child: Icon(
                                        FontAwesomeIcons.userDoctor,
                                        size: 50,
                                        color: Colors.white,
                                      ),
                                    );
                                  })
                                : Center(
                                    child: Text(
                                      getAbbreviatedName(_doctorInfo!.name),
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 30,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 265,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _doctorInfo!.careerTitiles,
                            style: const TextStyle(
                              color: Colors.black,
                              fontSize: 14,
                              height: 1.5,
                            ),
                          ),
                          Text(
                            _doctorInfo!.name,
                            style: const TextStyle(
                              color: Colors.black87,
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                              height: 1.4,
                            ),
                          ),
                          Text(
                            'Chuyên khoa: ${getAllOfSpecialties(_doctorInfo!.specialty)}',
                            style: const TextStyle(
                              color: Colors.black,
                              fontSize: 14,
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(
                height: 15,
              ),

              // Chọn hồ sơ
              Container(
                margin: const EdgeInsets.only(left: 15),
                child: const Row(
                  children: [
                    Text(
                      'Đặt lịch tư vấn cho:',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(
                height: 5,
              ),
              Container(
                width: double.infinity,
                height: 195,
                margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 15),
                decoration: BoxDecoration(
                    color: Colors.blueGrey.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(15)),
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: () {
                        _showDetailProfileBottomSheet(context, _userProfile!);
                      },
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(15)),
                        child: StreamBuilder<DocumentSnapshot>(
                          stream: _userProfileStreamController!.stream,
                          builder: (context, snapshot) {
                            if (snapshot.hasError) {
                              return Text('Error: ${snapshot.error}');
                            }

                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const Center(
                                  child: CircularProgressIndicator());
                            }

                            if (!snapshot.hasData || !snapshot.data!.exists) {
                              return const Text('No data available');
                            }

                            // Lấy dữ liệu từ snapshot
                            _userProfile = UserProfile.fromJson(
                                snapshot.data!.data() as Map<String, dynamic>);
                            return Column(
                              children: [
                                const SizedBox(
                                  height: 5,
                                ),
                                Row(
                                  children: [
                                    const Text(
                                      'Họ và tên:',
                                      style: TextStyle(
                                        color: Colors.black87,
                                        fontSize: 13,
                                      ),
                                    ),
                                    const Spacer(),
                                    Text(
                                      _userProfile!.name,
                                      style: const TextStyle(
                                          color: Colors.black87,
                                          fontSize: 13,
                                          fontWeight: FontWeight.w500),
                                    ),
                                  ],
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                                Row(
                                  children: [
                                    const Text(
                                      'Giới tính:',
                                      style: TextStyle(
                                        color: Colors.black87,
                                        fontSize: 13,
                                      ),
                                    ),
                                    const Spacer(),
                                    Text(
                                      _userProfile!.gender,
                                      style: const TextStyle(
                                          color: Colors.black87,
                                          fontSize: 13,
                                          fontWeight: FontWeight.w500),
                                    ),
                                  ],
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                                Row(
                                  children: [
                                    const Text(
                                      'Ngày sinh:',
                                      style: TextStyle(
                                        color: Colors.black87,
                                        fontSize: 13,
                                      ),
                                    ),
                                    const Spacer(),
                                    Text(
                                      _userProfile!.doB,
                                      style: const TextStyle(
                                          color: Colors.black87,
                                          fontSize: 13,
                                          fontWeight: FontWeight.w500),
                                    ),
                                  ],
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                                Row(
                                  children: [
                                    const Text(
                                      'Điện thoại:',
                                      style: TextStyle(
                                        color: Colors.black87,
                                        fontSize: 13,
                                      ),
                                    ),
                                    const Spacer(),
                                    Text(
                                      _userProfile!.phone,
                                      style: const TextStyle(
                                        color: Colors.black87,
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500,
                                        letterSpacing: 1.1,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(
                                  height: 5,
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 2,
                    ),
                    Row(
                      children: [
                        const SizedBox(
                          width: 12,
                        ),
                        GestureDetector(
                          onTap: () {
                            _showDetailProfileBottomSheet(
                                context, _userProfile!);
                          },
                          child: const Text(
                            'Xem chi tiết',
                            style: TextStyle(
                                fontSize: 13,
                                color: Colors.black54,
                                fontWeight: FontWeight.w500,
                                height: 1.5),
                          ),
                        ),
                        const Spacer(),
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => AddOrEditProfileScreen(
                                  isEdit: true,
                                  profile: _userProfile,
                                ),
                              ),
                            );
                          },
                          style: ButtonStyle(
                            shape: MaterialStateProperty.all<
                                RoundedRectangleBorder>(
                              RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            backgroundColor:
                                MaterialStateProperty.all<Color>(Colors.white),
                          ),
                          child: const Text(
                            'Sửa hồ sơ',
                            style: TextStyle(
                                fontSize: 14, color: Themes.gradientDeepClr),
                          ),
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 2,
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () {
                  _showProfileListBottomSheet(context);
                },
                child: Container(
                  padding: const EdgeInsets.all(5),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Chọn hoặc tạo hồ sơ khác',
                        style: TextStyle(color: Colors.blue),
                      ),
                      const SizedBox(
                        width: 5,
                      ),
                      Icon(
                        Icons.arrow_circle_right_rounded,
                        color: Colors.blue.withOpacity(0.5),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(
                height: 15,
              ),

              // Chọn ngày
              Container(
                margin: const EdgeInsets.only(left: 15),
                child: const Row(
                  children: [
                    Text(
                      'Chọn ngày tư vấn:',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(
                height: 5,
              ),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 15),
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        GestureDetector(
                          onTap: () {
                            _showCalendarBottomSheet(context);
                          },
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                    width: 1,
                                    color: Colors.grey.withOpacity(0.5))),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Lịch tháng $_currentMonth/$_currentYear',
                                  style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.black87),
                                ),
                                const SizedBox(
                                  width: 3,
                                ),
                                const Icon(
                                  FontAwesomeIcons.angleDown,
                                  size: 14,
                                  color: Themes.gradientDeepClr,
                                ),
                              ],
                            ),
                          ),
                        ),
                        Container(
                          margin: const EdgeInsets.symmetric(
                            vertical: 10,
                          ),
                          child: (_shouldReloadDatePicker)
                              ? DatePicker(
                                  DateTime(
                                      _currentYear, _currentMonth, initDate!),
                                  height: 80,
                                  width: 70,
                                  daysCount: _countTheRestDayOfSelectedMonth(),
                                  initialSelectedDate: _initialSelectedDate,
                                  locale: 'vi_VN',
                                  selectionColor: Themes.gradientLightClr,
                                  selectedTextColor: Colors.white,
                                  dateTextStyle: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black,
                                  ),
                                  dayTextStyle: const TextStyle(
                                    fontSize: 11,
                                    color: Colors.blueGrey,
                                  ),
                                  monthTextStyle: const TextStyle(
                                    fontSize: 11,
                                    color: Colors.blueGrey,
                                  ),
                                  onDateChange: (date) {
                                    setState(() {
                                      _selectedDate = date;
                                      _initialSelectedDate = date;
                                      _startTime = '08:00';
                                      _endTime = '16:00';
                                      _selectedTime = '';
                                    });
                                    _updateStartTimeAndEndTime();
                                    calculateCountSlot(startHour!, startMinute!,
                                        endHour!, endMinute!);
                                  },
                                )
                              : const SizedBox(
                                  height: 100,
                                  child: Center(
                                      child: CircularProgressIndicator()),
                                ),
                        ),
                        const SizedBox(
                          height: 3,
                        ),
                        Container(
                          width: 130,
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [
                                Themes.gradientDeepClr,
                                Themes.gradientLightClr
                              ],
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                            ),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                CupertinoIcons.person_3_fill,
                                size: 20,
                                color: Colors.white,
                              ),
                              const SizedBox(
                                width: 8,
                              ),
                              Text(
                                'Còn $countSlot lượt',
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.white,
                                ),
                              )
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(
                height: 15,
              ),

              // Chọn giờ
              Container(
                margin: const EdgeInsets.only(left: 15),
                child: const Row(
                  children: [
                    Text(
                      'Chọn giờ tư vấn:',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(
                height: 5,
              ),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 15),
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15)),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                          color: Colors.white,
                          child: Row(
                            children: [
                              Expanded(
                                child: GestureDetector(
                                  onTap: () {
                                    if (isMorning) return;
                                    setState(() {
                                      isMorning = true;
                                    });
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.all(15),
                                    decoration: BoxDecoration(
                                      color: (isMorning)
                                          ? Colors.white
                                          : Colors.blueAccent.withOpacity(0.2),
                                      borderRadius: const BorderRadius.only(
                                        topLeft: Radius.circular(20),
                                        bottomRight: Radius.circular(20),
                                      ),
                                    ),
                                    child: const Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.sunny,
                                          size: 20,
                                          color: Colors.amber,
                                        ),
                                        SizedBox(
                                          width: 8,
                                        ),
                                        Text(
                                          'Buổi sáng',
                                          style: TextStyle(
                                            fontSize: 15,
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: GestureDetector(
                                  onTap: () {
                                    if (!isMorning) return;
                                    setState(() {
                                      isMorning = false;
                                    });
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.all(15),
                                    decoration: BoxDecoration(
                                      color: (!isMorning)
                                          ? Colors.white
                                          : Colors.blueAccent.withOpacity(0.2),
                                      borderRadius: const BorderRadius.only(
                                        topRight: Radius.circular(20),
                                        bottomLeft: Radius.circular(20),
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          FontAwesomeIcons.cloudSun,
                                          size: 20,
                                          color: Colors.blueAccent.shade200,
                                        ),
                                        const SizedBox(
                                          width: 8,
                                        ),
                                        const Text(
                                          'Buổi chiều',
                                          style: TextStyle(
                                            fontSize: 15,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          )),
                      Column(
                        children: [
                          const SizedBox(
                            height: 10,
                          ),
                          if (isMorning)
                            (_isAnyTimeFrame(isMorning: true))
                                ? GridView.builder(
                                    scrollDirection: Axis.vertical,
                                    shrinkWrap: true,
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    gridDelegate:
                                        const SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount:
                                          3, // Số lượng cột trong grid
                                      mainAxisSpacing:
                                          15, // Khoảng cách giữa các phần tử theo chiều dọc
                                      crossAxisSpacing:
                                          15, // Khoảng cách giữa các phần tử theo chiều ngang
                                      childAspectRatio:
                                          2.5, // Tỷ lệ giữa chiều rộng và chiều cao của mỗi phần tử
                                    ),
                                    itemCount: ((12 - startHour!) * 60 +
                                            (0 - startMinute!)) ~/
                                        15,
                                    itemBuilder: (context, index) {
                                      int tempStartMinute = startMinute!;

                                      int hour = startHour! + index ~/ 4;
                                      int minute =
                                          (index % 4) * 15 + tempStartMinute;
                                      if (minute >= 60) {
                                        minute = minute % 60;
                                        hour += 1;
                                      }

                                      // Tính giờ và phút kết thúc
                                      int nextMinute = minute + 15;
                                      int nextHour = hour;
                                      if (nextMinute >= 60) {
                                        nextMinute = 0;
                                        nextHour += 1;
                                      }

                                      // Format thời gian
                                      String startDurationTime =
                                          '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
                                      String endDurationTime =
                                          '${nextHour.toString().padLeft(2, '0')}:${nextMinute.toString().padLeft(2, '0')}';
                                      String time =
                                          '$startDurationTime-$endDurationTime';

                                      bool isSelectedTime =
                                          time == _selectedTime;
                                      return (!_isPastTime(hour, minute))
                                          ? Stack(
                                              children: [
                                                GestureDetector(
                                                  onTap: () {
                                                    if (isTimeFull(
                                                        _selectedDate,
                                                        time,
                                                        appointmentFull)) {
                                                    } else {
                                                      setState(() {
                                                        _selectedTime = time;
                                                      });
                                                    }
                                                  },
                                                  child: Container(
                                                    decoration: BoxDecoration(
                                                      border: Border.all(
                                                        color: (isSelectedTime)
                                                            ? Colors
                                                                .blue.shade900
                                                            : Colors.blueGrey
                                                                .shade100,
                                                        width: (isSelectedTime)
                                                            ? 1.5
                                                            : 1,
                                                      ),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              15),
                                                      color: (isSelectedTime)
                                                          ? Colors.blueAccent
                                                              .withOpacity(0.15)
                                                          : Colors.white,
                                                    ),
                                                    child: Center(
                                                      child: Text(
                                                        time,
                                                        style: TextStyle(
                                                            color:
                                                                (isSelectedTime)
                                                                    ? Colors
                                                                        .blue
                                                                        .shade800
                                                                    : Colors
                                                                        .black),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                if (isTimeFull(_selectedDate,
                                                    time, appointmentFull))
                                                  Transform.rotate(
                                                    angle: 330 *
                                                        3.141592653589793 /
                                                        180,
                                                    child: Center(
                                                      child: Container(
                                                          padding:
                                                              const EdgeInsets
                                                                  .symmetric(
                                                                  horizontal: 5,
                                                                  vertical: 1),
                                                          decoration:
                                                              BoxDecoration(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        20),
                                                            color: Colors.red,
                                                          ),
                                                          child: const Text(
                                                            'ĐẦY LỊCH',
                                                            style: TextStyle(
                                                              color:
                                                                  Colors.white,
                                                              fontSize: 9,
                                                            ),
                                                          )),
                                                    ),
                                                  ),
                                              ],
                                            )
                                          : Stack(
                                              children: [
                                                Container(
                                                  decoration: BoxDecoration(
                                                    border: Border.all(
                                                      color: Colors
                                                          .blueGrey.shade100,
                                                      width: (isSelectedTime)
                                                          ? 1.5
                                                          : 1,
                                                    ),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            15),
                                                    color: Colors.grey
                                                        .withOpacity(0.2),
                                                  ),
                                                  child: Center(
                                                    child: Text(
                                                      time,
                                                      style: const TextStyle(
                                                          color: Colors.grey),
                                                    ),
                                                  ),
                                                ),
                                                if (isTimeFull(_selectedDate,
                                                    time, appointmentFull))
                                                  Transform.rotate(
                                                    angle: 330 *
                                                        3.141592653589793 /
                                                        180,
                                                    child: Center(
                                                      child: Container(
                                                          padding:
                                                              const EdgeInsets
                                                                  .symmetric(
                                                                  horizontal: 5,
                                                                  vertical: 1),
                                                          decoration:
                                                              BoxDecoration(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        20),
                                                            color: Colors.red,
                                                          ),
                                                          child: const Text(
                                                            'ĐẦY LỊCH',
                                                            style: TextStyle(
                                                              color:
                                                                  Colors.white,
                                                              fontSize: 9,
                                                            ),
                                                          )),
                                                    ),
                                                  ),
                                              ],
                                            );
                                    },
                                  )
                                : Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 13,
                                    ),
                                    alignment: Alignment.center,
                                    child: const Text(
                                      'Không có khung giờ vào khoảng thời gian này. Bạn hãy chọn lịch khám vào buổi chiều hoặc chọn một ngày khác',
                                      style: TextStyle(
                                          fontSize: 14,
                                          height: 1.3,
                                          color: Colors.black54),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                          if (!isMorning)
                            ((_isAnyTimeFrame(isMorning: false)))
                                ? GridView.builder(
                                    scrollDirection: Axis.vertical,
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    shrinkWrap: true,
                                    gridDelegate:
                                        const SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount:
                                          3, // Số lượng cột trong grid
                                      mainAxisSpacing:
                                          15, // Khoảng cách giữa các phần tử theo chiều dọc
                                      crossAxisSpacing:
                                          15, // Khoảng cách giữa các phần tử theo chiều ngang
                                      childAspectRatio:
                                          2.5, // Tỷ lệ giữa chiều rộng và chiều cao của mỗi phần tử
                                    ),
                                    itemCount:
                                        ((endHour! - 12) * 60 + endMinute!) ~/
                                            15,
                                    itemBuilder: (context, index) {
                                      // Tính giờ và phút bắt đầu

                                      int hour = 12 + index ~/ 4;
                                      int minute = (index % 4) * 15;
                                      if (minute >= 60) {
                                        minute = 0;
                                        hour += 1;
                                      }

                                      // Tính giờ và phút kết thúc
                                      int nextMinute = minute + 15;
                                      int nextHour = hour;
                                      if (nextMinute >= 60) {
                                        nextMinute = 0;
                                        nextHour += 1;
                                      }

                                      // Format thời gian
                                      String startDurationTime =
                                          '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
                                      String endDurationTime =
                                          '${nextHour.toString().padLeft(2, '0')}:${nextMinute.toString().padLeft(2, '0')}';
                                      String time =
                                          '$startDurationTime-$endDurationTime';
                                      bool isSelectedTime =
                                          time == _selectedTime;

                                      return (!_isPastTime(hour, minute))
                                          ? GestureDetector(
                                              onTap: () {
                                                if (isTimeFull(_selectedDate,
                                                    time, appointmentFull)) {
                                                } else {
                                                  setState(() {
                                                    _selectedTime = time;
                                                  });
                                                }
                                              },
                                              child: Stack(
                                                children: [
                                                  Container(
                                                    decoration: BoxDecoration(
                                                      border: Border.all(
                                                        color: (isSelectedTime)
                                                            ? Colors
                                                                .blue.shade900
                                                            : Colors.blueGrey
                                                                .shade100,
                                                        width: (isSelectedTime)
                                                            ? 1.5
                                                            : 1,
                                                      ),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              15),
                                                      color: (isSelectedTime)
                                                          ? Colors.blueAccent
                                                              .withOpacity(0.15)
                                                          : Colors.white,
                                                    ),
                                                    child: Center(
                                                      child: Text(
                                                        time,
                                                        style: TextStyle(
                                                            color:
                                                                (isSelectedTime)
                                                                    ? Colors
                                                                        .blue
                                                                        .shade800
                                                                    : Colors
                                                                        .black),
                                                      ),
                                                    ),
                                                  ),
                                                  if (isTimeFull(_selectedDate,
                                                      time, appointmentFull))
                                                    Transform.rotate(
                                                      angle: 330 *
                                                          3.141592653589793 /
                                                          180,
                                                      child: Center(
                                                        child: Container(
                                                            padding:
                                                                const EdgeInsets
                                                                    .symmetric(
                                                                    horizontal:
                                                                        5,
                                                                    vertical:
                                                                        1),
                                                            decoration:
                                                                BoxDecoration(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          20),
                                                              color: Colors.red,
                                                            ),
                                                            child: const Text(
                                                              'ĐẦY LỊCH',
                                                              style: TextStyle(
                                                                color: Colors
                                                                    .white,
                                                                fontSize: 9,
                                                              ),
                                                            )),
                                                      ),
                                                    ),
                                                ],
                                              ),
                                            )
                                          : Stack(
                                              children: [
                                                Container(
                                                  decoration: BoxDecoration(
                                                    border: Border.all(
                                                      color: Colors
                                                          .blueGrey.shade100,
                                                      width: (isSelectedTime)
                                                          ? 1.5
                                                          : 1,
                                                    ),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            15),
                                                    color: Colors.grey
                                                        .withOpacity(0.2),
                                                  ),
                                                  child: Center(
                                                    child: Text(
                                                      time,
                                                      style: const TextStyle(
                                                          color: Colors.grey),
                                                    ),
                                                  ),
                                                ),
                                                if (isTimeFull(_selectedDate,
                                                    time, appointmentFull))
                                                  Transform.rotate(
                                                    angle: 330 *
                                                        3.141592653589793 /
                                                        180,
                                                    child: Center(
                                                      child: Container(
                                                          padding:
                                                              const EdgeInsets
                                                                  .symmetric(
                                                                  horizontal: 5,
                                                                  vertical: 1),
                                                          decoration:
                                                              BoxDecoration(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        20),
                                                            color: Colors.red,
                                                          ),
                                                          child: const Text(
                                                            'ĐẦY LỊCH',
                                                            style: TextStyle(
                                                              color:
                                                                  Colors.white,
                                                              fontSize: 9,
                                                            ),
                                                          )),
                                                    ),
                                                  ),
                                              ],
                                            );
                                    },
                                  )
                                : Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 13),
                                    alignment: Alignment.center,
                                    child: const Text(
                                      'Không có khung giờ vào khoảng thời gian này. Bạn hãy chọn lịch khám vào buổi sáng hoặc chọn một ngày khác',
                                      style: TextStyle(
                                          fontSize: 14,
                                          height: 1.3,
                                          color: Colors.black54),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                        ],
                      ),
                    ]),
              ),
              const SizedBox(
                height: 15,
              ),

              // Thông tin bổ sung
              Container(
                margin: const EdgeInsets.only(left: 15),
                child: const Row(
                  children: [
                    Text(
                      'Thông tin bổ sung (không bắt buộc)',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(
                height: 5,
              ),
              Container(
                padding: const EdgeInsets.only(left: 15, top: 5, bottom: 5),
                alignment: Alignment.center,
                child: const Text(
                  'Bạn có thể cung cấp thêm các thông tin như lý do khám, triệu chứng, đơn thuốc sử dụng gần đây',
                  style: TextStyle(
                      fontSize: 14, height: 1.3, color: Colors.blueGrey),
                ),
              ),
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10)),
                margin: const EdgeInsets.symmetric(
                  horizontal: 15,
                ),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 15, vertical: 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(
                            height: 5,
                          ),
                          const Text(
                            'Triệu chứng',
                            style: TextStyle(
                                fontSize: 15, fontWeight: FontWeight.w500),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          TextField(
                            controller: _reasonForExaminationController!,
                            decoration: const InputDecoration(
                              hintText:
                                  'Lý do khám, triệu chứng, trạng thái, tiền sử bệnh...',
                              hintStyle: TextStyle(
                                  fontSize: 14, fontWeight: FontWeight.w400),
                              border: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10)),
                              ),
                            ),
                            textInputAction: TextInputAction.newline,
                            keyboardType: TextInputType.multiline,
                            maxLines: 2,
                          ),
                          const SizedBox(
                            height: 15,
                          ),
                          const Text(
                            'Toa thuốc, hình ảnh',
                            style: TextStyle(
                                fontSize: 15, fontWeight: FontWeight.w500),
                          ),
                          const SizedBox(
                            height: 5,
                          ),
                          const Text(
                            'Toa(đơn) thuốc đang dùng gần đây',
                            style: TextStyle(
                              color: Colors.black87,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(
                            height: 5,
                          ),
                          Container(
                            margin: const EdgeInsets.symmetric(
                              vertical: 8,
                            ),
                            child: GridView.builder(
                              padding: EdgeInsets.zero,
                              scrollDirection: Axis.vertical,
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: _selectedFiles!.length + 1,
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 3,
                                mainAxisSpacing: 6,
                                crossAxisSpacing: 6,
                                childAspectRatio: 1,
                              ),
                              itemBuilder: (context, index) {
                                if (index != _selectedFiles!.length) {
                                  File file = _selectedFiles![index];
                                  String extension =
                                      file.path.split('.').last.toLowerCase();

                                  return GestureDetector(
                                    onTap: () {
                                      OpenFile.open(file.path);
                                    },
                                    child: Stack(
                                      children: [
                                        LayoutBuilder(builder:
                                            (BuildContext context,
                                                BoxConstraints constraints) {
                                          return Center(
                                            child: Container(
                                              height: constraints.maxWidth - 10,
                                              width: constraints.maxHeight - 10,
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(6),
                                                color: Colors.grey,
                                              ),
                                              alignment: Alignment.center,
                                              child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  if (extension == 'pdf')
                                                    const Icon(
                                                        Icons.picture_as_pdf,
                                                        size: 50),
                                                  if (extension == 'doc' ||
                                                      extension == 'docx')
                                                    const Icon(
                                                        Icons.description,
                                                        size: 50),
                                                  if (extension == 'mp4')
                                                    const Icon(
                                                        Icons
                                                            .play_circle_filled,
                                                        size: 50),
                                                  if (extension == 'png' ||
                                                      extension == 'jpg' ||
                                                      extension == 'jpeg')
                                                    SizedBox(
                                                      height:
                                                          constraints.maxWidth -
                                                              10,
                                                      width: constraints
                                                              .maxHeight -
                                                          10,
                                                      child: ClipRRect(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(6),
                                                        child: Image.file(
                                                          file,
                                                          fit: BoxFit.cover,
                                                        ),
                                                      ),
                                                    ),
                                                ],
                                              ),
                                            ),
                                          );
                                        }),
                                        Positioned(
                                          top: 0,
                                          right: 0,
                                          child: InkWell(
                                            onTap: () {
                                              setState(() {
                                                File file =
                                                    _selectedFiles![index];
                                                // Xóa tệp cục bộ
                                                file.deleteSync();
                                                // Xóa tệp khỏi danh sách
                                                _selectedFiles!.removeAt(index);
                                              });
                                            },
                                            child: const CircleAvatar(
                                              backgroundColor: Colors.red,
                                              radius: 12,
                                              child: Icon(
                                                Icons.remove,
                                                color: Colors.white,
                                                size: 15,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                } else {
                                  return GestureDetector(
                                    onTap: () {
                                      _showImageBottomSheet(context);
                                    },
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: Colors.grey.shade100,
                                        borderRadius: BorderRadius.circular(15),
                                      ),
                                      child: const Center(
                                        child: Icon(
                                          Icons.add,
                                          size: 35,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ),
                                  );
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(
                height: 10,
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        height: 65,
        padding: const EdgeInsets.all(8),
        decoration: const BoxDecoration(
          border: Border(
            top: BorderSide(
              color: Colors.blueGrey,
              width: 0.2,
            ),
          ),
        ),
        child: GestureDetector(
          onTap: () {
            if (_selectedTime == null || _selectedTime!.isEmpty) {
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Text('Thông báo'),
                    content: const Text('Vui lòng chọn ngày và giờ đặt lịch.'),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: const Text('Đóng'),
                      ),
                    ],
                  );
                },
              );
              return;
            }
            if (widget.isEdit) {
              _appointmentSchedule!.userProfile = _userProfile!;
              _appointmentSchedule!.reasonForExamination =
                  _reasonForExaminationController!.text;
              _appointmentSchedule!.listOfHealthInformationFiles =
                  _selectedFiles!;
              _appointmentSchedule!.selectedDate = _selectedDate;
              _appointmentSchedule!.time = _selectedTime!;
              _appointmentSchedule!.isMorning = isMorning;

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => RegisterCallStep2(
                    isEdit: true,
                    appointmentSchedule: _appointmentSchedule,
                    skipPayment: widget
                        .skipPayment, // Truyền thêm biến kiểm soát thanh toán
                  ),
                ),
              );
            } else {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => RegisterCallStep2(
                    isEdit: false,
                    doctorInfo: _doctorInfo!,
                    userProfile: _userProfile!,
                    reasonForExamination: _reasonForExaminationController!.text,
                    listOfHealthInformationFiles: _selectedFiles!,
                    selectedDate: _selectedDate,
                    time: _selectedTime!,
                    isMorning: isMorning,
                    skipPayment:
                        false, // Mặc định không bỏ qua thanh toán khi đặt mới
                  ),
                ),
              );
            }
          },
          child: Container(
            padding: const EdgeInsets.all(13),
            margin: const EdgeInsets.symmetric(horizontal: 5),
            decoration: BoxDecoration(
              color: Themes.gradientDeepClr,
              borderRadius: BorderRadius.circular(8),
            ),
            alignment: Alignment.center,
            child: const Text(
              'Tiếp tục',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showDetailProfileBottomSheet(
      BuildContext context, UserProfile userProfile) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
          return Container(
            color: Colors.transparent,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Container(
                  height: 5,
                  width: 50,
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(2.5),
                    color: Colors.grey.shade300,
                  ),
                ),
                Container(
                  height: 610,
                  padding: const EdgeInsets.symmetric(
                    vertical: 15,
                  ),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                  ),
                  child: Stack(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const Text(
                            'Chi tiết hồ sơ',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w500),
                          ),
                          Container(
                            width: MediaQuery.of(context).size.width * 0.9,
                            margin: const EdgeInsets.all(20),
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: Colors.grey.shade300,
                                  width: 1,
                                )),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(
                                  height: 5,
                                ),
                                Row(
                                  children: [
                                    const Text(
                                      'Mã bệnh nhân:',
                                      style: TextStyle(
                                        color: Colors.black87,
                                        fontSize: 14,
                                      ),
                                    ),
                                    const Spacer(),
                                    Text(
                                      userProfile.idProfile,
                                      style: const TextStyle(
                                          color: Colors.black87,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500),
                                    ),
                                  ],
                                ),
                                const SizedBox(
                                  height: 20,
                                ),
                                Row(
                                  children: [
                                    const Text(
                                      'Họ và tên:',
                                      style: TextStyle(
                                        color: Colors.black87,
                                        fontSize: 14,
                                      ),
                                    ),
                                    const Spacer(),
                                    Text(
                                      userProfile.name,
                                      style: const TextStyle(
                                          color: Colors.black87,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500),
                                    ),
                                  ],
                                ),
                                const SizedBox(
                                  height: 20,
                                ),
                                Row(
                                  children: [
                                    const Text(
                                      'Giới tính:',
                                      style: TextStyle(
                                        color: Colors.black87,
                                        fontSize: 14,
                                      ),
                                    ),
                                    const Spacer(),
                                    Text(
                                      userProfile.gender,
                                      style: const TextStyle(
                                          color: Colors.black87,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500),
                                    ),
                                  ],
                                ),
                                const SizedBox(
                                  height: 20,
                                ),
                                Row(
                                  children: [
                                    const Text(
                                      'Ngày sinh:',
                                      style: TextStyle(
                                        color: Colors.black87,
                                        fontSize: 14,
                                      ),
                                    ),
                                    const Spacer(),
                                    Text(
                                      userProfile.doB,
                                      style: const TextStyle(
                                          color: Colors.black87,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500),
                                    ),
                                  ],
                                ),
                                const SizedBox(
                                  height: 20,
                                ),
                                Row(
                                  children: [
                                    const Text(
                                      'Điện thoại:',
                                      style: TextStyle(
                                        color: Colors.black87,
                                        fontSize: 14,
                                      ),
                                    ),
                                    const Spacer(),
                                    Text(
                                      userProfile.phone,
                                      style: const TextStyle(
                                        color: Colors.black87,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                        letterSpacing: 1.1,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(
                                  height: 20,
                                ),
                                const Row(
                                  children: [
                                    Text(
                                      'Mã bảo hiểm y tế',
                                      style: TextStyle(
                                        color: Colors.black87,
                                        fontSize: 14,
                                      ),
                                    ),
                                    Spacer(),
                                    Text(
                                      'Chưa cập nhật',
                                      style: TextStyle(
                                          color: Colors.black45,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500),
                                    ),
                                  ],
                                ),
                                const SizedBox(
                                  height: 20,
                                ),
                                const Row(
                                  children: [
                                    Text(
                                      'Địa chỉ',
                                      style: TextStyle(
                                        color: Colors.black87,
                                        fontSize: 14,
                                      ),
                                    ),
                                    Spacer(),
                                    Text(
                                      'Chưa cập nhật',
                                      style: TextStyle(
                                          color: Colors.black45,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500),
                                    ),
                                  ],
                                ),
                                const SizedBox(
                                  height: 20,
                                ),
                                const Row(
                                  children: [
                                    Text(
                                      'Dân tộc',
                                      style: TextStyle(
                                        color: Colors.black87,
                                        fontSize: 14,
                                      ),
                                    ),
                                    Spacer(),
                                    Text(
                                      'Chưa cập nhật',
                                      style: TextStyle(
                                          color: Colors.black45,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500),
                                    ),
                                  ],
                                ),
                                const SizedBox(
                                  height: 20,
                                ),
                                const Row(
                                  children: [
                                    Text(
                                      'Nghề nghiệp',
                                      style: TextStyle(
                                        color: Colors.black87,
                                        fontSize: 14,
                                      ),
                                    ),
                                    Spacer(),
                                    Text(
                                      'Chưa cập nhật',
                                      style: TextStyle(
                                          color: Colors.black45,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500),
                                    ),
                                  ],
                                ),
                                const SizedBox(
                                  height: 20,
                                ),
                                const Row(
                                  children: [
                                    Text(
                                      'Email',
                                      style: TextStyle(
                                        color: Colors.black87,
                                        fontSize: 14,
                                      ),
                                    ),
                                    Spacer(),
                                    Text(
                                      'Chưa cập nhật',
                                      style: TextStyle(
                                          color: Colors.black45,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500),
                                    ),
                                  ],
                                ),
                                const SizedBox(
                                  height: 5,
                                ),
                              ],
                            ),
                          ),
                          const Spacer(),
                          Row(
                            children: [
                              Expanded(
                                child: GestureDetector(
                                  onTap: () {
                                    Navigator.of(context).pop();
                                  },
                                  child: Container(
                                    width: double.infinity,
                                    height: 50,
                                    margin: const EdgeInsets.only(
                                      left: 20,
                                      right: 10,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.grey.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: const Center(
                                      child: Text(
                                        'Đóng',
                                        style: TextStyle(
                                            color: Colors.black,
                                            fontWeight: FontWeight.w500),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: GestureDetector(
                                  onTap: () {
                                    Navigator.of(context)
                                        .push(
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                AddOrEditProfileScreen(
                                              isEdit: true,
                                              profile: userProfile,
                                            ),
                                          ),
                                        )
                                        .then((value) =>
                                            Navigator.of(context).pop());
                                  },
                                  child: Container(
                                    width: double.infinity,
                                    height: 50,
                                    margin: const EdgeInsets.only(
                                      left: 10,
                                      right: 20,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Themes.gradientDeepClr,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: const Center(
                                      child: Text(
                                        'Sửa thông tin',
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w500),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      Positioned(
                        top: 0,
                        right: 15,
                        child: GestureDetector(
                          onTap: () {
                            Navigator.of(context).pop();
                          },
                          child: const Icon(
                            Icons.close,
                            size: 24,
                            color: Colors.grey,
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ],
            ),
          );
        });
      },
    );
  }

  void _showProfileListBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
          return StreamBuilder<List<DocumentSnapshot>>(
            stream: getUserProfilesStream(),
            builder: (BuildContext context,
                AsyncSnapshot<List<DocumentSnapshot>> snapshot) {
              if (snapshot.hasData && snapshot.data != null) {
                final profiles = snapshot.data!.reversed.toList();
                return Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                      height: 5,
                      width: 50,
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(2.5),
                        color: Colors.grey.shade300,
                      ),
                    ),
                    Container(
                      height: 585,
                      padding: const EdgeInsets.symmetric(
                        vertical: 15,
                      ),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(20),
                          topRight: Radius.circular(20),
                        ),
                      ),
                      child: Stack(
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              const Text(
                                'Chọn hồ sơ bệnh nhân',
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.w500),
                              ),
                              const SizedBox(
                                height: 15,
                              ),
                              Container(
                                height: 445,
                                decoration: const BoxDecoration(
                                    border: Border(
                                  top: BorderSide(color: Colors.grey),
                                )),
                                child: ListView.builder(
                                  itemCount: profiles.length,
                                  itemBuilder:
                                      (BuildContext context, int index) {
                                    final profile = profiles[index];
                                    UserProfile userProfile =
                                        UserProfile.fromJson(profile.data()
                                            as Map<String, dynamic>);
                                    bool isAvtEmpty = userProfile.image == '';
                                    bool isSelectedProfile =
                                        _userProfile!.idProfile ==
                                            userProfile.idProfile;
                                    return GestureDetector(
                                      onTap: () {
                                        _updateSelectedProfile(userProfile);
                                        Navigator.of(context).pop();
                                      },
                                      child: Container(
                                        margin: const EdgeInsets.symmetric(
                                          horizontal: 15,
                                          vertical: 5,
                                        ),
                                        padding: const EdgeInsets.only(
                                          top: 10,
                                          left: 10,
                                          bottom: 10,
                                          right: 0,
                                        ),
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                            color: isSelectedProfile
                                                ? Themes.gradientDeepClr
                                                : Colors.grey.withOpacity(0.6),
                                            width:
                                                isSelectedProfile ? 1.5 : 0.5,
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(15),
                                        ),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            GestureDetector(
                                              onTap: () {
                                                _showDetailProfileBottomSheet(
                                                    context, userProfile);
                                              },
                                              child: Container(
                                                width: 90,
                                                padding:
                                                    const EdgeInsets.all(4),
                                                decoration: BoxDecoration(
                                                  color: Colors.blueAccent
                                                      .withOpacity(0.2),
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                ),
                                                child: Center(
                                                  child: Text(
                                                    'Xem chi tiết',
                                                    style: TextStyle(
                                                        color: Colors
                                                            .blue.shade900,
                                                        fontSize: 12),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            const SizedBox(
                                              height: 10,
                                            ),
                                            Row(
                                              children: [
                                                Container(
                                                  margin: const EdgeInsets.only(
                                                    right: 10,
                                                  ),
                                                  child: Column(
                                                    children: [
                                                      Stack(
                                                        children: [
                                                          SizedBox(
                                                            width: 90,
                                                            child: Column(
                                                              children: [
                                                                SizedBox(
                                                                  width: 60,
                                                                  height: 60,
                                                                  child:
                                                                      ClipOval(
                                                                    child:
                                                                        Container(
                                                                      decoration:
                                                                          const BoxDecoration(
                                                                        gradient:
                                                                            LinearGradient(
                                                                          colors: [
                                                                            Themes.gradientDeepClr,
                                                                            Themes.gradientLightClr
                                                                          ],
                                                                          begin:
                                                                              Alignment.bottomCenter,
                                                                          end: Alignment
                                                                              .topCenter,
                                                                        ),
                                                                      ),
                                                                      child: (isAvtEmpty)
                                                                          ? Center(
                                                                              child: Text(
                                                                                getAbbreviatedName(userProfile.name),
                                                                                style: const TextStyle(
                                                                                  color: Colors.white,
                                                                                  fontSize: 25,
                                                                                  fontWeight: FontWeight.bold,
                                                                                ),
                                                                              ),
                                                                            )
                                                                          : Image.network(userProfile.image, fit: BoxFit.cover, errorBuilder: (BuildContext context, Object exception, StackTrace? stackTrace) {
                                                                              return const Center(
                                                                                child: Icon(
                                                                                  CupertinoIcons.person_circle_fill,
                                                                                  size: 50,
                                                                                  color: Colors.white,
                                                                                ),
                                                                              );
                                                                            }),
                                                                    ),
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                          Positioned(
                                                            top: 0,
                                                            right: 0,
                                                            child: Row(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .center,
                                                              children: [
                                                                Container(
                                                                  padding: const EdgeInsets
                                                                      .symmetric(
                                                                      vertical:
                                                                          2,
                                                                      horizontal:
                                                                          4),
                                                                  decoration:
                                                                      BoxDecoration(
                                                                          borderRadius: BorderRadius.circular(
                                                                              15),
                                                                          color: Themes.gradientDeepClr.withOpacity(
                                                                              0.9),
                                                                          border:
                                                                              Border.all(
                                                                            color:
                                                                                Colors.white,
                                                                            width:
                                                                                3,
                                                                          )),
                                                                  child: Center(
                                                                      child:
                                                                          Text(
                                                                    userProfile
                                                                        .relationship,
                                                                    style: const TextStyle(
                                                                        color: Colors
                                                                            .white,
                                                                        fontSize:
                                                                            12),
                                                                  )),
                                                                ),
                                                              ],
                                                            ),
                                                          )
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                Stack(
                                                  children: [
                                                    SizedBox(
                                                      width: 260,
                                                      child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          Text(
                                                            userProfile.name,
                                                            style:
                                                                const TextStyle(
                                                              color:
                                                                  Colors.black,
                                                              fontSize: 14,
                                                              height: 1.5,
                                                            ),
                                                          ),
                                                          Text(
                                                            '${userProfile.gender} - ${userProfile.doB}',
                                                            style:
                                                                const TextStyle(
                                                              color: Colors
                                                                  .black87,
                                                              fontSize: 15,
                                                              height: 1.4,
                                                            ),
                                                          ),
                                                          Text(
                                                            userProfile.phone,
                                                            style:
                                                                const TextStyle(
                                                              color:
                                                                  Colors.black,
                                                              fontSize: 14,
                                                              height: 1.5,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    (isSelectedProfile)
                                                        ? Positioned(
                                                            bottom: 0,
                                                            right: 0,
                                                            child: Container(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .symmetric(
                                                                      vertical:
                                                                          4,
                                                                      horizontal:
                                                                          8),
                                                              decoration:
                                                                  BoxDecoration(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            15),
                                                                color: Themes
                                                                    .gradientDeepClr,
                                                                boxShadow: [
                                                                  BoxShadow(
                                                                    color: Colors
                                                                        .grey
                                                                        .withOpacity(
                                                                            0.5),
                                                                    spreadRadius:
                                                                        2,
                                                                    blurRadius:
                                                                        5,
                                                                    offset:
                                                                        const Offset(
                                                                            0,
                                                                            2),
                                                                  ),
                                                                ],
                                                              ),
                                                              child:
                                                                  const Center(
                                                                      child:
                                                                          Text(
                                                                'ĐANG CHỌN',
                                                                style:
                                                                    TextStyle(
                                                                  color: Colors
                                                                      .white,
                                                                  fontSize: 13,
                                                                ),
                                                              )),
                                                            ),
                                                          )
                                                        : const SizedBox
                                                            .shrink(),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.only(
                                  top: 15,
                                ),
                                decoration: const BoxDecoration(
                                    border: Border(
                                        top: BorderSide(
                                  color: Colors.blueGrey,
                                  width: 0.3,
                                ))),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: GestureDetector(
                                        onTap: () {
                                          Navigator.of(context).pop();
                                        },
                                        child: Container(
                                          width: double.infinity,
                                          height: 50,
                                          margin: const EdgeInsets.only(
                                            left: 20,
                                            right: 10,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.grey.withOpacity(0.2),
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                          child: const Center(
                                            child: Text(
                                              'Đóng',
                                              style: TextStyle(
                                                  color: Colors.black,
                                                  fontWeight: FontWeight.w500),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: GestureDetector(
                                        onTap: () {
                                          Navigator.of(context)
                                              .push(
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  AddOrEditProfileScreen(
                                                isEdit: false,
                                              ),
                                            ),
                                          )
                                              .whenComplete(() {
                                            UserProfile addedProfile =
                                                UserProfile.fromJson(profiles[1]
                                                        .data()
                                                    as Map<String, dynamic>);
                                            _updateSelectedProfile(
                                                addedProfile);
                                            Navigator.of(context).pop();
                                          });
                                        },
                                        child: Container(
                                          width: double.infinity,
                                          height: 50,
                                          margin: const EdgeInsets.only(
                                            left: 10,
                                            right: 20,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Themes.gradientDeepClr,
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                          child: const Center(
                                            child: Text(
                                              'Tạo hồ sơ mới',
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.w500),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          Positioned(
                            top: 0,
                            right: 15,
                            child: GestureDetector(
                              onTap: () {
                                Navigator.of(context).pop();
                              },
                              child: const Icon(
                                Icons.close,
                                size: 24,
                                color: Colors.grey,
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  ],
                );
              } else if (snapshot.hasError) {
                return Text('Đã xảy ra lỗi: ${snapshot.error}');
              } else {
                return const Text('Đang tải dữ liệu...');
              }
            },
          );
        });
      },
    );
  }

  void _showCalendarBottomSheet(BuildContext context) {
    int tempYear = _currentYear;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
          return Container(
            color: Colors.transparent,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  height: 5,
                  width: 50,
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(2.5),
                    color: Colors.grey.shade300,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 15,
                  ),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                  ),
                  child: Stack(
                    children: [
                      SizedBox(
                        width: double.infinity,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const Text(
                              'Chọn tháng',
                              style: TextStyle(
                                  fontSize: 17, fontWeight: FontWeight.w500),
                            ),
                            const SizedBox(
                              height: 26,
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 20),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  (tempYear != DateTime.now().year)
                                      ? GestureDetector(
                                          onTap: () {
                                            setState(() {
                                              tempYear--;
                                            });
                                          },
                                          child: const Icon(
                                              CupertinoIcons.arrow_left,
                                              color: Colors.blue),
                                        )
                                      : const SizedBox(
                                          width: 24,
                                        ),
                                  Text(
                                    tempYear.toString(),
                                    style: const TextStyle(fontSize: 17),
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        tempYear++;
                                      });
                                    },
                                    child: const Icon(
                                      CupertinoIcons.arrow_right,
                                      color: Colors.blue,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Divider(
                              color: Colors.grey,
                              indent: 20,
                              endIndent: 20,
                            ),
                            Container(
                              margin: const EdgeInsets.symmetric(
                                horizontal: 20,
                              ),
                              child: GridView.count(
                                shrinkWrap: true,
                                crossAxisCount: 3,
                                mainAxisSpacing: 10,
                                crossAxisSpacing: 10,
                                childAspectRatio: 2,
                                children: List.generate(12, (index) {
                                  final month = index + 1;
                                  final isPastMonth =
                                      (month < DateTime.now().month &&
                                          tempYear == DateTime.now().year);

                                  final color =
                                      isPastMonth ? Colors.grey : Colors.black;

                                  bool isSelectedMonth =
                                      (month == _currentMonth &&
                                          tempYear == _currentYear);

                                  return GestureDetector(
                                    onTap: () {
                                      if (isPastMonth) return;
                                      if (!isSelectedMonth) {
                                        _setSelectedYear(tempYear);
                                        _setSelectedMonth(month);

                                        _selectedTime = '';

                                        _updateInitDate();
                                      }
                                      Navigator.of(context).pop();
                                    },
                                    child: (isSelectedMonth)
                                        ? Container(
                                            margin: const EdgeInsets.symmetric(
                                                vertical: 10),
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(40),
                                              color: Themes.gradientLightClr,
                                            ),
                                            child: Center(
                                              child: Text(
                                                '${index + 1}',
                                                style: const TextStyle(
                                                  fontSize: 16,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ),
                                          )
                                        : Container(
                                            color: Colors.white,
                                            child: Center(
                                              child: Text(
                                                '${index + 1}',
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  color: color,
                                                ),
                                              ),
                                            ),
                                          ),
                                  );
                                }),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Positioned(
                        top: 0,
                        right: 15,
                        child: GestureDetector(
                          onTap: () {
                            Navigator.of(context).pop();
                          },
                          child: const Icon(
                            Icons.close,
                            size: 24,
                            color: Colors.grey,
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ],
            ),
          );
        });
      },
    );
  }

  void _showImageBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return Wrap(
              children: [
                ListTile(
                  leading: const Icon(Icons.photo),
                  title: const Text('Chọn file từ thư viện'),
                  onTap: () {
                    Navigator.pop(context);
                    pickMultipleFile();
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.camera),
                  title: const Text('Chụp ảnh'),
                  onTap: () {
                    Navigator.pop(context);
                    captureImage();
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> pickMultipleFile() async {
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.custom,
      allowedExtensions: ['png', 'jpg', 'jpeg', 'mp4', 'doc', 'docx', 'pdf'],
    );
    if (result != null) {
      setState(() {
        _selectedFiles!.addAll(result.paths.map((path) => File(path!)));
      });
    }
  }

  Future<void> captureImage() async {
    final imagePicker = ImagePicker();
    final pickedFile = await imagePicker.pickImage(source: ImageSource.camera);

    if (pickedFile != null) {
      setState(() {
        _selectedFiles!.add(File(pickedFile.path));
      });
    }
  }

  _setSelectedYear(int selectedYear) {
    setState(() {
      _currentYear = selectedYear;
    });
  }

  _setSelectedMonth(int selectedMonth) {
    setState(() {
      _currentMonth = selectedMonth;
    });
  }

  _updateSelectedProfile(UserProfile selectedProfile) {
    setState(() {
      _userProfile = selectedProfile;
      _idDoc = selectedProfile.idDoc;
    });
  }

  Stream<List<DocumentSnapshot>> getUserProfilesStream() {
    return _firestore
        .collection('users')
        .doc(_uid!)
        .collection('health_profiles')
        .snapshots()
        .map((snapshot) => snapshot.docs);
  }

  _updateStartTimeAndEndTime() {
    List<int> startParts = _startTime!.split(':').map(int.parse).toList();
    List<int> endParts = _endTime!.split(':').map(int.parse).toList();
    setState(() {
      // Chuyển đổi chuỗi thành số
      endHour = endParts[0];
      endMinute = endParts[1];
      startHour = startParts[0];
      startMinute = startParts[1];
    });
  }

  bool _isCurrentMonthOfCurrentYear() {
    if (_currentYear == DateTime.now().year &&
        _currentMonth == DateTime.now().month) return true;
    return false;
  }

  int _countTheRestDayOfSelectedMonth() {
    int daysOfSelectedMonth = _getTotalDaysInMonth(_currentYear, _currentMonth);
    int pastDaysOfSelectedMonth =
        (_isCurrentMonthOfCurrentYear()) ? DateTime.now().day : 0;

    int count = daysOfSelectedMonth - pastDaysOfSelectedMonth;
    return count;
  }

  int _getTotalDaysInMonth(int year, int month) {
    // Tạo một DateTime object đại diện cho ngày đầu tiên của tháng
    DateTime firstDayOfMonth = DateTime(year, month, 1);

    // Tạo một DateTime object đại diện cho ngày đầu tiên của tháng tiếp theo
    DateTime firstDayOfNextMonth = DateTime(year, month + 1, 1);

    // Tính số ngày giữa hai ngày trên để lấy tổng số ngày trong tháng
    Duration duration = firstDayOfNextMonth.difference(firstDayOfMonth);

    // Trả về tổng số ngày
    return duration.inDays;
  }

  _updateInitDate() {
    setState(() {
      _shouldReloadDatePicker = false;
    });
    Future.delayed(const Duration(milliseconds: 300), () {
      setState(() {
        _shouldReloadDatePicker = true;

        if (!_isCurrentMonthOfCurrentYear()) {
          _initialSelectedDate = DateTime(_currentYear, _currentMonth, 1);
        } else {
          _initialSelectedDate = DateTime.now();
          if (_isNotEmptySlot()) {
            _initialSelectedDate = DateTime.now().add(const Duration(days: 1));
          }
        }

        initDate = _initialSelectedDate.day;
        _selectedDate = _initialSelectedDate;
      });
    });

    Future.delayed(const Duration(milliseconds: 400), () {
      setState(() {
        _startTime = '08:00';
        _endTime = '16:00';
      });
      _updateStartTimeAndEndTime();
    });
  }

  _isPastTime(int startHour, int startMinute) {
    if (!_isCurrentDate()) return false;
    if (startHour > DateTime.now().hour ||
        (startHour == DateTime.now().hour &&
            startMinute >= DateTime.now().minute)) {
      return false;
    }
    return true;
  }

  _isCurrentDate() {
    DateTime selectedDate = _selectedDate;

    DateTime now = DateTime.now();

    bool isSameDay = selectedDate.year == now.year &&
        selectedDate.month == now.month &&
        selectedDate.day == now.day;

    return isSameDay;
  }

  _isSameDate(DateTime date) {
    DateTime selectedDate = _selectedDate;

    bool isSameDay = selectedDate.year == date.year &&
        selectedDate.month == date.month &&
        selectedDate.day == date.day;

    return isSameDay;
  }

  _isAnyTimeFrame({required bool isMorning}) {
    if (!_isCurrentDate()) return true;
    if (isMorning) {
      if (DateTime.now().hour < 12) {
        return true;
      }
      if (DateTime.now().hour == 11 && DateTime.now().minute <= 45) {
        return true;
      }
    } else {
      if (DateTime.now().hour < endHour!) {
        return true;
      }
      if (DateTime.now().hour == endHour! &&
          DateTime.now().minute <= (endMinute! - 15)) {
        return true;
      }
    }
    return false;
  }

  _isNotEmptySlot() {
    if (_isAnyTimeFrame(isMorning: true) == false &&
        _isAnyTimeFrame(isMorning: false) == false) return false;
    return true;
  }

  Stream<List<AppointmentSchedule>> getScheduleData() {
    return FirebaseFirestore.instance
        .collection('appointment_schedule')
        .snapshots()
        .map((QuerySnapshot querySnapshot) {
      List<AppointmentSchedule> scheduleData = [];
      for (var document in querySnapshot.docs) {
        scheduleData.add(AppointmentSchedule.fromJson(
            document.data() as Map<String, dynamic>));
      }
      return scheduleData;
    });
  }

  bool isTimeFull(DateTime date, String time, List<String> appointment) {
    String formattedDate = DateFormat('dd/MM/yyyy').format(date);
    bool isTimeFull =
        appointment.any((element) => element == '$formattedDate/$time');

    return isTimeFull;
  }
}
