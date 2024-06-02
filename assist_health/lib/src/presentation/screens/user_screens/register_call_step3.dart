// ignore_for_file: avoid_print, use_build_context_synchronously

import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:assist_health/src/models/doctor/doctor_info.dart';
import 'package:assist_health/src/models/other/appointment_schedule.dart';
import 'package:assist_health/src/models/user/user_profile.dart';
import 'package:assist_health/src/others/methods.dart';
import 'package:assist_health/src/others/theme.dart';
import 'package:assist_health/src/presentation/screens/user_screens/register_call_step4.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

// ignore: must_be_immutable
class RegisterCallStep3 extends StatefulWidget {
  DoctorInfo doctorInfo;
  UserProfile userProfile;
  String reasonForExamination;
  List<File> listOfHealthInformationFiles;
  DateTime selectedDate;
  String time;
  bool isMorning;

  RegisterCallStep3(
      {required this.doctorInfo,
      required this.userProfile,
      required this.reasonForExamination,
      required this.listOfHealthInformationFiles,
      required this.selectedDate,
      required this.time,
      required this.isMorning,
      super.key});

  @override
  State<RegisterCallStep3> createState() => _RegisterCallStep3();
}

class _RegisterCallStep3 extends State<RegisterCallStep3> {
  int _secondsRemaining = 3600;

  DoctorInfo? _doctorInfo;
  UserProfile? _userProfile;
  String? _reasonForExamination;
  List<File>? _listOfHealthInformationFiles;

  DateTime? _selectedDate;
  String? _time;
  bool? _isMorning;

  String? _transferContent;

  bool _isSaving = false;

  String? _linkQRCode;

  String? _appointmentCode;

  DateTime? _paymentStartTime;

  @override
  void initState() {
    super.initState();

    _doctorInfo = widget.doctorInfo;
    _userProfile = widget.userProfile;
    _reasonForExamination = widget.reasonForExamination;
    _listOfHealthInformationFiles = widget.listOfHealthInformationFiles;

    _selectedDate = widget.selectedDate;
    _time = widget.time;
    _isMorning = widget.isMorning;

    _transferContent = _generateTransferContent();

    _linkQRCode =
        'https://img.vietqr.io/image/vietcombank-1017904862-compact.jpg?amount=${_doctorInfo!.serviceFee * 1.0083}&addInfo=${_transferContent!}&accountName=HUYNH TIEN PHAT';

    _appointmentCode = _generateAppointmentCode();

    _paymentStartTime = DateTime.now();

    startTimer();
  }

