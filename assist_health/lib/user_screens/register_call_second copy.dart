import 'package:assist_health/functions/methods.dart';
import 'package:assist_health/models/doctor/doctor_service.dart';
import 'package:flutter/material.dart';

class RegisterCallSecond extends StatefulWidget {
  final String uid;

  const RegisterCallSecond(this.uid, {super.key});

  @override
  State<RegisterCallSecond> createState() => _RegisterCallSecond();
}

class _RegisterCallSecond extends State<RegisterCallSecond> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Đăng ký dịch vụ'),
        centerTitle: true,
        backgroundColor: const Color(0xFF7165D6),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Padding(
            padding: EdgeInsets.all(15.0),
            child: Text(
              '2. Chọn lịch khám',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
