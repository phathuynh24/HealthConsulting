// ignore_for_file: avoid_print

import 'dart:async';

import 'package:assist_health/src/models/doctor/doctor_info.dart';
import 'package:assist_health/src/others/methods.dart';
import 'package:assist_health/src/others/theme.dart';
import 'package:assist_health/src/presentation/screens/user_screens/blog_list.dart';
import 'package:assist_health/src/presentation/screens/user_screens/chatbot/chatbot.dart';
import 'package:assist_health/src/presentation/screens/user_screens/doctor_chat.dart';
import 'package:assist_health/src/presentation/screens/user_screens/doctor_detail.dart';
import 'package:assist_health/src/presentation/screens/user_screens/doctor_list.dart';
import 'package:assist_health/src/presentation/screens/user_screens/doctor_recommendation/get_started/sc_get_started.dart';
import 'package:assist_health/src/presentation/screens/user_screens/excercise/excercise_screen.dart';
import 'package:assist_health/src/presentation/screens/user_screens/favorite_doctor_list.dart';
import 'package:assist_health/src/presentation/screens/user_screens/g_chatbot/germini_chatbot.dart';
import 'package:assist_health/src/presentation/screens/user_screens/health_profile_list.dart';
import 'package:assist_health/src/presentation/screens/user_screens/meals/calorie_tracker_home.dart';
import 'package:assist_health/src/presentation/screens/user_screens/public_questions.dart';
import 'package:assist_health/src/presentation/screens/user_screens/store/home_store.dart';
import 'package:assist_health/src/presentation/screens/user_screens/view_result_list.dart';
import 'package:assist_health/src/widgets/doctor_popular_card.dart';
import 'package:assist_health/src/widgets/health_metrics_topnavbar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dots_indicator/dots_indicator.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final StreamController<List<DoctorInfo>> _doctorStreamController =
      StreamController<List<DoctorInfo>>.broadcast();
  Future<void> setOffline() async {
    try {
      final User? user = _auth.currentUser;
      if (user != null) {
        final CollectionReference users =
            FirebaseFirestore.instance.collection('users');

        await users.doc(user.uid).update({'status': 'offline'});
      }
    } catch (e) {
      print('Error setting user status offline: $e');
    }
  }

  List symptoms = [
    "Tay mũi họng",
    "Bệnh nhiệt đới",
    "Nội thần kinh",
    "Mắt",
    "Nha khoa",
    "Chấn thương chỉnh hình",
    "Tim mạch",
    "Tiêu hóa",
    "Hô hấp",
    "Huyết học",
    "Nội tiết",
  ];

  List imgs = [
    "doctor1.jpg",
    "doctor2.jpg",
    "doctor3.jpg",
    "doctor4.jpg",
  ];

  final items = [
    Image.asset('assets/slider1.jpg', fit: BoxFit.cover),
    Image.asset('assets/slider2.jpg', fit: BoxFit.cover),
    Image.asset('assets/slider3.jpeg', fit: BoxFit.cover),
  ];

  int currentIndex = 0;

  bool isPressed = false;

  String name = '...';
  String imageURL = '';

  @override
  void initState() {
    super.initState();
    getUserData(_auth.currentUser!.uid);
    _doctorStreamController.addStream(getInfoDoctors());
  }

  @override
  void dispose() {
    setOffline();
    super.dispose();
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
          toolbarHeight: 105,
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
          title: Column(
            children: [
              Row(
                children: [
                  SizedBox(
                    width: 40,
                    height: 40,
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
                        "Chào bạn!",
                        style: TextStyle(
                          fontSize: 12,
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
              const SizedBox(
                height: 8,
              ),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => DoctorListScreen()),
                  );
                },
                child: Container(
                  height: 38,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Row(
                    children: [
                      const SizedBox(
                        width: 10,
                      ),
                      Icon(
                        CupertinoIcons.search,
                        color: Colors.blueGrey.shade300,
                        size: 23,
                      ),
                      const SizedBox(
                        width: 4,
                      ),
                      Text(
                        'Tên bác sĩ, chuyên khoa,...',
                        style: TextStyle(
                            color: Colors.blueGrey.shade400,
                            fontSize: 15,
                            fontWeight: FontWeight.w300),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(
                height: 8,
              ),
            ],
          ),
        ),
        body: SingleChildScrollView(
          child: Container(
            color: Colors.grey.withOpacity(0.1),
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
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
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
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                        ),
                        child: Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 10,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(15),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.blueGrey.withOpacity(0.2),
                                    spreadRadius: 1,
                                    blurRadius: 5,
                                  ),
                                ],
                              ),
                              child: GridView.count(
                                shrinkWrap: true,
                                padding: EdgeInsets.zero,
                                physics: const NeverScrollableScrollPhysics(),
                                crossAxisCount: 4,
                                crossAxisSpacing: 0,
                                mainAxisSpacing: 10,
                                children: [
                                  itemDashboard(
                                      'Gọi video với bác sĩ',
                                      FontAwesomeIcons.mobile,
                                      const Color(0xFFD58EEE),
                                      const Color(0xFF801BE0), () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (_) => DoctorListScreen()),
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
                                          builder: (_) =>
                                              const DoctorChatScreen()),
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
                                      'Chỉ số sức khỏe',
                                      FontAwesomeIcons.chartColumn,
                                      const Color(0xFFFFDF3F),
                                      const Color(0xFFFA7516), () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                          builder: (_) =>
                                              const HealthMetricsTopNavBar()),
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
                                      const Color(0xFF2EA05A), () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                          builder: (_) =>
                                              const ViewResultListScreen()),
                                    );
                                  }),
                                  itemDashboard(
                                      'Cửa hàng sản phẩm',
                                      FontAwesomeIcons.cartShopping,
                                      const Color.fromARGB(255, 241, 85, 0),
                                      const Color.fromARGB(255, 160, 122, 46),
                                      () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                          builder: (_) =>
                                              const HomeStoreScreen()),
                                    );
                                  }),
                                  itemDashboard(
                                    'Đề xuất bác sĩ',
                                    FontAwesomeIcons.robot,
                                    const Color(0xFF2EF76F),
                                    const Color(0xFF2EA05A),
                                    () {
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                            builder: (_) => GetStartedScreen()),
                                      );
                                    },
                                  ),
                                  itemDashboard(
                                    'Dinh dưỡng',
                                    Icons.restaurant_menu,
                                    const Color(0xFFFFA726), // Màu cam sáng
                                    const Color(0xFFFF7043), // Màu cam đậm
                                    () {
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                            builder: (_) =>
                                                const CalorieTrackerHome()),
                                      );
                                    },
                                  ),
                                  itemDashboard(
                                    'Bài tập',
                                    Icons.fitness_center,
                                    const Color(0xFF42A5F5), // Màu xanh nhạt
                                    const Color(0xFF1E88E5), // Màu xanh đậm
                                    () {
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                            builder: (_) =>
                                                DailyWorkoutScreen()),
                                      );
                                    },
                                  ),
                                  itemDashboard(
                                    'Bài viết',
                                    Icons.article_outlined,
                                    const Color(0xFF66BB6A), // Màu xanh lá nhạt
                                    const Color(0xFF388E3C), // Màu xanh lá đậm
                                    () {
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                            builder: (_) => BlogListPage()),
                                      );
                                    },
                                  ),
                                  itemDashboard(
                                    'Danh sách quan tâm',
                                    Icons.favorite,
                                    const Color(0xFFE57373), // Màu đỏ nhạt
                                    const Color(0xFFD32F2F), // Màu đỏ đậm
                                    () {
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                            builder: (_) =>
                                                const FavoriteDoctorList()),
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 10,
                ),
                Container(
                  color: Colors.white,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 15, top: 15),
                        child: Row(
                          children: [
                            Icon(
                              FontAwesomeIcons.solidStar,
                              size: 16,
                              color: Colors.yellow.shade600,
                            ),
                            const SizedBox(
                              width: 8,
                            ),
                            const Text(
                              "Bác sĩ nổi bật",
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                            const Spacer(),
                            InkWell(
                              onTapDown: (details) {
                                setState(() {
                                  isPressed = true;
                                });
                              },
                              onTapUp: (details) {
                                setState(() {
                                  isPressed = false;
                                });
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (_) => DoctorListScreen()),
                                );
                              },
                              onTapCancel: () {
                                setState(() {
                                  isPressed = false;
                                });
                              },
                              onTap: () {
                                // Xử lý khi nút được nhấn (ví dụ: mở rộng nội dung)
                              },
                              child: Padding(
                                padding: const EdgeInsets.only(
                                    right: 12, top: 8, bottom: 8),
                                child: Row(
                                  children: [
                                    Text(
                                      'Xem thêm',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: isPressed
                                            ? Colors.grey
                                            : Colors.black54,
                                        // Các thuộc tính khác của văn bản
                                      ),
                                    ),
                                    Icon(
                                      Icons.chevron_right_outlined,
                                      color: isPressed
                                          ? Colors.grey
                                          : Colors.black54,
                                      size: 22,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      StreamBuilder<List<DoctorInfo>>(
                        stream: _doctorStreamController.stream,
                        builder: (_, snapshot) {
                          if (snapshot.hasError) {
                            return SizedBox(
                              height: 280,
                              width: double.infinity,
                              child: Center(
                                child: Text('Đã xảy ra lỗi: ${snapshot.error}'),
                              ),
                            );
                          }

                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const SizedBox(
                              height: 280,
                              width: double.infinity,
                              child: Center(
                                child: SizedBox(
                                  height: 40,
                                  width: 40,
                                  child: CircularProgressIndicator(),
                                ),
                              ),
                            );
                          }

                          return SizedBox(
                            height: 290,
                            child: ListView.builder(
                              itemCount: snapshot.data!.length,
                              shrinkWrap: true,
                              padding: const EdgeInsets.only(left: 11),
                              scrollDirection: Axis.horizontal,
                              itemBuilder: (context, index) {
                                return InkWell(
                                  onTap: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                DoctorDetailScreen(
                                                    doctorInfo: snapshot
                                                        .data![index])));
                                  },
                                  child: Container(
                                    margin: EdgeInsets.only(
                                        left: 4,
                                        right:
                                            (index != snapshot.data!.length - 1)
                                                ? 4
                                                : 15,
                                        top: 10,
                                        bottom: 10),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(10),
                                      boxShadow: const [
                                        BoxShadow(
                                          color: Colors.black12,
                                          blurRadius: 4,
                                          spreadRadius: 1,
                                        ),
                                      ],
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      children: [
                                        DoctorPopularCardWidget(
                                          image: snapshot.data![index].imageURL,
                                          name: snapshot.data![index].name,
                                          count: snapshot.data![index].count,
                                          workplace:
                                              snapshot.data![index].workplace,
                                          expert: snapshot
                                              .data![index].specialty[snapshot
                                                  .data![index]
                                                  .specialty
                                                  .length -
                                              1],
                                          rating: snapshot.data![index].rating
                                              .toDouble(),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 8,
                ),
                Container(
                  color: Colors.white,
                  padding: const EdgeInsets.only(left: 5, right: 5, bottom: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 15, top: 10),
                        child: Row(
                          children: [
                            Icon(
                              FontAwesomeIcons.briefcaseMedical,
                              size: 18,
                              color: Colors.greenAccent.shade700,
                            ),
                            const SizedBox(
                              width: 8,
                            ),
                            const Text(
                              "Khám theo chuyên khoa",
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      SizedBox(
                        height: 85,
                        child: ListView.builder(
                          shrinkWrap: true,
                          scrollDirection: Axis.horizontal,
                          itemCount: symptoms.length,
                          itemBuilder: (context, index) {
                            return GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (_) => DoctorListScreen(
                                            filterSpecialty: symptoms[index],
                                          )),
                                );
                              },
                              child: Container(
                                margin: EdgeInsets.only(
                                  left: 15,
                                  top: 15,
                                  bottom: 15,
                                  right:
                                      (index != symptoms.length - 1) ? 0 : 15,
                                ),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 25, vertical: 8),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFE5FDFF),
                                  borderRadius: BorderRadius.circular(10),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey.withOpacity(0.5),
                                      spreadRadius: 2,
                                      blurRadius: 5,
                                      offset: const Offset(0, 3),
                                    ),
                                  ],
                                ),
                                child: Center(
                                  child: Text(
                                    symptoms[index],
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: Themes.gradientDeepClr
                                          .withOpacity(0.8),
                                    ),
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
              ],
            ),
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const GeminiChatBot()),
            );
          },
          backgroundColor: Colors.blue,
          child: const Icon(Icons.comment),
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
              Stack(
                children: [
                  Container(
                    padding: (title == 'Cộng đồng hỏi đáp')
                        ? const EdgeInsets.all(10)
                        : const EdgeInsets.all(12),
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
                      size: (title == 'Cộng đồng hỏi đáp') ? 32 : 28,
                    ),
                  ),
                  (title == 'Gọi video với bác sĩ')
                      ? Positioned(
                          left: 0,
                          right: 0,
                          top: 0,
                          bottom: 0,
                          child: Icon(
                            CupertinoIcons.waveform_circle_fill,
                            color: bottomClr.withOpacity(0.6),
                            size: 18,
                          ),
                        )
                      : const SizedBox(),
                ],
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: 70,
                child: Text(
                  title,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Colors.black,
                    height: 1.2,
                  ),
                ),
              ),
            ],
          ),
        ),
      );

  Future<void> getUserData(String uid) async {
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
}
