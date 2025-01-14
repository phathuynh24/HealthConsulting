// ignore_for_file: use_build_context_synchronously

import 'dart:developer';

import 'package:agora_rtc_engine/rtc_engine.dart';
import 'package:assist_health/src/config/videocall_settings.dart';
import 'package:assist_health/src/models/other/appointment_schedule.dart';
import 'package:assist_health/src/others/methods.dart';
import 'package:assist_health/src/others/theme.dart';
import 'package:assist_health/src/video_call/pages/call.dart';
import 'package:dots_indicator/dots_indicator.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:permission_handler/permission_handler.dart';

// ignore: must_be_immutable
class ScheduleCard extends StatelessWidget {
  AppointmentSchedule appointmentSchedule;
  ScheduleCard({required this.appointmentSchedule, super.key});
  final String _channel = channelName;
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
                        Text(
                          'STT ${findIntervalIndex(appointmentSchedule.time!)}',
                          style: const TextStyle(
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
                            margin: const EdgeInsets.only(top: 8, bottom: 10),
                            child: ElevatedButton(
                              onPressed: () {
                                _showInfoAppointmentBottomSheet(
                                    context, appointmentSchedule);
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                              ),
                              child: const Text(
                                'Vào cuộc gọi',
                                style: TextStyle(
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ),
                        )
                      : const SizedBox(),
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
                appointmentSchedule: appointmentSchedule,
                isDoctor: false,
                isUser: true,
              )),
    );
  }

  Future<void> _handleCameraAndMic(Permission permission) async {
    final status = await permission.request();
    log(status.toString());
  }

  void _showInfoAppointmentBottomSheet(
      BuildContext context, AppointmentSchedule appointmentSchedule) {
    showModalBottomSheet(
        context: context,
        backgroundColor: Colors.transparent,
        isScrollControlled: true,
        builder: (BuildContext context) {
          return StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Container(
                  height: 5,
                  width: 50,
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(2.5),
                    color: Colors.grey.shade300,
                  ),
                ),
                Container(
                  height: 520,
                  padding: const EdgeInsets.symmetric(
                    vertical: 15,
                  ),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                  ),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Text(
                          'Xác nhận thông tin',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w500),
                        ),
                        const SizedBox(
                          height: 15,
                        ),
                        Container(
                          height: 100,
                          margin: const EdgeInsets.symmetric(
                            horizontal: 15,
                            vertical: 5,
                          ),
                          padding: const EdgeInsets.only(
                              top: 15, right: 10, left: 10, bottom: 10),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: Colors.grey.withOpacity(0.6),
                              width: 0.5,
                            ),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Container(
                                margin: const EdgeInsets.only(
                                  right: 10,
                                ),
                                child: Column(
                                  children: [
                                    Stack(
                                      children: [
                                        SizedBox(
                                          width: 90,
                                          child: Column(
                                            children: [
                                              SizedBox(
                                                width: 70,
                                                height: 70,
                                                child: ClipOval(
                                                  child: Container(
                                                    decoration:
                                                        const BoxDecoration(
                                                      gradient: LinearGradient(
                                                        colors: [
                                                          Themes
                                                              .gradientDeepClr,
                                                          Themes
                                                              .gradientLightClr
                                                        ],
                                                        begin: Alignment
                                                            .bottomCenter,
                                                        end:
                                                            Alignment.topCenter,
                                                      ),
                                                    ),
                                                    child: (appointmentSchedule
                                                            .userProfile!
                                                            .image
                                                            .isEmpty)
                                                        ? Center(
                                                            child: Text(
                                                              getAbbreviatedName(
                                                                  appointmentSchedule
                                                                      .userProfile!
                                                                      .name),
                                                              style:
                                                                  const TextStyle(
                                                                color: Colors
                                                                    .white,
                                                                fontSize: 25,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                              ),
                                                            ),
                                                          )
                                                        : Image.network(
                                                            appointmentSchedule
                                                                .userProfile!
                                                                .image,
                                                            fit: BoxFit.cover,
                                                            errorBuilder:
                                                                (BuildContext context,
                                                                    Object
                                                                        exception,
                                                                    StackTrace?
                                                                        stackTrace) {
                                                            return const Center(
                                                              child: Icon(
                                                                CupertinoIcons
                                                                    .person_circle_fill,
                                                                size: 50,
                                                                color: Colors
                                                                    .white,
                                                              ),
                                                            );
                                                          }),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Positioned(
                                          top: 0,
                                          right: 0,
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        vertical: 2,
                                                        horizontal: 4),
                                                decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            15),
                                                    color: Themes
                                                        .gradientDeepClr
                                                        .withOpacity(0.9),
                                                    border: Border.all(
                                                      color: Colors.white,
                                                      width: 3,
                                                    )),
                                                child: Center(
                                                    child: Text(
                                                  appointmentSchedule
                                                      .userProfile!
                                                      .relationship,
                                                  style: const TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 12),
                                                )),
                                              ),
                                            ],
                                          ),
                                        )
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    appointmentSchedule.userProfile!.name,
                                    style: const TextStyle(
                                      color: Colors.black,
                                      fontSize: 14,
                                      height: 1.5,
                                    ),
                                  ),
                                  Text(
                                    '${appointmentSchedule.userProfile!.gender} - ${appointmentSchedule.userProfile!.doB}',
                                    style: const TextStyle(
                                      color: Colors.black87,
                                      fontSize: 15,
                                      height: 1.4,
                                    ),
                                  ),
                                  Text(
                                    appointmentSchedule.userProfile!.phone,
                                    style: const TextStyle(
                                      color: Colors.black,
                                      fontSize: 14,
                                      height: 1.5,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Container(
                          margin: const EdgeInsets.symmetric(
                            horizontal: 15,
                            vertical: 5,
                          ),
                          padding: const EdgeInsets.all(15),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: Colors.grey.withOpacity(0.6),
                              width: 0.5,
                            ),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Row(
                                children: [
                                  Icon(
                                    Icons.medical_information,
                                    size: 22,
                                    color: Colors.blueGrey,
                                  ),
                                  SizedBox(
                                    width: 5,
                                  ),
                                  Text(
                                    'Lý do khám, triệu chứng: ',
                                    style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w400),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Text(
                                appointmentSchedule.reasonForExamination! == ''
                                    ? 'Trống'
                                    : appointmentSchedule.reasonForExamination!,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: (appointmentSchedule
                                          .reasonForExamination!.isNotEmpty)
                                      ? Colors.blue
                                      : Colors.black,
                                ),
                              ),
                              Divider(
                                thickness: 0.5,
                                color: Colors.grey.shade400,
                                height: 20,
                              ),
                              const Row(
                                children: [
                                  Icon(
                                    FontAwesomeIcons.images,
                                    size: 18,
                                    color: Colors.blueGrey,
                                  ),
                                  SizedBox(
                                    width: 8,
                                  ),
                                  Text(
                                    'Hình ảnh, toa thuốc:',
                                    style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w400,
                                        height: 1.5),
                                  ),
                                ],
                              ),
                              (appointmentSchedule
                                      .listOfHealthInformationURLs!.isNotEmpty)
                                  ? Container(
                                      margin: const EdgeInsets.symmetric(
                                        vertical: 10,
                                      ),
                                      child: GridView.builder(
                                          padding: EdgeInsets.zero,
                                          scrollDirection: Axis.vertical,
                                          shrinkWrap: true,
                                          physics:
                                              const NeverScrollableScrollPhysics(),
                                          itemCount: appointmentSchedule
                                              .listOfHealthInformationURLs!
                                              .length,
                                          gridDelegate:
                                              const SliverGridDelegateWithFixedCrossAxisCount(
                                            crossAxisCount: 4,
                                            mainAxisSpacing: 6,
                                            crossAxisSpacing: 6,
                                            childAspectRatio: 1,
                                          ),
                                          itemBuilder: (context, index) {
                                            String url = appointmentSchedule
                                                    .listOfHealthInformationURLs![
                                                index];
                                            String extension =
                                                getExtensionFromURL(url)
                                                    .toLowerCase();

                                            return LayoutBuilder(builder:
                                                (BuildContext context,
                                                    BoxConstraints
                                                        constraints) {
                                              return Center(
                                                child: Container(
                                                  height:
                                                      constraints.maxWidth - 10,
                                                  width: constraints.maxHeight -
                                                      10,
                                                  decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            6),
                                                    color: Colors.grey,
                                                  ),
                                                  alignment: Alignment.center,
                                                  child: Column(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    children: [
                                                      if (extension == '')
                                                        const CircularProgressIndicator(),
                                                      if (extension == 'pdf')
                                                        const Icon(
                                                            Icons
                                                                .picture_as_pdf,
                                                            size: 50),
                                                      if (extension == 'doc' ||
                                                          extension == 'docx')
                                                        const Icon(
                                                            Icons.description,
                                                            size: 50),
                                                      if (extension == 'mp4')
                                                        const Icon(
                                                            Icons
                                                                .play_circle_filled,
                                                            size: 50),
                                                      if (extension == 'png' ||
                                                          extension == 'jpg' ||
                                                          extension == 'jpeg')
                                                        SizedBox(
                                                          height: constraints
                                                                  .maxWidth -
                                                              10,
                                                          width: constraints
                                                                  .maxHeight -
                                                              10,
                                                          child: ClipRRect(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        6),
                                                            child:
                                                                Image.network(
                                                              url,
                                                              fit: BoxFit.cover,
                                                            ),
                                                          ),
                                                        ),
                                                    ],
                                                  ),
                                                ),
                                              );
                                            });
                                          }),
                                    )
                                  : Container(
                                      margin: const EdgeInsets.only(
                                          top: 6, bottom: 10),
                                      child: const Text(
                                        'Trống',
                                        style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.black,
                                            fontWeight: FontWeight.w400),
                                      ),
                                    ),
                            ],
                          ),
                        ),
                      ]),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            Navigator.of(context).pop();
                          },
                          child: Container(
                            width: double.infinity,
                            height: 50,
                            margin: const EdgeInsets.only(
                              left: 20,
                              right: 10,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.grey.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Center(
                              child: Text(
                                'Đóng',
                                style: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.w500),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            Navigator.of(context).pop();
                            onJoin(context);
                          },
                          child: Container(
                            width: double.infinity,
                            height: 50,
                            margin: const EdgeInsets.only(
                              left: 10,
                              right: 20,
                            ),
                            decoration: BoxDecoration(
                              color: Themes.gradientDeepClr,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Center(
                              child: Text(
                                'Xác nhận',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w500),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          });
        });
  }

  String getExtensionFromURL(String url) {
    String start = 'appointment_schedule_files%';
    String end = '?';
    final startIndex = url.indexOf(start);
    final endIndex = url.indexOf(end, startIndex + start.length);

    if (startIndex != -1 && endIndex != -1) {
      return url.substring(startIndex + start.length, endIndex).split('.').last;
    }

    return '';
  }
}
