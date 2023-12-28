// ignore_for_file: avoid_print, use_build_context_synchronously

import 'package:assist_health/others/theme.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:assist_health/others/methods.dart';
import 'package:assist_health/ui/user_screens/phone.dart';
import 'package:assist_health/ui/widgets/user_navbar.dart';
import 'package:assist_health/ui/widgets/doctor_navbar.dart';
import 'package:assist_health/ui/widgets/admin_navbar.dart';
import 'package:firebase_auth/firebase_auth.dart';
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  bool passToggle = true;
  bool isLoading = false;
  final TextEditingController _name = TextEditingController();
  final TextEditingController _password = TextEditingController();
  late DocumentReference documentReference;

  Future<void> setOffline() async {
    if (documentReference != null) {
      await documentReference.update({'status': 'offline'});
    }
  }
  void resetPassword(String email) async {
  try {
    await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
    // Thành công: Hiển thị thông báo cho người dùng rằng email đã được gửi thành công
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Thành công"),
          content: const Text("Một liên kết đặt lại mật khẩu đã được gửi đến email của bạn."),
          actions: [
            TextButton(
              child: const Text("Đóng"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  } catch (error) {
    // Xử lý lỗi: Hiển thị thông báo lỗi cho người dùng
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Lỗi"),
          content: Text("Đã xảy ra lỗi: $error"),
          actions: [
            TextButton(
              child: const Text("Đóng"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
  @override
  Widget build(BuildContext context) {
    return Material(
      color: Themes.backgroundClr,
      child: SingleChildScrollView(
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Image.asset(
                  "assets/doctors.png",
                ),
              ),
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.all(12),
                child: TextField(
                  controller: _name,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    label: Text("Nhập email"),
                    prefixIcon: Icon(Icons.person),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(12),
                child: TextField(
                  controller: _password,
                  obscureText: passToggle ? true : false,
                  decoration: InputDecoration(
                    border: const OutlineInputBorder(),
                    label: const Text("Nhập mật khẩu"),
                    prefixIcon: const Icon(Icons.lock),
                    suffixIcon: InkWell(
                      onTap: () {
                        if (passToggle == true) {
                          passToggle = false;
                        } else {
                          passToggle = true;
                        }
                        setState(() {});
                      },
                      child: passToggle
                          ? const Icon(CupertinoIcons.eye_slash_fill)
                          : const Icon(CupertinoIcons.eye_fill),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.all(15),
                child: InkWell(
                  onTap: () {
                    //login function
                    if (_name.text.isNotEmpty && _password.text.isNotEmpty) {
                      setState(() {
                        isLoading = true;
                      });
                      logIn(_name.text, _password.text).then((user) async {
                        if (user == null) {
                          print("Login failed");
                          setState(() {
                            isLoading = false;
                          });
                          return;
                        }

                        print("Login Successfull");
                        setState(() {
                          isLoading = false;
                        });

                        DocumentReference documentReference =
                            firestore.collection('users').doc(user.uid);
                        DocumentSnapshot document =
                            await documentReference.get();
                        String role = document['role'];
                        switch (role) {
                          case 'user':
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) => const UserNavBar()));
                            break;
                          case 'doctor':
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) => const DoctorNavBar()));
                            break;
                          case 'admin':
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) => const AdminNavBar()));
                            break;
                        }
                        await documentReference.update({'status': 'online'});
 
                      });
                    } else {
                      print("Please fill");
                    }
                  },
                  
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Themes.buttonClr,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 4,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Text(
                        "Đăng nhập",
                        style: TextStyle(
                          fontSize: 23,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "Nếu bạn chưa có tài khoản?",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.black54,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const PhoneScreen(),
                          ));
                    },
                    child: const Text(
                      "Đăng ký",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Themes.primaryColor,
                      ),
                    ),
                  ),
                ],
              ),
              InkWell(
                onTap: () {
                  // Call resetPassword when the user clicks "Quên mật khẩu"
                  if (_name.text.isNotEmpty) {
                    resetPassword(_name.text);
                  } else {
                    // Show an error or prompt the user to enter an email
                    print("Vui lòng nhập email của bạn");
                  }
                },
                child: const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                    "Quên mật khẩu?",
                    style: TextStyle(
                      color: Themes.primaryColor,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
   @override
  void dispose() {
    // Call setOffline when the widget is disposed (e.g., when user logs out or closes the app)
    setOffline();
    super.dispose();
  }
}
