// ignore_for_file: avoid_print

import 'package:assist_health/others/methods.dart';
import 'package:assist_health/others/theme.dart';
import 'package:assist_health/ui/widgets/admin_navbar.dart';
import 'package:assist_health/ui/widgets/doctor_navbar.dart';
import 'package:assist_health/ui/widgets/user_navbar.dart';
import 'package:assist_health/ui/user_screens/phone.dart';
import 'package:assist_health/ui/other_screens/login.dart';
import 'package:flutter/material.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Material(
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
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const UserNavBar(),
                            ));
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
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const DoctorNavBar(),
                            ));
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
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const AdminNavBar(),
                            ));
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
                            builder: (_) => const PhoneScreen(),
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
    );
  }
}