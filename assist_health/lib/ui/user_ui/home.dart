import 'package:assist_health/functions/methods.dart';
import 'package:assist_health/models/doctor/doctor_info.dart';
import 'package:assist_health/ui/user_ui/detail_doctor.dart';
import 'package:assist_health/ui/user_ui/list_doctor.dart';
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
                    Text(
                      "Huỳnh Tiến Phát",
                      style: TextStyle(
                        fontSize: 35,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    CircleAvatar(
                      radius: 25,
                      backgroundImage: AssetImage("assets/doctor1.jpg"),
                    ),
                  ],
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 300,
                      child: ListView(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                            ),
                            decoration: const BoxDecoration(
                              color: Colors.white,
                            ),
                            child: GridView.count(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              padding: EdgeInsets.zero,
                              crossAxisCount: 3,
                              crossAxisSpacing: 40,
                              mainAxisSpacing: 0,
                              children: [
                                itemDashboard(
                                    'Tư vấn online',
                                    CupertinoIcons.play_rectangle,
                                    Colors.deepOrange, () {
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
                                    Colors.green,
                                    () {}),
                                itemDashboard(
                                    'Hồ sơ sức khỏe',
                                    CupertinoIcons.person_2,
                                    Colors.purple,
                                    () {}),
                                itemDashboard(
                                    'Cộng đồng',
                                    CupertinoIcons.chat_bubble_2,
                                    Colors.brown,
                                    () {}),
                                itemDashboard(
                                    'Lịch khám',
                                    CupertinoIcons.calendar,
                                    Colors.indigo,
                                    () {}),
                                itemDashboard(
                                    'Gói dịch vụ',
                                    CupertinoIcons.add_circled,
                                    Colors.teal,
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
                  "What are your symptoms?",
                  style: TextStyle(
                    fontSize: 23,
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
                        color: const Color(0xFFF4F6FA),
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
                  "LỰA CHỌN PHỔ BIẾN",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w400,
                    color: Colors.black87,
                  ),
                ),
              ),
              FutureBuilder<List<DoctorInfo>>(
                future: getInfoDoctors(),
                builder: (context, snapshot) {
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

  itemDashboard(String title, IconData iconData, Color background,
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
                    color: background,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(iconData, color: Colors.white)),
              const SizedBox(height: 8),
              Text(
                title,
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.titleSmall,
              ),
            ],
          ),
        ),
      );
}
