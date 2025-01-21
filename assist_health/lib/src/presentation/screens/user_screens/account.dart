// import 'package:assist_health/src/models/user/user_profile.dart';
// import 'package:assist_health/src/others/theme.dart';
// import 'package:assist_health/src/others/methods.dart';
// import 'package:assist_health/src/presentation/screens/user_screens/excercise/excercise_screen.dart';
// import 'package:assist_health/src/presentation/screens/user_screens/favorite_doctor_list.dart';
// import 'package:assist_health/src/presentation/screens/user_screens/health_profile_detail.dart';
// import 'package:assist_health/src/presentation/screens/user_screens/health_profile_list.dart';
// import 'package:assist_health/src/presentation/screens/user_screens/store/evaluate_list.dart';
// import 'package:assist_health/src/presentation/screens/user_screens/store/order_detail_screen.dart';
// import 'package:assist_health/src/widgets/health_metrics_topnavbar.dart';
// import 'package:assist_health/src/widgets/user_navbar.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';

// class AccountScreen extends StatefulWidget {
//   const AccountScreen({super.key});

//   @override
//   State<AccountScreen> createState() => _AccountScreenState();
// }

// class _AccountScreenState extends State<AccountScreen> {
//   UserProfile? userProfile;
//   bool isLoading = false;

//   @override
//   void initState() {
//     super.initState();
//     getUserData();
//   }

//   // Future<void> getUserData() async {
//   //   setState(() {
//   //     isLoading = true;
//   //   });

//   //   String userId = FirebaseAuth.instance.currentUser!.uid;

//   //   DocumentSnapshot snapshot = await FirebaseFirestore.instance
//   //       .collection('users')
//   //       .doc(userId)
//   //       .collection('health_profiles')
//   //       .doc('main_profile')
//   //       .get();

//   //   if (snapshot.exists) {
//   //     setState(() {
//   //       userProfile =
//   //           UserProfile.fromJson(snapshot.data() as Map<String, dynamic>);
//   //       isLoading = false;
//   //     });
//   //   }
//   // }

//   Future<void> getUserData() async {
//   setState(() {
//     isLoading = true;
//   });

//   try {
//     final user = FirebaseAuth.instance.currentUser;
//     if (user == null) {
//       throw Exception("Người dùng chưa đăng nhập.");
//     }

//     // Truy vấn tài liệu có `uid` giống với user hiện tại
//     final firestore = FirebaseFirestore.instance;
//     final querySnapshot = await firestore
//         .collection('users')
//         .where('uid', isEqualTo: user.uid)
//         .limit(1)
//         .get();

//     if (querySnapshot.docs.isEmpty) {
//       throw Exception("Không tìm thấy tài liệu người dùng.");
//     }

//     final userDocId = querySnapshot.docs.first.id;

//     // Lấy tài liệu `main_profile` từ `health_profiles` trong tài liệu của người dùng
//     final profileSnapshot = await firestore
//         .collection('users')
//         .doc(userDocId)
//         .collection('health_profiles')
//         .doc('main_profile')
//         .get();

//     if (!profileSnapshot.exists) {
//       throw Exception("Không tìm thấy thông tin 'main_profile'.");
//     }

//     setState(() {
//       userProfile =
//           UserProfile.fromJson(profileSnapshot.data() as Map<String, dynamic>);
//       isLoading = false;
//     });
//   } catch (e) {
//     setState(() {
//       isLoading = false;
//     });

//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text("Lỗi khi tải dữ liệu: $e"),
//         backgroundColor: Colors.red,
//       ),
//     );
//   }
// }

