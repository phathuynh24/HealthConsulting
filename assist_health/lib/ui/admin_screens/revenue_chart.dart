import 'dart:async';

import 'package:assist_health/models/other/appointment_schedule.dart';
import 'package:assist_health/others/methods.dart';
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

  // String getMonthName(dynamic monthIndex) {
  //   final monthNames = [
  //     'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
  //   ];
  //   return monthNames[(monthIndex is double ? monthIndex.toInt() : monthIndex) - 1];
  // }

  int getMonthIndex(String monthYear) {
    final parts = monthYear.split('/');
    return int.parse(parts[0]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Revenue Chart'),
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
                  num serviceFee = appointment.doctorInfo?.serviceFee ?? 0.0;
                  monthlyRevenue[monthYear] = (monthlyRevenue[monthYear] ?? 0.0) + serviceFee;
                }
                print('Monthly Revenue: $monthlyRevenue');

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        showDataDialog(monthlyRevenue);
                      },
                      child: Text('Show Monthly Revenue'),
                    ),
                    SizedBox(height: 18),
                    // Adjusted the height and width constraints for the LineChart
                    Container(
                     width: 400, // Set the width to take the available space
                      height: 600, // Adjust this value as needed
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
                              axisNameWidget: const Text('Month'),

                              sideTitles: SideTitles(
                                showTitles: true,
                                 interval: 1,
                                 ),
                            ),
                            // leftTitles: AxisTitles(
                            //   axisNameWidget: const Text('Revenue'),
                            //   sideTitles: SideTitles(showTitles: true, reservedSize: 1),
                            // ),
                            //  rightTitles: AxisTitles(
                              
                            //   sideTitles: SideTitles(showTitles: false, reservedSize: 1),
                            // ),
                          ),
                          gridData: FlGridData(
                            show: false,
                          ),
                          borderData: FlBorderData(
                            show: true,
                          ),
                          lineBarsData: [
                            LineChartBarData(
                              spots: monthlyRevenue.entries
                                  .map((entry) => FlSpot(
                                    getMonthIndex(entry.key).toDouble(),
                                    entry.value.toDouble(),
                                  ))
                                  .toList(),
                              isCurved: true,
                              color: Colors.blue,
                              barWidth: 4,
                              dotData: FlDotData(show: false),
                              belowBarData: BarAreaData(
                                show: true,
                                color: Colors.blue.withOpacity(0.3),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              } else {
                return const SizedBox(
                  height: 600,
                  child: Center(child: CircularProgressIndicator()),
                );
              }
            },
          ),
        ),
      ),
    );
  }
}
