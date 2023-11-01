// ignore_for_file: avoid_print, use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:assist_health/functions/methods.dart';
import 'package:assist_health/user_screens/phone_screen.dart';
import 'package:assist_health/widgets/user_navbar.dart';
import 'package:assist_health/widgets/doctor_navbar.dart';
import 'package:assist_health/widgets/admin_navbar.dart';

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
  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
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
                    label: Text("Enter Username"),
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
                    label: const Text("Enter Password"),
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
                      });
                    } else {
                      print("Please fill");
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: const Color(0xFF7165D6),
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
                        "Log In",
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
                    "Don't have any account?",
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
                            builder: (context) => const PhoneScreen(),
                          ));
                    },
                    child: const Text(
                      "Sign up",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF7165D6),
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
