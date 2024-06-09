import 'package:assist_health/src/others/theme.dart';
import 'package:assist_health/src/presentation/screens/admin_screens/add_blog.dart';
import 'package:assist_health/src/presentation/screens/admin_screens/admin_account.dart';
import 'package:assist_health/src/presentation/screens/admin_screens/admin_blog_list.dart';
import 'package:assist_health/src/presentation/screens/admin_screens/content_topbar.dart';
import 'package:assist_health/src/presentation/screens/admin_screens/doctor_profile_list.dart';
import 'package:assist_health/src/presentation/screens/admin_screens/evaluate_management.dart';
import 'package:assist_health/src/presentation/screens/admin_screens/message_admin.dart';
import 'package:assist_health/src/presentation/screens/admin_screens/shop_chart.dart';
import 'package:assist_health/src/presentation/screens/admin_screens/store/order.dart';
import 'package:assist_health/src/presentation/screens/admin_screens/store/product_list.dart';
import 'package:assist_health/src/presentation/screens/admin_screens/store/voucher/add_voucher_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:assist_health/src/presentation/screens/admin_screens/revenue_chart.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class AdminNavBar extends StatefulWidget {
  const AdminNavBar({super.key});

  @override
  State<AdminNavBar> createState() => _AdminNavBarState();
}

class _AdminNavBarState extends State<AdminNavBar> {
  int _selectedIndex = 0;
  final _screens = [
    // Screen 1
    // const RevenueChartScreen(),
    // ReviewManagementPage(),
    ShopChart(),
    AdminBlog(),
    const AddVoucherScreen(),
    // Screen 2
    const ContentTopBar(),
    // Screen 3
    const MessageAdminScreen(),
    // Screen 4
    // const DoctorProfileList(),
    // Screen 5
    const AdminAccountScreen(),
    //Screen 6
    // const ProductListScreen(),
    //Screen 7
    // const AdminOrderManagementScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: _screens[_selectedIndex],
      bottomNavigationBar: SizedBox(
        height: 80,
        child: BottomNavigationBar(
          backgroundColor: Colors.white,
          type: BottomNavigationBarType.fixed,
          selectedItemColor: Themes.selectedClr,
          unselectedItemColor: Colors.black26,
          selectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 15,
          ),
          currentIndex: _selectedIndex,
          onTap: (index) {
            setState(() {
              _selectedIndex = index;
            });
          },
          items: const [
            // BottomNavigationBarItem(
            //   icon: Icon(Icons.bar_chart_outlined),
            //   label: "Thống kê",
            // ),
            BottomNavigationBarItem(
              icon: Icon(Icons.chat_rounded),
              label: "Doanh thu",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.article_outlined),
              label: "Bài viết",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.card_giftcard),
              label: "Vouchers",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.my_library_books_rounded),
              label: "Nội dung",
            ),
            BottomNavigationBarItem(
              icon: Icon(CupertinoIcons.chat_bubble_text_fill),
              label: "Tin nhắn",
            ),
            // BottomNavigationBarItem(
            //   icon: Icon(FontAwesomeIcons.userDoctor),
            //   label: "Bác sĩ",
            // ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings),
              label: "Tài khoản",
            ),
            // BottomNavigationBarItem(
            //   icon: Icon(Icons.store),
            //   label: "Thêm sản phẩm",
            // ),
            // BottomNavigationBarItem(
            //   icon: Icon(Icons.shopping_bag),
            //   label: "Đơn hàng",
            // ),
          ],
        ),
      ),
    );
  }
}
