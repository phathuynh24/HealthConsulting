import 'package:assist_health/src/presentation/screens/user_screens/meals/core/firebase/firebase_constants.dart';
import 'package:assist_health/src/presentation/screens/user_screens/meals/views/main_screen.dart';
import 'package:assist_health/src/presentation/screens/user_screens/meals/views/user_info_survey/gender_selection_screen.dart';
import 'package:assist_health/src/presentation/screens/user_screens/meals/widgets/custom_snackbar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class UserMealService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> checkAndCreateUserMealData(BuildContext context) async {
    final User? user = _auth.currentUser;

    if (user != null) {
      final DocumentReference userMealRef = _firestore
          .collection(FirebaseConstants.usersCollection)
          .doc(user.uid);

      try {
        final DocumentSnapshot userMealSnapshot = await userMealRef.get();

        if (!context.mounted) return; // Kiểm tra context trước khi sử dụng

        if (!userMealSnapshot.exists) {
          // Tạo tài liệu mới nếu chưa tồn tại
          await userMealRef.set({
            'uid': user.uid,
            'email': user.email,
            'createdAt': FieldValue.serverTimestamp(),
            'status': 'active',
            'isFirstLogin': true,
            'gender': '',
            'age': 0,
            'height': 0,
            'weight': 0,
            'targetWeight': 0,
            'activityLevel': '',
            'goal': '',
            'calories': 0,
            'weightChangeRate': 0,
            'surveyHistory': [],
          });
          debugPrint('Đã tạo tài liệu users_meal mới cho user: ${user.uid}');

          if (!context.mounted) return; // Kiểm tra lần nữa trước khi điều hướng

          // Điều hướng đến trang khảo sát lần đầu
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => GenderSelectionScreen(
                surveyData: {
                  'uid': user.uid,
                  'email': user.email,
                  'isFirstLogin': true,
                },
              ),
            ),
          );
        } else {
          // Nếu đã có tài liệu, kiểm tra trạng thái đăng nhập lần đầu
          Map<String, dynamic> data =
              userMealSnapshot.data() as Map<String, dynamic>;

          if (data['isFirstLogin'] == true) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => GenderSelectionScreen(
                  surveyData: {
                    'uid': data['uid'],
                    'email': data['email'],
                    'isFirstLogin': data['isFirstLogin'],
                  },
                ),
              ),
            );
          } else {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const MainScreen()),
            );
          }
        }
      } catch (e) {
        debugPrint('Lỗi khi kiểm tra hoặc tạo dữ liệu: $e');
        if (context.mounted) {
          CustomSnackbar.show(context, 'Đã xảy ra lỗi. Vui lòng thử lại!',
              isSuccess: false);
        }
      }
    }
  }
}
