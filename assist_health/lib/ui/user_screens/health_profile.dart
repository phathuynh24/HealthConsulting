// ignore_for_file: use_build_context_synchronously

import 'dart:io';

import 'package:assist_health/others/theme.dart';
import 'package:assist_health/others/methods.dart';
import 'package:assist_health/models/user/user_profile.dart';
import 'package:assist_health/ui/user_screens/health_profile_add.dart';
import 'package:assist_health/ui/widgets/health_metrics_topnavbar.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

class HealthProfileScreen extends StatefulWidget {
  const HealthProfileScreen({super.key});

  @override
  State<HealthProfileScreen> createState() => _HealthProfileScreenState();
}

class _HealthProfileScreenState extends State<HealthProfileScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  late String _uid;

  late UserProfile _currentProfile;
  List<UserProfile> _userProfiles = [];

  int _selectedItemIndex = 0;

  @override
  void initState() {
    super.initState();
    _uid = _auth.currentUser!.uid;
    _currentProfile = UserProfile('', '', '', '', '', '');
    _loadDataFromFirestore(false);
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Themes.backgroundClr,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Appbar và List account
            Container(
              padding: const EdgeInsets.only(
                top: 40,
                bottom: 20,
              ),
              margin: EdgeInsets.zero,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Themes.leftClr, Themes.rightClr],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
              ),
              child: Column(
                children: [
                  // Appbar
                  Container(
                    padding: const EdgeInsets.only(
                      left: 25,
                      right: 20,
                      bottom: 10,
                    ),
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          const Expanded(
                            child: Text(
                              'HỒ SƠ SỨC KHỎE',
                              style: TextStyle(
                                  fontSize: 22,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.add,
                              size: 35,
                              color: Colors.white,
                            ),
                            onPressed: () async {
                              bool isAdded = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        const AddProfileScreen()),
                              );

                              if (isAdded) {
                                setState(() {
                                  _loadDataFromFirestore(true);
                                });
                                ScaffoldMessenger.of(context)
                                    .hideCurrentSnackBar();
                                ScaffoldMessenger.of(context)
                                    .showSnackBar(const SnackBar(
                                  content: Text('Lưu hồ sơ thành công!'),
                                  backgroundColor: Colors.green,
                                ));
                              }
                            },
                          ),
                        ]),
                  ),
                  // List account
                  SizedBox(
                    height: 155,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _userProfiles.length,
                      itemBuilder: (_, index) {
                        bool isSelected = (index == _selectedItemIndex);
                        return Column(
                          children: [
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  _selectedItemIndex = index;
                                  _currentProfile = _userProfiles[index];
                                });
                              },
                              child: Container(
                                width: 90,
                                height: 130,
                                margin: EdgeInsets.only(
                                  left: (index == 0) ? 20 : 10,
                                  right: (index == _userProfiles.length - 1)
                                      ? 20
                                      : 0,
                                  top: 10,
                                  bottom: 4,
                                ),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(24),
                                  border: Border.all(
                                    color: isSelected
                                        ? Colors.yellowAccent.withOpacity(0.8)
                                        : Colors.transparent,
                                    width: 4,
                                  ),
                                  color: Themes.highlightClr,
                                  boxShadow: isSelected
                                      ? [
                                          BoxShadow(
                                            color: Colors.yellowAccent.withOpacity(
                                                0.5), // Màu vàng với độ trong suốt
                                            blurRadius: 8,
                                            spreadRadius: 2,
                                          ),
                                        ]
                                      : [],
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(20),
                                  child: Image.network(
                                    _userProfiles[index].image,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            ),
                            if (isSelected)
                              Container(
                                height: 3,
                                width: 50,
                                margin: EdgeInsets.only(
                                  left: (index == 0) ? 20 : 10,
                                  right: (index == _userProfiles.length - 1)
                                      ? 20
                                      : 0,
                                  top: 8,
                                ),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(2),
                                  color: Colors.white,
                                ),
                              ),
                          ],
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            // Thông tin cá nhân và nút chỉ số sức khỏe
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 15,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _currentProfile.name,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Themes.textClr,
                          ),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 5),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            color: Colors.amber,
                          ),
                          child: Text(
                            (_currentProfile.idDoc == 'main_profile')
                                ? _currentProfile.relationship
                                : '${_currentProfile.relationship} của tôi',
                            style: const TextStyle(
                              fontSize: 14,
                              color: Themes.textClr,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Center(
                    child: GestureDetector(
                      onTap: () {},
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Ink(
                            height: 45,
                            width: 45,
                            padding: EdgeInsets.zero,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.red.withOpacity(0.2),
                            ),
                            child: IconButton(
                              icon: const Icon(
                                Icons.favorite,
                                size: 28,
                                color: Colors.red,
                              ),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          HealthMetricsTopNavBar(
                                            userProfile: _currentProfile,
                                          )),
                                );
                              },
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Chỉ số sức khỏe',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.red.withOpacity(0.7),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  _loadDataFromFirestore(bool isReturnData) async {
    try {
      List<UserProfile> userProfiles = await getProfileUsers(_uid);
      userProfiles = userProfiles.reversed.toList();

      setState(() {
        _userProfiles = userProfiles;
        _currentProfile = (isReturnData) ? _userProfiles[1] : _userProfiles[0];
      });
    } catch (error) {
      // Xử lý lỗi tại đây (nếu cần)
    }
  }
}
