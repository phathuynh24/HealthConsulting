// ignore_for_file: use_build_context_synchronously

import 'dart:async';

import 'package:assist_health/models/user/user_profile.dart';
import 'package:assist_health/others/methods.dart';
import 'package:assist_health/others/theme.dart';
import 'package:assist_health/screens/user_screens/health_profile_add_edit.dart';
import 'package:assist_health/screens/user_screens/health_profile_detail.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class HealthProfileListScreen extends StatefulWidget {
  const HealthProfileListScreen({super.key});

  @override
  State<HealthProfileListScreen> createState() =>
      _HealthProfileListScreenState();
}

class _HealthProfileListScreenState extends State<HealthProfileListScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  late String _uid;

  final StreamController<List<UserProfile>> _userStreamController =
      StreamController<List<UserProfile>>.broadcast();

  @override
  void initState() {
    super.initState();
    _uid = _auth.currentUser!.uid;
    _userStreamController.addStream(getProfileUsers(_uid));
  }

  @override
  void dispose() {
    _userStreamController.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        foregroundColor: Colors.white,
        title: const Text(
          'Hồ sơ sức khỏe',
          style: TextStyle(fontSize: 20),
        ),
        elevation: 0,
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
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add),
            onPressed: () async {
              bool? isAdded = await Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => AddOrEditProfileScreen(
                          isEdit: false,
                        )),
              );

              if (isAdded != null && isAdded == true) {
                _userStreamController.addStream(getProfileUsers(_uid));
                ScaffoldMessenger.of(context).hideCurrentSnackBar();
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  content: Text('Lưu hồ sơ thành công!'),
                  backgroundColor: Colors.green,
                ));
              }
            },
          ),
        ],
      ),
      body: Center(
        child: Container(
          width: double.infinity,
          height: double.infinity,
          color: Colors.grey.withOpacity(0.1),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: StreamBuilder<List<UserProfile>>(
                stream: _userStreamController.stream,
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Text('Đã xảy ra lỗi: ${snapshot.error}');
                  }

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  List<UserProfile> userProfiles = snapshot.data!;
                  return ListView.builder(
                    shrinkWrap: true,
                    itemCount: userProfiles.length,
                    itemBuilder: (context, index) {
                      UserProfile profile = userProfiles[index];
                      return Container(
                        margin: EdgeInsets.only(
                          top: 15,
                          bottom: (index == userProfiles.length - 1) ? 15 : 0,
                          left: 5,
                          right: 5,
                        ),
                        padding: const EdgeInsets.symmetric(
                          vertical: 10,
                          horizontal: 12,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: Colors.white,
                        ),
                        child: InkWell(
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        HealthProfileDetailScreen(
                                          profile: profile,
                                          isUserOfProfile: true,
                                        )));
                            _userStreamController
                                .addStream(getProfileUsers(_uid));
                          },
                          child: Row(
                            children: [
                              SizedBox(
                                height: 70,
                                width: 75,
                                child: Stack(
                                  children: [
                                    Positioned(
                                      left: 0,
                                      bottom: 2,
                                      child: ClipOval(
                                        child: Container(
                                          width: 65,
                                          height: 65,
                                          decoration: const BoxDecoration(
                                            gradient: LinearGradient(
                                              colors: [
                                                Themes.gradientDeepClr,
                                                Themes.gradientLightClr
                                              ],
                                              begin: Alignment.bottomCenter,
                                              end: Alignment.topCenter,
                                            ),
                                          ),
                                          child: (profile.image != '')
                                              ? Image.network(
                                                  profile.image,
                                                  fit: BoxFit.cover,
                                                )
                                              : Center(
                                                  child: Text(
                                                    getAbbreviatedName(
                                                        profile.name),
                                                    style: const TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 24,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                ),
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                      top: 0,
                                      right: 0,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(20),
                                            color: Themes.gradientDeepClr
                                                .withOpacity(0.8)),
                                        child: Text(
                                          profile.relationship,
                                          style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 14,
                                              fontWeight: FontWeight.w400),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(
                                width: 15,
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    profile.name,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      color: Colors.black,
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 8,
                                  ),
                                  Text(
                                    profile.idProfile,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Colors.black54,
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 8,
                                  ),
                                  Text(
                                    profile.doB,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Colors.black54,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                }),
          ),
        ),
      ),
    );
  }
}
