// ignore_for_file: avoid_print

import 'dart:async';

import 'package:assist_health/src/models/other/appointment_schedule.dart';
import 'package:assist_health/src/others/methods.dart';
import 'package:assist_health/src/others/theme.dart';
import 'package:assist_health/src/presentation/screens/user_screens/register_call_now_step3.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

// ignore: must_be_immutable
class RegisterCallNowStep2 extends StatefulWidget {
  AppointmentSchedule appointmentSchedule;
  RegisterCallNowStep2({super.key, required this.appointmentSchedule});

  @override
  State<RegisterCallNowStep2> createState() => _RegisterCallNowStep2State();
}

class _RegisterCallNowStep2State extends State<RegisterCallNowStep2> {
  AppointmentSchedule? appointmentSchedule;
  bool _isSaving = false;
  int _secondsRemaining = 3600;

  @override
  void initState() {
    super.initState();
    appointmentSchedule = widget.appointmentSchedule;
    startTimer();
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
                                        '${appointmentSchedule!.doctorInfo!.serviceFee}');
                                Clipboard.setData(data);
                                showToastMessage(
                                    context, 'Số tiền đã được sao chép');
                              },
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Text(
                                    '${NumberFormat("#,##0", "en_US").format(int.parse((appointmentSchedule!.doctorInfo!.serviceFee).toInt().toString()))} VNĐ',
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
                                final data = ClipboardData(
                                    text:
                                        appointmentSchedule!.transferContent!);
                                Clipboard.setData(data);
                                showToastMessage(context,
                                    'Nội dung chuyển khoản đã được sao chép');
                              },
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Text(
                                    appointmentSchedule!.transferContent!,
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
                        appointmentSchedule!.linkQRCode!,
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
                    title: const Text(
                        'Nếu bạn đã thanh toán thì hãy tích vào và nhấn nút tiếp tục'),
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
                            // ignore: use_build_context_synchronously
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

  _saveExaminationForm() async {
    try {
      appointmentSchedule!.idDoc = '${DateTime.now()}';
      await appointmentSchedule!.saveAppointmentToFirestore().whenComplete(() {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) => RegisterCallNowStep3(
              appointmentSchedule: appointmentSchedule!,
            ),
          ),
          (Route<dynamic> route) => false,
        );
      });
      print('Dữ liệu đã được lưu thành công!');
    } catch (e) {
      print('Lỗi khi lưu dữ liệu: $e');
    }
  }

  void updateIsSaving(bool value) {
    setState(() {
      _isSaving = value;
    });
  }

  String formatTime(int seconds) {
    int hours = seconds ~/ 3600;
    int minutes = (seconds % 3600) ~/ 60;
    int remainingSeconds = seconds % 60;
    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
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
}
