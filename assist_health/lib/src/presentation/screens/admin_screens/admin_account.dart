import 'package:assist_health/src/models/user/user_profile.dart';
import 'package:assist_health/src/others/theme.dart';
import 'package:assist_health/src/others/methods.dart';
import 'package:assist_health/src/presentation/screens/admin_screens/add_blog.dart';
import 'package:assist_health/src/presentation/screens/admin_screens/doctor_profile_list.dart';
import 'package:assist_health/src/presentation/screens/admin_screens/evaluate_management.dart';
import 'package:assist_health/src/presentation/screens/admin_screens/excercies/excercise_manager.dart';
import 'package:assist_health/src/presentation/screens/admin_screens/revenue_chart.dart';
import 'package:assist_health/src/presentation/screens/admin_screens/store/order.dart';
import 'package:assist_health/src/presentation/screens/admin_screens/store/product_list.dart';
import 'package:assist_health/src/widgets/admin_navbar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class AdminAccountScreen extends StatefulWidget {
  const AdminAccountScreen({super.key});

  @override
  State<AdminAccountScreen> createState() => _AdminAccountScreenState();
}

class _AdminAccountScreenState extends State<AdminAccountScreen> {
  UserProfile? userProfile;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const AdminNavBar()),
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
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        GestureDetector(
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: Colors.white,
                            ),
                            child: const ListTile(
                              leading: CircleAvatar(
                                radius: 25,
                                backgroundImage: AssetImage(
                                    'assets/health_care_logo_nobg.png'),
                              ),
                              title: Text(
                                'Quản trị viên',
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 15,
                                ),
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
                                height: 30,
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
                                height: 30,
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
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                const RevenueChartScreen()));
                                  },
                                  leading: const Icon(
                                    Icons.bar_chart_outlined,
                                    color: Colors.indigoAccent,
                                    size: 30,
                                  ),
                                  title: const Text(
                                    "Thống kê và báo cáo",
                                    style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                      fontSize: 15,
                                    ),
                                  ),
                                ),
                              ),
                              Divider(
                                height: 30,
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
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                const AdminOrderManagementScreen()));
                                  },
                                  leading: const Icon(
                                    Icons.shopping_bag,
                                    color: Colors.deepOrange,
                                    size: 30,
                                  ),
                                  title: const Text(
                                    "Đơn hàng",
                                    style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                      fontSize: 15,
                                    ),
                                  ),
                                ),
                              ),
                              Divider(
                                height: 30,
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
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                const ExerciseManagerScreen()));
                                  },
                                  leading: const Icon(
                                    Icons.sports_gymnastics,
                                    color: Colors.yellowAccent,
                                    size: 30,
                                  ),
                                  title: const Text(
                                    "Quản lý bài tập",
                                    style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                      fontSize: 15,
                                    ),
                                  ),
                                ),
                              ),
                              Divider(
                                height: 30,
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
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                const ReviewManagementPage()));
                                  },
                                  leading: const Icon(
                                    Icons.reviews_sharp,
                                    color: Colors.deepPurpleAccent,
                                    size: 30,
                                  ),
                                  title: const Text(
                                    "Đánh giá sản phẩm",
                                    style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                      fontSize: 15,
                                    ),
                                  ),
                                ),
                              ),
                              Divider(
                                height: 30,
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
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                const ProductListScreen()));
                                  },
                                  leading: const Icon(
                                    Icons.store,
                                    color: Colors.teal,
                                    size: 30,
                                  ),
                                  title: const Text(
                                    "Sản phẩm",
                                    style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                      fontSize: 15,
                                    ),
                                  ),
                                ),
                              ),
                              Divider(
                                height: 30,
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
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                const DoctorProfileList()));
                                  },
                                  leading: const Icon(
                                    FontAwesomeIcons.userDoctor,
                                    color: Colors.brown,
                                    size: 30,
                                  ),
                                  title: const Text(
                                    "Danh sách bác sĩ",
                                    style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                      fontSize: 15,
                                    ),
                                  ),
                                ),
                              ),
                              Divider(
                                height: 30,
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
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                const CreateBlogPostPage()));
                                  },
                                  leading: const Icon(
                                    FontAwesomeIcons.blog,
                                    color: Colors.cyan,
                                    size: 30,
                                  ),
                                  title: const Text(
                                    "Tạo bài viết",
                                    style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                      fontSize: 15,
                                    ),
                                  ),
                                ),
                              ),
                              Divider(
                                height: 30,
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
                                height: 30,
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
                                height: 30,
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
                                height: 30,
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
                      ],
                    ),
                  ),
                ),
        ),
      ),
    );
  }
}
