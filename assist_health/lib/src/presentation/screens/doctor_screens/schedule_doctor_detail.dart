// ignore_for_file: use_build_context_synchronously, avoid_print

import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:agora_rtc_engine/rtc_engine.dart';
import 'package:assist_health/src/config/videocall_settings.dart';
import 'package:assist_health/src/models/other/appointment_schedule.dart';
import 'package:assist_health/src/models/user/user_profile.dart';
import 'package:assist_health/src/others/methods.dart';
import 'package:assist_health/src/others/theme.dart';
import 'package:assist_health/src/presentation/screens/doctor_screens/examination_results.dart';
import 'package:assist_health/src/presentation/screens/user_screens/chatroom_new.dart';
import 'package:assist_health/src/presentation/screens/user_screens/health_profile_detail.dart';
import 'package:assist_health/src/presentation/screens/user_screens/schedule_qr.dart';
import 'package:assist_health/src/widgets/half_circle.dart';
import 'package:assist_health/src/widgets/my_separator.dart';
import 'package:assist_health/src/video_call/pages/call.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:open_file/open_file.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

// ignore: must_be_immutable
class ScheduleDoctorDetail extends StatefulWidget {
  AppointmentSchedule appointmentSchedule;

  ScheduleDoctorDetail({required this.appointmentSchedule, super.key});
  @override
  State<ScheduleDoctorDetail> createState() => _ScheduleDoctorDetailState();
}

class _ScheduleDoctorDetailState extends State<ScheduleDoctorDetail> {
  AppointmentSchedule? _appointmentSchedule;
  int? _secondsRemaining;

  String? _buttonContext;

  final String _channel = channelName;
  final ClientRole _role = ClientRole.Broadcaster;

  @override
  void initState() {
    super.initState();
    _appointmentSchedule = widget.appointmentSchedule;
    loadFileFromStorage();
    if (_appointmentSchedule!.status == 'Đã duyệt' &&
        isWithinTimeRange(
            _appointmentSchedule!.time!, _appointmentSchedule!.selectedDate!)) {
      _buttonContext = 'Vào cuộc gọi';
    } else if (_appointmentSchedule!.status == 'Đã khám') {
      _buttonContext = 'Trả kết quả';
    }
    if (_appointmentSchedule!.paymentStatus == 'Thanh toán thành công' ||
        _appointmentSchedule!.paymentStatus == 'Thanh toán thất bại') {
      _secondsRemaining = 0;
      return;
    }

    _secondsRemaining =
        calculateSecondsFromNow(_appointmentSchedule!.paymentStartTime!);
    if (_appointmentSchedule!.paymentStatus == 'Đã duyệt') {
      checkOutOfDateApproved();
    }
  }

  void checkOutOfDateApproved() {
    setState(() {
      if (_appointmentSchedule!.status == 'Đã duyệt' &&
          isAfterEndTime(_appointmentSchedule!.time!,
              _appointmentSchedule!.selectedDate!)) {
        if (_appointmentSchedule!.isExamined!) {
          _appointmentSchedule!.status = 'Đã khám';
        } else {
          _appointmentSchedule!.status = 'Quá hẹn';
        }
        _appointmentSchedule!
            .updateAppointmentStatus(_appointmentSchedule!.status!);
      }
    });
  }

