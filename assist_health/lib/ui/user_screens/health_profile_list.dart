// ignore_for_file: use_build_context_synchronously

import 'package:assist_health/models/user/user_profile.dart';
import 'package:assist_health/others/methods.dart';
import 'package:assist_health/others/theme.dart';
import 'package:assist_health/ui/user_screens/health_profile_add_edit.dart';
import 'package:assist_health/ui/user_screens/health_profile_detail.dart';
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

  List<UserProfile> _userProfiles = [];

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _uid = _auth.currentUser!.uid;
    _loadDataFromFirestore();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Container(
        color: Colors.black54,
        child: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    } else {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Hồ sơ y tế'),
          elevation: 0,
          centerTitle: true,
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Themes.leftClr, Themes.rightClr],
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
                  _loadDataFromFirestore();
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
        body: Container(
          width: double.infinity,
          height: double.infinity,
          color: Colors.grey.withOpacity(0.1),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: _userProfiles.length,
              itemBuilder: (context, index) {
                UserProfile profile = _userProfiles[index];
                return Container(
                  margin: EdgeInsets.only(
                    top: 15,
                    bottom: (index == _userProfiles.length - 1) ? 15 : 0,
                  ),
                  padding: const EdgeInsets.symmetric(
                    vertical: 10,
                    horizontal: 15,
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
                                          profile: profile)))
                          .then((value) => _loadDataFromFirestore());
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
                                  child: (profile.image != '')
                                      ? Image.network(
                                          profile.image,
                                          fit: BoxFit.cover,
                                          width: 65,
                                          height: 65,
                                        )
                                      : Container(
                                          width: 65,
                                          height: 65,
                                          decoration: const BoxDecoration(
                                            gradient: LinearGradient(
                                              colors: [
                                                Themes.leftClr,
                                                Themes.rightClr
                                              ],
                                              begin: Alignment.bottomCenter,
                                              end: Alignment.topCenter,
                                            ),
                                          ),
                                          child: Center(
                                            child: Text(
                                              getAbbreviatedName(profile.name),
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 24,
                                                fontWeight: FontWeight.bold,
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
                                      borderRadius: BorderRadius.circular(20),
                                      color: Colors.lightBlue.withOpacity(0.8)),
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
                          width: 20,
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              profile.name,
                              style: const TextStyle(
                                fontSize: 18,
                                color: Colors.black,
                              ),
                            ),
                            const SizedBox(
                              height: 8,
                            ),
                            Text(
                              profile.idProfile,
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.black54,
                              ),
                            ),
                            const SizedBox(
                              height: 8,
                            ),
                            Text(
                              profile.doB,
                              style: const TextStyle(
                                fontSize: 16,
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
            ),
          ),
        ),
      );
    }
  }

  _loadDataFromFirestore() async {
    try {
      List<UserProfile> userProfiles = await getProfileUsers(_uid);
      userProfiles = userProfiles.reversed.toList();

      setState(() {
        _userProfiles = userProfiles;
        _isLoading = false;
      });
    } catch (error) {
      // Xử lý lỗi tại đây (nếu cần)
    }
  }
}
