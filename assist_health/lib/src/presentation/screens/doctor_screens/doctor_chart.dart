// ignore_for_file: avoid_print

import 'dart:async';

import 'package:assist_health/src/models/other/appointment_schedule.dart';
import 'package:assist_health/src/others/methods.dart';
import 'package:assist_health/src/others/theme.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

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
  final FirebaseAuth _auth = FirebaseAuth.instance;

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
        // Handle the case where the user is not signed in
        print('User is not signed in');
      }
    } catch (error) {
      // Handle any errors that occur
      print('Error loading data: $error');
      showErrorMessage();
    }
  }

  void showDataDialog(Map<String, double> monthlyRevenue) {
    int total = 0;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            'Thống kê doanh thu hàng tháng',
            textAlign: TextAlign.center,
          ),
          content: Column(
            children: [
              Column(
                children: monthlyRevenue.entries.map(
                  (entry) {
                    total += entry.value.toInt();
                    return Text(
                      'Tháng ${entry.key}: +${formatNumber(entry.value.toInt())}',
                      style: TextStyle(
                        fontSize: 16,
                        height: 2,
                      ),
                    );
                  },
                ).toList(),
              ),
              Divider(),
              Text(
                'Tổng doanh thu trong năm ${_selectedYear}: ${formatNumber(total)}',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.greenAccent.shade700,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              )
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Đóng'),
            ),
          ],
        );
      },
    );
  }

  void showErrorMessage() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Failed to fetch data from Firestore. Please try again.'),
        duration: Duration(seconds: 3),
      ),
    );
  }

  DateTime _getDateTime(String monthYear) {
    final parts = monthYear.split('/');
    final month = int.parse(parts[0]);
    final year = int.parse(parts[1]);
    return DateTime(year, month);
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
              return Text('Error: ${snapshot.error}');
            }
            if (snapshot.hasData) {
              List<AppointmentSchedule> appointmentSchedules = snapshot.data!;
              if (appointmentSchedules.isEmpty) {
                return const SizedBox(
                  height: 600,
                  child: Center(child: Text('No appointments available')),
                );
              }
              Map<String, double> monthlyRevenue = {};
              for (AppointmentSchedule appointment in appointmentSchedules) {
                DateTime? paymentTime = appointment.paymentStartTime;
                String monthYear = '${paymentTime?.month}/${paymentTime?.year}';
                DateTime dateTime = _getDateTime(monthYear);
                User? currentUser = _auth.currentUser;
                if (dateTime.year == _selectedYear &&
                    appointment.doctorInfo?.uid == currentUser?.uid) {
                  num serviceFee = appointment.doctorInfo?.serviceFee ?? 0.0;
                  monthlyRevenue[monthYear] =
                      (monthlyRevenue[monthYear] ?? 0.0) + serviceFee;
                }
              }
              // Sắp xếp lại tháng
              monthlyRevenue = Map.fromEntries(monthlyRevenue.entries.toList()
                ..sort((a, b) =>
                    _getDateTime(a.key).compareTo(_getDateTime(b.key))));
              print('Monthly Revenue: $monthlyRevenue');
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 15, vertical: 10),
                    child: Row(
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            showDataDialog(monthlyRevenue);
                          },
                          child: const Text('Doanh thu các tháng trong năm'),
                        ),
                        const SizedBox(width: 16),
                        const Spacer(),
                        DropdownButton<int>(
                          value: _selectedYear,
                          items: List.generate(10, (index) {
                            int year = DateTime.now().year - index + 2;
                            return DropdownMenuItem<int>(
                              value: year,
                              child: Text(year.toString()),
                            );
                          }),
                          onChanged: (year) {
                            setState(() {
                              _selectedYear = year!;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                  Container(
                    width: 400,
                    height: 600,
                    margin: const EdgeInsets.symmetric(horizontal: 10),
                    child: LineChart(
                      LineChartData(
                        minX: 1,
                        maxX: 12,
                        minY: 0,
                        maxY: monthlyRevenue.values.isNotEmpty
                            ? monthlyRevenue.values
                                .reduce((a, b) => a > b ? a : b)
                            : 0,
                        titlesData: const FlTitlesData(
                          show: true,
                          bottomTitles: AxisTitles(
                            axisNameWidget: Text(
                              'Tháng',
                              style: TextStyle(fontSize: 15, height: 1.5),
                            ),
                            axisNameSize: 22,
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 25,
                              interval: 1,
                            ),
                          ),
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 50,
                            ),
                          ),
                          rightTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 50,
                            ),
                          ),
                        ),
                        gridData: const FlGridData(
                          show: true,
                        ),
                        borderData: FlBorderData(
                          border: Border.all(color: Colors.black),
                        ),
                        lineBarsData: [
                          LineChartBarData(
                            spots: monthlyRevenue.entries
                                .where((entry) =>
                                    _getDateTime(entry.key).year ==
                                    _selectedYear)
                                .map((entry) => FlSpot(
                                      _getDateTime(entry.key).month.toDouble(),
                                      entry.value.toDouble(),
                                    ))
                                .toList(),
                            //custom
                            isCurved: true,
                            color: Colors.blue,
                            barWidth: 4,
                            belowBarData: BarAreaData(
                                show: true,
                                color: Colors.blue.withOpacity(0.3)),
                            dotData: const FlDotData(show: true),
                          ),
                        ],
                      ),
                    ),
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

  @override
  void dispose() {
    // _appointmentScheduleController.close();
    super.dispose();
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
}
