import 'package:assist_health/others/theme.dart';
import 'package:flutter/material.dart';

class RegisterCallStep2 extends StatefulWidget {
  final String uid;

  const RegisterCallStep2(this.uid, {super.key});

  @override
  State<RegisterCallStep2> createState() => _RegisterCallStep2();
}

class _RegisterCallStep2 extends State<RegisterCallStep2> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Themes.backgroundClr,
      appBar: AppBar(
        title: const Text('Đăng ký dịch vụ'),
        centerTitle: true,
        backgroundColor: Themes.hearderClr,
      ),
      body: const SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding: EdgeInsets.all(15),
              child: Text(
                '2. Chọn người khám',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
