import 'dart:async';

import 'package:assist_health/src/models/other/appointment_schedule.dart';
import 'package:assist_health/src/others/methods.dart';
import 'package:assist_health/src/others/theme.dart';
import 'package:assist_health/src/presentation/screens/doctor_screens/schedule_doctor_detail.dart';
import 'package:assist_health/src/widgets/doctor_navbar.dart';
import 'package:assist_health/src/widgets/doctor_schedule_card.dart';
import 'package:flutter/material.dart';

class DoctorAppointmentScreen extends StatefulWidget {
  const DoctorAppointmentScreen({super.key});

  @override
  State<DoctorAppointmentScreen> createState() =>
      _DoctorAppointmentScreenState();
}

class _DoctorAppointmentScreenState extends State<DoctorAppointmentScreen> {
  final TextEditingController _searchController = TextEditingController();
  final StreamController<List<AppointmentSchedule>> _appointmentController =
      StreamController<List<AppointmentSchedule>>.broadcast();

  int _selectedIndex = 0;
  String _status = 'Đã duyệt';
  String _searchText = '';

  final List<String> _statusList = [
    'Đã duyệt',
    'Đã khám',
    'Đã hủy',
    'Quá hẹn',
  ];

  @override
  void initState() {
    super.initState();
    _appointmentController.addStream(getAppointmentSchdedulesForDocotr());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

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
        backgroundColor: Colors.blueAccent.withOpacity(0.1),
        body: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              child: TextFormField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Tìm tên bệnh nhân, mã lịch khám...',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onChanged: (value) {
                  setState(() {
                    _searchText = value;
                  });
                },
              ),
            ),
            Container(
              height: 50,
              padding: const EdgeInsets.only(bottom: 8),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _statusList.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedIndex = index;
                        _status = _statusList[index];
                      });
                    },
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 8),
                      padding: const EdgeInsets.symmetric(
                          vertical: 8, horizontal: 16),
                      decoration: BoxDecoration(
                        color: _selectedIndex == index
                            ? Themes.gradientDeepClr
                            : Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.blueGrey),
                      ),
                      child: Center(
                        child: Text(
                          _statusList[index],
                          style: TextStyle(
                            color: _selectedIndex == index
                                ? Colors.white
                                : Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            Expanded(
              child: StreamBuilder<List<AppointmentSchedule>>(
                stream: _appointmentController.stream,
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Center(child: Text('Lỗi: ${snapshot.error}'));
                  }

                  if (snapshot.hasData) {
                    List<AppointmentSchedule> appointments = snapshot.data!
                        .where((appointment) => appointment.status == _status)
                        .toList();

                    // Lọc theo tên hoặc mã cuộc hẹn (nếu có tìm kiếm)
                    if (_searchText.isNotEmpty) {
                      appointments = appointments
                          .where((appointment) =>
                              appointment.userProfile!.name
                                  .toLowerCase()
                                  .contains(_searchText.toLowerCase()) ||
                              appointment.appointmentCode!
                                  .toLowerCase()
                                  .contains(_searchText.toLowerCase()))
                          .toList();
                    }

                    // ✅ Xử lý sắp xếp
                    if (_status == 'Đã khám') {
                      // Tách các cuộc hẹn chưa có kết quả (isResult == false) và đã có kết quả (isResult == true)
                      List<AppointmentSchedule> noResultAppointments =
                          appointments
                              .where((appointment) =>
                                  appointment.isResult == false)
                              .toList();
                      List<AppointmentSchedule> hasResultAppointments =
                          appointments
                              .where(
                                  (appointment) => appointment.isResult == true)
                              .toList();

                      // Sắp xếp từng nhóm theo ngày gần nhất
                      noResultAppointments.sort(
                          (a, b) => b.selectedDate!.compareTo(a.selectedDate!));
                      hasResultAppointments.sort(
                          (a, b) => b.selectedDate!.compareTo(a.selectedDate!));

                      // Gộp lại: chưa có kết quả lên đầu
                      appointments = [
                        ...noResultAppointments,
                        ...hasResultAppointments
                      ];
                    } else {
                      // Các trạng thái khác: sắp xếp tất cả chỉ theo ngày gần nhất
                      appointments.sort(
                          (a, b) => b.selectedDate!.compareTo(a.selectedDate!));
                    }

                    if (appointments.isEmpty) {
                      return SingleChildScrollView(
                        child: Center(
                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 20),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Image.asset(
                                  'assets/empty-box.png',
                                  width: 250,
                                  height: 250,
                                  fit: BoxFit.contain,
                                ),
                                const SizedBox(height: 12),
                                const Text(
                                  'Chưa có lịch khám ở mục này',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blueGrey,
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                const Text(
                                  'Lịch khám phù hợp sẽ được hiển thị tại đây.',
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
                        ),
                      );
                    }

                    return ListView.builder(
                      itemCount: appointments.length,
                      itemBuilder: (context, index) {
                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ScheduleDoctorDetail(
                                  appointmentSchedule: appointments[index],
                                ),
                              ),
                            );
                          },
                          child: DoctorScheduleCard(
                              appointmentSchedule: appointments[index]),
                        );
                      },
                    );
                  }

                  return const Center(child: CircularProgressIndicator());
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
