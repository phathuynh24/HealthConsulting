import 'package:assist_health/models/doctor/doctor_info.dart';
import 'package:assist_health/others/methods.dart';
import 'package:assist_health/others/theme.dart';
import 'package:assist_health/ui/user_screens/register_call_step1.dart';
import 'package:date_picker_timeline/date_picker_widget.dart';
import 'package:dots_indicator/dots_indicator.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';

// ignore: must_be_immutable
class DoctorDetailScreen extends StatefulWidget {
  DoctorInfo doctorInfo;
  DoctorDetailScreen({required this.doctorInfo, super.key});

  @override
  State<DoctorDetailScreen> createState() => _DoctorDetailScreenState();
}

class _DoctorDetailScreenState extends State<DoctorDetailScreen> {
  final ScrollController _scrollController = ScrollController();

  bool _isFavorite = false;

  bool _isCalendarVisible = true;
  bool _isFeeServiceVisible = true;
  bool _isWorkTimeVisible = true;
  bool _isInformationVisible = true;
  bool _isSpecialtyVisible = true;
  bool _isWorkPlaceVisible = true;
  bool _isStudyVisible = true;
  bool _isExperienceVisible = true;
  bool _isImageVisible = true;

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

  int? initDate;

  DoctorInfo? _doctorInfo;

