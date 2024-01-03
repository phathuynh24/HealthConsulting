import 'package:assist_health/others/theme.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dots_indicator/dots_indicator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class HomeDoctor extends StatefulWidget {
  const HomeDoctor({super.key});

  @override
  State<HomeDoctor> createState() => _HomeDoctorState();
}

class _HomeDoctorState extends State<HomeDoctor> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  String name = '...';
  String imageURL = '';
  int currentIndex = 0;

  bool _isSwitched = false;

  final items = [
    Image.asset('assets/slider1.jpg', fit: BoxFit.cover),
    Image.asset('assets/slider2.jpg', fit: BoxFit.cover),
    //Image.asset('assets/slider3.jpeg', fit: BoxFit.cover),
  ];

  @override
  void initState() {
    super.initState();
    getDoctorData(_auth.currentUser!.uid);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Bạn có muốn thoát ứng dụng?'),
            actions: [
              Padding(
                padding: const EdgeInsets.only(left: 15, right: 15, bottom: 5),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    InkWell(
                      child: Padding(
                        padding: const EdgeInsets.all(8),
                        child: Text(
                          'Không',
                          style: TextStyle(
                            color: Colors.greenAccent.shade700.withOpacity(0.7),
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      onTap: () => Navigator.of(context).pop(false),
                    ),
                    InkWell(
                      child: const Padding(
                        padding: EdgeInsets.all(8),
                        child: Text(
                          'Thoát',
                          style: TextStyle(
                            color: Colors.red,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      onTap: () => Navigator.of(context).pop(true),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          foregroundColor: Colors.white,
          toolbarHeight: 70,
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
          title: Column(
            children: [
              Row(
                children: [
                  SizedBox(
                    width: 50,
                    height: 50,
                    child: ClipOval(
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Themes.gradientLightClr.withOpacity(0.4),
                              Themes.gradientLightClr
                            ],
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 5,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: (imageURL != '')
                            ? Image.network(imageURL, fit: BoxFit.cover,
                                errorBuilder: (BuildContext context,
                                    Object exception, StackTrace? stackTrace) {
                                return const Center(
                                  child: Icon(
                                    FontAwesomeIcons.userDoctor,
                                    size: 40,
                                    color: Colors.white,
                                  ),
                                );
                              })
                            : const Center(
                                child: CircleAvatar(
                                  radius: 25,
                                  backgroundColor: Colors.transparent,
                                  child: Icon(
                                    Icons.person,
                                    size: 25,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                      ),
                    ),
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Bác sĩ",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: Colors.white,
                          letterSpacing: 1.1,
                          wordSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(
                        height: 2,
                      ),
                      Text(
                        name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                          letterSpacing: 1.1,
                          wordSpacing: 1.2,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(
                height: 8,
              ),
            ],
          ),
        ),
        body: SingleChildScrollView(
          child: Container(
            child: Column(
              children: [
                const SizedBox(
                  height: 10,
                ),
                Stack(
                  children: [
                    CarouselSlider(
                      items: [
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: AspectRatio(
                              aspectRatio: 3 / 1,
                              child: items[0],
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: AspectRatio(
                              aspectRatio: 3 / 1,
                              child: items[1],
                            ),
                          ),
                        ),
                        // Padding(
                        //   padding: const EdgeInsets.symmetric(
                        //     horizontal: 12,
                        //   ),
                        //   child: ClipRRect(
                        //     borderRadius: BorderRadius.circular(10),
                        //     child: AspectRatio(
                        //       aspectRatio: 3 / 1,
                        //       child: items[2],
                        //     ),
                        //   ),
                        // ),
                      ],
                      options: CarouselOptions(
                        height: 200,
                        viewportFraction: 1,
                        autoPlay: true,
                        onPageChanged: (index, reason) {
                          setState(() {
                            currentIndex = index;
                          });
                        },
                      ),
                    ),
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 3,
                      child: DotsIndicator(
                        dotsCount: items.length,
                        position: currentIndex,
                        decorator: DotsDecorator(
                          color: Colors.black.withOpacity(0.3),
                          activeColor: Colors.white,
                          size: const Size(14, 3),
                          activeSize: const Size(14, 3),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5)),
                          activeShape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5)),
                        ),
                      ),
                    )
                  ],
                ),
                const SizedBox(
                  height: 10,
                ),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 10),
                  child: GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    childAspectRatio: 0.85,
                    children: List.generate(3, (index) {
                      return Container(
                        height: 100,
                        margin: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(),
                        ),
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 40,
                                  height: 40,
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.blue,
                                  ),
                                  child: Icon(
                                    getIcon(index),
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                ),
                                const Spacer(),
                                if (index == 2)
                                  Switch(
                                    value: _isSwitched,
                                    activeColor: Colors.white,
                                    activeTrackColor:
                                        Colors.greenAccent.shade400,
                                    onChanged: (value) {
                                      setState(() {
                                        _isSwitched = value;
                                      });
                                    },
                                  ),
                              ],
                            ),
                            const Text(
                              '100',
                              style: TextStyle(
                                fontSize: 60,
                                color: Themes.gradientDeepClr,
                              ),
                            ),
                            Row(
                              children: [
                                Text(
                                  getTitle(index),
                                  style: const TextStyle(
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(
                                  width: 5,
                                ),
                                const Spacer(),
                                const Icon(
                                  Icons.arrow_circle_right_outlined,
                                  color: Themes.gradientDeepClr,
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    }),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> getDoctorData(String uid) async {
    try {
      DocumentSnapshot snapshot =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();

      if (snapshot.exists) {
        setState(() {
          imageURL = snapshot.get('imageURL');
          name = snapshot.get('name');
        });
      } else {
        print('User does not exist');
      }
    } catch (error) {
      print('Failed to fetch user data: $error');
    }
  }

  String getTitle(int index) {
    switch (index) {
      case 0:
        return 'Lịch hôm nay';
      case 1:
        return 'Lịch tháng';
      case 2:
        return 'Hồ sơ';
      default:
        return 'Trống';
    }
  }

  getIcon(int index) {
    switch (index) {
      case 0:
        return FontAwesomeIcons.phone;
      case 1:
        return FontAwesomeIcons.calendarCheck;
      case 2:
        return FontAwesomeIcons.briefcaseMedical;
      default:
        return 'Trống';
    }
  }
}