//   @override
//   Widget build(BuildContext context) {
//     return WillPopScope(
//       onWillPop: () async {
//         Navigator.pushAndRemoveUntil(
//           context,
//           MaterialPageRoute(builder: (context) => const UserNavBar()),
//           (route) => false,
//         );
//         return true;
//       },
//       child: Scaffold(
//         backgroundColor: Colors.blueAccent.withOpacity(0.1),
//         appBar: AppBar(
//           foregroundColor: Colors.white,
//           title: const Text(
//             'Tài khoản',
//             style: TextStyle(fontSize: 20),
//           ),
//           elevation: 0,
//           centerTitle: true,
//           automaticallyImplyLeading: false,
//           flexibleSpace: Container(
//             decoration: const BoxDecoration(
//               gradient: LinearGradient(
//                 colors: [Themes.gradientDeepClr, Themes.gradientLightClr],
//                 begin: Alignment.centerLeft,
//                 end: Alignment.centerRight,
//               ),
//             ),
//           ),
//         ),
//         body: Center(
//           child: isLoading
//               ? const CircularProgressIndicator()
//               : userProfile == null
//                   ? const Text(
//                       "Không tìm thấy thông tin tài khoản.",
//                       style: TextStyle(fontSize: 18, color: Colors.red),
//                     )
//                   : SingleChildScrollView(
//                       child: Container(
//                         padding: const EdgeInsets.all(12),
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             GestureDetector(
//                               onTap: () {
//                                 Navigator.push(
//                                     context,
//                                     MaterialPageRoute(
//                                         builder: (context) =>
//                                             HealthProfileDetailScreen(
//                                               profile: userProfile!,
//                                               isUserOfProfile: true,
//                                             ))).then((value) => getUserData());
//                               },
//                               child: Container(
//                                 decoration: BoxDecoration(
//                                   borderRadius: BorderRadius.circular(10),
//                                   color: Colors.white,
//                                 ),
//                                 child: ListTile(
//                                   leading: (userProfile!.image != '')
//                                       ? CircleAvatar(
//                                           radius: 25,
//                                           backgroundImage:
//                                               NetworkImage(userProfile!.image))
//                                       : Container(
//                                           width: 65,
//                                           height: 65,
//                                           decoration: const BoxDecoration(
//                                             shape: BoxShape.circle,
//                                             gradient: LinearGradient(
//                                               colors: [
//                                                 Themes.gradientDeepClr,
//                                                 Themes.gradientLightClr
//                                               ],
//                                               begin: Alignment.bottomCenter,
//                                               end: Alignment.topCenter,
//                                             ),
//                                           ),
//                                           child: Center(
//                                             child: Text(
//                                               getAbbreviatedName(
//                                                   userProfile!.name),
//                                               style: const TextStyle(
//                                                 color: Colors.white,
//                                                 fontSize: 24,
//                                                 fontWeight: FontWeight.bold,
//                                               ),
//                                             ),
//                                           ),
//                                         ),
//                                   title: Text(
//                                     userProfile!.name,
//                                     style: const TextStyle(
//                                       fontWeight: FontWeight.w500,
//                                       fontSize: 15,
//                                     ),
//                                   ),
//                                   subtitle: Container(
//                                     margin: const EdgeInsets.only(
//                                       top: 4,
//                                     ),
//                                     child: Text(
//                                       userProfile!.phone != ''
//                                           ? userProfile!.phone
//                                           : 'Chưa cập nhật số điện thoại',
//                                       style: const TextStyle(fontSize: 15),
//                                     ),
//                                   ),
//                                 ),
//                               ),
//                             ),
//                             const SizedBox(height: 10),
//                             Container(
//                               padding: const EdgeInsets.symmetric(vertical: 15),
//                               decoration: BoxDecoration(
//                                 borderRadius: BorderRadius.circular(10),
//                                 color: Colors.white,
//                               ),
//                               child: Column(
//                                 children: [
//                                   Container(
//                                     height: 50,
//                                     margin: const EdgeInsets.only(
//                                       left: 8,
//                                     ),
//                                     child: ListTile(
//                                       onTap: () {
//                                         Navigator.of(context).push(
//                                           MaterialPageRoute(
//                                               builder: (_) =>
//                                                   const HealthProfileListScreen()),
//                                         );
//                                       },
//                                       leading: const Icon(
//                                         CupertinoIcons.folder_solid,
//                                         color: Colors.blue,
//                                         size: 28,
//                                       ),
//                                       title: const Text(
//                                         "Hồ sơ sức khỏe",
//                                         style: TextStyle(
//                                           fontWeight: FontWeight.w500,
//                                           fontSize: 15,
//                                         ),
//                                       ),
//                                       trailing: const Icon(
//                                         Icons.arrow_forward_ios_rounded,
//                                         size: 16,
//                                       ),
//                                     ),
//                                   ),
//                                   Divider(
//                                     height: 10,
//                                     indent: 15,
//                                     endIndent: 15,
//                                     color: Colors.grey.shade100,
//                                   ),
//                                   Container(
//                                     height: 50,
//                                     margin: const EdgeInsets.only(
//                                       left: 8,
//                                     ),
//                                     child: ListTile(
//                                       onTap: () {
//                                         Navigator.of(context).push(
//                                           MaterialPageRoute(
//                                             builder: (context) =>
//                                                 const FavoriteDoctorList(),
//                                           ),
//                                         );
//                                       },
//                                       leading: const Icon(
//                                         Icons.favorite,
//                                         color: Colors.red,
//                                         size: 30,
//                                       ),
//                                       title: const Text(
//                                         "Danh sách quan tâm",
//                                         style: TextStyle(
//                                           fontWeight: FontWeight.w500,
//                                           fontSize: 15,
//                                         ),
//                                       ),
//                                       trailing: const Icon(
//                                         Icons.arrow_forward_ios_rounded,
//                                         size: 16,
//                                       ),
//                                     ),
//                                   ),
//                                   Divider(
//                                     height: 10,
//                                     indent: 15,
//                                     endIndent: 15,
//                                     color: Colors.grey.shade100,
//                                   ),
//                                   Container(
//                                     height: 50,
//                                     margin: const EdgeInsets.only(
//                                       left: 8,
//                                     ),
//                                     child: ListTile(
//                                       onTap: () {
//                                         Navigator.push(
//                                             context,
//                                             MaterialPageRoute(
//                                                 builder: (context) =>
//                                                     const HealthMetricsTopNavBar()));
//                                       },
//                                       leading: const Icon(
//                                         Icons.add_chart,
//                                         color: Colors.indigo,
//                                         size: 30,
//                                       ),
//                                       title: const Text(
//                                         "Chỉ số sức khỏe",
//                                         style: TextStyle(
//                                           fontWeight: FontWeight.w500,
//                                           fontSize: 15,
//                                         ),
//                                       ),
//                                       trailing: const Icon(
//                                         Icons.arrow_forward_ios_rounded,
//                                         size: 16,
//                                       ),
//                                     ),
//                                   ),
//                                   Divider(
//                                     height: 10,
//                                     indent: 15,
//                                     endIndent: 15,
//                                     color: Colors.grey.shade100,
//                                   ),
//                                   Container(
//                                     height: 50,
//                                     margin: const EdgeInsets.only(
//                                       left: 8,
//                                     ),
//                                     child: ListTile(
//                                       onTap: () {
//                                         Navigator.push(
//                                             context,
//                                             MaterialPageRoute(
//                                                 builder: (context) =>
//                                                     const OrderDetailsPage()));
//                                       },
//                                       leading: const Icon(
//                                         Icons.shopping_cart,
//                                         color:
//                                             Color.fromARGB(255, 223, 133, 15),
//                                         size: 30,
//                                       ),
//                                       title: const Text(
//                                         "Đơn mua",
//                                         style: TextStyle(
//                                           fontWeight: FontWeight.w500,
//                                           fontSize: 15,
//                                         ),
//                                       ),
//                                       trailing: const Icon(
//                                         Icons.arrow_forward_ios_rounded,
//                                         size: 16,
//                                       ),
//                                     ),
//                                   ),
//                                   Divider(
//                                     height: 10,
//                                     indent: 15,
//                                     endIndent: 15,
//                                     color: Colors.grey.shade100,
//                                   ),
//                                   Container(
//                                     height: 50,
//                                     margin: const EdgeInsets.only(
//                                       left: 8,
//                                     ),
//                                     child: ListTile(
//                                       onTap: () {
//                                         Navigator.push(
//                                             context,
//                                             MaterialPageRoute(
//                                                 builder: (context) =>
//                                                     EvaluatePage()));
//                                       },
//                                       leading: const Icon(
//                                         Icons.rate_review,
//                                         color:
//                                             Color.fromARGB(255, 192, 192, 10),
//                                         size: 30,
//                                       ),
//                                       title: const Text(
//                                         "Đánh giá",
//                                         style: TextStyle(
//                                           fontWeight: FontWeight.w500,
//                                           fontSize: 15,
//                                         ),
//                                       ),
//                                       trailing: const Icon(
//                                         Icons.arrow_forward_ios_rounded,
//                                         size: 16,
//                                       ),
//                                     ),
//                                   ),
//                                   Divider(
//                                     height: 10,
//                                     indent: 15,
//                                     endIndent: 15,
//                                     color: Colors.grey.shade100,
//                                   ),
//                                   Container(
//                                     height: 50,
//                                     margin: const EdgeInsets.only(
//                                       left: 8,
//                                     ),
//                                     child: ListTile(
//                                       onTap: () {
//                                         Navigator.push(
//                                             context,
//                                             MaterialPageRoute(
//                                               builder: (context) =>
//                                                   DailyWorkoutScreen(), // Schedule Screen
//                                             ));
//                                       },
//                                       leading: const Icon(
//                                         Icons.fitness_center,
//                                         color: Colors.blueAccent,
//                                         size: 30,
//                                       ),
//                                       title: const Text(
//                                         "Tập luyện",
//                                         style: TextStyle(
//                                           fontWeight: FontWeight.w500,
//                                           fontSize: 15,
//                                         ),
//                                       ),
//                                       trailing: const Icon(
//                                         Icons.arrow_forward_ios_rounded,
//                                         size: 16,
//                                       ),
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             ),
//                             const SizedBox(height: 10),
//                             Container(
//                               padding: const EdgeInsets.symmetric(vertical: 15),
//                               decoration: BoxDecoration(
//                                 borderRadius: BorderRadius.circular(10),
//                                 color: Colors.white,
//                               ),
//                               child: Column(
//                                 children: [
//                                   Container(
//                                     height: 50,
//                                     margin: const EdgeInsets.only(
//                                       left: 8,
//                                     ),
//                                     child: ListTile(
//                                       onTap: () {},
//                                       leading: const Icon(
//                                         Icons.info,
//                                         color: Colors.deepPurple,
//                                         size: 30,
//                                       ),
//                                       title: const Text(
//                                         "Điều khoản và dịch vụ",
//                                         style: TextStyle(
//                                           fontWeight: FontWeight.w500,
//                                           fontSize: 15,
//                                         ),
//                                       ),
//                                       trailing: const Icon(
//                                         Icons.arrow_forward_ios_rounded,
//                                         size: 16,
//                                       ),
//                                     ),
//                                   ),
//                                   Divider(
//                                     height: 10,
//                                     indent: 15,
//                                     endIndent: 15,
//                                     color: Colors.grey.shade100,
//                                   ),
//                                   Container(
//                                     height: 50,
//                                     margin: const EdgeInsets.only(
//                                       left: 8,
//                                     ),
//                                     child: ListTile(
//                                       onTap: () {},
//                                       leading: const Icon(
//                                         CupertinoIcons.person_3_fill,
//                                         color: Colors.lightGreen,
//                                         size: 30,
//                                       ),
//                                       title: const Text(
//                                         "Tham gia cộng đồng",
//                                         style: TextStyle(
//                                           fontWeight: FontWeight.w500,
//                                           fontSize: 15,
//                                         ),
//                                       ),
//                                     ),
//                                   ),
//                                   Divider(
//                                     height: 10,
//                                     indent: 15,
//                                     endIndent: 15,
//                                     color: Colors.grey.shade100,
//                                   ),
//                                   Container(
//                                     height: 50,
//                                     margin: const EdgeInsets.only(
//                                       left: 8,
//                                     ),
//                                     child: ListTile(
//                                       onTap: () {},
//                                       leading: const Icon(
//                                         Icons.share,
//                                         color: Colors.orange,
//                                         size: 30,
//                                       ),
//                                       title: const Text(
//                                         "Chia sẽ ứng dụng",
//                                         style: TextStyle(
//                                           fontWeight: FontWeight.w500,
//                                           fontSize: 15,
//                                         ),
//                                       ),
//                                     ),
//                                   ),
//                                   Divider(
//                                     height: 10,
//                                     indent: 15,
//                                     endIndent: 15,
//                                     color: Colors.grey.shade100,
//                                   ),
//                                   Container(
//                                     height: 50,
//                                     margin: const EdgeInsets.only(
//                                       left: 8,
//                                     ),
//                                     child: ListTile(
//                                       onTap: () {},
//                                       leading: const Icon(
//                                         Icons.contact_support,
//                                         color: Colors.indigoAccent,
//                                         size: 30,
//                                       ),
//                                       title: const Text(
//                                         "Liên hệ và hỗ trợ",
//                                         style: TextStyle(
//                                           fontWeight: FontWeight.w500,
//                                           fontSize: 15,
//                                         ),
//                                       ),
//                                     ),
//                                   ),
//                                   Divider(
//                                     height: 10,
//                                     indent: 15,
//                                     endIndent: 15,
//                                     color: Colors.grey.shade100,
//                                   ),
//                                   Container(
//                                     height: 50,
//                                     margin: const EdgeInsets.only(
//                                       left: 8,
//                                     ),
//                                     child: ListTile(
//                                       onTap: () {},
//                                       leading: const Icon(
//                                         Icons.settings,
//                                         color: Colors.black54,
//                                         size: 30,
//                                       ),
//                                       title: const Text(
//                                         "Cài đặt",
//                                         style: TextStyle(
//                                           fontWeight: FontWeight.w500,
//                                           fontSize: 15,
//                                         ),
//                                       ),
//                                       trailing: const Icon(
//                                         Icons.arrow_forward_ios_rounded,
//                                         size: 16,
//                                       ),
//                                     ),
//                                   ),
//                                   Divider(
//                                     height: 10,
//                                     indent: 15,
//                                     endIndent: 15,
//                                     color: Colors.grey.shade100,
//                                   ),
//                                   Container(
//                                     height: 50,
//                                     margin: const EdgeInsets.only(
//                                       left: 8,
//                                     ),
//                                     child: ListTile(
//                                       onTap: () {
//                                         logOut(context);
//                                       },
//                                       leading: const Icon(
//                                         Icons.logout,
//                                         color: Colors.redAccent,
//                                         size: 30,
//                                       ),
//                                       title: const Text(
//                                         "Đăng xuất",
//                                         style: TextStyle(
//                                           fontWeight: FontWeight.w500,
//                                           fontSize: 15,
//                                         ),
//                                       ),
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ),
//         ),
//       ),
//     );
//   }
// }