  @override
  void initState() {
    super.initState();

    _doctorInfo = widget.doctorInfo;

    _scrollController.addListener(() {
      setState(() {
        _scrollController.offset >= 200;
      });
    });

    _startTime = '08:30';
    _endTime = '20:00';

    _updateStartTimeAndEndTime();

    _initialSelectedDate = _isNotEmptySlot()
        ? DateTime.now()
        : DateTime.now().add(Duration(days: 1));

    _selectedDate = _initialSelectedDate;

    initDate = _isCurrentMonthOfCurrentYear() ? _initialSelectedDate.day : 1;
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Themes.backgroundClr,
        appBar: AppBar(
          toolbarHeight: 50,
          title: const Text('Thông tin bác sĩ'),
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
          actions: [
            GestureDetector(
              onTap: () {
                setState(() {
                  _isFavorite = !_isFavorite;
                });
              },
              child: Container(
                margin: const EdgeInsets.only(
                  right: 15,
                ),
                child: Row(
                  children: [
                    (_isFavorite)
                        ? Icon(
                            FontAwesomeIcons.solidHeart,
                            color: Colors.red.shade600,
                            size: 19,
                          )
                        : const Icon(
                            FontAwesomeIcons.heart,
                            color: Colors.white,
                            size: 19,
                          ),
                    const SizedBox(
                      width: 8,
                    ),
                    Text(
                      (_isFavorite) ? 'Đã lưu' : 'Lưu lại',
                      style: const TextStyle(fontSize: 15, color: Colors.white),
                    )
                  ],
                ),
              ),
            )
          ],
        ),
        body: SingleChildScrollView(
          controller: _scrollController,
          child: Container(
            padding: const EdgeInsets.symmetric(
              vertical: 10,
            ),
            color: Colors.blueAccent.withOpacity(0.1),
            child: Column(
              children: [
                // Thông tin bác sĩ
                Container(
                  color: Colors.white,
                  width: double.infinity,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Container(
                            margin: const EdgeInsets.only(
                              right: 15,
                            ),
                            child: Stack(
                              children: [
                                SizedBox(
                                  width: 80,
                                  height: 80,
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
                                                  (BuildContext context,
                                                      Object exception,
                                                      StackTrace? stackTrace) {
                                              return Center(
                                                child: Icon(
                                                  FontAwesomeIcons.userDoctor,
                                                  size: 60,
                                                  color: Colors.white,
                                                ),
                                              );
                                            })
                                          : Center(
                                              child: Text(
                                                getAbbreviatedName(
                                                    _doctorInfo!.name),
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
                                Positioned(
                                    bottom: 0,
                                    right: 0,
                                    child: Container(
                                      padding: const EdgeInsets.all(2),
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Colors.greenAccent.shade700,
                                      ),
                                      child: const Icon(
                                        CupertinoIcons.video_camera_solid,
                                        size: 18,
                                        color: Colors.white,
                                      ),
                                    )),
                              ],
                            ),
                          ),
                          SizedBox(
                            width: 255,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _doctorInfo!.careerTitiles,
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 15,
                                    height: 1.5,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                Text(
                                  _doctorInfo!.name,
                                  style: TextStyle(
                                    color: Colors.black87,
                                    fontSize: 16,
                                    height: 1.5,
                                    fontWeight: FontWeight.w500,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                Text(
                                  '${DateTime.now().year - _doctorInfo!.graduationYear} năm kinh nghiệm',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 15,
                                    height: 1.5,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 6,
                      ),
                      Row(
                        children: [
                          const Text(
                            'Chuyên khoa: ',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 15,
                              height: 1.5,
                            ),
                          ),
                          SizedBox(
                              height: 35,
                              width: 265,
                              child: ListView.builder(
                                shrinkWrap: true,
                                scrollDirection: Axis.horizontal,
                                itemCount: _doctorInfo!.specialty.length,
                                itemBuilder: (context, index) {
                                  final specialty =
                                      _doctorInfo!.specialty[index];
                                  return Container(
                                    margin: const EdgeInsets.symmetric(
                                        horizontal: 2),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 9),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(20),
                                      color: Colors.blueGrey.withOpacity(0.1),
                                    ),
                                    child: Center(
                                      child: Text(
                                        specialty,
                                        style: const TextStyle(
                                            color: Colors.black,
                                            fontSize: 13,
                                            fontWeight: FontWeight.w400),
                                      ),
                                    ),
                                  );
                                },
                              )),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 5,
                ),
                // Lịch tư vấn
                Container(
                  color: Colors.white,
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _isCalendarVisible = !_isCalendarVisible;
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.only(
                            bottom: 10,
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                FontAwesomeIcons.calendarDays,
                                color: Colors.blueGrey,
                                size: 20,
                              ),
                              const SizedBox(
                                width: 16,
                              ),
                              const Expanded(
                                child: Text(
                                  'Lịch tư vấn',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w500,
                                    height: 1.5,
                                  ),
                                ),
                              ),
                              Icon(
                                (_isCalendarVisible)
                                    ? FontAwesomeIcons.angleDown
                                    : FontAwesomeIcons.angleUp,
                                size: 20,
                                color: Colors.grey,
                              )
                            ],
                          ),
                        ),
                      ),
                      if (_isCalendarVisible)
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
                                        width: 1, color: Colors.grey.shade300)),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      'Lịch tháng $_currentMonth/$_currentYear',
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const SizedBox(
                                      width: 5,
                                    ),
                                    const Icon(
                                      FontAwesomeIcons.angleDown,
                                      size: 16,
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
                                      DateTime(_currentYear, _currentMonth,
                                          initDate!),
                                      height: 85,
                                      width: 70,
                                      daysCount:
                                          _countTheRestDayOfSelectedMonth(),
                                      initialSelectedDate: _initialSelectedDate,
                                      locale: 'vi_VN',
                                      selectionColor: Themes.gradientLightClr
                                          .withOpacity(0.8),
                                      selectedTextColor: Colors.white,
                                      dateTextStyle: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.black,
                                      ),
                                      dayTextStyle: const TextStyle(
                                        fontSize: 12,
                                        color: Colors.blueGrey,
                                      ),
                                      monthTextStyle: const TextStyle(
                                        fontSize: 12,
                                        color: Colors.blueGrey,
                                      ),
                                      onDateChange: (date) {
                                        setState(() {
                                          _selectedDate = date;
                                          _initialSelectedDate = date;
                                          _startTime = '8:30';
                                          _endTime = '20:00';
                                          _selectedTime = '';
                                        });
                                        _updateStartTimeAndEndTime();
                                      },
                                    )
                                  : const SizedBox(
                                      height: 85,
                                      child: Center(
                                          child: CircularProgressIndicator()),
                                    ),
                            ),
                            Container(
                              width: 140,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 6,
                              ),
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
                              child: const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    CupertinoIcons.person_3_fill,
                                    size: 20,
                                    color: Colors.white,
                                  ),
                                  SizedBox(
                                    width: 8,
                                  ),
                                  Text(
                                    'Còn 48 slot',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.white,
                                    ),
                                  )
                                ],
                              ),
                            ),
                            SizedBox(
                              height: 5,
                            ),
                            Column(
                              children: [
                                (_isAnyTimeFrame(isMorning: true))
                                    ? Column(
                                        children: [
                                          const SizedBox(
                                            height: 10,
                                          ),
                                          const Row(
                                            children: [
                                              Icon(
                                                Icons.sunny,
                                                size: 18,
                                                color: Colors.amber,
                                              ),
                                              SizedBox(
                                                width: 10,
                                              ),
                                              Text(
                                                'Buổi sáng',
                                                style: TextStyle(
                                                  fontSize: 15,
                                                ),
                                              )
                                            ],
                                          ),
                                          const SizedBox(
                                            height: 8,
                                          ),
                                          SizedBox(
                                            height: 45,
                                            child: ListView.builder(
                                              scrollDirection: Axis.horizontal,
                                              itemCount:
                                                  ((12 - startHour!) * 60 +
                                                          (0 - startMinute!)) ~/
                                                      15,
                                              itemBuilder: (context, index) {
                                                int tempStartMinute =
                                                    startMinute!;

                                                int hour =
                                                    startHour! + index ~/ 4;
                                                int minute = (index % 4) * 15 +
                                                    tempStartMinute;
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
                                                return (!_isPastTime(
                                                        hour, minute))
                                                    ? GestureDetector(
                                                        onTap: () {
                                                          setState(() {
                                                            _selectedTime =
                                                                time;
                                                            Navigator.push(
                                                                context,
                                                                MaterialPageRoute(
                                                                    builder:
                                                                        (context) =>
                                                                            RegisterCallStep1(
                                                                              isEdit: false,
                                                                              doctorInfo: _doctorInfo!,
                                                                              selectedDate: _selectedDate,
                                                                              time: _selectedTime,
                                                                              isMorning: true,
                                                                            )));
                                                          });
                                                        },
                                                        child: Container(
                                                          padding:
                                                              const EdgeInsets
                                                                  .symmetric(
                                                                  horizontal:
                                                                      15,
                                                                  vertical: 10),
                                                          margin:
                                                              const EdgeInsets
                                                                  .all(3),
                                                          decoration:
                                                              BoxDecoration(
                                                            border: Border.all(
                                                              color: (isSelectedTime)
                                                                  ? Colors.blue
                                                                      .shade900
                                                                  : Colors
                                                                      .blueGrey
                                                                      .shade100,
                                                              width:
                                                                  (isSelectedTime)
                                                                      ? 1.5
                                                                      : 1,
                                                            ),
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        15),
                                                            color: (isSelectedTime)
                                                                ? Colors
                                                                    .blueAccent
                                                                    .withOpacity(
                                                                        0.15)
                                                                : Colors.white,
                                                          ),
                                                          child: Center(
                                                            child: Text(
                                                              time,
                                                              style: TextStyle(
                                                                color: (isSelectedTime)
                                                                    ? Colors
                                                                        .blue
                                                                        .shade800
                                                                    : Colors
                                                                        .black,
                                                                wordSpacing:
                                                                    1.2,
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      )
                                                    : const SizedBox.shrink();
                                              },
                                            ),
                                          ),
                                        ],
                                      )
                                    : const SizedBox.shrink(),
                                ((_isAnyTimeFrame(isMorning: false)))
                                    ? Column(
                                        children: [
                                          const SizedBox(
                                            height: 10,
                                          ),
                                          Row(
                                            children: [
                                              Icon(
                                                FontAwesomeIcons.cloudSun,
                                                size: 18,
                                                color:
                                                    Colors.blueAccent.shade200,
                                              ),
                                              const SizedBox(
                                                width: 12,
                                              ),
                                              const Text(
                                                'Buổi chiều',
                                                style: TextStyle(
                                                  fontSize: 15,
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(
                                            height: 10,
                                          ),
                                          SizedBox(
                                            height: 45,
                                            child: ListView.builder(
                                              scrollDirection: Axis.horizontal,
                                              itemCount: ((endHour! - 12) * 60 +
                                                      endMinute!) ~/
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

                                                return (!_isPastTime(
                                                        hour, minute))
                                                    ? GestureDetector(
                                                        onTap: () {
                                                          setState(() {
                                                            _selectedTime =
                                                                time;
                                                            Navigator.push(
                                                                context,
                                                                MaterialPageRoute(
                                                                    builder:
                                                                        (context) =>
                                                                            RegisterCallStep1(
                                                                              isEdit: false,
                                                                              doctorInfo: _doctorInfo!,
                                                                              selectedDate: _selectedDate,
                                                                              time: _selectedTime,
                                                                              isMorning: false,
                                                                            )));
                                                          });
                                                        },
                                                        child: Container(
                                                          padding:
                                                              const EdgeInsets
                                                                  .symmetric(
                                                                  horizontal:
                                                                      15,
                                                                  vertical: 10),
                                                          margin:
                                                              const EdgeInsets
                                                                  .all(3),
                                                          decoration:
                                                              BoxDecoration(
                                                            border: Border.all(
                                                              color: (isSelectedTime)
                                                                  ? Colors.blue
                                                                      .shade900
                                                                  : Colors
                                                                      .blueGrey
                                                                      .shade100,
                                                              width:
                                                                  (isSelectedTime)
                                                                      ? 1.5
                                                                      : 1,
                                                            ),
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        15),
                                                            color: (isSelectedTime)
                                                                ? Colors
                                                                    .blueAccent
                                                                    .withOpacity(
                                                                        0.15)
                                                                : Colors.white,
                                                          ),
                                                          child: Center(
                                                            child: Text(
                                                              time,
                                                              style: TextStyle(
                                                                color: (isSelectedTime)
                                                                    ? Colors
                                                                        .blue
                                                                        .shade800
                                                                    : Colors
                                                                        .black,
                                                                wordSpacing:
                                                                    1.2,
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      )
                                                    : const SizedBox.shrink();
                                              },
                                            ),
                                          ),
                                        ],
                                      )
                                    : const SizedBox.shrink(),
                              ],
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            const Row(
                              children: [
                                Icon(
                                  FontAwesomeIcons.solidHandPointUp,
                                  size: 20,
                                  color: Colors.grey,
                                ),
                                SizedBox(
                                  width: 8,
                                ),
                                Text(
                                  'Chọn một khung giờ để đặt',
                                  style: TextStyle(fontSize: 15),
                                ),
                              ],
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 5,
                ),
                // Phí dịch vụ
                Container(
                  color: Colors.white,
                  width: double.infinity,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _isFeeServiceVisible = !_isFeeServiceVisible;
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.only(
                            bottom: 10,
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                FontAwesomeIcons.creditCard,
                                color: Colors.blueGrey,
                                size: 20,
                              ),
                              const SizedBox(
                                width: 12,
                              ),
                              const Expanded(
                                child: Text(
                                  'Phí dịch vụ',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w500,
                                    height: 1.5,
                                  ),
                                ),
                              ),
                              Icon(
                                (_isFeeServiceVisible)
                                    ? FontAwesomeIcons.angleDown
                                    : FontAwesomeIcons.angleUp,
                                size: 16,
                                color: Colors.grey,
                              )
                            ],
                          ),
                        ),
                      ),
                      if (_isFeeServiceVisible)
                        Container(
                          padding: const EdgeInsets.only(
                            top: 5,
                            left: 4,
                            right: 4,
                            bottom: 6,
                          ),
                          child: Center(
                            child: Row(
                              children: [
                                Text(
                                  'Tư vấn trực tuyến',
                                  style: TextStyle(
                                    fontSize: 15,
                                  ),
                                ),
                                Spacer(),
                                Text(
                                  '${NumberFormat("#,##0", "en_US").format(int.parse(_doctorInfo!.serviceFee.toString()))} VNĐ',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 5,
                ),
                // Giờ làm việc
                Container(
                  color: Colors.white,
                  width: double.infinity,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _isWorkTimeVisible = !_isWorkTimeVisible;
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.only(
                            bottom: 10,
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                FontAwesomeIcons.clock,
                                color: Colors.blueGrey,
                                size: 20,
                              ),
                              const SizedBox(
                                width: 12,
                              ),
                              const Expanded(
                                child: Text(
                                  'Giờ làm việc',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w500,
                                    height: 1.5,
                                  ),
                                ),
                              ),
                              Icon(
                                (_isWorkTimeVisible)
                                    ? FontAwesomeIcons.angleDown
                                    : FontAwesomeIcons.angleUp,
                                size: 16,
                                color: Colors.grey,
                              )
                            ],
                          ),
                        ),
                      ),
                      if (_isWorkTimeVisible)
                        Container(
                          padding: const EdgeInsets.only(
                            top: 5,
                            left: 4,
                            right: 4,
                            bottom: 6,
                          ),
                          child: const Center(
                            child: Row(
                              children: [
                                Text(
                                  'Thứ 2 - Chủ nhật',
                                  style: TextStyle(
                                    fontSize: 15,
                                  ),
                                ),
                                Spacer(),
                                Text(
                                  '8:00 - 20:00',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 5,
                ),
                // Giới thiệu
                Container(
                  color: Colors.white,
                  width: double.infinity,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _isInformationVisible = !_isInformationVisible;
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.only(
                            bottom: 10,
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                CupertinoIcons.person_circle,
                                color: Colors.blueGrey,
                                size: 25,
                              ),
                              const SizedBox(
                                width: 8,
                              ),
                              const Expanded(
                                child: Text(
                                  'Giới thiệu',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w500,
                                    height: 1.5,
                                  ),
                                ),
                              ),
                              Icon(
                                (_isInformationVisible)
                                    ? FontAwesomeIcons.angleDown
                                    : FontAwesomeIcons.angleUp,
                                size: 16,
                                color: Colors.grey,
                              )
                            ],
                          ),
                        ),
                      ),
                      if (_isInformationVisible)
                        Container(
                          padding: const EdgeInsets.only(
                            top: 5,
                            left: 4,
                            right: 4,
                            bottom: 6,
                          ),
                          child: Text(
                            _doctorInfo!.description,
                            style: TextStyle(
                              fontSize: 15,
                              height: 1.5,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 5,
                ),
                // Chuyên khám
                Container(
                  color: Colors.white,
                  width: double.infinity,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _isSpecialtyVisible = !_isSpecialtyVisible;
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.only(
                            bottom: 10,
                          ),
                          child: Row(
                            children: [
                              const SizedBox(
                                width: 4,
                              ),
                              const Icon(
                                FontAwesomeIcons.starOfLife,
                                size: 16,
                                color: Colors.blueGrey,
                              ),
                              const SizedBox(
                                width: 12,
                              ),
                              const Expanded(
                                child: Text(
                                  'Chuyên khám',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w500,
                                    height: 1.5,
                                  ),
                                ),
                              ),
                              Icon(
                                (_isSpecialtyVisible)
                                    ? FontAwesomeIcons.angleDown
                                    : FontAwesomeIcons.angleUp,
                                size: 16,
                                color: Colors.grey,
                              )
                            ],
                          ),
                        ),
                      ),
                      if (_isSpecialtyVisible)
                        Container(
                          padding: const EdgeInsets.only(
                            top: 5,
                            bottom: 6,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  DotsIndicator(
                                    dotsCount: 1,
                                    decorator: const DotsDecorator(
                                      activeColor: Colors.grey,
                                      activeSize: Size(7, 7),
                                    ),
                                  ),
                                  const SizedBox(
                                    width: 5,
                                  ),
                                  const Text(
                                    'Nội khoa tổng quát',
                                    style: TextStyle(
                                      fontSize: 15,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(
                                height: 15,
                              ),
                              Row(
                                children: [
                                  DotsIndicator(
                                    dotsCount: 1,
                                    decorator: const DotsDecorator(
                                      activeColor: Colors.grey,
                                      activeSize: Size(7, 7),
                                    ),
                                  ),
                                  const SizedBox(
                                    width: 5,
                                  ),
                                  const Text(
                                    'Nội khoa tổng quát',
                                    style: TextStyle(
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(
                                height: 15,
                              ),
                              Row(
                                children: [
                                  DotsIndicator(
                                    dotsCount: 1,
                                    decorator: const DotsDecorator(
                                      activeColor: Colors.grey,
                                      activeSize: Size(7, 7),
                                    ),
                                  ),
                                  const SizedBox(
                                    width: 5,
                                  ),
                                  const Text(
                                    'Nội khoa tổng quát',
                                    style: TextStyle(
                                      fontSize: 15,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 5,
                ),
                // Nơi công tác
                Container(
                  color: Colors.white,
                  width: double.infinity,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _isWorkPlaceVisible = !_isWorkPlaceVisible;
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.only(
                            bottom: 10,
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                CupertinoIcons.building_2_fill,
                                size: 20,
                                color: Colors.blueGrey,
                              ),
                              const SizedBox(
                                width: 12,
                              ),
                              const Expanded(
                                child: Text(
                                  'Nơi công tác',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w500,
                                    height: 1.5,
                                  ),
                                ),
                              ),
                              Icon(
                                (_isWorkPlaceVisible)
                                    ? FontAwesomeIcons.angleDown
                                    : FontAwesomeIcons.angleUp,
                                size: 16,
                                color: Colors.grey,
                              )
                            ],
                          ),
                        ),
                      ),
                      if (_isWorkPlaceVisible)
                        Container(
                          padding: const EdgeInsets.only(
                            top: 5,
                            bottom: 6,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  DotsIndicator(
                                    dotsCount: 1,
                                    decorator: const DotsDecorator(
                                      activeColor: Colors.grey,
                                      activeSize: Size(7, 7),
                                    ),
                                  ),
                                  const SizedBox(
                                    width: 5,
                                  ),
                                  Text(
                                    _doctorInfo!.workplace,
                                    style: TextStyle(
                                      fontSize: 15,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 5,
                ),
                // Quá trình đào tạo
                Container(
                  color: Colors.white,
                  width: double.infinity,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _isStudyVisible = !_isStudyVisible;
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.only(
                            bottom: 10,
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                FontAwesomeIcons.graduationCap,
                                size: 18,
                                color: Colors.blueGrey,
                              ),
                              const SizedBox(
                                width: 12,
                              ),
                              const Expanded(
                                child: Text(
                                  'Quá trình đào tạo',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w500,
                                    height: 1.5,
                                  ),
                                ),
                              ),
                              Icon(
                                (_isStudyVisible)
                                    ? FontAwesomeIcons.angleDown
                                    : FontAwesomeIcons.angleUp,
                                size: 16,
                                color: Colors.grey,
                              )
                            ],
                          ),
                        ),
                      ),
                      if (_isStudyVisible)
                        Container(
                          padding: const EdgeInsets.only(
                            top: 5,
                            bottom: 6,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  DotsIndicator(
                                    dotsCount: 1,
                                    decorator: const DotsDecorator(
                                      activeColor: Colors.grey,
                                      activeSize: Size(7, 7),
                                    ),
                                  ),
                                  const SizedBox(
                                    width: 5,
                                  ),
                                  const Text(
                                    'Bệnh viện An Bình',
                                    style: TextStyle(
                                      fontSize: 15,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 5,
                ),
                // Kinh nghiệm
                Container(
                  color: Colors.white,
                  width: double.infinity,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _isExperienceVisible = !_isExperienceVisible;
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.only(
                            bottom: 10,
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                FontAwesomeIcons.award,
                                size: 18,
                                color: Colors.blueGrey,
                              ),
                              const SizedBox(
                                width: 15,
                              ),
                              const Expanded(
                                child: Text(
                                  'Kinh nghiệm',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w500,
                                    height: 1.5,
                                  ),
                                ),
                              ),
                              Icon(
                                (_isExperienceVisible)
                                    ? FontAwesomeIcons.angleDown
                                    : FontAwesomeIcons.angleUp,
                                size: 16,
                                color: Colors.grey,
                              )
                            ],
                          ),
                        ),
                      ),
                      if (_isExperienceVisible)
                        Container(
                          padding: const EdgeInsets.only(
                            top: 5,
                            bottom: 6,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  DotsIndicator(
                                    dotsCount: 1,
                                    decorator: const DotsDecorator(
                                      activeColor: Colors.grey,
                                      activeSize: Size(7, 7),
                                    ),
                                  ),
                                  const SizedBox(
                                    width: 5,
                                  ),
                                  const Text(
                                    'Bệnh viện An Bình',
                                    style: TextStyle(
                                      fontSize: 15,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 5,
                ),
                // Hình ảnh
                Container(
                  color: Colors.white,
                  width: double.infinity,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _isImageVisible = !_isImageVisible;
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.only(
                            bottom: 10,
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                FontAwesomeIcons.image,
                                size: 20,
                                color: Colors.blueGrey,
                              ),
                              const SizedBox(
                                width: 14,
                              ),
                              const Expanded(
                                child: Text(
                                  'Hình ảnh',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w500,
                                    height: 1.5,
                                  ),
                                ),
                              ),
                              Icon(
                                (_isImageVisible)
                                    ? FontAwesomeIcons.angleDown
                                    : FontAwesomeIcons.angleUp,
                                size: 16,
                                color: Colors.grey,
                              )
                            ],
                          ),
                        ),
                      ),
                      if (_isImageVisible)
                        Container(
                          height: 100,
                          width: 200,
                          color: Colors.green,
                          child: const Center(
                            child: Text(
                              'Visible',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    _scrollController.animateTo(
                      0,
                      duration: const Duration(milliseconds: 500),
                      curve: Curves.easeInOut,
                    );
                  },
                  child: Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(top: 15, bottom: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.arrow_upward_rounded,
                          color: Colors.blueGrey.shade300,
                          size: 15,
                        ),
                        const SizedBox(
                          width: 3,
                        ),
                        Text(
                          'LÊN ĐẦU TRANG',
                          style: TextStyle(
                              color: Colors.blueGrey.shade300,
                              fontSize: 10,
                              height: 1.5),
                        )
                      ],
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
        bottomNavigationBar: Container(
          height: 130,
          padding: const EdgeInsets.all(8),
          decoration: const BoxDecoration(
            border: Border(
              top: BorderSide(
                color: Colors.blueGrey,
                width: 0.2,
              ),
            ),
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(13),
                margin: const EdgeInsets.symmetric(horizontal: 5),
                decoration: BoxDecoration(
                  color: Colors.blue.shade100.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Colors.blue,
                    width: 1,
                  ),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      FontAwesomeIcons.solidCommentDots,
                      color: Colors.blue,
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    Text(
                      'Chat với bác sĩ',
                      style: TextStyle(
                        color: Colors.blue,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => Container()));
                      },
                      child: Container(
                        padding: const EdgeInsets.all(15),
                        margin: const EdgeInsets.symmetric(horizontal: 5),
                        decoration: BoxDecoration(
                          color: Colors.greenAccent.shade700,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Center(
                          child: Text(
                            'Gọi video ngay',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => RegisterCallStep1(
                                    isEdit: false, doctorInfo: _doctorInfo!)));
                      },
                      child: Container(
                        padding: const EdgeInsets.all(15),
                        margin: const EdgeInsets.symmetric(horizontal: 5),
                        decoration: BoxDecoration(
                          color: Colors.blueAccent.shade700,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Center(
                          child: Text(
                            'Đặt lịch gọi',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ));
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
            _initialSelectedDate = DateTime.now().add(Duration(days: 1));
          }
        }

        initDate = _initialSelectedDate.day;
        _selectedDate = _initialSelectedDate;
      });
    });

    Future.delayed(const Duration(milliseconds: 400), () {
      setState(() {
        _startTime = '08:00';
        _endTime = '20:30';
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
}
