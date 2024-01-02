import 'dart:async';

import 'package:assist_health/models/other/appointment_schedule.dart';
import 'package:assist_health/others/methods.dart';
import 'package:assist_health/ui/admin_screens/doctor_list_revenue.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class RevenueChartScreen extends StatefulWidget {
  const RevenueChartScreen({Key? key}) : super(key: key);

  @override
  State<RevenueChartScreen> createState() => _RevenueChartScreenState();
}

class _RevenueChartScreenState extends State<RevenueChartScreen> {
  StreamController<List<AppointmentSchedule>>? _appointmentScheduleController =
      StreamController<List<AppointmentSchedule>>.broadcast();
  int _selectedYear = DateTime.now().year;

  @override
  void initState() {
    super.initState();
    _appointmentScheduleController!.addStream(getAllAppointmentSchdedules());
  }

  void showDataDialog(Map<String, double> monthlyRevenue) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Monthly Revenue Data'),
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
              child: Text('OK'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => DoctorListRevenue()),
                );
              },
              child: Text('Go to Doctor List'),
            ),
          ],
        );
      },
    );
  }

  void showErrorMessage() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
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
        title: Text('Sơ đồ doanh thu'),
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
                  String monthYear =
                      '${paymentTime?.month}/${paymentTime?.year}';
                  DateTime dateTime = _getDateTime(monthYear);
                  if (dateTime.year == _selectedYear) {
                    num serviceFee = appointment.doctorInfo?.serviceFee ?? 0.0;
                    monthlyRevenue[monthYear] =
                        (monthlyRevenue[monthYear] ?? 0.0) + serviceFee;
                  }
                }
                //Sắp xếp lại tháng
                monthlyRevenue = Map.fromEntries(monthlyRevenue.entries.toList()
                  ..sort((a, b) =>
                      _getDateTime(a.key).compareTo(_getDateTime(b.key))));
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
                          child: Text('Doanh thu theo tháng'),
                        ),
                        SizedBox(width: 16),
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
                    SizedBox(height: 18),
                    Container(
                      padding: EdgeInsets.all(8),
                      width: double.infinity,
                      height: 600,
                      child: LineChart(
                        LineChartData(
                          minX: 1,
                          maxX: 12,
                          minY: 0,
                          maxY: monthlyRevenue.values.isNotEmpty
                              ? monthlyRevenue.values
                                  .reduce((a, b) => a > b ? a : b)
                              : 0,
                          titlesData: FlTitlesData(
                            show: true,
                            bottomTitles: AxisTitles(
                              axisNameWidget: const Text(
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
                                      _getDateTime(entry.key).year ==
                                      _selectedYear)
                                  .map((entry) => FlSpot(
                                        _getDateTime(entry.key)
                                            .month
                                            .toDouble(),
                                        entry.value.toDouble(),
                                      ))
                                  .toList(),
                              isCurved: true,
                              color: Colors.blue,
                              barWidth: 4,
                              belowBarData: BarAreaData(
                                  show: true,
                                  color: Colors.blue.withOpacity(0.3)),
                              dotData: FlDotData(show: true),
                            ),
                          ],
                        ),
                      ),
                    )
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
    _appointmentScheduleController?.close();
    super.dispose();
  }
}
