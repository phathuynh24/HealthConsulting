import 'dart:async';
import 'dart:math';

import 'package:assist_health/src/others/theme.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

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
                'Thông tin thanh toán',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              Text(
                'Thời gian còn lại: ${formatTime(_secondsRemaining)}',
                style: const TextStyle(fontSize: 18),
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
                child: const Text('Xác nhận thanh toán'),
              ),
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
  String randomString = 'cam on vi da den';
  return randomString;
}