  String formatTime(int seconds) {
    int hours = seconds ~/ 3600;
    int minutes = (seconds % 3600) ~/ 60;
    int remainingSeconds = seconds % 60;
    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Themes.backgroundClr,
      appBar: AppBar(
        foregroundColor: Colors.white,
        title: const Text(
          'Chi tiết lịch khám',
          style: TextStyle(fontSize: 20),
        ),
        elevation: 0,
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
          color: Colors.blueAccent.withOpacity(0.1),
          child: Column(
            children: [
              Container(
                  color: Colors.white,
                  margin: const EdgeInsets.only(
                    bottom: 5,
                  ),
                  padding: const EdgeInsets.only(
                      top: 10, left: 15, right: 15, bottom: 10),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(10),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.folder_shared,
                              size: 18,
                              color: Colors.grey,
                            ),
                            const SizedBox(
                              width: 10,
                            ),
                            Text(
                              _appointmentSchedule!.appointmentCode!,
                              style: const TextStyle(
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(
                              width: 10,
                            ),
                            GestureDetector(
                              onTap: () {
                                final data = ClipboardData(
                                    text:
                                        _appointmentSchedule!.appointmentCode!);
                                Clipboard.setData(data);
                                showToastMessage(
                                    context, 'Mã lịch khám đã được sao chép');
                              },
                              child: const Icon(
                                Icons.content_copy,
                                size: 18,
                              ),
                            ),
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                  color: getStatusColor(
                                          _appointmentSchedule!.status!)
                                      .withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(30)),
                              child: Text(
                                _appointmentSchedule!.status!,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: getStatusColor(
                                      _appointmentSchedule!.status!),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                            top: 10, bottom: 15, left: 10, right: 10),
                        child: Row(
                          children: [
                            const Icon(
                              FontAwesomeIcons.solidPenToSquare,
                              size: 16,
                              color: Colors.grey,
                            ),
                            const SizedBox(
                              width: 10,
                            ),
                            const Text(
                              'Ngày tạo phiếu',
                              style: TextStyle(
                                fontSize: 14,
                              ),
                            ),
                            const Spacer(),
                            Center(
                              child: Text(
                                _appointmentSchedule!.receivedAppointmentTime!,
                                style: const TextStyle(
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(10),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.person,
                              size: 18,
                              color: Colors.grey,
                            ),
                            const SizedBox(
                              width: 8,
                            ),
                            GestureDetector(
                              onTap: () {
                                _showDetailProfileBottomSheet(context,
                                    _appointmentSchedule!.userProfile!);
                              },
                              child: Text(
                                _appointmentSchedule!.userProfile!.name,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const Spacer(),
                            Center(
                              child: Text(
                                'STT ${findIntervalIndex(_appointmentSchedule!.time!)}',
                                style: const TextStyle(
                                  color: Themes.gradientDeepClr,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  )),
              Container(
                  color: Colors.white,
                  margin: const EdgeInsets.only(
                    bottom: 5,
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 15,
                    vertical: 5,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 7,
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          FontAwesomeIcons.calendarCheck,
                          size: 19,
                          color: Colors.blue,
                        ),
                        const SizedBox(
                          width: 6,
                        ),
                        const Text(
                          'Giờ hẹn:',
                          style: TextStyle(
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(5),
                            color: Colors.greenAccent.shade400.withOpacity(0.2),
                          ),
                          child: Row(children: [
                            Icon(
                              Icons.watch_later_outlined,
                              size: 20,
                              color: Colors.green.shade700,
                            ),
                            const SizedBox(
                              width: 5,
                            ),
                            Text(
                              _appointmentSchedule!.time!,
                              style: TextStyle(
                                  fontSize: 13.5,
                                  color: Colors.green.shade700,
                                  fontWeight: FontWeight.bold),
                            ),
                          ]),
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(5),
                            color: Colors.greenAccent.shade400.withOpacity(0.2),
                          ),
                          child: Row(children: [
                            Icon(
                              Icons.watch_later_outlined,
                              size: 20,
                              color: Colors.green.shade700,
                            ),
                            const SizedBox(
                              width: 5,
                            ),
                            Text(
                              DateFormat('dd/MM/yyyy', 'vi_VN')
                                  .format(_appointmentSchedule!.selectedDate!)
                                  .toString(),
                              style: TextStyle(
                                  fontSize: 13.5,
                                  color: Colors.green.shade700,
                                  fontWeight: FontWeight.bold),
                            ),
                          ]),
                        ),
                      ],
                    ),
                  )),
              Container(
                color: Colors.white,
                padding: const EdgeInsets.all(15),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.lightBlueAccent.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    children: [
                      Container(
                        width: double.infinity,
                        height: 170,
                        margin: const EdgeInsets.only(
                          left: 15,
                          right: 15,
                          top: 15,
                          bottom: 5,
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(15),
                          child: Image.asset(
                            'assets/sample_image.png',
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      Divider(
                        thickness: 0.7,
                        color: Colors.grey.shade400,
                        indent: 15,
                        endIndent: 15,
                      ),

                      Container(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 15,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 15, vertical: 10),
                              child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      '${_appointmentSchedule!.doctorInfo!.careerTitiles != '' ? _appointmentSchedule!.doctorInfo!.careerTitiles : 'Bác sĩ'} ${_appointmentSchedule!.doctorInfo!.name}',
                                      style: const TextStyle(
                                        fontSize: 14,
                                      ),
                                    ),
                                    SizedBox(
                                      width: 50,
                                      height: 50,
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(15),
                                        child: Image.network(
                                          _appointmentSchedule!
                                              .doctorInfo!.imageURL,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                  ]),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                HalfCircle(
                                    height: 14,
                                    weight: 8,
                                    color: const Color(0xFFECF9FF),
                                    isLeft: true),
                                const SizedBox(
                                  width: 6,
                                ),
                                MySeparator(color: Colors.grey.shade400),
                                const SizedBox(
                                  width: 6,
                                ),
                                HalfCircle(
                                    height: 14,
                                    weight: 8,
                                    color: const Color(0xFFECF9FF),
                                    isLeft: false),
                              ],
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 15, vertical: 20),
                              child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    const SizedBox(
                                      width: 140,
                                      child: Text(
                                        'Chuyên khoa',
                                        style: TextStyle(
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: Text(
                                        getAllOfSpecialties(
                                            _appointmentSchedule!
                                                .doctorInfo!.specialty),
                                        style: const TextStyle(
                                          fontSize: 14,
                                        ),
                                        textAlign: TextAlign.right,
                                      ),
                                    ),
                                  ]),
                            ),
                            if (_appointmentSchedule!.status == 'Đã duyệt' ||
                                _appointmentSchedule!.status == 'Quá hẹn')
                              GestureDetector(
                                onTap: () {
                                  goToChatRoom();
                                },
                                child: Container(
                                  width: double.infinity,
                                  margin: const EdgeInsets.only(
                                      bottom: 16, left: 16, right: 16),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 16),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(30),
                                    color:
                                        Colors.lightBlueAccent.withOpacity(0.1),
                                  ),
                                  child: const Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        FontAwesomeIcons.solidCommentDots,
                                        color: Themes.gradientDeepClr,
                                      ),
                                      SizedBox(
                                        width: 10,
                                      ),
                                      Text(
                                        'Nhắn tin với bệnh nhân',
                                        style: TextStyle(
                                          color: Themes.gradientDeepClr,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),

                      // Lý do khám
                      if (_isNotEmptyReasonForExamination())
                        Container(
                          padding: const EdgeInsets.only(
                            top: 10,
                          ),
                          margin: const EdgeInsets.symmetric(
                              horizontal: 15, vertical: 5),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: Colors.white,
                          ),
                          child: Column(
                            children: [
                              Container(
                                width: double.infinity,
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 15),
                                child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Row(
                                        children: [
                                          Icon(
                                            Icons.medical_information,
                                            size: 22,
                                            color: Colors.blue,
                                          ),
                                          SizedBox(
                                            width: 5,
                                          ),
                                          Text(
                                            'Lý do khám, triệu chứng',
                                            style: TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w400),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        _appointmentSchedule!
                                                    .reasonForExamination! ==
                                                ''
                                            ? 'Trống'
                                            : _appointmentSchedule!
                                                .reasonForExamination!,
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.black,
                                        ),
                                      ),
                                      Divider(
                                        thickness: 0.5,
                                        color: Colors.grey.shade400,
                                        height: 30,
                                      ),
                                      const Row(
                                        children: [
                                          Icon(
                                            FontAwesomeIcons.images,
                                            size: 18,
                                            color: Colors.blue,
                                          ),
                                          SizedBox(
                                            width: 8,
                                          ),
                                          Text(
                                            'Hình ảnh, toa thuốc',
                                            style: TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w400),
                                          ),
                                        ],
                                      ),
                                      (_appointmentSchedule!
                                              .listOfHealthInformationURLs!
                                              .isNotEmpty)
                                          ? Container(
                                              margin:
                                                  const EdgeInsets.symmetric(
                                                vertical: 10,
                                              ),
                                              child: GridView.builder(
                                                  padding: EdgeInsets.zero,
                                                  scrollDirection:
                                                      Axis.vertical,
                                                  shrinkWrap: true,
                                                  physics:
                                                      const NeverScrollableScrollPhysics(),
                                                  itemCount: _appointmentSchedule!
                                                      .listOfHealthInformationURLs!
                                                      .length,
                                                  gridDelegate:
                                                      const SliverGridDelegateWithFixedCrossAxisCount(
                                                    crossAxisCount: 4,
                                                    mainAxisSpacing: 6,
                                                    crossAxisSpacing: 6,
                                                    childAspectRatio: 1,
                                                  ),
                                                  itemBuilder:
                                                      (context, index) {
                                                    if (_appointmentSchedule!
                                                        .listOfHealthInformationFiles!
                                                        .isEmpty) {
                                                      return LayoutBuilder(
                                                          builder: (BuildContext
                                                                  context,
                                                              BoxConstraints
                                                                  constraints) {
                                                        return Center(
                                                          child: Container(
                                                            height: constraints
                                                                    .maxWidth -
                                                                10,
                                                            width: constraints
                                                                    .maxHeight -
                                                                10,
                                                            decoration:
                                                                BoxDecoration(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          6),
                                                              color: Colors.grey
                                                                  .shade300,
                                                            ),
                                                            alignment: Alignment
                                                                .center,
                                                            child: const SizedBox(
                                                                height: 25,
                                                                width: 25,
                                                                child:
                                                                    CircularProgressIndicator()),
                                                          ),
                                                        );
                                                      });
                                                    }

                                                    File file =
                                                        _appointmentSchedule!
                                                                .listOfHealthInformationFiles![
                                                            index];
                                                    String extension = file.path
                                                        .split('.')
                                                        .last
                                                        .toLowerCase();

                                                    return GestureDetector(
                                                      onTap: () {
                                                        OpenFile.open(
                                                            file.path);
                                                      },
                                                      child: LayoutBuilder(
                                                          builder: (BuildContext
                                                                  context,
                                                              BoxConstraints
                                                                  constraints) {
                                                        return Center(
                                                          child: Container(
                                                            height: constraints
                                                                    .maxWidth -
                                                                10,
                                                            width: constraints
                                                                    .maxHeight -
                                                                10,
                                                            decoration:
                                                                BoxDecoration(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          6),
                                                              color:
                                                                  Colors.grey,
                                                            ),
                                                            alignment: Alignment
                                                                .center,
                                                            child: Column(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .center,
                                                              children: [
                                                                if (extension ==
                                                                    '')
                                                                  const CircularProgressIndicator(),
                                                                if (extension ==
                                                                    'pdf')
                                                                  const Icon(
                                                                      Icons
                                                                          .picture_as_pdf,
                                                                      size: 50),
                                                                if (extension ==
                                                                        'doc' ||
                                                                    extension ==
                                                                        'docx')
                                                                  const Icon(
                                                                      Icons
                                                                          .description,
                                                                      size: 50),
                                                                if (extension ==
                                                                    'mp4')
                                                                  const Icon(
                                                                      Icons
                                                                          .play_circle_filled,
                                                                      size: 50),
                                                                if (extension == 'png' ||
                                                                    extension ==
                                                                        'jpg' ||
                                                                    extension ==
                                                                        'jpeg')
                                                                  SizedBox(
                                                                    height:
                                                                        constraints.maxWidth -
                                                                            10,
                                                                    width: constraints
                                                                            .maxHeight -
                                                                        10,
                                                                    child:
                                                                        ClipRRect(
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              6),
                                                                      child: Image
                                                                          .file(
                                                                        file,
                                                                        fit: BoxFit
                                                                            .cover,
                                                                      ),
                                                                    ),
                                                                  ),
                                                              ],
                                                            ),
                                                          ),
                                                        );
                                                      }),
                                                    );
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
                                                    fontWeight:
                                                        FontWeight.w400),
                                              ),
                                            ),
                                    ]),
                              ),
                            ],
                          ),
                        ),

                      // Thanh toán
                      Container(
                          padding: const EdgeInsets.only(
                            top: 10,
                          ),
                          margin: const EdgeInsets.only(
                              top: 5, bottom: 15, left: 15, right: 15),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: Colors.white,
                          ),
                          child: Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 15,
                                  vertical: 10,
                                ),
                                child: Row(
                                  children: [
                                    const Icon(
                                      FontAwesomeIcons.wallet,
                                      size: 18,
                                      color: Colors.blue,
                                    ),
                                    const SizedBox(
                                      width: 10,
                                    ),
                                    const Text(
                                      'Thanh toán',
                                      style: TextStyle(
                                        fontSize: 14,
                                      ),
                                    ),
                                    const Spacer(),
                                    Text(
                                      _appointmentSchedule!.paymentStatus!,
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: getPaymentStatusColor(
                                            _appointmentSchedule!
                                                .paymentStatus!),
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const Padding(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 15,
                                  vertical: 10,
                                ),
                                child: Row(
                                  children: [
                                    Text(
                                      'Phương thức thanh toán',
                                      style: TextStyle(
                                        fontSize: 14,
                                      ),
                                    ),
                                    Spacer(),
                                    Text(
                                      'Quét mã QR',
                                      style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                              ),
                              (_secondsRemaining! > 0)
                                  ? Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 15,
                                        vertical: 10,
                                      ),
                                      child: Row(
                                        children: [
                                          const Text(
                                            'Thời hạn thanh toán',
                                            style: TextStyle(
                                              fontSize: 14,
                                            ),
                                          ),
                                          const Spacer(),
                                          Text(
                                            formatTime(_secondsRemaining!),
                                            style: const TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.red,
                                            ),
                                          ),
                                        ],
                                      ),
                                    )
                                  : const SizedBox(),
                              (_secondsRemaining! > 0)
                                  ? GestureDetector(
                                      onTap: () {
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    ScheduleQRPage(
                                                      serviceFee:
                                                          _appointmentSchedule!
                                                              .doctorInfo!
                                                              .serviceFee,
                                                      transferContent:
                                                          _appointmentSchedule!
                                                              .transferContent!,
                                                      linkQRCode:
                                                          _appointmentSchedule!
                                                              .linkQRCode!,
                                                    )));
                                      },
                                      child: Container(
                                        margin: const EdgeInsets.only(
                                            left: 15,
                                            right: 15,
                                            bottom: 10,
                                            top: 5),
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 15,
                                          vertical: 10,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.blueAccent.shade100
                                              .withOpacity(0.2),
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                        child: const Text(
                                          'Nếu chưa thanh toán, hãy nhấn vào đây để tiếp tục thanh toán.',
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.blueAccent,
                                            height: 1.5,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                    )
                                  : const SizedBox(),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  HalfCircle(
                                      height: 14,
                                      weight: 8,
                                      color: const Color(0xFFECF9FF),
                                      isLeft: true),
                                  const SizedBox(
                                    width: 6,
                                  ),
                                  MySeparator(color: Colors.grey.shade400),
                                  const SizedBox(
                                    width: 6,
                                  ),
                                  HalfCircle(
                                      height: 14,
                                      weight: 8,
                                      color: const Color(0xFFECF9FF),
                                      isLeft: false),
                                ],
                              ),
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(
                                    vertical: 15, horizontal: 15),
                                decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(15)),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        const Text(
                                          'Tổng thanh toán',
                                          style: TextStyle(
                                              fontSize: 15,
                                              color: Colors.black87,
                                              fontWeight: FontWeight.w500),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          '${NumberFormat("#,##0", "en_US").format(int.parse((_appointmentSchedule!.doctorInfo!.serviceFee).toInt().toString()))} VNĐ',
                                          style: const TextStyle(
                                              fontSize: 15,
                                              color: Colors.red,
                                              fontWeight: FontWeight.w500),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          )),
                    ],
                  ),
                ),
              ),
              (_buttonContext == 'Hủy lịch khám')
                  ? GestureDetector(
                      onTap: () {
                        showDialog(
                          barrierDismissible: false,
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: const Text('Xác nhận'),
                              content: const Text(
                                  'Bạn có chắc chắn muốn hủy cuộc hẹn không?'),
                              actions: [
                                TextButton(
                                  child: const Text('Không'),
                                  onPressed: () {
                                    Navigator.of(context)
                                        .pop(); // Đóng hộp thoại
                                  },
                                ),
                                TextButton(
                                  child: const Text('Xác nhận'),
                                  onPressed: () {
                                    // Thực hiện hành động khi xác nhận
                                    setState(() {
                                      _appointmentSchedule!.status = 'Đã hủy';
                                      _appointmentSchedule!
                                          .updateAppointmentStatus(
                                              _appointmentSchedule!.status!);
                                      _buttonContext = 'Đặt khám lại';
                                    });

                                    Navigator.of(context)
                                        .pop(); // Đóng hộp thoại
                                  },
                                ),
                              ],
                            );
                          },
                        );
                      },
                      child: Container(
                        decoration: BoxDecoration(
                            border: Border.all(color: Colors.black),
                            borderRadius: BorderRadius.circular(10)),
                        width: double.infinity,
                        alignment: Alignment.center,
                        margin: const EdgeInsets.all(15),
                        padding: const EdgeInsets.all(15),
                        child: Text(
                          _buttonContext!,
                          style: const TextStyle(
                            color: Colors.black,
                          ),
                        ),
                      ),
                    )
                  : const SizedBox(),
            ],
          ),
        ),
      ),
      bottomNavigationBar: (_buttonContext == 'Trả kết quả' ||
              _buttonContext == 'Vào cuộc gọi')
          ? Container(
              height: 70,
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 10),
              decoration: const BoxDecoration(
                border: Border(
                  top: BorderSide(
                    color: Colors.blueGrey,
                    width: 0.2,
                  ),
                ),
              ),
              child: Row(
                children: [
                  if (_appointmentSchedule!.isResult! == false)
                    Expanded(
                      child: GestureDetector(
                        onTap: () async {
                          if (_buttonContext == 'Trả kết quả') {
                            final result = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        ExaminationResultsScreen(
                                          appointmentSchedule:
                                              _appointmentSchedule!,
                                          isFromCall: false,
                                        )));
                            if (result) {
                              setState(() {
                                _appointmentSchedule!.isResult = true;
                              });
                            }
                          }
                          if (_buttonContext == 'Vào cuộc gọi') {
                            onJoin();
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.all(13),
                          margin: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: (_buttonContext == 'Vào cuộc gọi')
                                ? Colors.green
                                : Themes.gradientDeepClr,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            _buttonContext!,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                    ),
                  (_appointmentSchedule!.status == 'Đã khám')
                      ? Expanded(
                          child: GestureDetector(
                            onTap: () async {
                              if (_appointmentSchedule!.idFeedback != '') {
                                showFeedbackDialog(
                                    context, _appointmentSchedule!.idFeedback!);
                              } else {
                                showNotificationDialog(context);
                              }
                            },
                            child: Container(
                              padding: const EdgeInsets.all(13),
                              margin: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: (_appointmentSchedule!.idFeedback == '')
                                    ? Colors.grey.shade400
                                    : Themes.gradientDeepClr,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              alignment: Alignment.center,
                              child: const Text(
                                'Xem đánh giá',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ),
                        )
                      : const SizedBox(),
                ],
              ),
            )
          : const SizedBox(),
    );
  }

  void showNotificationDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text(
          'Thông báo',
          style: TextStyle(
            fontSize: 18,
          ),
          textAlign: TextAlign.center,
        ),
        content: const Text(
          'Chưa có đánh giá từ bệnh nhân.',
          style: TextStyle(
            fontSize: 16,
          ),
          textAlign: TextAlign.center,
        ),
        actions: [
          TextButton(
            child: const Text('Đồng ý'),
            onPressed: () {
              Navigator.of(context).pop(); // Đóng thông báo
            },
          ),
        ],
      ),
    );
  }

  void _showDetailProfileBottomSheet(
      BuildContext context, UserProfile userProfile) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
          return Container(
            color: Colors.transparent,
            child: Column(
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
                  height: 610,
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
                  child: Stack(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const Text(
                            'Chi tiết hồ sơ',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w500),
                          ),
                          Container(
                            width: MediaQuery.of(context).size.width * 0.9,
                            margin: const EdgeInsets.all(20),
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: Colors.grey.shade300,
                                  width: 1,
                                )),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(
                                  height: 5,
                                ),
                                Row(
                                  children: [
                                    const Text(
                                      'Mã bệnh nhân:',
                                      style: TextStyle(
                                        color: Colors.black87,
                                        fontSize: 14,
                                      ),
                                    ),
                                    const Spacer(),
                                    Text(
                                      userProfile.idProfile,
                                      style: const TextStyle(
                                          color: Colors.black87,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500),
                                    ),
                                  ],
                                ),
                                const SizedBox(
                                  height: 20,
                                ),
                                Row(
                                  children: [
                                    const Text(
                                      'Họ và tên:',
                                      style: TextStyle(
                                        color: Colors.black87,
                                        fontSize: 14,
                                      ),
                                    ),
                                    const Spacer(),
                                    Text(
                                      userProfile.name,
                                      style: const TextStyle(
                                          color: Colors.black87,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500),
                                    ),
                                  ],
                                ),
                                const SizedBox(
                                  height: 20,
                                ),
                                Row(
                                  children: [
                                    const Text(
                                      'Giới tính:',
                                      style: TextStyle(
                                        color: Colors.black87,
                                        fontSize: 14,
                                      ),
                                    ),
                                    const Spacer(),
                                    Text(
                                      userProfile.gender,
                                      style: const TextStyle(
                                          color: Colors.black87,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500),
                                    ),
                                  ],
                                ),
                                const SizedBox(
                                  height: 20,
                                ),
                                Row(
                                  children: [
                                    const Text(
                                      'Ngày sinh:',
                                      style: TextStyle(
                                        color: Colors.black87,
                                        fontSize: 14,
                                      ),
                                    ),
                                    const Spacer(),
                                    Text(
                                      userProfile.doB,
                                      style: const TextStyle(
                                          color: Colors.black87,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500),
                                    ),
                                  ],
                                ),
                                const SizedBox(
                                  height: 20,
                                ),
                                Row(
                                  children: [
                                    const Text(
                                      'Điện thoại:',
                                      style: TextStyle(
                                        color: Colors.black87,
                                        fontSize: 14,
                                      ),
                                    ),
                                    const Spacer(),
                                    Text(
                                      userProfile.phone,
                                      style: const TextStyle(
                                        color: Colors.black87,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                        letterSpacing: 1.1,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(
                                  height: 20,
                                ),
                                const Row(
                                  children: [
                                    Text(
                                      'Mã bảo hiểm y tế',
                                      style: TextStyle(
                                        color: Colors.black87,
                                        fontSize: 14,
                                      ),
                                    ),
                                    Spacer(),
                                    Text(
                                      'Chưa cập nhật',
                                      style: TextStyle(
                                          color: Colors.black45,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500),
                                    ),
                                  ],
                                ),
                                const SizedBox(
                                  height: 20,
                                ),
                                const Row(
                                  children: [
                                    Text(
                                      'Địa chỉ',
                                      style: TextStyle(
                                        color: Colors.black87,
                                        fontSize: 14,
                                      ),
                                    ),
                                    Spacer(),
                                    Text(
                                      'Chưa cập nhật',
                                      style: TextStyle(
                                          color: Colors.black45,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500),
                                    ),
                                  ],
                                ),
                                const SizedBox(
                                  height: 20,
                                ),
                                const Row(
                                  children: [
                                    Text(
                                      'Dân tộc',
                                      style: TextStyle(
                                        color: Colors.black87,
                                        fontSize: 14,
                                      ),
                                    ),
                                    Spacer(),
                                    Text(
                                      'Chưa cập nhật',
                                      style: TextStyle(
                                          color: Colors.black45,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500),
                                    ),
                                  ],
                                ),
                                const SizedBox(
                                  height: 20,
                                ),
                                const Row(
                                  children: [
                                    Text(
                                      'Nghề nghiệp',
                                      style: TextStyle(
                                        color: Colors.black87,
                                        fontSize: 14,
                                      ),
                                    ),
                                    Spacer(),
                                    Text(
                                      'Chưa cập nhật',
                                      style: TextStyle(
                                          color: Colors.black45,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500),
                                    ),
                                  ],
                                ),
                                const SizedBox(
                                  height: 20,
                                ),
                                const Row(
                                  children: [
                                    Text(
                                      'Email',
                                      style: TextStyle(
                                        color: Colors.black87,
                                        fontSize: 14,
                                      ),
                                    ),
                                    Spacer(),
                                    Text(
                                      'Chưa cập nhật',
                                      style: TextStyle(
                                          color: Colors.black45,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500),
                                    ),
                                  ],
                                ),
                                const SizedBox(
                                  height: 5,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(
                            height: 5,
                          ),
                          Row(
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
                              const SizedBox(
                                width: 20,
                              ),
                              Expanded(
                                child: GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                HealthProfileDetailScreen(
                                                    profile: userProfile,
                                                    isUserOfProfile: false,
                                                    isDoctorViewing: true)));
                                  },
                                  child: Container(
                                    width: double.infinity,
                                    height: 50,
                                    margin: const EdgeInsets.only(
                                      right: 20,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Themes.gradientDeepClr,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: const Center(
                                      child: Text(
                                        'Xem hồ sơ',
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
                        ],
                      ),
                      Positioned(
                        top: 0,
                        right: 15,
                        child: GestureDetector(
                          onTap: () {
                            Navigator.of(context).pop();
                          },
                          child: const Icon(
                            Icons.close,
                            size: 24,
                            color: Colors.grey,
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ],
            ),
          );
        });
      },
    );
  }

  void showFeedbackDialog(BuildContext context, String docId) {
    Stream<DocumentSnapshot<Map<String, dynamic>>> feedbackStream =
        getFeedbackDocumentStream(docId);

    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
          stream: feedbackStream,
          builder: (BuildContext context,
              AsyncSnapshot<DocumentSnapshot<Map<String, dynamic>>> snapshot) {
            if (snapshot.hasError) {
              return Text('Có lỗi xảy ra: ${snapshot.error}');
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (!snapshot.hasData || !snapshot.data!.exists) {
              return const Text('Không tìm thấy tài liệu phản hồi');
            }
            Map<String, dynamic> feedbackData = snapshot.data!.data()!;
            Timestamp rateDate = feedbackData['rateDate'];

            String formattedDate =
                DateFormat('dd/MM/yyyy').format(rateDate.toDate());
            return AlertDialog(
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    feedbackData['username'].toString().toUpperCase(),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  RatingBar.builder(
                    initialRating: feedbackData['rating'],
                    minRating: 1,
                    direction: Axis.horizontal,
                    allowHalfRating: true,
                    itemCount: 5,
                    itemSize: 20,
                    itemPadding: const EdgeInsets.symmetric(horizontal: 1),
                    itemBuilder: (context, _) => const Icon(
                      Icons.star,
                      color: Colors.amber,
                    ),
                    ignoreGestures: true,
                    onRatingUpdate: (rating) {},
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Text(
                    feedbackData['content'],
                    style: const TextStyle(
                      fontSize: 16,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Text(
                    formattedDate,
                    style: const TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                        fontStyle: FontStyle.italic),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('Đóng'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  _isNotEmptyReasonForExamination() {
    if (_appointmentSchedule!.reasonForExamination!.isNotEmpty ||
        _appointmentSchedule!.listOfHealthInformationFiles!.isNotEmpty) {
      return true;
    }
    return false;
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

  Future<File> getFileFromURL(String url) async {
    String extension = getExtensionFromURL(url);
    // Sử dụng package http để tải file từ URL
    var response = await http.get(Uri.parse(url));
    var tempDir = await getTemporaryDirectory();
    File file = File(
        '${tempDir.path}/${DateTime.now().millisecondsSinceEpoch}.$extension');

    await file.writeAsBytes(response.bodyBytes);
    return file;
  }

  loadFileFromStorage() async {
    List<File> files = [];

    for (String fileURL in _appointmentSchedule!.listOfHealthInformationURLs!) {
      // Tạo một đối tượng File từ URL
      File file = await getFileFromURL(fileURL);
      // Thêm file đã tải về vào danh sách
      files.add(file);
    }

    setState(() {
      _appointmentSchedule!.listOfHealthInformationFiles = files;
    });
  }

  Stream<DocumentSnapshot<Map<String, dynamic>>> getFeedbackDocumentStream(
      String docId) {
    return FirebaseFirestore.instance
        .collection('feedback')
        .doc(docId)
        .snapshots();
  }

  Future<void> onJoin() async {
    await _handleCameraAndMic(Permission.camera);
    await _handleCameraAndMic(Permission.microphone);
    await Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => CallPage(
                channelName: _channel,
                role: _role,
                appointmentSchedule: _appointmentSchedule!,
                isDoctor: true,
                isUser: false,
              )),
    );
  }

  Future<void> _handleCameraAndMic(Permission permission) async {
    final status = await permission.request();
    log(status.toString());
  }

  void goToChatRoom() async {
    try {
      var querySnapshot = await FirebaseFirestore.instance
          .collection('chatroom')
          .where('idProfile',
              isEqualTo: _appointmentSchedule!.userProfile!.idDoc)
          .where('idDoctor', isEqualTo: _appointmentSchedule!.doctorInfo!.uid)
          .where('idUser', isEqualTo: _appointmentSchedule!.idDocUser)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        // Tài liệu đã tồn tại, lấy ID của tài liệu đầu tiên
        String chatRoomId = querySnapshot.docs[0].id;

        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => ChatRoomNew(
              chatRoomId: chatRoomId,
              userProfile: _appointmentSchedule!.userProfile!,
              doctorInfo: _appointmentSchedule!.doctorInfo!,
            ),
          ),
        );
      } else {
        // Tài liệu không tồn tại, tạo tài liệu mới
        var docRef =
            await FirebaseFirestore.instance.collection('chatroom').add({
          'idProfile': _appointmentSchedule!.userProfile!.idDoc,
          'idDoctor': _appointmentSchedule!.doctorInfo!.uid,
          'idUser': _appointmentSchedule!.idDocUser,
        });

        String chatRoomId = docRef.id;

        await docRef.update({'idDoc': chatRoomId});

        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => ChatRoomNew(
              chatRoomId: chatRoomId,
              userProfile: _appointmentSchedule!.userProfile!,
              doctorInfo: _appointmentSchedule!.doctorInfo!,
            ),
          ),
        );
      }

      print('Chatroom created successfully');
    } catch (e) {
      print('Error creating or accessing chatroom: $e');
    }
  }
}
