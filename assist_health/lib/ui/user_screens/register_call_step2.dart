import 'dart:io';

import 'package:assist_health/models/doctor/doctor_info.dart';
import 'package:assist_health/models/other/appointment_schedule.dart';
import 'package:assist_health/models/user/user_profile.dart';
import 'package:assist_health/others/methods.dart';
import 'package:assist_health/others/theme.dart';
import 'package:assist_health/ui/user_screens/register_call_step3.dart';
import 'package:assist_health/ui/user_screens/register_call_step4.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:open_file/open_file.dart';

// ignore: must_be_immutable
class RegisterCallStep2 extends StatefulWidget {
  DoctorInfo? doctorInfo;
  UserProfile? userProfile;
  String? reasonForExamination;
  List<File>? listOfHealthInformationFiles;
  DateTime? selectedDate;
  String? time;
  bool? isMorning;

  bool isEdit;
  AppointmentSchedule? appointmentSchedule;

  RegisterCallStep2(
      {required this.isEdit,
      this.appointmentSchedule,
      this.doctorInfo,
      this.userProfile,
      this.reasonForExamination,
      this.listOfHealthInformationFiles,
      this.selectedDate,
      this.time,
      this.isMorning,
      super.key});

  @override
  State<RegisterCallStep2> createState() => _RegisterCallStep2();
}

class _RegisterCallStep2 extends State<RegisterCallStep2> {
  bool _isVisibleInformation = true;
  bool _isVisibleReasonForExamination = true;

  DoctorInfo? _doctorInfo;
  UserProfile? _userProfile;
  String? _reasonForExamination;
  List<File>? _listOfHealthInformationFiles;

  DateTime? _selectedDate;
  String? _time;
  bool? _isMorning;