import 'package:assist_health/src/presentation/screens/user_screens/favorite_doctor_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:assist_health/src/models/user/user_profile.dart';
import 'package:assist_health/src/others/theme.dart';
import 'package:assist_health/src/others/methods.dart';
import 'package:assist_health/src/widgets/user_navbar.dart';
import 'package:assist_health/src/presentation/screens/user_screens/health_profile_detail.dart';
import 'package:assist_health/src/presentation/screens/user_screens/health_profile_list.dart';
import 'package:assist_health/src/presentation/screens/user_screens/store/order_detail_screen.dart';
import 'package:assist_health/src/presentation/screens/user_screens/store/evaluate_list.dart';
import 'package:assist_health/src/presentation/screens/user_screens/excercise/excercise_screen.dart';
import 'package:assist_health/src/widgets/health_metrics_topnavbar.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen({Key? key}) : super(key: key);

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  UserProfile? userProfile;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    getUserData();
  }

  Future<void> getUserData() async {
    setState(() => isLoading = true);
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception("Người dùng chưa đăng nhập.");

      final firestore = FirebaseFirestore.instance;
      final querySnapshot = await firestore
          .collection('users')
          .where('uid', isEqualTo: user.uid)
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) {
        throw Exception("Không tìm thấy tài liệu người dùng.");
      }

      final userDocId = querySnapshot.docs.first.id;

      final profileSnapshot = await firestore
          .collection('users')
          .doc(userDocId)
          .collection('health_profiles')
          .doc('main_profile')
          .get();

      if (!profileSnapshot.exists) {
        throw Exception("Không tìm thấy thông tin 'main_profile'.");
      }

      setState(() {
        userProfile =
            UserProfile.fromJson(profileSnapshot.data() as Map<String, dynamic>);
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      _showSnackBar("Lỗi khi tải dữ liệu: $e", Colors.red);
    }
  }

  void _showSnackBar(String message, Color color) {
    final snackBar = SnackBar(
      content: Text(message),
      backgroundColor: color,
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const UserNavBar()),
          (route) => false,
        );
        return true;
      },
      child: Scaffold(
        backgroundColor: Colors.blueAccent.withOpacity(0.1),
        appBar: _buildAppBar(),
        body: isLoading
            ? const Center(child: CircularProgressIndicator())
            : userProfile == null
                ? _buildNoDataMessage()
                : _buildAccountDetails(),
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      title: const Text('Tài khoản', style: TextStyle(fontSize: 20)),
      centerTitle: true,
      foregroundColor: Colors.white,
      elevation: 0,
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
    );
  }

  Widget _buildNoDataMessage() {
    return const Center(
      child: Text(
        "Không tìm thấy thông tin tài khoản.",
        style: TextStyle(fontSize: 18, color: Colors.red),
      ),
    );
  }

  Widget _buildAccountDetails() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildProfileTile(),
          const SizedBox(height: 10),
          _buildFeatureSection(
            items: [
              _buildFeatureItem(
                icon: CupertinoIcons.folder_solid,
                color: Colors.blue,
                title: "Hồ sơ sức khỏe",
                onTap: () => _navigateTo(const HealthProfileListScreen()),
              ),
              _buildFeatureItem(
                icon: Icons.favorite,
                color: Colors.red,
                title: "Danh sách quan tâm",
                onTap: () => _navigateTo(const FavoriteDoctorList()),
              ),
              _buildFeatureItem(
                icon: Icons.add_chart,
                color: Colors.indigo,
                title: "Chỉ số sức khỏe",
                onTap: () => _navigateTo(const HealthMetricsTopNavBar()),
              ),
              _buildFeatureItem(
                icon: Icons.shopping_cart,
                color: Colors.orange,
                title: "Đơn mua",
                onTap: () => _navigateTo(const OrderDetailsPage()),
              ),
              _buildFeatureItem(
                icon: Icons.rate_review,
                color: Colors.yellow,
                title: "Đánh giá",
                onTap: () => _navigateTo(EvaluatePage()),
              ),
              _buildFeatureItem(
                icon: Icons.fitness_center,
                color: Colors.blueAccent,
                title: "Tập luyện",
                onTap: () => _navigateTo(DailyWorkoutScreen()),
                showDivider: false,
              ),
            ],
          ),
          const SizedBox(height: 10),
          _buildFeatureSection(
            items: [
              _buildFeatureItem(
                icon: Icons.info,
                color: Colors.deepPurple,
                title: "Điều khoản và dịch vụ",
                onTap: () {},
              ),
              _buildFeatureItem(
                icon: CupertinoIcons.person_3_fill,
                color: Colors.lightGreen,
                title: "Tham gia cộng đồng",
                onTap: () {},
              ),
              _buildFeatureItem(
                icon: Icons.share,
                color: Colors.orange,
                title: "Chia sẻ ứng dụng",
                onTap: () {},
              ),
              _buildFeatureItem(
                icon: Icons.contact_support,
                color: Colors.indigoAccent,
                title: "Liên hệ và hỗ trợ",
                onTap: () {},
              ),
              _buildFeatureItem(
                icon: Icons.settings,
                color: Colors.black54,
                title: "Cài đặt",
                onTap: () {},
              ),
              _buildFeatureItem(
                icon: Icons.logout,
                color: Colors.redAccent,
                title: "Đăng xuất",
                onTap: () => logOut(context),
                showDivider : false,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProfileTile() {
    return GestureDetector(
      onTap: () {
        _navigateTo(
          HealthProfileDetailScreen(profile: userProfile!, isUserOfProfile: true),
        ).then((_) => getUserData());
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
        ),
        child: ListTile(
          leading: (userProfile!.image.isNotEmpty)
              ? CircleAvatar(
                  radius: 25,
                  backgroundImage: NetworkImage(userProfile!.image),
                )
              : CircleAvatar(
                  radius: 32,
                  backgroundColor: Themes.gradientDeepClr,
                  child: Text(
                    getAbbreviatedName(userProfile!.name),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
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
          subtitle: Text(
            userProfile!.phone.isNotEmpty
                ? userProfile!.phone
                : 'Chưa cập nhật số điện thoại',
            style: const TextStyle(fontSize: 15),
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureSection({required List<Widget> items}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(children: items),
    );
  }

  Widget _buildFeatureItem({
    required IconData icon,
    required Color color,
    required String title,
    required VoidCallback onTap,
    bool showDivider = true,
  }) {
    return Column(
      children: [
        ListTile(
          leading: Icon(icon, color: color, size: 30),
          title: Text(title, style: const TextStyle(fontSize: 15)),
          trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
          onTap: onTap,
        ),
        if (showDivider) Divider(
          height: 4,
          indent: 15,
          endIndent: 15,
          color: Colors.grey.shade100,
        ),
      ],
    );
  }

  Future<void> _navigateTo(Widget page) async {
    await Navigator.of(context).push(MaterialPageRoute(builder: (_) => page));
  }
}
