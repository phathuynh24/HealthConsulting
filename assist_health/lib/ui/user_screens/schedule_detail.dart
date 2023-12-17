import 'dart:io';

import 'package:assist_health/models/other/appointment_schedule.dart';
import 'package:assist_health/models/user/user_profile.dart';
import 'package:assist_health/others/methods.dart';
import 'package:assist_health/others/theme.dart';
import 'package:assist_health/ui/user_screens/doctor_detail.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:open_file/open_file.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

// ignore: must_be_immutable
class ScheduleDetail extends StatefulWidget {
  AppointmentSchedule appointmentSchedule;

  ScheduleDetail({required this.appointmentSchedule, super.key});
  @override
  State<ScheduleDetail> createState() => _ScheduleDetailState();
}

class _ScheduleDetailState extends State<ScheduleDetail> {
  AppointmentSchedule? _appointmentSchedule;

  @override
  void initState() {
    super.initState();
    _appointmentSchedule = widget.appointmentSchedule;
    loadFileFromStorage();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Themes.backgroundClr,
      appBar: AppBar(
        title: const Text('Chi tiêt lịch khám'),
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
                      top: 18, left: 15, right: 15, bottom: 10),
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
                        padding: const EdgeInsets.all(10),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.person,
                              size: 18,
                              color: Colors.grey,
                            ),
                            const SizedBox(
                              width: 10,
                            ),
                            Text(
                              _appointmentSchedule!.userProfile!.name,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const Spacer(),
                            GestureDetector(
                              onTap: () {
                                _showDetailProfileBottomSheet(context,
                                    _appointmentSchedule!.userProfile!);
                              },
                              child: const Center(
                                child: Text(
                                  'Xem chi tiết',
                                  style: TextStyle(
                                    color: Themes.gradientDeepClr,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(
                              width: 5,
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
                          size: 18,
                          color: Colors.blue,
                        ),
                        const SizedBox(
                          width: 10,
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
                        color: Colors.blueGrey.shade100,
                        indent: 15,
                        endIndent: 15,
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => DoctorDetailScreen(
                                      doctorInfo:
                                          _appointmentSchedule!.doctorInfo!)));
                        },
                        child: Container(
                          margin: const EdgeInsets.symmetric(
                            horizontal: 15,
                            vertical: 4,
                          ),
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '${_appointmentSchedule!.doctorInfo!.careerTitiles} ${_appointmentSchedule!.doctorInfo!.name}',
                                  style: const TextStyle(
                                    fontSize: 14,
                                  ),
                                ),
                                Container(
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
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      // Lý do khám
                      if (_isNotEmptyReasonForExamination())
                        Column(
                          children: [
                            Container(
                              width: double.infinity,
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 15),
                              child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.medical_information,
                                          size: 18,
                                          color: Colors.grey.shade600,
                                        ),
                                        SizedBox(
                                          width: 5,
                                        ),
                                        Text(
                                          'Lý do khám, triệu chứng',
                                          style: TextStyle(
                                              fontSize: 14,
                                              color: Colors.grey.shade600,
                                              fontWeight: FontWeight.w500),
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
                                          color: Colors.black,
                                          fontWeight: FontWeight.w500),
                                    ),
                                    const SizedBox(
                                      height: 16,
                                    ),
                                    Row(
                                      children: [
                                        Icon(
                                          FontAwesomeIcons.images,
                                          size: 16,
                                          color: Colors.grey.shade600,
                                        ),
                                        SizedBox(
                                          width: 8,
                                        ),
                                        Text(
                                          'Hình ảnh, toa thuốc',
                                          style: TextStyle(
                                              fontSize: 14,
                                              color: Colors.grey.shade600,
                                              fontWeight: FontWeight.w500),
                                        ),
                                      ],
                                    ),
                                    (_appointmentSchedule!
                                            .listOfHealthInformationURLs!
                                            .isNotEmpty)
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
                                                itemBuilder: (context, index) {
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
                                                            color: Colors
                                                                .grey.shade300,
                                                          ),
                                                          alignment:
                                                              Alignment.center,
                                                          child: SizedBox(
                                                              height: 25,
                                                              width: 25,
                                                              child:
                                                                  CircularProgressIndicator()),
                                                        ),
                                                      );
                                                    });
                                                  }

                                                  File file = _appointmentSchedule!
                                                          .listOfHealthInformationFiles![
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
                                                                  '')
                                                                CircularProgressIndicator(),
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
                                                }),
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
                          ],
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
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
                  height: 560,
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
}
