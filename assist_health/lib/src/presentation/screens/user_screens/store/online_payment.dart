import 'dart:async';
import 'dart:math';

import 'package:assist_health/src/others/methods.dart';
import 'package:assist_health/src/others/theme.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart'; // Make sure to import intl package for NumberFormat

class OnLinePaymentScreen extends StatefulWidget {
  final int totalPriceAfterDiscount;
  // final Function placeOrder;

  const OnLinePaymentScreen({
    Key? key,
    required this.totalPriceAfterDiscount,
    // required this.placeOrder,
  }) : super(key: key);

  @override
  State<OnLinePaymentScreen> createState() => _OnlinePaymentScreenState();
}

class _OnlinePaymentScreenState extends State<OnLinePaymentScreen> {
  int _secondsRemaining = 3600;
  String? _transferContent;
  late String _linkQRCode;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _transferContent = _generateTransferContent();
    _linkQRCode =
        'https://img.vietqr.io/image/vietcombank-1017904862-compact.jpg?amount=${widget.totalPriceAfterDiscount}&addInfo=$_transferContent&accountName=NGUYEN TRUONG BAO DUY';
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
    return Scaffold(
      appBar: AppBar(
        foregroundColor: Colors.white,
        title: const Text(
          'Thanh toán',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
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
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
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
                    'NH TMCP Ngoại Thương Việt Nam (Vietcombank)',
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
                        const data = ClipboardData(text: '1017904862');
                        Clipboard.setData(data);
                        showToastMessage(
                            context, 'Số tài khoản đã được sao chép');
                      },
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            '1017904862',
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
                    'NGUYEN TRUONG BAO DUY',
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
                        final data = ClipboardData(
                            text: '${widget.totalPriceAfterDiscount}');
                        Clipboard.setData(data);
                        showToastMessage(context, 'Số tiền đã được sao chép');
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            '${NumberFormat("#,##0", "en_US").format(int.parse((widget.totalPriceAfterDiscount).toString()))} VNĐ',
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
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Thời gian còn lại: ',
                    style: const TextStyle(fontSize: 18),
                  ),
                  Text(
                    '${formatTime(_secondsRemaining)}',
                    style: const TextStyle(
                        fontSize: 18,
                        color: Colors.red,
                        fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              CachedNetworkImage(
                imageUrl: _linkQRCode,
                fit: BoxFit.cover,
                placeholder: (context, url) => Center(
                  child: CircularProgressIndicator(),
                ),
                errorWidget: (context, url, error) => const Icon(Icons.error),
              ),
              if (_secondsRemaining <= 0)
                const Text(
                  'Hết thời gian! Vui lòng tạo lại mã QR.',
                  style: TextStyle(color: Colors.red),
                ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _secondsRemaining > 0 ? null : _regenerateQRCode,
                child: const Text('Tạo lại mã QR'),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _savePaymentData,
                child: const Text(
                  'Xác nhận thanh toán',
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontSize: 18),
                ),
                style: ButtonStyle(
                  padding:
                      MaterialStateProperty.all<EdgeInsets>(EdgeInsets.all(12)),
                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                    RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(10), // Thay đổi bán kính
                    ),
                  ),
                  backgroundColor:
                      MaterialStateProperty.all<Color>(Themes.gradientDeepClr),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  void _regenerateQRCode() {
    setState(() {
      _transferContent = _generateTransferContent();
      _linkQRCode =
          'https://img.vietqr.io/image/vietcombank-1017904862-compact.jpg?amount=${widget.totalPriceAfterDiscount}&addInfo=$_transferContent&accountName=NGUYEN TRUONG BAO DUY';
      _secondsRemaining = 3600;
      startTimer();
    });
  }

  Future<void> _savePaymentData() async {
    if (!_isSaving) {
      setState(() {
        _isSaving = true;
      });

      // await widget.placeOrder();

      setState(() {
        _isSaving = false;
      });

      // Navigate back to home screen after saving
      Navigator.popUntil(context, (route) => route.isFirst);
    }
  }
}

String _generateTransferContent() {
  String randomString = 'Xin cam on ban da su dung dich vu cua chung toi.';
  return randomString;
}
