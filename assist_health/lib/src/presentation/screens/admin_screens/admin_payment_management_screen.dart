import 'dart:async';

import 'package:assist_health/src/models/other/appointment_schedule.dart';
import 'package:assist_health/src/others/theme.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

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

  final Map<String, String> _cachedUserNames = {};

  final List<String> _statusList = [
    'Chờ duyệt',
    'Đã duyệt',
    'Đã hủy',
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
    if (_cachedUserNames.containsKey(uid)) {
      return _cachedUserNames[uid]!;
    }
    DocumentSnapshot userDoc =
        await FirebaseFirestore.instance.collection('users').doc(uid).get();
    if (userDoc.exists) {
      String name = userDoc['name'] ?? 'Không rõ';
      _cachedUserNames[uid] = name;
      return name;
    }
    return 'Không rõ';
  }

  String formatCurrency(int amount) {
    final formatter = NumberFormat('#,###', 'vi_VN');
    return formatter.format(amount);
  }

  String formatDate(DateTime date) {
    return DateFormat('HH:mm:ss dd/MM/yyyy').format(date);
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
                appointment.paymentStatus = 'Thanh toán thành công';
                appointment.updateAppointmentStatus(appointment.status!);
                appointment.updatePaymentStatus(appointment.paymentStatus!);
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
                appointment.updatePaymentStatus('Đã hoàn tiền');
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
            Text(
                'Ngày tạo: ${appointment.paymentStartTime?.toString() ?? "-"}'),
            Text(
                'Nội dung chuyển khoản: ${appointment.transferContent ?? "Không có"}'),
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
      backgroundColor: Colors.blueAccent.withOpacity(0.1),
      appBar: AppBar(
        foregroundColor: Colors.white,
        toolbarHeight: 80,
        title: Column(
          children: [
            const Text(
              'Quản lý thanh toán',
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
                  hintText: 'Tên BS, người khám, mã phiếu, NDCK...',
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
                              right: (index == _statusList.length - 1) ? 10 : 0,
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
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<List<AppointmentSchedule>>(
              stream: _appointmentScheduleController.stream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
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
                            .contains(_searchText.toLowerCase()) ||
                        (appointment.transferContent ?? '')
                            .toLowerCase()
                            .contains(_searchText.toLowerCase()))
                    .toList();

                filteredAppointments.sort((a, b) {
                  if (a.status == 'Đã hủy' &&
                      a.paymentStatus == 'Thanh toán thành công') {
                    return -1;
                  } else if (b.status == 'Đã hủy' &&
                      b.paymentStatus == 'Thanh toán thành công') {
                    return 1;
                  }
                  return b.paymentStartTime!.compareTo(a.paymentStartTime!);
                });

                if (filteredAppointments.isEmpty) {
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
                          const SizedBox(height: 12),
                          const Text(
                            'Chưa có phiếu khám ở mục này',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.blueGrey,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            'Phiếu khám phù hợp sẽ được hiển thị tại đây.',
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

                return ListView.builder(
                  itemCount: filteredAppointments.length,
                  itemBuilder: (context, index) {
                    final appointment = filteredAppointments[index];
                    return Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16.0),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.3),
                            spreadRadius: 2,
                            blurRadius: 5,
                            offset: Offset(0, 3),
                          ),
                        ],
                      ),
                      margin: const EdgeInsets.symmetric(
                          horizontal: 12.0, vertical: 8.0),
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Tài khoản: ${_cachedUserNames[appointment.idDocUser!] ?? "Đang tải..."}',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Icon(
                                appointment.status == 'Chờ duyệt'
                                    ? Icons.hourglass_top
                                    : appointment.status == 'Đã hủy'
                                        ? Icons.cancel
                                        : Icons.check_circle,
                                color: appointment.status == 'Chờ duyệt'
                                    ? Colors.orange
                                    : appointment.status == 'Đã hủy'
                                        ? Colors.red
                                        : Colors.green,
                                size: 28,
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Bác sĩ: ${appointment.doctorInfo!.name}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          Text(
                            'Hồ sơ: ${appointment.userProfile!.name}',
                            style: const TextStyle(fontSize: 14),
                          ),
                          Text(
                            'Mã phiếu: ${appointment.appointmentCode}',
                            style: const TextStyle(fontSize: 14),
                          ),
                          Text(
                            'Số tiền: ${formatCurrency(appointment.doctorInfo!.serviceFee)} VNĐ',
                            style: const TextStyle(
                                fontSize: 14, color: Colors.blue),
                          ),
                          Text(
                            'Ngày tạo: ${appointment.paymentStartTime != null ? formatDate(appointment.paymentStartTime!) : "-"}',
                            style: const TextStyle(fontSize: 14),
                          ),
                          Text(
                            'Nội dung chuyển khoản: ${appointment.transferContent ?? "Không có"}',
                            style: const TextStyle(fontSize: 14),
                          ),
                          const Divider(height: 20, thickness: 1),
                          Align(
                            alignment: Alignment.centerRight,
                            child: appointment.status == 'Chờ duyệt'
                                ? ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.green,
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 20, vertical: 12),
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(10)),
                                    ),
                                    onPressed: () =>
                                        showConfirmationDialog(appointment),
                                    child: const Text('Duyệt',
                                        style: TextStyle(
                                            fontSize: 16, color: Colors.white)),
                                  )
                                : appointment.status == 'Đã hủy' &&
                                        appointment.paymentStatus ==
                                            'Thanh toán thành công'
                                    ? ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.red,
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 20, vertical: 12),
                                          shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10)),
                                        ),
                                        onPressed: () =>
                                            showRefundDialog(appointment),
                                        child: const Text('Hoàn tiền',
                                            style: TextStyle(
                                                fontSize: 16,
                                                color: Colors.white)),
                                      )
                                    : const Text(
                                        'Đã xử lý',
                                        style: TextStyle(
                                          color: Colors.green,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                          ),
                        ],
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
        .asyncMap((snapshot) async {
      List<AppointmentSchedule> appointments = snapshot.docs
          .map((doc) => AppointmentSchedule.fromJson(doc.data()))
          .toList();

      for (var appointment in appointments) {
        if (!_cachedUserNames.containsKey(appointment.idDocUser!)) {
          _cachedUserNames[appointment.idDocUser!] =
              await getUserName(appointment.idDocUser!);
        }
      }

      return appointments;
    });
  }
}