  @override
  void initState() {
    super.initState();

    if (widget.isEdit) {
      _doctorInfo = widget.appointmentSchedule!.doctorInfo;
      _userProfile = widget.appointmentSchedule!.userProfile;
      _reasonForExamination = widget.appointmentSchedule!.reasonForExamination;
      _listOfHealthInformationFiles =
          widget.appointmentSchedule!.listOfHealthInformationFiles;

      _selectedDate = widget.appointmentSchedule!.selectedDate;
      _time = widget.appointmentSchedule!.time;
      _isMorning = widget.appointmentSchedule!.isMorning;
    } else {
      _doctorInfo = widget.doctorInfo;
      _userProfile = widget.userProfile;
      _reasonForExamination = widget.reasonForExamination;
      _listOfHealthInformationFiles = widget.listOfHealthInformationFiles;

      _selectedDate = widget.selectedDate;
      _time = widget.time;

      _isMorning = widget.isMorning;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Themes.backgroundClr,
      appBar: AppBar(
        toolbarHeight: 50,
        title: const Text('Xác nhận thông tin'),
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
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(45),
          child: Container(
            width: double.infinity,
            height: 45,
            color: Colors.white,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              color: Colors.blueAccent.withOpacity(0.1),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.greenAccent.shade700,
                      ),
                      child: const Text(
                        '1',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(
                      width: 5,
                    ),
                    Text(
                      'Chọn lịch tư vấn',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.greenAccent.shade700,
                      ),
                    ),
                    const SizedBox(
                      width: 5,
                    ),
                    const Icon(
                      Icons.arrow_right_alt_outlined,
                      size: 30,
                      color: Colors.blueGrey,
                    ),
                    const SizedBox(
                      width: 5,
                    ),
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.blueAccent.shade700,
                      ),
                      child: const Text(
                        '2',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(
                      width: 5,
                    ),
                    Text(
                      'Xác nhận',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.blueAccent.shade700,
                      ),
                    ),
                    (!widget.isEdit)
                        ? Row(
                            children: [
                              const SizedBox(
                                width: 5,
                              ),
                              const Icon(
                                Icons.arrow_right_alt_outlined,
                                size: 30,
                                color: Colors.blueGrey,
                              ),
                              const SizedBox(
                                width: 5,
                              ),
                              Container(
                                padding: const EdgeInsets.all(4),
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.blueGrey,
                                ),
                                child: const Text(
                                  '3',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              const SizedBox(
                                width: 5,
                              ),
                              const Text(
                                'Thanh toán',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.blueGrey,
                                ),
                              ),
                              const SizedBox(
                                width: 5,
                              ),
                            ],
                          )
                        : const SizedBox(),
                    const SizedBox(
                      width: 5,
                    ),
                    const Icon(
                      Icons.arrow_right_alt_outlined,
                      size: 30,
                      color: Colors.blueGrey,
                    ),
                    const SizedBox(
                      width: 5,
                    ),
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.blueGrey,
                      ),
                      child: (!widget.isEdit)
                          ? const Text(
                              '4',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.white,
                              ),
                            )
                          : const Text(
                              '3',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.white,
                              ),
                            ),
                    ),
                    const SizedBox(
                      width: 5,
                    ),
                    const Text(
                      'Nhận lịch hẹn',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.blueGrey,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
      body: Container(
        height: double.infinity,
        color: Colors.blueAccent.withOpacity(0.1),
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Thông tin đăng ký
              Container(
                margin: const EdgeInsets.only(
                  left: 15,
                  top: 20,
                  bottom: 5,
                ),
                child: const Row(
                  children: [
                    Text(
                      'THÔNG TIN ĐĂNG KÝ',
                      style: TextStyle(
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: double.infinity,
                margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 15),
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
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
                                              (BuildContext context,
                                                  Object exception,
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
                                            getAbbreviatedName(
                                                _doctorInfo!.name),
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
                                      fontSize: 15,
                                      height: 1.4,
                                      fontWeight: FontWeight.bold),
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
                    Divider(
                      thickness: 1,
                      color: Colors.grey.shade100,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 15,
                        vertical: 10,
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Giờ tư vấn',
                                  style: TextStyle(
                                    fontSize: 15,
                                    color: Colors.grey,
                                  ),
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                                Text(
                                  _time!.replaceAll('-', ' - '),
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.black,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Ngày tư vấn',
                                  style: TextStyle(
                                    fontSize: 15,
                                    color: Colors.grey,
                                  ),
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                                Text(
                                  DateFormat('EEEE - dd/MM/yyyy', 'vi_VN')
                                      .format(_selectedDate!),
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.black,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.only(left: 15),
                      child: Text(
                        (_isMorning!) ? 'Buổi sáng' : 'Buổi chiều',
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.greenAccent.shade700,
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),

                    // Thông tin bệnh nhân
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _isVisibleInformation = !_isVisibleInformation;
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 15),
                        child: Row(children: [
                          const Text(
                            'THÔNG TIN BỆNH NHÂN',
                            style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey,
                                fontWeight: FontWeight.w500),
                          ),
                          Expanded(
                            child: Divider(
                              height: 20,
                              indent: 10,
                              endIndent: 6,
                              thickness: 1,
                              color: Colors.grey.shade300,
                            ),
                          ),
                          Icon(
                            (_isVisibleInformation)
                                ? Icons.keyboard_arrow_down_rounded
                                : Icons.keyboard_arrow_up_rounded,
                            size: 25,
                            color: Colors.grey.shade400,
                          ),
                        ]),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Visibility(
                      visible: _isVisibleInformation,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 15),
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'Họ và tên',
                                          style: TextStyle(
                                              fontSize: 14,
                                              color: Colors.grey,
                                              fontWeight: FontWeight.w400),
                                        ),
                                        const SizedBox(height: 6),
                                        Text(
                                          _userProfile!.name,
                                          style: const TextStyle(
                                              fontSize: 14,
                                              color: Colors.black,
                                              fontWeight: FontWeight.w400),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'Giới tính',
                                          style: TextStyle(
                                              fontSize: 14,
                                              color: Colors.grey,
                                              fontWeight: FontWeight.w400),
                                        ),
                                        const SizedBox(height: 6),
                                        Text(
                                          _userProfile!.gender,
                                          style: const TextStyle(
                                              fontSize: 14,
                                              color: Colors.black,
                                              fontWeight: FontWeight.w400),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'Số điện thoại',
                                          style: TextStyle(
                                              fontSize: 14,
                                              color: Colors.grey,
                                              fontWeight: FontWeight.w400),
                                        ),
                                        const SizedBox(height: 6),
                                        Text(
                                          _userProfile!.phone,
                                          style: const TextStyle(
                                              fontSize: 14,
                                              color: Colors.black,
                                              fontWeight: FontWeight.w400),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'Ngày sinh',
                                          style: TextStyle(
                                              fontSize: 14,
                                              color: Colors.grey,
                                              fontWeight: FontWeight.w400),
                                        ),
                                        const SizedBox(height: 6),
                                        Text(
                                          _userProfile!.doB,
                                          style: const TextStyle(
                                              fontSize: 14,
                                              color: Colors.black,
                                              fontWeight: FontWeight.w400),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 20),
                            ]),
                      ),
                    ),

                    // Lý do khám
                    if (_isNotEmptyReasonForExamination())
                      Column(
                        children: [
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                _isVisibleReasonForExamination =
                                    !_isVisibleReasonForExamination;
                              });
                            },
                            child: Container(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 15),
                              child: Row(children: [
                                const Text(
                                  'LÝ DO KHÁM',
                                  style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.grey,
                                      fontWeight: FontWeight.w500),
                                ),
                                Expanded(
                                  child: Divider(
                                    height: 20,
                                    indent: 10,
                                    endIndent: 6,
                                    thickness: 1,
                                    color: Colors.grey.shade300,
                                  ),
                                ),
                                Icon(
                                  (_isVisibleReasonForExamination)
                                      ? Icons.keyboard_arrow_down_rounded
                                      : Icons.keyboard_arrow_up_rounded,
                                  size: 25,
                                  color: Colors.grey.shade400,
                                ),
                              ]),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Visibility(
                            visible: _isVisibleReasonForExamination,
                            child: Container(
                              width: double.infinity,
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 15),
                              child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Lý do khám, triệu chứng',
                                      style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey,
                                          fontWeight: FontWeight.w400),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      _reasonForExamination! == ''
                                          ? 'Trống'
                                          : _reasonForExamination!,
                                      style: const TextStyle(
                                          fontSize: 14,
                                          color: Colors.black,
                                          fontWeight: FontWeight.w400),
                                    ),
                                    const SizedBox(
                                      height: 16,
                                    ),
                                    const Text(
                                      'Hình ảnh, toa thuốc',
                                      style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey,
                                          fontWeight: FontWeight.w400),
                                    ),
                                    (_listOfHealthInformationFiles!.isNotEmpty)
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
                                              itemCount:
                                                  _listOfHealthInformationFiles!
                                                      .length,
                                              gridDelegate:
                                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                                crossAxisCount: 4,
                                                mainAxisSpacing: 6,
                                                crossAxisSpacing: 6,
                                                childAspectRatio: 1,
                                              ),
                                              itemBuilder: (context, index) {
                                                if (index !=
                                                    _listOfHealthInformationFiles!
                                                        .length) {
                                                  File file =
                                                      _listOfHealthInformationFiles![
                                                          index];
                                                  String extension = file.path
                                                      .split('.')
                                                      .last
                                                      .toLowerCase();

                                                  return GestureDetector(
                                                    onTap: () {
                                                      OpenFile.open(file.path);
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
                                                            color: Colors.grey,
                                                          ),
                                                          alignment:
                                                              Alignment.center,
                                                          child: Column(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .center,
                                                            children: [
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
                                                                  height: constraints
                                                                          .maxWidth -
                                                                      10,
                                                                  width: constraints
                                                                          .maxHeight -
                                                                      10,
                                                                  child:
                                                                      ClipRRect(
                                                                    borderRadius:
                                                                        BorderRadius
                                                                            .circular(6),
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
                                                }
                                                return null;
                                              },
                                            ),
                                          )
                                        : Container(
                                            margin: const EdgeInsets.only(
                                              top: 6,
                                            ),
                                            child: const Text(
                                              'Trống',
                                              style: TextStyle(
                                                  fontSize: 14,
                                                  color: Colors.black,
                                                  fontWeight: FontWeight.w400),
                                            ),
                                          ),
                                    const SizedBox(height: 20),
                                  ]),
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
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
        height: (widget.isEdit) ? 70 : 150,
        padding: const EdgeInsets.symmetric(
          vertical: 8,
          horizontal: 15,
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
            (!widget.isEdit)
                ? Padding(
                    padding: const EdgeInsets.only(top: 6, bottom: 10),
                    child: Text(
                      'Hiện tại chỉ có thể thanh toán bằng cách quét mã thanh toán sau khi thực hiện xác nhận đăng ký',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                        height: 1.3,
                        wordSpacing: 1.2,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  )
                : const SizedBox(),
            (!widget.isEdit)
                ? Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Tổng',
                          style: TextStyle(
                              fontSize: 16,
                              color: Colors.red,
                              fontWeight: FontWeight.w500),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '${NumberFormat("#,##0", "en_US").format(int.parse((_doctorInfo!.serviceFee * 1.0083).toInt().toString()))} VNĐ',
                          style: const TextStyle(
                              fontSize: 16,
                              color: Colors.red,
                              fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  )
                : const SizedBox(),
            (!widget.isEdit)
                ? const SizedBox(
                    height: 8,
                  )
                : const SizedBox(),
            GestureDetector(
              onTap: () {
                if (widget.isEdit) {
                  widget.userProfile = _userProfile!;
                  widget.appointmentSchedule!.reasonForExamination !=
                      _reasonForExamination!;
                  widget.appointmentSchedule!.listOfHealthInformationFiles !=
                      _listOfHealthInformationFiles!;
                  widget.appointmentSchedule!.selectedDate = _selectedDate!;
                  widget.appointmentSchedule!.time = _time!;
                  widget.appointmentSchedule!.isMorning = _isMorning;
                  widget.appointmentSchedule!.reasonForExamination =
                      _reasonForExamination;
                  widget.appointmentSchedule!.status = 'Đã duyệt';
                  widget.appointmentSchedule!.updateAppointmentStatus(
                      widget.appointmentSchedule!.status!);
                  widget.appointmentSchedule!.updateAppointmentInFirestore(
                      widget.appointmentSchedule!.idDoc!);
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => RegisterCallStep4(
                              appointmentSchedule:
                                  widget.appointmentSchedule!)));
                } else {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => RegisterCallStep3(
                                doctorInfo: _doctorInfo!,
                                userProfile: _userProfile!,
                                reasonForExamination: _reasonForExamination!,
                                listOfHealthInformationFiles:
                                    _listOfHealthInformationFiles!,
                                selectedDate: _selectedDate!,
                                time: _time!,
                                isMorning: _isMorning!,
                              )));
                }
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
                  'Xác nhận',
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

  _isNotEmptyReasonForExamination() {
    if (_reasonForExamination!.isNotEmpty ||
        _listOfHealthInformationFiles!.isNotEmpty) return true;
    return false;
  }
}
