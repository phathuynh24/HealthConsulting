// ignore_for_file: avoid_print

import 'dart:io';

import 'package:assist_health/others/methods.dart';
import 'package:assist_health/others/theme.dart';
import 'package:assist_health/screens/user_screens/otp.dart';
import 'package:assist_health/screens/widgets/admin_navbar.dart';
import 'package:assist_health/screens/widgets/doctor_navbar.dart';
import 'package:assist_health/screens/widgets/user_navbar.dart';
import 'package:assist_health/screens/user_screens/phone.dart';
import 'package:assist_health/screens/other_screens/login.dart';
import 'package:flutter/material.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return await showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text("Xác nhận thoát ứng dụng"),
              content: const Text("Bạn có chắc chắn muốn thoát ứng dụng?"),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(false); // Không thoát ứng dụng
                  },
                  child: const Text("Hủy"),
                ),
                TextButton(
                  onPressed: () {
                    exit(0);
                  },
                  child: const Text("Xác nhận"),
                ),
              ],
            );
          },
        );
      },
      child: Material(
        color: Themes.backgroundClr,
        child: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          padding: const EdgeInsets.all(10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(
                height: 40,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {
                        logIn('huynhphat2405@gmail.com', '123456').then((user) {
                          print("Login Successfull");
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const UserNavBar()),
                            (route) => false,
                          );
                        });
                      },
                      child: const Text(
                        "User",
                        style: TextStyle(
                          color: Themes.selectedClr,
                          fontSize: 20,
                        ),
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {
                        logIn('2409huynhphat@gmail.com', '123456').then((user) {
                          print("Login Successfull");
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const DoctorNavBar()),
                            (route) => false,
                          );
                        });
                      },
                      child: const Text(
                        "Doctor",
                        style: TextStyle(
                          color: Themes.selectedClr,
                          fontSize: 20,
                        ),
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {
                        logIn('21520388@gm.uit.edu.vn', '123456').then((user) {
                          print("Login Successfull");
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const AdminNavBar()),
                            (route) => false,
                          );
                        });
                      },
                      child: const Text(
                        "Admin",
                        style: TextStyle(
                          color: Themes.selectedClr,
                          fontSize: 20,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 20,
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Image.asset("assets/doctors.png"),
              ),
              const SizedBox(height: 50),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Material(
                    color: Themes.buttonClr,
                    borderRadius: BorderRadius.circular(10),
                    child: InkWell(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const LoginScreen(),
                            ));
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: 15, horizontal: 40),
                        child: const Text(
                          "Đăng nhập",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Material(
                    color: Themes.buttonClr,
                    borderRadius: BorderRadius.circular(10),
                    child: InkWell(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const OtpVerificationScreen(),
                            ));
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: 15, horizontal: 40),
                        child: const Text(
                          "Đăng ký",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
