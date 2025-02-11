import 'package:assist_health/src/models/user/user_profile.dart';
import 'package:assist_health/src/others/theme.dart';
import 'package:assist_health/src/others/methods.dart';
import 'package:assist_health/src/presentation/screens/doctor_screens/doctor_chart.dart';
import 'package:assist_health/src/presentation/screens/doctor_screens/update_doctor_info_screen.dart';
import 'package:assist_health/src/widgets/doctor_navbar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class DoctorAccountScreen extends StatefulWidget {
  const DoctorAccountScreen({super.key});

  @override
  State<DoctorAccountScreen> createState() => _DoctorAccountScreenState();
}

class _DoctorAccountScreenState extends State<DoctorAccountScreen> {
  UserProfile? userProfile;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    getUserData();
  }

  Future<void> getUserData() async {
    setState(() {
      isLoading = true;
    });

    String userId = FirebaseAuth.instance.currentUser!.uid;

    DocumentSnapshot snapshot =
        await FirebaseFirestore.instance.collection('users').doc(userId).get();

    if (snapshot.exists) {
      setState(() {
        userProfile =
            UserProfile.fromJson(snapshot.data() as Map<String, dynamic>);
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const DoctorNavBar()),
          (route) => false,
        );
        return true;
      },
      child: Scaffold(
        backgroundColor: Colors.blueAccent.withOpacity(0.1),
        appBar: AppBar(
          foregroundColor: Colors.white,
          title: const Text(
            'Tài khoản',
            style: TextStyle(fontSize: 20),
          ),
          elevation: 0,
          centerTitle: true,
          automaticallyImplyLeading: false,
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
        body: Center(
          child: isLoading
              ? const CircularProgressIndicator()
              : SingleChildScrollView(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 15, vertical: 10),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: Colors.white,
                          ),
                          child: ListTile(
                            leading: (userProfile!.image != '')
                                ? CircleAvatar(
                                    radius: 25,
                                    backgroundImage:
                                        NetworkImage(userProfile!.image))
                                : Container(
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
                                    child: Center(
                                      child: Text(
                                        getAbbreviatedName(userProfile!.image),
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 24,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                            title: Text(
                              userProfile!.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 15,
                              ),
                            ),
                            subtitle: Container(
                              margin: const EdgeInsets.only(
                                top: 4,
                              ),
                              child: Text(
                                userProfile!.phone,
                                style: const TextStyle(fontSize: 15),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Container(
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: Colors.white,
                          ),
                          child: Column(
                            children: [
                              Container(
                                height: 50,
                                margin: const EdgeInsets.only(
                                  left: 8,
                                ),
                                child: ListTile(
                                  onTap: () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                          builder: (_) =>
                                              const UpdateDoctorInfoScreen(isEditScreen: true,)),
                                    );
                                  },
                                  leading: const Icon(
                                    CupertinoIcons.person_circle_fill,
                                    color: Colors.blueAccent,
                                    size: 30,
                                  ),
                                  title: const Text(
                                    "Thông tin tài khoản",
                                    style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                      fontSize: 15,
                                    ),
                                  ),
                                  trailing: const Icon(
                                    Icons.arrow_forward_ios_rounded,
                                    size: 16,
                                  ),
                                ),
                              ),
                              Divider(
                                height: 10,
                                indent: 15,
                                endIndent: 15,
                                color: Colors.grey.shade100,
                              ),
                              Container(
                                height: 50,
                                margin: const EdgeInsets.only(
                                  left: 8,
                                ),
                                child: ListTile(
                                  onTap: () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                          builder: (_) =>
                                              const DoctorChartScreen()),
                                    );
                                  },
                                  leading: Icon(
                                    CupertinoIcons.chart_bar_alt_fill,
                                    color: Colors.yellow.shade700,
                                    size: 30,
                                  ),
                                  title: const Text(
                                    "Thống kê doanh thu",
                                    style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                      fontSize: 15,
                                    ),
                                  ),
                                  trailing: const Icon(
                                    Icons.arrow_forward_ios_rounded,
                                    size: 16,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        Container(
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: Colors.white,
                          ),
                          child: Column(
                            children: [
                              Container(
                                height: 50,
                                margin: const EdgeInsets.only(
                                  left: 8,
                                ),
                                child: ListTile(
                                  onTap: () {},
                                  leading: const Icon(
                                    Icons.info,
                                    color: Colors.deepPurple,
                                    size: 30,
                                  ),
                                  title: const Text(
                                    "Điều khoản và dịch vụ",
                                    style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                      fontSize: 15,
                                    ),
                                  ),
                                  trailing: const Icon(
                                    Icons.arrow_forward_ios_rounded,
                                    size: 16,
                                  ),
                                ),
                              ),
                              Divider(
                                height: 10,
                                indent: 15,
                                endIndent: 15,
                                color: Colors.grey.shade100,
                              ),
                              Container(
                                height: 50,
                                margin: const EdgeInsets.only(
                                  left: 8,
                                ),
                                child: ListTile(
                                  onTap: () {},
                                  leading: const Icon(
                                    CupertinoIcons.person_3_fill,
                                    color: Colors.lightGreen,
                                    size: 30,
                                  ),
                                  title: const Text(
                                    "Tham gia cộng đồng",
                                    style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                      fontSize: 15,
                                    ),
                                  ),
                                ),
                              ),
                              Divider(
                                height: 10,
                                indent: 15,
                                endIndent: 15,
                                color: Colors.grey.shade100,
                              ),
                              Container(
                                height: 50,
                                margin: const EdgeInsets.only(
                                  left: 8,
                                ),
                                child: ListTile(
                                  onTap: () {},
                                  leading: const Icon(
                                    Icons.share,
                                    color: Colors.orange,
                                    size: 30,
                                  ),
                                  title: const Text(
                                    "Chia sẽ ứng dụng",
                                    style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                      fontSize: 15,
                                    ),
                                  ),
                                ),
                              ),
                              Divider(
                                height: 10,
                                indent: 15,
                                endIndent: 15,
                                color: Colors.grey.shade100,
                              ),
                              Container(
                                height: 50,
                                margin: const EdgeInsets.only(
                                  left: 8,
                                ),
                                child: ListTile(
                                  onTap: () {},
                                  leading: const Icon(
                                    Icons.contact_support,
                                    color: Colors.indigoAccent,
                                    size: 30,
                                  ),
                                  title: const Text(
                                    "Liên hệ và hỗ trợ",
                                    style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                      fontSize: 15,
                                    ),
                                  ),
                                ),
                              ),
                              Divider(
                                height: 10,
                                indent: 15,
                                endIndent: 15,
                                color: Colors.grey.shade100,
                              ),
                              Container(
                                height: 50,
                                margin: const EdgeInsets.only(
                                  left: 8,
                                ),
                                child: ListTile(
                                  onTap: () {},
                                  leading: const Icon(
                                    Icons.settings,
                                    color: Colors.black54,
                                    size: 30,
                                  ),
                                  title: const Text(
                                    "Cài đặt",
                                    style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                      fontSize: 15,
                                    ),
                                  ),
                                  trailing: const Icon(
                                    Icons.arrow_forward_ios_rounded,
                                    size: 16,
                                  ),
                                ),
                              ),
                              Divider(
                                height: 10,
                                indent: 15,
                                endIndent: 15,
                                color: Colors.grey.shade100,
                              ),
                              Container(
                                height: 50,
                                margin: const EdgeInsets.only(
                                  left: 8,
                                ),
                                child: ListTile(
                                  onTap: () {
                                    logOut(context);
                                  },
                                  leading: const Icon(
                                    Icons.logout,
                                    color: Colors.redAccent,
                                    size: 30,
                                  ),
                                  title: const Text(
                                    "Đăng xuất",
                                    style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                      fontSize: 15,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
        ),
      ),
    );
  }
}
