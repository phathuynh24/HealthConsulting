import 'package:assist_health/src/others/theme.dart';
import 'package:assist_health/src/presentation/screens/admin_screens/store/voucher/list_voucher_screen.dart';
import 'package:assist_health/src/presentation/screens/user_screens/chatbot_screen/chatbot.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

class InvertedCircleClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();
    var radius = 20.0;

    path.moveTo(radius, 0);
    path.lineTo(size.width - radius, 0);
    path.arcToPoint(
        Offset(
          size.width,
          radius,
        ),
        radius: Radius.circular(radius),
        clockwise: false);

    path.lineTo(size.width, size.height - radius);
    path.arcToPoint(Offset(size.width - radius, size.height),
        radius: Radius.circular(radius), clockwise: false);
    path.lineTo(radius, size.height);
    path.arcToPoint(Offset(0, size.height - radius),
        radius: Radius.circular(radius), clockwise: false);
    path.lineTo(0, radius);
    path.arcToPoint(Offset(radius, 0),
        radius: Radius.circular(radius), clockwise: false);

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

class AddVoucherScreen extends StatefulWidget {
  const AddVoucherScreen({super.key});

  @override
  _AddVoucherScreenState createState() => _AddVoucherScreenState();
}

class _AddVoucherScreenState extends State<AddVoucherScreen> {
  final _formKey = GlobalKey<FormState>();
  final _voucherCodeController = TextEditingController();
  final _discountController = TextEditingController();

  void createVoucher() async {
    if (_formKey.currentState!.validate()) {
      CollectionReference vouchers =
          FirebaseFirestore.instance.collection('vouchers');

      await vouchers
          .add({
            'voucherCode': _voucherCodeController.text,
            'discount': int.parse(_discountController.text),
            'createdAt': Timestamp.now(),
          })
          .then((value) => print("Voucher Added"))
          .catchError((error) => print("Failed to add voucher: $error"));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        foregroundColor: Colors.white,
        title: const Text(
          'Thêm Voucher',
          style: TextStyle(fontSize: 20),
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
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Row(
                children: [
                  const SizedBox(width: 16),
                  Flexible(
                    child: ClipPath(
                      clipper: InvertedCircleClipper(),
                      child: Container(
                        color: Themes.gradientDeepClr,
                        child: SizedBox(
                          height: 200,
                          width: 150,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Expanded(
                                      child: TextFormField(
                                        style: const TextStyle(
                                            fontSize: 40, color: Colors.white),
                                        controller: _discountController,
                                        decoration: const InputDecoration(
                                          labelText: 'Discount',
                                          labelStyle: TextStyle(
                                              color: Colors.white,
                                              fontSize: 20),
                                        ),
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return 'Please enter discount';
                                          }
                                          return null;
                                        },
                                      ),
                                    ),
                                    const Text(
                                      '%',
                                      style: TextStyle(
                                          color: Colors.white, fontSize: 50),
                                    ),
                                  ],
                                ),
                                const Text(
                                  'SALE OFF',
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 20),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  ClipPath(
                    clipper: InvertedCircleClipper(),
                    child: Container(
                      color: Themes.gradientLightClr,
                      child: SizedBox(
                        height: 200,
                        width: 200,
                        child: Center(
                          child: TextFormField(
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                                fontSize: 30, color: Colors.white),
                            controller: _voucherCodeController,
                            decoration: const InputDecoration(
                                labelStyle: TextStyle(
                                    color: Colors.white, fontSize: 25),
                                labelText: 'Voucher Code'),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter voucher code';
                              }
                              return null;
                            },
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 50),
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    createVoucher();
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const ListVoucherScreen()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 32.0, vertical: 12.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    backgroundColor:
                        Themes.gradientLightClr, // Đặt màu nền của nút
                    foregroundColor: Colors.white, // Đặt màu chữ của nút
                    // primary: Themes.gradientLightClr,
                    // onPrimary: Colors.white,
                  ),
                  child: const Text(
                    'Tạo mới',
                    style: TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
