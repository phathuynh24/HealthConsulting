import 'package:assist_health/others/theme.dart';
import 'package:assist_health/others/methods.dart';
import 'package:assist_health/models/doctor/doctor_info.dart';
import 'package:assist_health/ui/user_screens/doctor_list.dart';
import 'package:assist_health/ui/user_screens/health_profile_list.dart';
import 'package:assist_health/ui/user_screens/message.dart';
import 'package:assist_health/ui/user_screens/public_questions.dart';
import 'package:assist_health/ui/widgets/doctor_popular_card.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dots_indicator/dots_indicator.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:carousel_slider/carousel_slider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _MyHomeScreen();
}

class _MyHomeScreen extends State<HomeScreen> {
  final FirebaseStorage storage = FirebaseStorage.instance;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  List symptoms = [
    "Tay mũi họng",
    "Bệnh nhiệt đới",
    "Nội thần kinh",
    "Mắt",
    "Nha khoa",
    "Chấn khương chỉnh hình",
  ];

  List imgs = [
    "doctor1.jpg",
    "doctor2.jpg",
    "doctor3.jpg",
    "doctor4.jpg",
  ];

  final items = [
    Image.network(
        'https://st2.depositphotos.com/1518767/5391/i/950/depositphotos_53914119-stock-photo-doctors-smiling-and-working-together.jpg',
        fit: BoxFit.cover),
    Image.network(
        'https://t3.ftcdn.net/jpg/02/42/30/90/360_F_242309050_QxHLRfmtm5eRz61WxhmlUTfSIwZQQUfh.jpg',
        fit: BoxFit.cover),
    Image.network(
        'https://t.vietgiaitri.com/2021/5/11/2-poster-cua-hospital-playlist-khien-khan-gia-hao-huc-lot-dep-hong-phim-148-5796649.jpeg',
        fit: BoxFit.cover),
  ];

  int currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.withOpacity(0.1),
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.grey,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 5,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const CircleAvatar(
                radius: 25,
                backgroundColor: Colors.transparent,
                child: Icon(
                  Icons.person,
                  size: 25,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(
              width: 10,
            ),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Chào bạn!",
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: Colors.white,
                    letterSpacing: 1.1,
                    wordSpacing: 1.2,
                  ),
                ),
                SizedBox(
                  height: 2,
                ),
                Text(
                  "Huỳnh Tiến Phát",
                  style: TextStyle(
                    fontSize: 14,
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
        automaticallyImplyLeading: false,
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Themes.gradientDeepClr, Themes.gradientLightClr],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
          ),
        ),
        actions: const [
          IconButton(
            icon: Icon(
              CupertinoIcons.bell_fill,
              color: Colors.white,
            ),
            iconSize: 26,
            onPressed: null,
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
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
                        horizontal: 15,
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
                        horizontal: 15,
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: AspectRatio(
                          aspectRatio: 3 / 1,
                          child: items[1],
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 15,
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: AspectRatio(
                          aspectRatio: 3 / 1,
                          child: items[2],
                        ),
                      ),
                    ),
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
                                  'Đặt khám bác sĩ',
                                  FontAwesomeIcons.userDoctor,
                                  const Color(0xFFFFDF3F),
                                  const Color(0xFFFA7516),
                                  () {}),
                              itemDashboard(
                                  'Gọi video với bác sĩ',
                                  FontAwesomeIcons.mobileScreen,
                                  const Color(0xFFD585EF),
                                  const Color(0xFF801BEE), () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (_) => const DoctorListScreen()),
                                );
                              }),
                              itemDashboard(
                                  'Chat với bác sĩ',
                                  FontAwesomeIcons.commentDots,
                                  const Color(0xFF38D9F8),
                                  const Color(0xFF6169F0), () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (_) => const MessageScreen()),
                                );
                              }),
                              itemDashboard(
                                  'Cộng đồng hỏi đáp',
                                  CupertinoIcons.person_3_fill,
                                  const Color(0xFF22F1EC),
                                  const Color(0xFF0E66E9), () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (_) =>
                                          const PublicQuestionsScreen()),
                                );
                              }),
                              itemDashboard(
                                  'Hồ sơ sức khỏe',
                                  FontAwesomeIcons.addressBook,
                                  const Color(0xFFEB98AE),
                                  const Color(0xFFF0005E), () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                      builder: (_) =>
                                          const HealthProfileListScreen()),
                                );
                              }),
                              itemDashboard(
                                  'Kết quả khám',
                                  FontAwesomeIcons.briefcaseMedical,
                                  const Color(0xFF2EF76F),
                                  const Color(0xFF2EA05A),
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
                            // Navigator.push(
                            //     context,
                            //     MaterialPageRoute(
                            //         builder: (_) => DetailDoctorScreen(
                            //             snapshot.data![index])));
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
          ],
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
                  padding: const EdgeInsets.all(12),
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
                    size: 24,
                  )),
              const SizedBox(height: 8),
              Text(
                title,
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Colors.black,
                ),
              ),
            ],
          ),
        ),
      );
}
