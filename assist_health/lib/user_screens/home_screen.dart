import 'dart:ffi';
import 'package:assist_health/models/doctor_info.dart';
import 'package:assist_health/user_screens/appointment_screen.dart';
import 'package:assist_health/widgets/doctor_popular_card.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:pinput/pinput.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _MyHomeScreen();
}

class _MyHomeScreen extends State<HomeScreen> {
  final FirebaseAuth auth = FirebaseAuth.instance;
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
                      "Hello",
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
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 300,
                      child: ListView(
                        children: [
                          Container(
                            color: Theme.of(context).primaryColor,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 20,
                              ),
                              decoration: const BoxDecoration(
                                color: Colors.white,
                              ),
                              child: GridView.count(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                crossAxisCount: 4,
                                crossAxisSpacing: 0,
                                mainAxisSpacing: 20,
                                children: [
                                  itemDashboard(
                                      'Tư vấn online',
                                      CupertinoIcons.play_rectangle,
                                      Colors.deepOrange),
                                  itemDashboard(
                                      'Analytics',
                                      CupertinoIcons.graph_circle,
                                      Colors.green),
                                  itemDashboard('Audience',
                                      CupertinoIcons.person_2, Colors.purple),
                                  itemDashboard(
                                      'Comments',
                                      CupertinoIcons.chat_bubble_2,
                                      Colors.brown),
                                  itemDashboard(
                                      'Revenue',
                                      CupertinoIcons.money_dollar_circle,
                                      Colors.indigo),
                                  itemDashboard('Upload',
                                      CupertinoIcons.add_circled, Colors.teal),
                                  itemDashboard(
                                      'About',
                                      CupertinoIcons.question_circle,
                                      Colors.blue),
                                  itemDashboard('Contact', CupertinoIcons.phone,
                                      Colors.pinkAccent),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 25),
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
              SizedBox(
                height: 290,
                child: ListView.builder(
                  itemCount: 3,
                  shrinkWrap: true,
                  padding: const EdgeInsets.only(left: 7),
                  scrollDirection: Axis.horizontal,
                  itemBuilder: (context, index) {
                    return InkWell(
                      onTap: () {
                        // Navigator.push(
                        //     context,
                        //     MaterialPageRoute(
                        //       builder: (context) => const AppointmentScreen(),
                        //     ));
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
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            FutureBuilder<List<DoctorInfo>>(
                              future: getInfoDoctors(),
                              builder: (context, snapshot) {
                                if (snapshot.hasData) {
                                  return DoctorPopularCardWidget(
                                    image: snapshot.data![index].image,
                                    name: snapshot.data![index].name,
                                    expert: snapshot.data![index].expert,
                                    rating: snapshot.data![index].rating,
                                  );
                                } else if (snapshot.hasError) {
                                  return Text('Error: ${snapshot.error}');
                                } else {
                                  return const SizedBox(
                                      height: 290,
                                      width: 160,
                                      child: Center(
                                        child: SizedBox(
                                          height: 40,
                                          width: 40,
                                          child: CircularProgressIndicator(),
                                        ),
                                      ));
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  itemDashboard(String title, IconData iconData, Color background) => InkWell(
        onTap: () {},
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

  Future<String> getUrl(String fileName) async {
    final ref = storage.ref().child('Doctors/$fileName');
    String url = await ref.getDownloadURL();
    return url;
  }

  Future<List<DoctorInfo>> getInfoDoctors() async {
    String name;
    String desc;
    int avgTime;
    int count;
    String expert;
    String image;
    int rating;
    String workplace;
    String address;
    List<DoctorInfo> doctorInfos = [];
    final doctorDocs = await firestore
        .collection('users')
        .where('role', isEqualTo: 'doctor')
        .get();

    for (final doctorDoc in doctorDocs.docs) {
      final infoRef =
          firestore.collection('users').doc(doctorDoc.id).collection('info');

      name = doctorDoc.data()['name'];
      desc = await infoRef.get().then((value) => value.docs.first['desc']);
      avgTime =
          await infoRef.get().then((value) => value.docs.first['avgTime']);
      count = await infoRef.get().then((value) => value.docs.first['count']);
      expert = await infoRef.get().then((value) => value.docs.first['expert']);
      image = await getUrl(await infoRef
          .get()
          .then((value) => value.docs.first['image'].toString()));
      rating = await infoRef.get().then((value) => value.docs.first['rating']);
      workplace =
          await infoRef.get().then((value) => value.docs.first['workplace']);
      address =
          await infoRef.get().then((value) => value.docs.first['address']);

      DoctorInfo doctorInfo = DoctorInfo(name, desc, avgTime, count, expert,
          image, rating, workplace, address);
      doctorInfos.add(doctorInfo);
    }
    return doctorInfos;
  }
}
