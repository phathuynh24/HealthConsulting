import 'dart:async';

import 'package:assist_health/models/other/appointment_schedule.dart';
import 'package:assist_health/others/methods.dart';
import 'package:assist_health/others/theme.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class DoctorChartScreen extends StatefulWidget {
  const DoctorChartScreen({Key? key}) : super(key: key);

  @override
  State<DoctorChartScreen> createState() => _DoctorChartScreenState();
}

class _DoctorChartScreenState extends State<DoctorChartScreen> {
  final StreamController<List<AppointmentSchedule>> _appointmentScheduleController =
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
        _appointmentScheduleController!.addStream(
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
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Thống kê doanh thu hàng tháng'),
          content: Column(
            children: monthlyRevenue.entries
                .map((entry) =>
                    Text('${entry.key}: ${entry.value.toStringAsFixed(2)}'))
                .toList(),
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
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
          'Đồ thị doanh thu bác sĩ',
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
        child: Container(
          child: StreamBuilder<List<AppointmentSchedule>>(
            stream: _appointmentScheduleController!.stream,
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
                  if (dateTime.year == _selectedYear && appointment.doctorInfo?.uid == currentUser?.uid) {
                    num serviceFee = appointment.doctorInfo?.serviceFee ?? 0.0;
                    monthlyRevenue[monthYear] = (monthlyRevenue[monthYear] ?? 0.0) + serviceFee;
                  }
                }
                // Sắp xếp lại tháng
                monthlyRevenue = Map.fromEntries(monthlyRevenue.entries.toList()
                  ..sort((a, b) => _getDateTime(a.key).compareTo(_getDateTime(b.key))));
                print('Monthly Revenue: $monthlyRevenue');
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            showDataDialog(monthlyRevenue);
                          },
                          child: const Text('Doanh thu hàng tháng'),
                        ),
                        const SizedBox(width: 16),
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
                    const SizedBox(height: 18),
                    Container(
                      width: 400,
                      height: 600,
                      child: LineChart(
                        LineChartData(
                          minX: 1,
                          maxX: 12,
                          minY: 0,
                          maxY: monthlyRevenue.values.isNotEmpty
                              ? monthlyRevenue.values.reduce((a, b) => a > b ? a : b)
                              : 0,
                          titlesData: FlTitlesData(
                            show: true,
                            bottomTitles: AxisTitles(
                              axisNameWidget: const Text('Tháng'),
                              sideTitles: SideTitles(
                                showTitles: true,
                                interval: 1,
                              ),
                            ),
                          ),
                          gridData: FlGridData(
                            show: false,
                          ),
                          borderData: FlBorderData(
                            border: Border.all(color: Colors.black),
                          ),
                          lineBarsData: [
                            LineChartBarData(
                              spots: monthlyRevenue.entries
                                  .where((entry) =>
                                      _getDateTime(entry.key).year == _selectedYear)
                                  .map((entry) => FlSpot(
                                    _getDateTime(entry.key).month.toDouble(),
                                    entry.value.toDouble(),
                                  ))
                                  .toList(),
                              //custom
                              isCurved: true,
                              color: Colors.blue,
                              barWidth: 4,
                              belowBarData: BarAreaData(show: true, color: Colors.blue.withOpacity(0.3)),
                              dotData: FlDotData(show: true),
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
      ),
    );
  }

  @override
  void dispose() {
    // _appointmentScheduleController.close();
    super.dispose();
  }
}
