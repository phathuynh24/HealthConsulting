// ignore_for_file: avoid_print

import 'dart:async';
import 'package:assist_health/src/models/other/appointment_schedule.dart';
import 'package:assist_health/src/others/methods.dart';
import 'package:assist_health/src/others/theme.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class DoctorChartScreen extends StatefulWidget {
  const DoctorChartScreen({super.key});

  @override
  State<DoctorChartScreen> createState() => _DoctorChartScreenState();
}

class _DoctorChartScreenState extends State<DoctorChartScreen> {
  final StreamController<List<AppointmentSchedule>>
      _appointmentScheduleController =
      StreamController<List<AppointmentSchedule>>.broadcast();

  int _selectedYear = DateTime.now().year;
  bool _isRangeSelected = false;
  DateTimeRange? _selectedDateRange;
  double _totalRevenue = 0.0;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  List<Map<String, dynamic>> _detailedRevenue = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      User? currentUser = _auth.currentUser;
      if (currentUser != null) {
        _appointmentScheduleController.addStream(
          getAppointmentSchedulesByDoctor(currentUser.uid),
        );
      } else {
        print('User is not signed in');
      }
    } catch (error) {
      print('Error loading data: $error');
      showErrorMessage();
    }
  }

  void showErrorMessage() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Lỗi khi tải dữ liệu. Vui lòng thử lại.'),
        duration: Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        foregroundColor: Colors.white,
        title: const Text(
          'Thống kê doanh thu',
          style: TextStyle(fontSize: 20),
        ),
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
        child: StreamBuilder<List<AppointmentSchedule>>(
          stream: _appointmentScheduleController.stream,
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Text('Lỗi: ${snapshot.error}');
            }
            if (snapshot.hasData) {
              List<AppointmentSchedule> appointmentSchedules = snapshot.data!;
              if (appointmentSchedules.isEmpty) {
                return const SizedBox(
                  height: 600,
                  child: Center(child: Text('Không có dữ liệu')),
                );
              }

              Map<int, double> monthlyRevenue = {};
              Map<DateTime, double> dailyRevenue = {};
              _totalRevenue = 0.0;
              _detailedRevenue.clear();

              for (AppointmentSchedule appointment in appointmentSchedules) {
                DateTime? paymentTime = appointment.paymentStartTime;
                User? currentUser = _auth.currentUser;

                if (appointment.doctorInfo?.uid == currentUser?.uid &&
                    appointment.status == 'Đã khám') {
                  num serviceFee = appointment.doctorInfo?.serviceFee ?? 0.0;
                  _totalRevenue += serviceFee.toDouble();

                  if (_isRangeSelected && _selectedDateRange != null) {
                    if (paymentTime != null &&
                        paymentTime.isAfter(_selectedDateRange!.start) &&
                        paymentTime.isBefore(_selectedDateRange!.end)) {
                      DateTime onlyDate = DateTime(
                          paymentTime.year, paymentTime.month, paymentTime.day);

                      dailyRevenue[onlyDate] =
                          (dailyRevenue[onlyDate] ?? 0.0) + serviceFee;

                      _detailedRevenue.add({
                        'date': paymentTime,
                        'amount': serviceFee,
                      });
                    }
                  } else if (paymentTime?.year == _selectedYear) {
                    monthlyRevenue[paymentTime!.month] =
                        (monthlyRevenue[paymentTime.month] ?? 0.0) + serviceFee;

                    _detailedRevenue.add({
                      'date': paymentTime,
                      'amount': serviceFee,
                    });
                  }
                }
              }

              _detailedRevenue.sort((a, b) => b['date'].compareTo(a['date']));

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 15, vertical: 10),
                    child: Row(
                      children: [
                        TextButton(
                          onPressed: () async {
                            DateTimeRange? picked = await showDateRangePicker(
                              context: context,
                              firstDate: DateTime(2023),
                              lastDate: DateTime.now(),
                            );

                            if (picked != null) {
                              setState(() {
                                _selectedDateRange = picked;
                                _isRangeSelected = true;
                              });
                            }
                          },
                          child: const Text("Chọn khoảng thời gian"),
                        ),
                        const Spacer(),
                        DropdownButton<int>(
                          value: _selectedYear,
                          items: List.generate(DateTime.now().year - 2023 + 1,
                              (index) {
                            int year = 2023 + index;
                            return DropdownMenuItem<int>(
                              value: year,
                              child: Text(year.toString()),
                            );
                          }),
                          onChanged: (year) {
                            setState(() {
                              _selectedYear = year!;
                              _isRangeSelected = false;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      'Tổng doanh thu: ${_formatCurrency(_totalRevenue)}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: SfCartesianChart(
                      primaryXAxis: _isRangeSelected
                          ? DateTimeAxis(
                              title: const AxisTitle(text: 'Ngày'),
                              dateFormat: DateFormat('dd/MM'),
                              intervalType: DateTimeIntervalType.days,
                            )
                          : NumericAxis(
                              title: const AxisTitle(text: 'Tháng'),
                            ),
                      primaryYAxis: const NumericAxis(
                        title: AxisTitle(text: 'Doanh thu (VNĐ)'),
                      ),
                      series: <CartesianSeries>[
                        _isRangeSelected
                            ? LineSeries<dynamic, dynamic>(
                                dataSource: dailyRevenue.entries.toList(),
                                xValueMapper: (entry, _) => entry.key,
                                yValueMapper: (entry, _) => entry.value,
                                markerSettings:
                                    const MarkerSettings(isVisible: true),
                                color: Colors.blue,
                                name: 'Doanh thu',
                              )
                            : ColumnSeries<dynamic, dynamic>(
                                dataSource: monthlyRevenue.entries.toList(),
                                xValueMapper: (entry, _) => entry.key,
                                yValueMapper: (entry, _) => entry.value,
                                color: Colors.blue,
                                name: 'Doanh thu',
                              ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _detailedRevenue.length,
                    itemBuilder: (context, index) {
                      var item = _detailedRevenue[index];
                      return ListTile(
                        title: Text(DateFormat('dd/MM/yyyy HH:mm')
                            .format(item['date'])),
                        subtitle: Text(
                          'Doanh thu: ${_formatCurrency(item['amount'].toDouble())}', // ✅ Đảm bảo kiểu double
                          style: const TextStyle(
                              fontSize: 14, fontWeight: FontWeight.bold),
                        ),
                      );
                    },
                  ),
                ],
              );
            }
            return const Center(child: CircularProgressIndicator());
          },
        ),
      ),
    );
  }

  String _formatCurrency(double amount) {
    return NumberFormat.currency(locale: 'vi_VN', symbol: 'VNĐ').format(amount);
  }
}
