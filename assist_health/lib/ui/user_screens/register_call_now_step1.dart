// ignore_for_file: avoid_print

import 'dart:async';
import 'dart:math';

import 'package:assist_health/models/doctor/doctor_info.dart';
import 'package:assist_health/models/other/appointment_schedule.dart';
import 'package:assist_health/models/user/user_profile.dart';
import 'package:assist_health/others/methods.dart';
import 'package:assist_health/others/theme.dart';
import 'package:assist_health/ui/user_screens/health_profile_add_edit.dart';
import 'package:assist_health/ui/user_screens/register_call_now_step2.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';

// ignore: must_be_immutable
class RegisterCallNowStep1 extends StatefulWidget {
  DoctorInfo doctorInfo;
  RegisterCallNowStep1({super.key, required this.doctorInfo});

  @override
  State<RegisterCallNowStep1> createState() => _RegisterCallNowStep1State();
}

class _RegisterCallNowStep1State extends State<RegisterCallNowStep1> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String? _uid;
  UserProfile? _userProfile;
  DoctorInfo? _doctorInfo;
  String? _idDoc;

  StreamController<DocumentSnapshot>? _userProfileStreamController;

  String? _linkQRCode;
  String? _transferContent;

  @override
  void initState() {
    super.initState();
    _uid = _auth.currentUser!.uid;
    _doctorInfo = widget.doctorInfo;
    _idDoc = 'main_profile';
    _userProfileStreamController = StreamController<DocumentSnapshot>();
    _transferContent = _generateTransferContent();
    _linkQRCode =
        'https://img.vietqr.io/image/sacombank-070119955066-compact.jpg?amount=${_doctorInfo!.serviceFee * 1.0083}&addInfo=${_transferContent!}&accountName=HUYNH TIEN PHAT';
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _firestore
        .collection('users')
        .doc(_uid!)
        .collection('health_profiles')
        .doc(_idDoc!)
        .snapshots()
        .listen((snapshot) {
      _userProfileStreamController!.add(snapshot);
    });
    return Scaffold(
      backgroundColor: const Color(0xFFE8EEFA),
      appBar: AppBar(
        foregroundColor: Colors.white,
        toolbarHeight: 50,
        centerTitle: true,
        title: const Text('Gọi video ngay'),
        titleTextStyle: const TextStyle(fontSize: 16),
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
          margin: const EdgeInsets.symmetric(horizontal: 5, vertical: 10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Thông tin bác sĩ
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 15),
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15)),
                child: Row(
                  children: [
                    Container(
                      margin: const EdgeInsets.only(
                        right: 15,
                      ),
                      child: SizedBox(
                        width: 70,
                        height: 70,
                        child: ClipOval(
                          child: Container(
                            decoration: const BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Themes.gradientDeepClr,
                                  Themes.gradientLightClr
                                ],
                                begin: Alignment.bottomCenter,
                                end: Alignment.topCenter,
                              ),
                            ),
                            child: (_doctorInfo!.imageURL != '')
                                ? Image.network(_doctorInfo!.imageURL,
                                    fit: BoxFit.cover, errorBuilder:
                                        (BuildContext context, Object exception,
                                            StackTrace? stackTrace) {
                                    return const Center(
                                      child: Icon(
                                        FontAwesomeIcons.userDoctor,
                                        size: 50,
                                        color: Colors.white,
                                      ),
                                    );
                                  })
                                : Center(
                                    child: Text(
                                      getAbbreviatedName(_doctorInfo!.name),
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 30,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 265,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _doctorInfo!.careerTitiles,
                            style: const TextStyle(
                              color: Colors.black,
                              fontSize: 14,
                              height: 1.5,
                            ),
                          ),
                          Text(
                            _doctorInfo!.name,
                            style: const TextStyle(
                              color: Colors.black87,
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                              height: 1.4,
                            ),
                          ),
                          Text(
                            'Chuyên khoa: ${getAllOfSpecialties(_doctorInfo!.specialty)}',
                            style: const TextStyle(
                              color: Colors.black,
                              fontSize: 14,
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(
                height: 15,
              ),

              // Chọn hồ sơ
              Container(
                margin: const EdgeInsets.only(left: 15),
                child: const Row(
                  children: [
                    Text(
                      'Đặt lịch tư vấn cho:',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(
                height: 5,
              ),
              Container(
                width: double.infinity,
                height: 195,
                margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 15),
                decoration: BoxDecoration(
                    color: Colors.blueGrey.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(15)),
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: () {
                        _showDetailProfileBottomSheet(context, _userProfile!);
                      },
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(15)),
                        child: StreamBuilder<DocumentSnapshot>(
                          stream: _userProfileStreamController!.stream,
                          builder: (context, snapshot) {
                            if (snapshot.hasError) {
                              return Text('Error: ${snapshot.error}');
                            }

                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const Center(
                                  child: CircularProgressIndicator());
                            }

                            if (!snapshot.hasData || !snapshot.data!.exists) {
                              return const Text('No data available');
                            }

                            // Lấy dữ liệu từ snapshot
                            _userProfile = UserProfile.fromJson(
                                snapshot.data!.data() as Map<String, dynamic>);
                            return Column(
                              children: [
                                const SizedBox(
                                  height: 5,
                                ),
                                Row(
                                  children: [
                                    const Text(
                                      'Họ và tên:',
                                      style: TextStyle(
                                        color: Colors.black87,
                                        fontSize: 13,
                                      ),
                                    ),
                                    const Spacer(),
                                    Text(
                                      _userProfile!.name,
                                      style: const TextStyle(
                                          color: Colors.black87,
                                          fontSize: 13,
                                          fontWeight: FontWeight.w500),
                                    ),
                                  ],
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                                Row(
                                  children: [
                                    const Text(
                                      'Giới tính:',
                                      style: TextStyle(
                                        color: Colors.black87,
                                        fontSize: 13,
                                      ),
                                    ),
                                    const Spacer(),
                                    Text(
                                      _userProfile!.gender,
                                      style: const TextStyle(
                                          color: Colors.black87,
                                          fontSize: 13,
                                          fontWeight: FontWeight.w500),
                                    ),
                                  ],
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                                Row(
                                  children: [
                                    const Text(
                                      'Ngày sinh:',
                                      style: TextStyle(
                                        color: Colors.black87,
                                        fontSize: 13,
                                      ),
                                    ),
                                    const Spacer(),
                                    Text(
                                      _userProfile!.doB,
                                      style: const TextStyle(
                                          color: Colors.black87,
                                          fontSize: 13,
                                          fontWeight: FontWeight.w500),
                                    ),
                                  ],
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                                Row(
                                  children: [
                                    const Text(
                                      'Điện thoại:',
                                      style: TextStyle(
                                        color: Colors.black87,
                                        fontSize: 13,
                                      ),
                                    ),
                                    const Spacer(),
                                    Text(
                                      _userProfile!.phone,
                                      style: const TextStyle(
                                        color: Colors.black87,
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500,
                                        letterSpacing: 1.1,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(
                                  height: 5,
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 2,
                    ),
                    Row(
                      children: [
                        const SizedBox(
                          width: 12,
                        ),
                        GestureDetector(
                          onTap: () {
                            _showDetailProfileBottomSheet(
                                context, _userProfile!);
                          },
                          child: const Text(
                            'Xem chi tiết',
                            style: TextStyle(
                                fontSize: 13,
                                color: Colors.black54,
                                fontWeight: FontWeight.w500,
                                height: 1.5),
                          ),
                        ),
                        const Spacer(),
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => AddOrEditProfileScreen(
                                  isEdit: true,
                                  profile: _userProfile,
                                ),
                              ),
                            );
                          },
                          style: ButtonStyle(
                            shape: MaterialStateProperty.all<
                                RoundedRectangleBorder>(
                              RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            backgroundColor:
                                MaterialStateProperty.all<Color>(Colors.white),
                          ),
                          child: const Text(
                            'Sửa hồ sơ',
                            style: TextStyle(
                                fontSize: 14, color: Themes.gradientDeepClr),
                          ),
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 2,
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () {
                  _showProfileListBottomSheet(context);
                },
                child: Container(
                  padding: const EdgeInsets.all(5),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Chọn hoặc tạo hồ sơ khác',
                        style: TextStyle(color: Colors.blue),
                      ),
                      const SizedBox(
                        width: 5,
                      ),
                      Icon(
                        Icons.arrow_circle_right_rounded,
                        color: Colors.blue.withOpacity(0.5),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(
                height: 5,
              ),

              // Chi tiết thanh toán
              Container(
                margin: const EdgeInsets.only(
                  left: 15,
                  top: 20,
                  bottom: 5,
                ),
                child: const Row(
                  children: [
                    Text(
                      'CHI TIẾT THANH TOÁN',
                      style: TextStyle(
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: double.infinity,
                margin: const EdgeInsets.only(
                    top: 5, bottom: 15, left: 15, right: 15),
                padding:
                    const EdgeInsets.symmetric(vertical: 15, horizontal: 15),
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15)),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Phí khám',
                          style: TextStyle(
                              fontSize: 14,
                              color: Colors.black87,
                              fontWeight: FontWeight.w400),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '${NumberFormat("#,##0", "en_US").format(int.parse(_doctorInfo!.serviceFee.toString()))} VNĐ',
                          style: const TextStyle(
                              fontSize: 14,
                              color: Colors.black87,
                              fontWeight: FontWeight.w400),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Divider(
                      thickness: 1,
                      color: Colors.grey.shade100,
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Phí tiện ích',
                          style: TextStyle(
                              fontSize: 14,
                              color: Colors.black87,
                              fontWeight: FontWeight.w400),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '${NumberFormat("#,##0", "en_US").format(int.parse((_doctorInfo!.serviceFee * 0.0083).toInt().toString()))} VNĐ',
                          style: const TextStyle(
                              fontSize: 14,
                              color: Colors.black87,
                              fontWeight: FontWeight.w400),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Divider(
                      thickness: 1,
                      color: Colors.grey.shade100,
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Tổng thanh toán',
                          style: TextStyle(
                              fontSize: 15,
                              color: Colors.black87,
                              fontWeight: FontWeight.w500),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '${NumberFormat("#,##0", "en_US").format(int.parse((_doctorInfo!.serviceFee * 1.0083).toInt().toString()))} VNĐ',
                          style: const TextStyle(
                              fontSize: 15,
                              color: Colors.black87,
                              fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        height: 105,
        padding: const EdgeInsets.symmetric(
          vertical: 8,
          horizontal: 10,
        ),
        decoration: const BoxDecoration(
          border: Border(
            top: BorderSide(
              color: Colors.blueGrey,
              width: 0.2,
            ),
          ),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 6, bottom: 10),
              child: Text(
                'Hiện tại chỉ có thể thanh toán bằng cách quét mã QR',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey.shade600,
                  height: 1.3,
                  wordSpacing: 1.2,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            GestureDetector(
              onTap: () {
                AppointmentSchedule appointmentSchedule = AppointmentSchedule(
                  doctorInfo: _doctorInfo,
                  userProfile: _userProfile,
                  idDocUser: FirebaseAuth.instance.currentUser!.uid,
                  reasonForExamination: '',
                  listOfHealthInformationFiles: [],
                  selectedDate: DateTime.now(),
                  time: _getTimeRange(),
                  isMorning: true,
                  transferContent: _transferContent,
                  appointmentCode: _generateAppointmentCode(),
                  linkQRCode: _linkQRCode,
                  receivedAppointmentTime: _getFormattedDateTime(),
                  paymentStartTime: DateTime.now(),
                  status: 'Gọi ngay',
                  paymentStatus: 'Chờ xác nhận',
                );
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => RegisterCallNowStep2(
                            appointmentSchedule: appointmentSchedule)));
              },
              child: Container(
                padding: const EdgeInsets.all(13),
                margin: const EdgeInsets.symmetric(horizontal: 5),
                decoration: BoxDecoration(
                  color: Themes.gradientDeepClr,
                  borderRadius: BorderRadius.circular(8),
                ),
                alignment: Alignment.center,
                child: const Text(
                  'Thanh toán',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ],
        ),
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
                  height: 570,
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
                          const Spacer(),
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
                                    Navigator.of(context)
                                        .push(
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                AddOrEditProfileScreen(
                                              isEdit: true,
                                              profile: userProfile,
                                            ),
                                          ),
                                        )
                                        .then((value) =>
                                            Navigator.of(context).pop());
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
                                        'Sửa thông tin',
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

  void _showProfileListBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
          return StreamBuilder<List<DocumentSnapshot>>(
            stream: _getUserProfilesStream(),
            builder: (BuildContext context,
                AsyncSnapshot<List<DocumentSnapshot>> snapshot) {
              if (snapshot.hasData && snapshot.data != null) {
                final profiles = snapshot.data!.reversed.toList();
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
                      height: 580,
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
                                'Chọn hồ sơ bệnh nhân',
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.w500),
                              ),
                              const SizedBox(
                                height: 15,
                              ),
                              SizedBox(
                                height: 445,
                                child: ListView.builder(
                                  itemCount: profiles.length,
                                  itemBuilder:
                                      (BuildContext context, int index) {
                                    final profile = profiles[index];
                                    UserProfile userProfile =
                                        UserProfile.fromJson(profile.data()
                                            as Map<String, dynamic>);
                                    bool isAvtEmpty = userProfile.image == '';
                                    bool isSelectedProfile =
                                        _userProfile!.idProfile ==
                                            userProfile.idProfile;
                                    return GestureDetector(
                                      onTap: () {
                                        _updateSelectedProfile(userProfile);
                                        Navigator.of(context).pop();
                                      },
                                      child: Container(
                                        margin: const EdgeInsets.symmetric(
                                          horizontal: 15,
                                          vertical: 5,
                                        ),
                                        padding: const EdgeInsets.only(
                                          top: 10,
                                          left: 10,
                                          bottom: 10,
                                          right: 0,
                                        ),
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                            color: isSelectedProfile
                                                ? Themes.gradientDeepClr
                                                : Colors.grey.withOpacity(0.6),
                                            width:
                                                isSelectedProfile ? 1.5 : 0.5,
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(15),
                                        ),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            GestureDetector(
                                              onTap: () {
                                                _showDetailProfileBottomSheet(
                                                    context, userProfile);
                                              },
                                              child: Container(
                                                width: 90,
                                                padding:
                                                    const EdgeInsets.all(4),
                                                decoration: BoxDecoration(
                                                  color: Colors.blueAccent
                                                      .withOpacity(0.2),
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                ),
                                                child: Center(
                                                  child: Text(
                                                    'Xem chi tiết',
                                                    style: TextStyle(
                                                        color: Colors
                                                            .blue.shade900,
                                                        fontSize: 12),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            const SizedBox(
                                              height: 10,
                                            ),
                                            Row(
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
                                                                  width: 60,
                                                                  height: 60,
                                                                  child:
                                                                      ClipOval(
                                                                    child:
                                                                        Container(
                                                                      decoration:
                                                                          const BoxDecoration(
                                                                        gradient:
                                                                            LinearGradient(
                                                                          colors: [
                                                                            Themes.gradientDeepClr,
                                                                            Themes.gradientLightClr
                                                                          ],
                                                                          begin:
                                                                              Alignment.bottomCenter,
                                                                          end: Alignment
                                                                              .topCenter,
                                                                        ),
                                                                      ),
                                                                      child: (isAvtEmpty)
                                                                          ? Center(
                                                                              child: Text(
                                                                                getAbbreviatedName(userProfile.name),
                                                                                style: const TextStyle(
                                                                                  color: Colors.white,
                                                                                  fontSize: 25,
                                                                                  fontWeight: FontWeight.bold,
                                                                                ),
                                                                              ),
                                                                            )
                                                                          : Image.network(userProfile.image, fit: BoxFit.cover, errorBuilder: (BuildContext context, Object exception, StackTrace? stackTrace) {
                                                                              return const Center(
                                                                                child: Icon(
                                                                                  CupertinoIcons.person_circle_fill,
                                                                                  size: 50,
                                                                                  color: Colors.white,
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
                                                                  MainAxisAlignment
                                                                      .center,
                                                              children: [
                                                                Container(
                                                                  padding: const EdgeInsets
                                                                      .symmetric(
                                                                      vertical:
                                                                          2,
                                                                      horizontal:
                                                                          4),
                                                                  decoration:
                                                                      BoxDecoration(
                                                                          borderRadius: BorderRadius.circular(
                                                                              15),
                                                                          color: Themes.gradientDeepClr.withOpacity(
                                                                              0.9),
                                                                          border:
                                                                              Border.all(
                                                                            color:
                                                                                Colors.white,
                                                                            width:
                                                                                3,
                                                                          )),
                                                                  child: Center(
                                                                      child:
                                                                          Text(
                                                                    userProfile
                                                                        .relationship,
                                                                    style: const TextStyle(
                                                                        color: Colors
                                                                            .white,
                                                                        fontSize:
                                                                            12),
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
                                                Stack(
                                                  children: [
                                                    SizedBox(
                                                      width: 260,
                                                      child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          Text(
                                                            userProfile.name,
                                                            style:
                                                                const TextStyle(
                                                              color:
                                                                  Colors.black,
                                                              fontSize: 14,
                                                              height: 1.5,
                                                            ),
                                                          ),
                                                          Text(
                                                            '${userProfile.gender} - ${userProfile.doB}',
                                                            style:
                                                                const TextStyle(
                                                              color: Colors
                                                                  .black87,
                                                              fontSize: 15,
                                                              height: 1.4,
                                                            ),
                                                          ),
                                                          Text(
                                                            userProfile.phone,
                                                            style:
                                                                const TextStyle(
                                                              color:
                                                                  Colors.black,
                                                              fontSize: 14,
                                                              height: 1.5,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    (isSelectedProfile)
                                                        ? Positioned(
                                                            bottom: 0,
                                                            right: 0,
                                                            child: Container(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .symmetric(
                                                                      vertical:
                                                                          4,
                                                                      horizontal:
                                                                          8),
                                                              decoration:
                                                                  BoxDecoration(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            15),
                                                                color: Themes
                                                                    .gradientDeepClr,
                                                                boxShadow: [
                                                                  BoxShadow(
                                                                    color: Colors
                                                                        .grey
                                                                        .withOpacity(
                                                                            0.5),
                                                                    spreadRadius:
                                                                        2,
                                                                    blurRadius:
                                                                        5,
                                                                    offset:
                                                                        const Offset(
                                                                            0,
                                                                            2),
                                                                  ),
                                                                ],
                                                              ),
                                                              child:
                                                                  const Center(
                                                                      child:
                                                                          Text(
                                                                'ĐANG CHỌN',
                                                                style:
                                                                    TextStyle(
                                                                  color: Colors
                                                                      .white,
                                                                  fontSize: 13,
                                                                ),
                                                              )),
                                                            ),
                                                          )
                                                        : const SizedBox
                                                            .shrink(),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.only(
                                  top: 15,
                                ),
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
                                            borderRadius:
                                                BorderRadius.circular(10),
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
                                          Navigator.of(context)
                                              .push(
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  AddOrEditProfileScreen(
                                                isEdit: false,
                                              ),
                                            ),
                                          )
                                              .whenComplete(() {
                                            UserProfile addedProfile =
                                                UserProfile.fromJson(profiles[1]
                                                        .data()
                                                    as Map<String, dynamic>);
                                            _updateSelectedProfile(
                                                addedProfile);
                                            Navigator.of(context).pop();
                                          });
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
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                          child: const Center(
                                            child: Text(
                                              'Tạo hồ sơ mới',
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
                );
              } else if (snapshot.hasError) {
                return Text('Đã xảy ra lỗi: ${snapshot.error}');
              } else {
                return const Text('Đang tải dữ liệu...');
              }
            },
          );
        });
      },
    );
  }

  _updateSelectedProfile(UserProfile selectedProfile) {
    setState(() {
      _userProfile = selectedProfile;
      _idDoc = selectedProfile.idDoc;
    });
  }

  Stream<List<DocumentSnapshot>> _getUserProfilesStream() {
    return _firestore
        .collection('users')
        .doc(_uid!)
        .collection('health_profiles')
        .snapshots()
        .map((snapshot) => snapshot.docs);
  }

  String _getFormattedDateTime() {
    DateTime now = DateTime.now();
    String formattedTime = DateFormat('HH:mm:ss').format(now);
    String formattedDate = DateFormat('dd/MM/yyyy').format(now);
    String formattedDateTime = '$formattedTime - $formattedDate';

    return formattedDateTime;
  }

  String _generateTransferContent() {
    String characters = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    Random random = Random();
    String randomString = 'GVN';

    for (int i = 0; i < 9; i++) {
      int randomIndex = random.nextInt(characters.length);
      randomString += characters[randomIndex];
    }

    return randomString;
  }

  String _generateAppointmentCode() {
    // Sinh số ngẫu nhiên gồm 8 chữ số
    Random random = Random();
    String randomDigits =
        List.generate(8, (_) => random.nextInt(10).toString()).join();

    // Ghép nó với "MDK"
    String appointmentCode = 'MDK$randomDigits';

    return appointmentCode;
  }

  String _getTimeRange() {
    DateTime now = DateTime.now();
    String startTime = DateFormat('HH:mm').format(now);
    DateTime endTime = now.add(const Duration(minutes: 15));
    String endTimeString = DateFormat('HH:mm').format(endTime);
    String timeRange = '$startTime-$endTimeString';
    return timeRange;
  }
}
