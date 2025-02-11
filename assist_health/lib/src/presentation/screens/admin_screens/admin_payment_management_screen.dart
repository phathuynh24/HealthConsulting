import 'dart:async';

import 'package:assist_health/src/models/other/appointment_schedule.dart';
import 'package:assist_health/src/others/theme.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AdminPaymentManagementScreen extends StatefulWidget {
  const AdminPaymentManagementScreen({super.key});

  @override
  State<AdminPaymentManagementScreen> createState() =>
      _AdminPaymentManagementScreenState();
}

class _AdminPaymentManagementScreenState
    extends State<AdminPaymentManagementScreen> {
  final TextEditingController _searchController = TextEditingController();
  final StreamController<List<AppointmentSchedule>>
      _appointmentScheduleController =
      StreamController<List<AppointmentSchedule>>.broadcast();

  int _buttonIndex = 0;
  String _status = 'Chờ duyệt';
  String _searchText = '';

  final List<String> _statusList = [
    'Chờ duyệt',
    'Đã duyệt',
    'Đã hủy',
    'Thanh toán thất bại',
    'Đã hoàn tiền'
  ];

  @override
  void initState() {
    super.initState();
    _appointmentScheduleController.addStream(getAppointmentSchedules());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<String> getUserName(String uid) async {
    DocumentSnapshot userDoc =
        await FirebaseFirestore.instance.collection('users').doc(uid).get();
    if (userDoc.exists) {
      return userDoc['name'] ?? 'Không rõ';
    }
    return 'Không rõ';
  }

  void showConfirmationDialog(AppointmentSchedule appointment) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận duyệt thanh toán'),
        content: const Text('Bạn có chắc chắn muốn duyệt phiếu này không?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                appointment.status = 'Đã duyệt';
                appointment.updateAppointmentStatus(appointment.status!);
              });
              Navigator.pop(context);
            },
            child: const Text('Xác nhận'),
          ),
        ],
      ),
    );
  }

  void showRefundDialog(AppointmentSchedule appointment) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận hoàn tiền'),
        content: const Text('Bạn có chắc chắn muốn hoàn tiền phiếu này không?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                appointment.status = 'Đã hoàn tiền';
                appointment.updateAppointmentStatus(appointment.status!);
              });
              Navigator.pop(context);
            },
            child: const Text('Xác nhận hoàn tiền'),
          ),
        ],
      ),
    );
  }

  void showAppointmentDetails(AppointmentSchedule appointment) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Chi tiết phiếu khám'),
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Bác sĩ: ${appointment.doctorInfo!.name}'),
            Text('Người khám: ${appointment.userProfile!.name}'),
            Text('Mã phiếu: ${appointment.appointmentCode}'),
            Text('Số tiền: ${appointment.doctorInfo!.serviceFee} VNĐ'),
            Text('Ngày tạo: ${appointment.paymentStartTime?.toString() ?? "-"}'),
            Text('Nội dung chuyển khoản: ${appointment.transferContent ?? "Không có"}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Đóng'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quản lý thanh toán'),
        backgroundColor: Themes.gradientDeepClr,
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Tìm kiếm theo tên, mã phiếu...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    setState(() {
                      _searchText = '';
                      _searchController.clear();
                    });
                  },
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              onChanged: (value) {
                setState(() {
                  _searchText = value;
                });
              },
            ),
          ),
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
                    margin: const EdgeInsets.symmetric(horizontal: 6),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: _buttonIndex == index
                          ? Themes.gradientDeepClr
                          : Colors.grey[300],
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Center(
                      child: Text(
                        _statusList[index],
                        style: TextStyle(
                          color: _buttonIndex == index
                              ? Colors.white
                              : Colors.black,
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
              stream: _appointmentScheduleController.stream,
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('Lỗi: ${snapshot.error}'));
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('Không có dữ liệu'));
                }

                List<AppointmentSchedule> filteredAppointments = snapshot.data!
                    .where((appointment) => appointment.status == _status)
                    .where((appointment) =>
                        appointment.doctorInfo!.name
                            .toLowerCase()
                            .contains(_searchText.toLowerCase()) ||
                        appointment.userProfile!.name
                            .toLowerCase()
                            .contains(_searchText.toLowerCase()) ||
                        appointment.appointmentCode!
                            .toLowerCase()
                            .contains(_searchText.toLowerCase()))
                    .toList();

                return ListView.builder(
                  itemCount: filteredAppointments.length,
                  itemBuilder: (context, index) {
                    final appointment = filteredAppointments[index];
                    return Card(
                      margin: const EdgeInsets.all(8.0),
                      child: ListTile(
                        onTap: () => showAppointmentDetails(appointment),
                        title: Text('Bác sĩ: ${appointment.doctorInfo!.name}'),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            FutureBuilder<String>(
                              future: getUserName(appointment.idDocUser!),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return const Text(
                                      'Đang tải tên người dùng...');
                                }
                                if (snapshot.hasError) {
                                  return const Text(
                                      'Không lấy được tên người dùng');
                                }
                                return Text('Tài khoản user: ${snapshot.data}');
                              },
                            ),
                            Text(
                                'Người khám: ${appointment.userProfile!.name}'),
                            Text('Mã phiếu: ${appointment.appointmentCode}'),
                            Text(
                                'Số tiền: ${appointment.doctorInfo!.serviceFee} VNĐ'),
                            Text(
                                'Ngày tạo: ${appointment.paymentStartTime?.toString() ?? "-"}'),
                            Text(
                                'Nội dung chuyển khoản: ${appointment.transferContent ?? "Không có"}'),
                          ],
                        ),
                        trailing: appointment.status == 'Chờ duyệt'
                            ? Column(
                                children: [
                                  ElevatedButton(
                                    onPressed: () =>
                                        showConfirmationDialog(appointment),
                                    child: const Text('Duyệt'),
                                  ),
                                  ElevatedButton(
                                    onPressed: () =>
                                        showRefundDialog(appointment),
                                    child: const Text('Hoàn tiền'),
                                  ),
                                ],
                              )
                            : const Icon(Icons.check_circle,
                                color: Colors.green),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Stream<List<AppointmentSchedule>> getAppointmentSchedules() {
    return FirebaseFirestore.instance
        .collection('appointment_schedule')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => AppointmentSchedule.fromJson(doc.data()))
            .toList());
  }
}
