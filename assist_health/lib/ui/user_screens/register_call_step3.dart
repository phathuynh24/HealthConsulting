import 'dart:async';

import 'package:assist_health/others/theme.dart';
import 'package:assist_health/ui/user_screens/register_call_step4.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class RegisterCallStep3 extends StatefulWidget {
  const RegisterCallStep3({super.key});

  @override
  State<RegisterCallStep3> createState() => _RegisterCallStep3();
}

class _RegisterCallStep3 extends State<RegisterCallStep3> {
  int secondsRemaining = 3600;

  @override
  void initState() {
    super.initState();
    startTimer();
  }

  void startTimer() {
    Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        if (secondsRemaining > 0) {
          secondsRemaining--;
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
    return Scaffold(
      backgroundColor: Themes.backgroundClr,
      appBar: AppBar(
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
                      decoration: BoxDecoration(
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
                    Text(
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
          padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
          color: Colors.blueAccent.withOpacity(0.1),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Column(children: [
                  Text(
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
                  Row(
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
                      SizedBox(width: 100, child: Text('Số tài khoản:')),
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            // Xử lý sự kiện sao chép số tài khoản
                            final data = ClipboardData(text: '0711995629966');
                            Clipboard.setData(data);
                            // Hiển thị thông báo hoặc thực hiện các tác vụ khác
                            ScaffoldMessenger.of(context).hideCurrentSnackBar();
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  backgroundColor: Colors.greenAccent.shade700,
                                  content:
                                      Text('Số tài khoản đã được sao chép')),
                            );
                          },
                          child: Row(
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
                  Row(
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
                      SizedBox(width: 100, child: Text('Số tài khoản:')),
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            // Xử lý sự kiện sao chép số tài khoản
                            final data = ClipboardData(text: '150000');
                            Clipboard.setData(data);
                            // Hiển thị thông báo hoặc thực hiện các tác vụ khác
                            ScaffoldMessenger.of(context).hideCurrentSnackBar();
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  backgroundColor: Colors.greenAccent.shade700,
                                  content: Text('Số tiền đã được sao chép')),
                            );
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Text(
                                '150.000 VNĐ',
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SizedBox(
                          width: 150, child: Text('Nội dung chuyển khoản:')),
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            // Xử lý sự kiện sao chép nội dung chuyển khoản
                            final data = ClipboardData(text: 'DKLK1112202401');
                            Clipboard.setData(data);
                            // Hiển thị thông báo hoặc thực hiện các tác vụ khác
                            ScaffoldMessenger.of(context).hideCurrentSnackBar();
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  backgroundColor: Colors.greenAccent.shade700,
                                  content: Text(
                                      'Nội dung chuyển khoản đã được sao chép')),
                            );
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Text(
                                'DKLK1112202401',
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
                  SizedBox(
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
              SizedBox(
                height: 10,
              ),
              Container(
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Column(children: [
                  Text(
                    'HOẶC MỞ APP ĐỂ QUÉT MÃ VIETQR',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Divider(
                    color: Colors.blueGrey.shade100,
                    thickness: 0.3,
                  ),
                  Image.network(
                      'https://lh7-us.googleusercontent.com/rls_hLHSQbp3ZQ4KaaPBwxuNet1xDDQ5JYXk_vewbPocu1HA0SQmV6Prj6rJjXZHMKTP1m756IrCfiY0H8dainuWkBYoRAquoUHImPg3r9kelb_PXOuv-MFaivo3gpPyEsB9SqyjzRHU2VVBrY6NJA'),
                  Divider(
                    color: Colors.blueGrey.shade100,
                    thickness: 0.3,
                  ),
                  Image.network(
                      'https://img.vietqr.io/image/sacombank-070119955066-compact2.jpg?amount=150000&addInfo=DKLK1112202401&accountName=Huynh Tien Phat'),
                ]),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        height: 80,
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
            Row(
              children: [
                Text('Hạn thanh toán:'),
                Text(
                  formatTime(secondsRemaining),
                ),
              ],
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
    );
  }

  void showConfirmationDialog(BuildContext context) {
    bool isChecked = false;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              title: Text('Xác nhận thanh toán'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CheckboxListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text('Nếu bạn đã thanh toán thì hãy tích vào'),
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
                  child: Text('Hủy'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                ElevatedButton(
                  child: Text('Tiếp tục'),
                  onPressed: isChecked
                      ? () {
                          Navigator.of(context).pop();
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => RegisterCallStep4()));
                        }
                      : null,
                ),
              ],
            );
          },
        );
      },
    );
  }
}
