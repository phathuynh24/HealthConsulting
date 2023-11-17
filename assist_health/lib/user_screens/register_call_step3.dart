import 'package:flutter/material.dart';

class RegisterCallStep3 extends StatefulWidget {
  final String uid;

  const RegisterCallStep3(this.uid, {super.key});

  @override
  State<RegisterCallStep3> createState() => _RegisterCallStep3();
}

class _RegisterCallStep3 extends State<RegisterCallStep3> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Đăng ký dịch vụ'),
        centerTitle: true,
        backgroundColor: const Color(0xFF7165D6),
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Padding(
              padding: EdgeInsets.all(15),
              child: Text(
                '3. Chọn lịch khám',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
