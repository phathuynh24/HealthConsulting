import 'dart:developer';

import 'package:agora_rtc_engine/rtc_engine.dart';
import 'package:assist_health/src/models/other/appointment_schedule.dart';
import 'package:assist_health/src/models/user/user_profile.dart';
import 'package:assist_health/src/others/methods.dart';
import 'package:assist_health/src/others/theme.dart';
import 'package:assist_health/src/widgets/half_circle.dart';
import 'package:assist_health/src/widgets/my_separator.dart';
import 'package:assist_health/src/widgets/user_navbar.dart';
import 'package:assist_health/src/video_call/pages/call.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';

// ignore: must_be_immutable
class RegisterCallNowStep3 extends StatefulWidget {
  AppointmentSchedule appointmentSchedule;
  RegisterCallNowStep3({super.key, required this.appointmentSchedule});

  @override
  State<RegisterCallNowStep3> createState() => _RegisterCallNowStep3State();
}

class _RegisterCallNowStep3State extends State<RegisterCallNowStep3> {
  AppointmentSchedule? _appointmentSchedule;
  bool _isVisibleInformation = true;
  bool _isVisiblePayment = true;

  final String _channel = 'video_call';
  final ClientRole _role = ClientRole.Broadcaster;

  @override
  void initState() {
    super.initState();
    _appointmentSchedule = widget.appointmentSchedule;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const UserNavBar()),
          (route) => false,
        );
        return true;
      },
      child: Scaffold(
        backgroundColor: Themes.backgroundClr,
        appBar: AppBar(
          foregroundColor: Colors.white,
          toolbarHeight: 50,
          title: const Text('Nhận lịch hẹn'),
          titleTextStyle: const TextStyle(fontSize: 16),
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
        ),
        body: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
            color: Colors.blueAccent.withOpacity(0.1),
            width: double.infinity,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Stack(
                  children: [
                    Container(
                      color: Colors.transparent,
                      child: Column(
                        children: [
                          Container(
                            width: double.infinity,
                            margin: const EdgeInsets.only(
                              top: 40,
                            ),
                            padding: const EdgeInsets.only(
                              top: 40,
                              bottom: 15,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: Column(
                              children: [
                                Text(
                                  'Đã đặt lịch',
                                  style: TextStyle(
                                    color: Colors.greenAccent.shade400,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(
                                  height: 8,
                                ),
                                Text(
                                  _appointmentSchedule!
                                      .receivedAppointmentTime!,
                                  style: const TextStyle(
                                    color: Colors.blueGrey,
                                    fontSize: 15,
                                  ),
                                ),
                                const SizedBox(
                                  height: 8,
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 8),
                                  margin: const EdgeInsets.symmetric(
                                      horizontal: 16),
                                  decoration: BoxDecoration(
                                      color: Colors.orange.shade400
                                          .withOpacity(0.8),
                                      borderRadius: BorderRadius.circular(15)),
                                  child: const Text(
                                    'Vui lòng đợi 3-5 phút để hệ thống xác nhận và cho phép tham gia cuộc gọi. Trong lúc đó bạn có thể chuẩn bị thông tin về triệu chứng hoặc đơn thuốc đã sử dụng. Ngoài ra, bạn cần ở nơi yên tĩnh và có tín hiệu Internet tốt để đảm bảo chất lượng tư vấn.',
                                    style: TextStyle(
                                      fontSize: 15,
                                      color: Colors.white,
                                    ),
                                    textAlign: TextAlign.justify,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Positioned(
                      top: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.greenAccent.shade400.withOpacity(0.2),
                        ),
                        child: Icon(
                          Icons.check_circle,
                          color: Colors.greenAccent.shade400,
                          size: 60,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 10,
                ),
                Container(
                  color: Colors.transparent,
                  child: Column(
                    children: [
                      Container(
                        width: double.infinity,
                        margin: const EdgeInsets.only(
                          bottom: 10,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Column(
                          children: [
                            const SizedBox(
                              height: 10,
                            ),
                            Container(
                              padding: const EdgeInsets.only(
                                bottom: 10,
                              ),
                              decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(15)),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Thông tin lịch khám
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                    ),
                                    child: Column(
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.all(10),
                                          child: Row(
                                            children: [
                                              Container(
                                                margin: const EdgeInsets.only(
                                                  right: 15,
                                                ),
                                                child: SizedBox(
                                                  width: 60,
                                                  height: 60,
                                                  child: ClipOval(
                                                    child: Container(
                                                      decoration:
                                                          const BoxDecoration(
                                                        gradient:
                                                            LinearGradient(
                                                          colors: [
                                                            Themes
                                                                .gradientDeepClr,
                                                            Themes
                                                                .gradientLightClr
                                                          ],
                                                          begin: Alignment
                                                              .bottomCenter,
                                                          end: Alignment
                                                              .topCenter,
                                                        ),
                                                      ),
                                                      child: (_appointmentSchedule!
                                                                  .doctorInfo!
                                                                  .imageURL !=
                                                              '')
                                                          ? Image.network(
                                                              _appointmentSchedule!
                                                                  .doctorInfo!
                                                                  .imageURL,
                                                              fit: BoxFit.cover,
                                                              errorBuilder: (BuildContext
                                                                      context,
                                                                  Object
                                                                      exception,
                                                                  StackTrace?
                                                                      stackTrace) {
                                                              return const Center(
                                                                child: Icon(
                                                                  FontAwesomeIcons
                                                                      .userDoctor,
                                                                  size: 50,
                                                                  color: Colors
                                                                      .white,
                                                                ),
                                                              );
                                                            })
                                                          : Center(
                                                              child: Text(
                                                                getAbbreviatedName(
                                                                    _appointmentSchedule!
                                                                        .doctorInfo!
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
                                                            ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              SizedBox(
                                                width: 255,
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      _appointmentSchedule!
                                                          .doctorInfo!
                                                          .careerTitiles,
                                                      style: const TextStyle(
                                                        color: Colors.black87,
                                                        fontSize: 15,
                                                        height: 1.5,
                                                      ),
                                                    ),
                                                    Text(
                                                      _appointmentSchedule!
                                                          .doctorInfo!.name,
                                                      style: const TextStyle(
                                                        color: Colors.black87,
                                                        fontSize: 16,
                                                        height: 1.4,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 10,
                                            vertical: 7,
                                          ),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              const SizedBox(
                                                  width: 110,
                                                  child: Text(
                                                    'Mã lịch khám',
                                                    style: TextStyle(
                                                      fontSize: 15,
                                                    ),
                                                  )),
                                              Expanded(
                                                child: GestureDetector(
                                                  onTap: () {
                                                    final data = ClipboardData(
                                                        text: _appointmentSchedule!
                                                            .appointmentCode!);
                                                    Clipboard.setData(data);
                                                    showToastMessage(context,
                                                        'Mã lịch khám đã được sao chép');
                                                  },
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.end,
                                                    children: [
                                                      Text(
                                                        _appointmentSchedule!
                                                            .appointmentCode!,
                                                        style: const TextStyle(
                                                          fontSize: 15,
                                                        ),
                                                        textAlign:
                                                            TextAlign.right,
                                                      ),
                                                      const SizedBox(
                                                        width: 5,
                                                      ),
                                                      const Icon(
                                                        Icons.content_copy,
                                                        size: 20,
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 10,
                                            vertical: 7,
                                          ),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              const SizedBox(
                                                  width: 100,
                                                  child: Text(
                                                    'Ngày khám',
                                                    style: TextStyle(
                                                      fontSize: 15,
                                                    ),
                                                  )),
                                              Expanded(
                                                  child: Text(
                                                DateFormat('EEEE - dd/MM/yyyy',
                                                        'vi_VN')
                                                    .format(
                                                        _appointmentSchedule!
                                                            .selectedDate!),
                                                style: const TextStyle(
                                                  fontSize: 15,
                                                ),
                                                textAlign: TextAlign.right,
                                              ))
                                            ],
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 10,
                                            vertical: 7,
                                          ),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              const SizedBox(
                                                  width: 100,
                                                  child: Text(
                                                    'Giờ khám',
                                                    style: TextStyle(
                                                      fontSize: 15,
                                                    ),
                                                  )),
                                              Expanded(
                                                  child: Text(
                                                (_appointmentSchedule!
                                                        .isMorning!)
                                                    ? '${_appointmentSchedule!.time!.replaceAll('-', ' - ')} (Buổi sáng)'
                                                    : '${_appointmentSchedule!.time!.replaceAll('-', ' - ')} (Buổi chiều)',
                                                style: TextStyle(
                                                  fontSize: 15,
                                                  color: Colors
                                                      .greenAccent.shade400,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                                textAlign: TextAlign.right,
                                              ))
                                            ],
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 10,
                                            vertical: 7,
                                          ),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              const SizedBox(
                                                  width: 100,
                                                  child: Text(
                                                    'Chuyên khoa',
                                                    style: TextStyle(
                                                      fontSize: 15,
                                                    ),
                                                  )),
                                              Expanded(
                                                  child: Text(
                                                getAllOfSpecialties(
                                                    _appointmentSchedule!
                                                        .doctorInfo!.specialty),
                                                style: const TextStyle(
                                                  fontSize: 15,
                                                ),
                                                textAlign: TextAlign.right,
                                              ))
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 20,
                                  ),

                                  // Thông tin bệnh nhân
                                  GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        _isVisibleInformation =
                                            !_isVisibleInformation;
                                      });
                                    },
                                    child: Row(children: [
                                      HalfCircle(
                                          height: 20,
                                          weight: 10,
                                          color: Colors.blueAccent
                                              .withOpacity(0.1),
                                          isLeft: true),
                                      const SizedBox(
                                        width: 10,
                                      ),
                                      const Text(
                                        'THÔNG TIN BỆNH NHÂN',
                                        style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.grey,
                                            fontWeight: FontWeight.w500),
                                      ),
                                      const SizedBox(
                                        width: 6,
                                      ),
                                      MySeparator(color: Colors.grey.shade400),
                                      Icon(
                                        (_isVisibleInformation)
                                            ? Icons.keyboard_arrow_down_rounded
                                            : Icons.keyboard_arrow_up_rounded,
                                        size: 27,
                                        color: Colors.grey.shade400,
                                      ),
                                      const SizedBox(
                                        width: 4,
                                      ),
                                      HalfCircle(
                                          height: 20,
                                          weight: 10,
                                          color: Colors.blueAccent
                                              .withOpacity(0.1),
                                          isLeft: false),
                                    ]),
                                  ),
                                  const SizedBox(height: 5),
                                  Visibility(
                                    visible: _isVisibleInformation,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 10,
                                              vertical: 7,
                                            ),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                const SizedBox(
                                                    width: 100,
                                                    child: Text(
                                                      'Họ và tên',
                                                      style: TextStyle(
                                                        fontSize: 15,
                                                      ),
                                                    )),
                                                Expanded(
                                                    child: Text(
                                                  _appointmentSchedule!
                                                      .userProfile!.name,
                                                  style: const TextStyle(
                                                    fontSize: 15,
                                                  ),
                                                  textAlign: TextAlign.right,
                                                ))
                                              ],
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 10,
                                              vertical: 7,
                                            ),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                const SizedBox(
                                                    width: 100,
                                                    child: Text(
                                                      'Ngày sinh',
                                                      style: TextStyle(
                                                        fontSize: 15,
                                                      ),
                                                    )),
                                                Expanded(
                                                    child: Text(
                                                  _appointmentSchedule!
                                                      .userProfile!.doB,
                                                  style: const TextStyle(
                                                    fontSize: 15,
                                                  ),
                                                  textAlign: TextAlign.right,
                                                ))
                                              ],
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 10,
                                              vertical: 7,
                                            ),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                const SizedBox(
                                                    width: 100,
                                                    child: Text(
                                                      'Giới tính',
                                                      style: TextStyle(
                                                        fontSize: 15,
                                                      ),
                                                    )),
                                                Expanded(
                                                    child: Text(
                                                  _appointmentSchedule!
                                                      .userProfile!.gender,
                                                  style: const TextStyle(
                                                    fontSize: 15,
                                                  ),
                                                  textAlign: TextAlign.right,
                                                ))
                                              ],
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 10,
                                              vertical: 7,
                                            ),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                const SizedBox(
                                                    width: 100,
                                                    child: Text(
                                                      'Số điện thoại',
                                                      style: TextStyle(
                                                        fontSize: 15,
                                                      ),
                                                    )),
                                                Expanded(
                                                    child: Text(
                                                  _appointmentSchedule!
                                                      .userProfile!.phone,
                                                  style: const TextStyle(
                                                    fontSize: 15,
                                                    letterSpacing: 1.1,
                                                  ),
                                                  textAlign: TextAlign.right,
                                                ))
                                              ],
                                            ),
                                          ),
                                          const SizedBox(
                                            height: 10,
                                          ),
                                          GestureDetector(
                                            onTap: () {
                                              _showDetailProfileBottomSheet(
                                                  context,
                                                  _appointmentSchedule!
                                                      .userProfile!);
                                            },
                                            child: const Center(
                                              child: Text(
                                                'Xem chi tiết',
                                                style: TextStyle(
                                                  color: Themes.gradientDeepClr,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 20,
                                  ),

                                  // Thông tin thanh toán
                                  GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        _isVisiblePayment = !_isVisiblePayment;
                                      });
                                    },
                                    child: Row(children: [
                                      HalfCircle(
                                          height: 20,
                                          weight: 10,
                                          color: Colors.blueAccent
                                              .withOpacity(0.1),
                                          isLeft: true),
                                      const SizedBox(
                                        width: 10,
                                      ),
                                      const Text(
                                        'THÔNG TIN THANH TOÁN',
                                        style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.grey,
                                            fontWeight: FontWeight.w500),
                                      ),
                                      const SizedBox(
                                        width: 6,
                                      ),
                                      MySeparator(color: Colors.grey.shade400),
                                      Icon(
                                        (_isVisibleInformation)
                                            ? Icons.keyboard_arrow_down_rounded
                                            : Icons.keyboard_arrow_up_rounded,
                                        size: 27,
                                        color: Colors.grey.shade400,
                                      ),
                                      const SizedBox(
                                        width: 4,
                                      ),
                                      HalfCircle(
                                          height: 20,
                                          weight: 10,
                                          color: Colors.blueAccent
                                              .withOpacity(0.1),
                                          isLeft: false),
                                    ]),
                                  ),
                                  const SizedBox(height: 5),
                                  Visibility(
                                    visible: _isVisiblePayment,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const Padding(
                                            padding: EdgeInsets.symmetric(
                                              horizontal: 10,
                                              vertical: 7,
                                            ),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                SizedBox(
                                                    width: 100,
                                                    child: Text(
                                                      'Phương thức',
                                                      style: TextStyle(
                                                        fontSize: 15,
                                                      ),
                                                    )),
                                                Expanded(
                                                    child: Text(
                                                  'Quét mã QR',
                                                  style: TextStyle(
                                                    fontSize: 15,
                                                  ),
                                                  textAlign: TextAlign.right,
                                                ))
                                              ],
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 10,
                                              vertical: 7,
                                            ),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                const SizedBox(
                                                    width: 100,
                                                    child: Text(
                                                      'Trạng thái',
                                                      style: TextStyle(
                                                        fontSize: 15,
                                                      ),
                                                    )),
                                                Expanded(
                                                    child: Text(
                                                  _appointmentSchedule!
                                                      .paymentStatus!,
                                                  style: TextStyle(
                                                    fontSize: 15,
                                                    fontWeight: FontWeight.bold,
                                                    color: getPaymentStatusColor(
                                                        _appointmentSchedule!
                                                            .paymentStatus!),
                                                  ),
                                                  textAlign: TextAlign.right,
                                                ))
                                              ],
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 10,
                                              vertical: 7,
                                            ),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                const SizedBox(
                                                    width: 100,
                                                    child: Text(
                                                      'Phí tư vấn',
                                                      style: TextStyle(
                                                        fontSize: 15,
                                                      ),
                                                    )),
                                                Expanded(
                                                  child: Text(
                                                    '${NumberFormat("#,##0", "en_US").format(int.parse((_appointmentSchedule!.doctorInfo!.serviceFee * 1.0083).toInt().toString()))} VNĐ',
                                                    style: const TextStyle(
                                                      fontSize: 15,
                                                      letterSpacing: 1.1,
                                                    ),
                                                    textAlign: TextAlign.right,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        bottomNavigationBar: Container(
          padding: const EdgeInsets.all(10),
          decoration: const BoxDecoration(
              border: Border(
                  top: BorderSide(
            color: Colors.blueGrey,
            width: 0.3,
          ))),
          child: Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: onJoin,
                  child: Container(
                    width: double.infinity,
                    height: 50,
                    margin: const EdgeInsets.only(
                      left: 5,
                      right: 5,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.greenAccent.shade700,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Vào cuộc gọi',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> onJoin() async {
    await _handleCameraAndMic(Permission.camera);
    await _handleCameraAndMic(Permission.microphone);
    // ignore: use_build_context_synchronously
    await Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => CallPage(
                channelName: _channel,
                role: _role,
                appointmentSchedule: _appointmentSchedule!,
                isDoctor: false,
                isUser: true,
              )),
    );
  }

  Future<void> _handleCameraAndMic(Permission permission) async {
    final status = await permission.request();
    log(status.toString());
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
                          GestureDetector(
                            onTap: () {
                              Navigator.of(context).pop();
                            },
                            child: Container(
                              width: double.infinity,
                              height: 50,
                              margin: const EdgeInsets.symmetric(
                                horizontal: 20,
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
}