  void startTimer() {
    Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_secondsRemaining > 0) {
          _secondsRemaining--;
        } else {
          timer.cancel();
        }
      });
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
    return Stack(
      children: [
        Scaffold(
          backgroundColor: Themes.backgroundClr,
          appBar: AppBar(
            foregroundColor: Colors.white,
            toolbarHeight: 50,
            title: const Text('Thanh toán bằng QR Code'),
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
                            color: Colors.greenAccent.shade700,
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
                        Text(
                          'Thanh toán',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.blueAccent.shade700,
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
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.blueGrey,
                          ),
                          child: const Text(
                            '4',
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
          body: SingleChildScrollView(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
              color: Colors.blueAccent.withOpacity(0.1),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Column(children: [
                      const Text(
                        'TÀI KHOẢN NHẬN CHUYỂN KHOẢN 24/7',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Divider(
                        color: Colors.blueGrey.shade100,
                        thickness: 0.3,
                        height: 30,
                      ),
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          SizedBox(width: 100, child: Text('Ngân hàng:')),
                          Expanded(
                              child: Text(
                            'NH TMCP Sài Gòn Thương Tín (Sacombank)',
                            textAlign: TextAlign.right,
                          ))
                        ],
                      ),
                      Divider(
                        color: Colors.blueGrey.shade100,
                        thickness: 0.3,
                        height: 30,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const SizedBox(
                              width: 100, child: Text('Số tài khoản:')),
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                // Xử lý sự kiện sao chép số tài khoản
                                const data =
                                    ClipboardData(text: '0711995629966');
                                Clipboard.setData(data);
                                showToastMessage(
                                    context, 'Số tài khoản đã được sao chép');
                              },
                              child: const Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Text(
                                    '0711995629966',
                                    style: TextStyle(
                                      color: Themes.gradientDeepClr,
                                      fontWeight: FontWeight.w500,
                                    ),
                                    textAlign: TextAlign.right,
                                  ),
                                  SizedBox(
                                    width: 5,
                                  ),
                                  Icon(
                                    Icons.content_copy,
                                    color: Themes.gradientDeepClr,
                                    size: 20,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      Divider(
                        color: Colors.blueGrey.shade100,
                        thickness: 0.3,
                        height: 30,
                      ),
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          SizedBox(width: 100, child: Text('Chủ tài khoản:')),
                          Expanded(
                              child: Text(
                            'HUYNH TIEN PHAT',
                            textAlign: TextAlign.right,
                          ))
                        ],
                      ),
                      Divider(
                        color: Colors.blueGrey.shade100,
                        thickness: 0.3,
                        height: 30,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const SizedBox(
                              width: 100, child: Text('Số tài khoản:')),
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                // Xử lý sự kiện sao chép số tài khoản
                                final data = ClipboardData(
                                    text:
                                        '${_doctorInfo!.serviceFee * 1.0083}');
                                Clipboard.setData(data);
                                showToastMessage(
                                    context, 'Số tiền đã được sao chép');
                              },
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Text(
                                    '${NumberFormat("#,##0", "en_US").format(int.parse((_doctorInfo!.serviceFee * 1.0083).toInt().toString()))} VNĐ',
                                    style: const TextStyle(
                                      color: Themes.gradientDeepClr,
                                      fontWeight: FontWeight.w500,
                                    ),
                                    textAlign: TextAlign.right,
                                  ),
                                  const SizedBox(
                                    width: 5,
                                  ),
                                  const Icon(
                                    Icons.content_copy,
                                    color: Themes.gradientDeepClr,
                                    size: 20,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      Divider(
                        color: Colors.blueGrey.shade100,
                        thickness: 0.3,
                        height: 30,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const SizedBox(
                              width: 150,
                              child: Text('Nội dung chuyển khoản:')),
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                // Xử lý sự kiện sao chép nội dung chuyển khoản
                                final data =
                                    ClipboardData(text: _transferContent!);
                                Clipboard.setData(data);
                                showToastMessage(context,
                                    'Nội dung chuyển khoản đã được sao chép');
                              },
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Text(
                                    _transferContent!,
                                    style: const TextStyle(
                                      color: Themes.gradientDeepClr,
                                      fontWeight: FontWeight.w500,
                                    ),
                                    textAlign: TextAlign.right,
                                  ),
                                  const SizedBox(
                                    width: 5,
                                  ),
                                  const Icon(
                                    Icons.content_copy,
                                    color: Themes.gradientDeepClr,
                                    size: 20,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 25,
                      ),
                      Text(
                        'Bạn hãy sao chép để gửi chính xác thông tin số tài khoản, nội dung chuyển khoản, đảm bảo lịch khám được xử lý ngay lập tức',
                        style: TextStyle(
                          height: 1.5,
                          color: Themes.gradientDeepClr.withOpacity(0.8),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ]),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Column(children: [
                      const Text(
                        'HOẶC MỞ APP ĐỂ QUÉT MÃ VIETQR',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Divider(
                        color: Colors.blueGrey.shade100,
                        thickness: 0.3,
                      ),
                      Image.asset('assets/guidanceVietQR.png'),
                      Divider(
                        color: Colors.blueGrey.shade100,
                        thickness: 0.3,
                      ),
                      Image.network(
                        _linkQRCode!,
                        errorBuilder: (BuildContext context, Object exception,
                            StackTrace? stackTrace) {
                          return Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(5),
                              color: Colors.redAccent.shade100.withOpacity(0.2),
                            ),
                            child: const Text(
                              'Hiện tại hệ thống đang lỗi, không thể xuất mã QR. Bạn có thể chuyển khoản qua tài khoản ngân hàng HUYNH TIEN PHAT được cung cấp ở bên trên hoặc vui lòng thử lại sau.',
                              style: TextStyle(
                                color: Colors.red,
                                fontWeight: FontWeight.w500,
                                height: 1.5,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          );
                        },
                      ),
                    ]),
                  ),
                ],
              ),
            ),
          ),
          bottomNavigationBar: Container(
            height: 110,
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
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                  child: Row(
                    children: [
                      const Text(
                        'Hạn thanh toán:',
                        style: TextStyle(fontSize: 15),
                      ),
                      const SizedBox(
                        width: 6,
                      ),
                      Text(
                        formatTime(_secondsRemaining),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.red,
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    showConfirmationDialog(context);
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
                      'Đã thanh toán',
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
        ),
        if (_isSaving)
          Positioned.fill(
            child: Container(
              color: Colors.black54,
              child: const Center(
                child: AlertDialog(
                  title: Text('Tạo phiếu khám'),
                  content: SingleChildScrollView(
                    child: ListBody(
                      children: [
                        Text(
                            'Vui lòng đợi trong khi chúng tôi tạo phiếu khám.'),
                        SizedBox(height: 30),
                        Center(child: CircularProgressIndicator()),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  void showConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        bool isChecked = false;

        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              title: const Text('Xác nhận thanh toán'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CheckboxListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Nếu bạn đã thanh toán thì hãy tích vào'),
                    value: isChecked,
                    onChanged: (bool? value) {
                      setState(() {
                        isChecked = value!;
                      });
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  child: const Text('Hủy'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                ElevatedButton(
                  onPressed: isChecked
                      ? () async {
                          // Đóng hộp thoại xác nhận thanh toán
                          Navigator.of(context).pop();

                          try {
                            await _saveExaminationForm();
                          } catch (e) {
                            showDialog(
                              context: context,
                              barrierDismissible: false,
                              builder: (context) => AlertDialog(
                                title: const Text('Thông báo lỗi'),
                                content: const SingleChildScrollView(
                                  child: ListBody(
                                    children: [
                                      Text(
                                          'Đã xảy ra lỗi khi tạo phiếu khám, vui lòng thử lại sau.'),
                                    ],
                                  ),
                                ),
                                actions: [
                                  TextButton(
                                    child: const Text('Đã hiểu'),
                                    onPressed: () {
                                      Navigator.of(context)
                                          .pop(); // Đóng hộp thoại lỗi
                                    },
                                  ),
                                ],
                              ),
                            );
                          }
                        }
                      : null,
                  child: const Text('Tiếp tục'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  String _generateTransferContent() {
    String characters = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    Random random = Random();
    String randomString = '';

    for (int i = 0; i < 12; i++) {
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

  _saveExaminationForm() async {
    updateIsSaving(true); // Mở ProgressDialog

    AppointmentSchedule appointmentSchedule = AppointmentSchedule(
      doctorInfo: _doctorInfo,
      userProfile: _userProfile,
      idDocUser: FirebaseAuth.instance.currentUser!.uid,
      reasonForExamination: _reasonForExamination,
      listOfHealthInformationFiles: _listOfHealthInformationFiles,
      selectedDate: _selectedDate,
      time: _time,
      isMorning: _isMorning,
      transferContent: _transferContent,
      appointmentCode: _appointmentCode,
      linkQRCode: _linkQRCode,
      receivedAppointmentTime: getFormattedDateTime(),
      paymentStartTime: _paymentStartTime,
      status: 'Chờ duyệt',
      paymentStatus: 'Chờ xác nhận',
      idDoc: DateTime.now().toString(),
    );

    try {
      await appointmentSchedule.saveAppointmentToFirestore().whenComplete(() {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) => RegisterCallStep4(
              appointmentSchedule: appointmentSchedule,
            ),
          ),
          (Route<dynamic> route) => false,
        );
      });
      print('Dữ liệu đã được lưu thành công!');
    } catch (e) {
      print('Lỗi khi lưu dữ liệu: $e');
    }
    updateIsSaving(false); // Ẩn ProgressDialog
  }

  void updateIsSaving(bool value) {
    setState(() {
      _isSaving = value;
    });
  }

  String getFormattedDateTime() {
    DateTime now = DateTime.now();
    String formattedTime = DateFormat('HH:mm:ss').format(now);
    String formattedDate = DateFormat('dd/MM/yyyy').format(now);
    String formattedDateTime = '$formattedTime - $formattedDate';

    return formattedDateTime;
  }
}
