import 'dart:async';

import 'package:assist_health/src/models/other/appointment_schedule.dart';
import 'package:assist_health/src/others/methods.dart';
import 'package:assist_health/src/others/theme.dart';
import 'package:assist_health/src/presentation/screens/user_screens/schedule_detail.dart';
import 'package:assist_health/src/widgets/user_navbar.dart';
import 'package:assist_health/src/widgets/schedule_card.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({super.key});

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  final TextEditingController _searchController = TextEditingController();

  final StreamController<List<AppointmentSchedule>>
      _appointmentScheduleController =
      StreamController<List<AppointmentSchedule>>.broadcast();

  int _buttonIndex = 0;
  String _status = 'Chờ duyệt';

  String _searchText = '';

  // List<int> _secondsRemainingList = [];
  // List<Timer> _timers = [];

  final List<String> _statusList = [
    'Chờ duyệt',
    'Đã duyệt',
    'Đã khám',
    'Quá hẹn',
    'Đã hủy',
    'Đã hoàn tiền',
  ];

  @override
  void initState() {
    super.initState();
    _appointmentScheduleController.addStream(getAppointmentSchdedules());

    // Kiểm tra trạng thái chờ duyệt ngay khi khởi tạo
    getAppointmentSchdedules().listen((appointmentSchedules) {
      checkPendingAppointments(appointmentSchedules);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void checkPendingAppointments(
      List<AppointmentSchedule> appointmentScheduleList) {
    DateTime now = DateTime.now();

    for (var appointment in appointmentScheduleList) {
      if (appointment.status == 'Chờ duyệt') {
        try {
          // Lấy giờ bắt đầu từ chuỗi time
          String startTime = appointment.time!.split('-')[0]; // Ví dụ: "08:00"

          // Kiểm tra kiểu dữ liệu của selectedDate
          DateTime selectedDate;
          if (appointment.selectedDate is DateTime) {
            selectedDate = appointment.selectedDate!;
          } else if (appointment.selectedDate is Timestamp) {
            selectedDate = (appointment.selectedDate as Timestamp).toDate();
          } else {
            throw Exception('Invalid date format in appointment data');
          }

          // Tạo DateTime đầy đủ với ngày và giờ bắt đầu
          DateTime appointmentDateTime = DateTime(
            selectedDate.year,
            selectedDate.month,
            selectedDate.day,
            int.parse(startTime.split(':')[0]), // Giờ
            int.parse(startTime.split(':')[1]), // Phút
          );

          // Kiểm tra nếu đã quá thời gian khám
          if (now.isAfter(appointmentDateTime)) {
            appointment.status = 'Đã hủy';
            appointment.statusReasonCanceled =
                'Quá thời gian khám mà chưa thanh toán';

            // Cập nhật lên Firestore
            appointment.updateAppointmentStatus(appointment.status!);
            appointment.updateAppointmentStatusReasonCanceled(
                appointment.statusReasonCanceled!);

            debugPrint(
                'Cuộc hẹn ${appointment.appointmentCode} đã bị hủy do quá hạn.');
          }
        } catch (e) {
          debugPrint('Lỗi khi kiểm tra trạng thái cuộc hẹn: $e');
        }
      }
    }
  }

  void checkOutOfDateApproved(
      List<AppointmentSchedule> appointmentScheduleList) {
    for (int index = 0; index < appointmentScheduleList.length; index++) {
      if (isAfterEndTime(appointmentScheduleList[index].time!,
          appointmentScheduleList[index].selectedDate!)) {
        AppointmentSchedule tempAppointmentSchedule =
            appointmentScheduleList[index];
        try {
          setState(() {
            appointmentScheduleList.removeAt(index);
            if (tempAppointmentSchedule.isExamined!) {
              tempAppointmentSchedule.status = 'Đã khám';
            } else {
              tempAppointmentSchedule.status = 'Quá hẹn';
            }
            tempAppointmentSchedule
                .updateAppointmentStatus(tempAppointmentSchedule.status!);
          });
        } catch (e) {
          debugPrint('Error: $e');
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const UserNavBar()),
          (route) => false,
        );
        return true;
      },
      child: Scaffold(
        backgroundColor: Colors.blueAccent.withOpacity(0.1),
        appBar: AppBar(
          foregroundColor: Colors.white,
          toolbarHeight: 80,
          title: Column(
            children: [
              const Text(
                'Lịch khám',
                style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.9),
              ),
              const SizedBox(
                height: 10,
              ),
              Container(
                height: 38,
                decoration: BoxDecoration(
                  color: Colors.blueGrey.shade800.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: TextFormField(
                  controller: _searchController,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.all(10),
                    hintText: 'Tên bác sĩ, bệnh nhân, mã phiếu khám',
                    hintStyle: const TextStyle(
                      color: Colors.white70,
                      fontSize: 15,
                    ),
                    prefixIcon: const Icon(
                      Icons.search,
                      color: Colors.white70,
                      size: 23,
                    ),
                    border: InputBorder.none,
                    suffixIconConstraints:
                        const BoxConstraints(maxHeight: 30, maxWidth: 30),
                    suffixIcon: GestureDetector(
                      onTap: () {
                        setState(() {
                          _searchText = '';
                          _searchController.text = _searchText;
                        });
                      },
                      child: Container(
                        width: 16,
                        height: 16,
                        margin: const EdgeInsets.only(
                          right: 10,
                        ),
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white70,
                        ),
                        child: Center(
                          child: Icon(
                            Icons.clear,
                            size: 15,
                            color: Colors.blueGrey.shade700,
                          ),
                        ),
                      ),
                    ),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _searchText = value;
                    });
                  },
                ),
              ),
            ],
          ),
          centerTitle: true,
          automaticallyImplyLeading: false,
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
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(
                  bottom: BorderSide(
                    color: Colors.blueGrey.withOpacity(0.8),
                    width: 0.3,
                  ),
                ),
              ),
              padding: const EdgeInsets.only(bottom: 6),
              child: Column(
                children: [
                  SizedBox(
                    height: 40,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _statusList.length,
                      itemBuilder: (context, index) {
                        return InkWell(
                          onTap: () {
                            setState(() {
                              _buttonIndex = index;
                              _status = _statusList[index];
                            });
                          },
                          child: Container(
                            margin: EdgeInsets.only(
                                left: (index == 0) ? 10 : 0,
                                right:
                                    (index == _statusList.length - 1) ? 10 : 0,
                                top: 5),
                            padding: const EdgeInsets.symmetric(
                                vertical: 8, horizontal: 15),
                            decoration: BoxDecoration(
                              color: _buttonIndex == index
                                  ? Themes.gradientDeepClr
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              _statusList[index],
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: _buttonIndex == index
                                    ? Colors.white
                                    : Colors.black87,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 8),
              Container(
                margin: const EdgeInsets.only(left: 4, right: 4, bottom: 4),
                child: StreamBuilder<List<AppointmentSchedule>>(
                  stream: _appointmentScheduleController.stream,
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      // Xử lý lỗi nếu có
                      return Text('Đã xảy ra lỗi: ${snapshot.error}');
                    }

                    if (snapshot.hasData) {
                      List<AppointmentSchedule> appointmentSchedulesStatus =
                          snapshot.data!
                              .where((element) => element.status == _status)
                              .toList()
                              .reversed
                              .toList();

                      // Kiểm tra và cập nhật trạng thái cho các cuộc hẹn chờ duyệt
                      checkPendingAppointments(appointmentSchedulesStatus);

                      // Nếu mục trống
                      if (appointmentSchedulesStatus.isEmpty) {
                        return Center(
                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 20),
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
                      //--------------------------------
                      // if (appointmentSchedulesStatus[0].status == 'Chờ duyệt') {
                      // startTimersForPending(appointmentSchedulesStatus);
                      // }

                      if (appointmentSchedulesStatus[0].status == 'Đã duyệt') {
                        checkOutOfDateApproved(appointmentSchedulesStatus);
                      }

                      if (appointmentSchedulesStatus.isEmpty) {
                        return Center(
                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 20),
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

                      // Lọc theo search
                      List<AppointmentSchedule> appointmentSchedulesSearch = [];
                      if (_searchText == '') {
                        appointmentSchedulesSearch = appointmentSchedulesStatus;
                      } else {
                        String searchText = _searchText.trim().toLowerCase();
                        appointmentSchedulesSearch = appointmentSchedulesStatus
                            .where((element) =>
                                element.doctorInfo!.name
                                    .toLowerCase()
                                    .contains(searchText) ||
                                element.userProfile!.name
                                    .toLowerCase()
                                    .contains(searchText) ||
                                element.appointmentCode!
                                    .toLowerCase()
                                    .contains(searchText))
                            .toList();
                      }
                      // Xử lý không tìm ra kết quả
                      if (appointmentSchedulesSearch.isEmpty) {
                        return SingleChildScrollView(
                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 20),
                            height: 350,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Image.asset(
                                  'assets/no_result_search_icon.png',
                                  width: 250,
                                  height: 250,
                                  fit: BoxFit.contain,
                                ),
                                const Text(
                                  'Không tìm thấy kết quả',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                  ),
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                                const Text(
                                  'Rất tiếc, chúng tôi không tìm thấy kết quả mà bạn mong muốn, hãy thử lại xem sao.',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey,
                                    height: 1.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }
                      //--------------------------------

                      //Hiển thị danh sách cuộc hẹn
                      return ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: appointmentSchedulesSearch.length,
                        itemBuilder: (context, index) {
                          final appointmentSchedule =
                              appointmentSchedulesSearch[index];
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
                                    builder: (context) => ScheduleDetail(
                                        appointmentSchedule:
                                            appointmentSchedule),
                                  ),
                                );
                              },
                              child: ScheduleCard(
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
        ),
      ),
    );
  }
}
