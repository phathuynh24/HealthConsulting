import 'package:assist_health/others/theme.dart';
import 'package:assist_health/ui/user_screens/phone.dart';
import 'package:assist_health/ui/user_screens/sign_up.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pinput/pinput.dart';

class OtpVerificationScreen extends StatefulWidget {
  const OtpVerificationScreen({super.key});

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  final FirebaseAuth auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    var code = "";

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Themes.backgroundClr,
      body: Container(
        margin: const EdgeInsets.only(left: 25, right: 25),
        alignment: Alignment.center,
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/doctors.png',
                width: 150,
                height: 150,
              ),
              const SizedBox(height: 25),
              const Text(
                "Nhập mã xác thực",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              const Text(
                "Vui lòng nhập mã xác thực để đăng ký số điện thoại tài khoản",
                style: TextStyle(
                  fontSize: 16,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),
              Pinput(
                length: 6,
                showCursor: true,
                onChanged: (value) {
                  code = value;
                },
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 45,
                child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Themes.buttonClr,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10))),
                    onPressed: () {
                      PhoneAuthCredential credential =
                          PhoneAuthProvider.credential(
                              verificationId: PhoneScreen.verify,
                              smsCode: code);
                      auth.signInWithCredential(credential);
                      auth.currentUser!.delete();

                      String? phoneNumber = auth.currentUser!.phoneNumber;
                      Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const SignUpScreen(),
                              settings: RouteSettings(arguments: phoneNumber)),
                          (route) => false);
                    },
                    child: const Text(
                      "Tiếp tục",
                      style: TextStyle(color: Colors.white),
                    )),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  TextButton(
                      onPressed: () {
                        Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const PhoneScreen()),
                            (route) => false);
                      },
                      child: const Text(
                        "Điều chỉnh số diện thoại",
                        style: TextStyle(color: Themes.buttonClr),
                      ))
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
