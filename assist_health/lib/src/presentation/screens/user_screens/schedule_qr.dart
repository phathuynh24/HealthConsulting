import 'package:assist_health/src/others/methods.dart';
import 'package:assist_health/src/others/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

// ignore: must_be_immutable
class ScheduleQRPage extends StatefulWidget {
  int serviceFee;
  String transferContent;
  String linkQRCode;
  ScheduleQRPage(
      {required this.linkQRCode,
      required this.transferContent,
      required this.serviceFee,
      super.key});

  @override
  State<ScheduleQRPage> createState() => _ScheduleQRPageState();
}

class _ScheduleQRPageState extends State<ScheduleQRPage> {
  late int _serviceFee;
  late String _transferContent;
  late String _linkQRCode;
  @override
  void initState() {
    super.initState();
    _serviceFee = widget.serviceFee;
    _transferContent = widget.transferContent;
    _linkQRCode = widget.linkQRCode;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
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
                      const SizedBox(width: 100, child: Text('Số tài khoản:')),
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            // Xử lý sự kiện sao chép số tài khoản
                            const data = ClipboardData(text: '0711995629966');
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
                      const SizedBox(width: 100, child: Text('Số tài khoản:')),
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            // Xử lý sự kiện sao chép số tài khoản
                            final data =
                                ClipboardData(text: '${_serviceFee * 1.0083}');
                            Clipboard.setData(data);
                            showToastMessage(
                                context, 'Số tiền đã được sao chép');
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Text(
                                '${NumberFormat("#,##0", "en_US").format(int.parse((_serviceFee * 1.0083).toInt().toString()))} VNĐ',
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
                          width: 150, child: Text('Nội dung chuyển khoản:')),
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            // Xử lý sự kiện sao chép nội dung chuyển khoản
                            final data = ClipboardData(text: _transferContent);
                            Clipboard.setData(data);
                            showToastMessage(context,
                                'Nội dung chuyển khoản đã được sao chép');
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Text(
                                _transferContent,
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
                    _linkQRCode,
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
    );
  }
}
