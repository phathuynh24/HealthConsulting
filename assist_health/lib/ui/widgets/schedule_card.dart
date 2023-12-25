import 'dart:developer';

import 'package:agora_rtc_engine/rtc_engine.dart';
import 'package:assist_health/models/other/appointment_schedule.dart';
import 'package:assist_health/others/methods.dart';
import 'package:assist_health/others/theme.dart';
import 'package:assist_health/video_call/pages/call.dart';
import 'package:dots_indicator/dots_indicator.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:permission_handler/permission_handler.dart';

// ignore: must_be_immutable
class ScheduleCard extends StatelessWidget {
  AppointmentSchedule appointmentSchedule;
  ScheduleCard({required this.appointmentSchedule, super.key});
  final String _channel = 'video_call';
  final ClientRole _role = ClientRole.Broadcaster;
  @override
  Widget build(BuildContext context) {
    initializeDateFormatting('vi_VN', null);
    String appointmentDate = DateFormat('dd/MM/yyyy', 'vi_VN')
        .format(appointmentSchedule.selectedDate!)
        .toString();
    String appointmentStartTime =
        '${appointmentSchedule.time!} - $appointmentDate';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.symmetric(vertical: 4),
            padding: const EdgeInsets.symmetric(vertical: 5),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.shade100,
                  blurRadius: 2,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: SizedBox(
              width: MediaQuery.of(context).size.width,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 15,
                      vertical: 4,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'STT 1',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Themes.gradientDeepClr,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.only(
                              left: 2, right: 8, top: 4, bottom: 4),
                          decoration: BoxDecoration(
                              color: getStatusColor(appointmentSchedule.status!)
                                  .withOpacity(0.2),
                              borderRadius: BorderRadius.circular(30)),
                          child: Row(
                            children: [
                              DotsIndicator(
                                dotsCount: 1,
                                decorator: DotsDecorator(
                                  activeColor: getStatusColor(
                                      appointmentSchedule.status!),
                                  activeSize: const Size(10, 10),
                                ),
                              ),
                              Text(
                                appointmentSchedule.status!,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: getStatusColor(
                                      appointmentSchedule.status!),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Divider(
                    color: Colors.grey.withOpacity(0.3),
                    thickness: 0.7,
                    height: 10,
                  ),
                  const SizedBox(height: 5),
                  ListTile(
                    title: Text(
                      appointmentSchedule.doctorInfo!.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 15,
                      ),
                    ),
                    trailing: CircleAvatar(
                      radius: 25,
                      backgroundImage: NetworkImage(
                          appointmentSchedule.doctorInfo!.imageURL),
                    ),
                  ),
                  const SizedBox(
                    height: 4,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 15,
                      vertical: 4,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Giờ khám',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade700,
                          ),
                        ),
                        Text(
                          appointmentStartTime,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey.shade900,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 15,
                      vertical: 4,
                    ),
                    child: Row(
                      children: [
                        Text(
                          'Chuyên khoa',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade700,
                          ),
                        ),
                        Expanded(
                          child: Text(
                            getAllOfSpecialties(
                                appointmentSchedule.doctorInfo!.specialty),
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey.shade900,
                            ),
                            textAlign: TextAlign.end,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 15,
                      vertical: 4,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Bệnh nhân',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade700,
                          ),
                        ),
                        Expanded(
                          child: Text(
                            appointmentSchedule.userProfile!.name,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey.shade900,
                            ),
                            textAlign: TextAlign.end,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 5),
                  (appointmentSchedule.status == 'Đã duyệt' &&
                          isWithinTimeRange(appointmentSchedule.time!,
                              appointmentSchedule.selectedDate!))
                      ? Center(
                          child: Container(
                            width: 200,
                            height: 45,
                            margin: EdgeInsets.only(top: 8, bottom: 10),
                            child: ElevatedButton(
                              onPressed: () {
                                onJoin(context);
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                              ),
                              child: Text(
                                'Vào cuộc gọi',
                                style: TextStyle(
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ),
                        )
                      : SizedBox(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  onJoin(BuildContext context) async {
    await _handleCameraAndMic(Permission.camera);
    await _handleCameraAndMic(Permission.microphone);
    await Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => CallPage(
                channelName: _channel,
                role: _role,
              )),
    );
  }

  Future<void> _handleCameraAndMic(Permission permission) async {
    final status = await permission.request();
    log(status.toString());
  }
}
