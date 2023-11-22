import 'package:assist_health/others/methods.dart';
import 'package:assist_health/models/doctor/doctor_info.dart';
import 'package:assist_health/others/theme.dart';
import 'package:assist_health/ui/user_screens/detail_doctor.dart';
import 'package:assist_health/ui/user_screens/list_doctor.dart';
import 'package:assist_health/ui/widgets/doctor_popular_card.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _MyHomeScreen();
}

class _MyHomeScreen extends State<HomeScreen> {
  final FirebaseStorage storage = FirebaseStorage.instance;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  List symptoms = [
    "Temperature",
    "Snuffle",
    "Fever",
    "Cough",
    "Cold",
  ];

  List imgs = [
    "doctor1.jpg",
    "doctor2.jpg",
    "doctor3.jpg",
    "doctor4.jpg",
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Themes.backgroundClr,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(top: 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 15),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 25,
                          backgroundImage: AssetImage("assets/doctor1.jpg"),
                        ),
                        SizedBox(
                          width: 20,
                        ),
                        Text(
                          "Huỳnh Tiến Phát",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    IconButton(
                      icon: Icon(Icons.notifications),
                      iconSize: 30,
                      onPressed: null,
                    ),
                  ],
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    child: Container(
                      height: 240,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 15,
                      ),
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                            ),
                            decoration: BoxDecoration(
                              color: Themes.backgroundClr,
                              borderRadius: BorderRadius.circular(15),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.4),
                                  spreadRadius: 1,
                                  blurRadius: 5,
                                ),
                              ],
                            ),
                            child: GridView.count(
                              shrinkWrap: true,
                              padding: EdgeInsets.zero,
                              physics: const NeverScrollableScrollPhysics(),
                              crossAxisCount: 3,
                              crossAxisSpacing: 20,
                              mainAxisSpacing: 0,
                              children: [
                                itemDashboard(
                                    'Tư vấn online',
                                    CupertinoIcons.play_rectangle,
                                    const Color(0xFFFABD24),
                                    const Color(0xFFFA7516), () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (_) =>
                                            const ListDoctorScreen()),
                                  );
                                }),
                                itemDashboard(
                                    'Hỏi riêng bác sĩ',
                                    CupertinoIcons.graph_circle,
                                    const Color(0xFF38B9F8),
                                    const Color(0xFF6169F0),
                                    () {}),
                                itemDashboard(
                                    'Hồ sơ sức khỏe',
                                    CupertinoIcons.person_2,
                                    const Color(0xFFEB68AE),
                                    const Color(0xFFF0005E),
                                    () {}),
                                itemDashboard(
                                    'Cộng đồng',
                                    CupertinoIcons.chat_bubble_2,
                                    const Color(0xFF22D1EC),
                                    const Color(0xFF0EA6E9),
                                    () {}),
                                itemDashboard(
                                    'Lịch khám',
                                    CupertinoIcons.calendar,
                                    const Color(0xFFD545EF),
                                    const Color(0xFF803BEE),
                                    () {}),
                                itemDashboard(
                                    'Gói dịch vụ',
                                    CupertinoIcons.add_circled,
                                    const Color(0xFF2ED0A0),
                                    const Color(0xFF08B7DF),
                                    () {}),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const Padding(
                padding: EdgeInsets.only(left: 15),
                child: Text(
                  "Khám theo chuyên khoa",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                    color: Colors.black54,
                  ),
                ),
              ),
              SizedBox(
                height: 70,
                child: ListView.builder(
                  shrinkWrap: true,
                  scrollDirection: Axis.horizontal,
                  itemCount: symptoms.length,
                  itemBuilder: (context, index) {
                    return Container(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 15, vertical: 10),
                      padding: const EdgeInsets.symmetric(horizontal: 25),
                      decoration: BoxDecoration(
                        color: Themes.highlightClr,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 4,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          symptoms[index],
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Colors.black54,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 15),
              const Padding(
                padding: EdgeInsets.only(left: 15),
                child: Text(
                  "Lựa chọn phổ biến",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                    color: Colors.black54,
                  ),
                ),
              ),
              FutureBuilder<List<DoctorInfo>>(
                future: getInfoDoctors(),
                builder: (_, snapshot) {
                  if (snapshot.hasError) {
                    return const SizedBox(
                        height: 290,
                        width: double.infinity,
                        child: Center(
                          child: Text('Something went wrong'),
                        ));
                  }

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const SizedBox(
                        height: 290,
                        width: double.infinity,
                        child: Center(
                          child: SizedBox(
                            height: 40,
                            width: 40,
                            child: CircularProgressIndicator(),
                          ),
                        ));
                  }

                  return SizedBox(
                    height: 290,
                    child: ListView.builder(
                        itemCount: snapshot.data!.length,
                        shrinkWrap: true,
                        padding: const EdgeInsets.only(left: 7),
                        scrollDirection: Axis.horizontal,
                        itemBuilder: (context, index) {
                          return InkWell(
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (_) => DetailDoctorScreen(
                                          snapshot.data![index])));
                            },
                            child: Container(
                              margin: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 15),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Colors.black12,
                                    blurRadius: 4,
                                    spreadRadius: 2,
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  DoctorPopularCardWidget(
                                    image: snapshot.data![index].image,
                                    name: snapshot.data![index].name,
                                    expert: snapshot.data![index].expert,
                                    rating:
                                        snapshot.data![index].rating.toDouble(),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  itemDashboard(String title, IconData iconData, Color topClr, Color bottomClr,
          Function() onTap) =>
      InkWell(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        topClr,
                        bottomClr,
                      ],
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    iconData,
                    color: Colors.white,
                    size: 30,
                  )),
              const SizedBox(height: 8),
              Text(
                title,
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: Colors.black54,
                ),
              ),
            ],
          ),
        ),
      );
}
