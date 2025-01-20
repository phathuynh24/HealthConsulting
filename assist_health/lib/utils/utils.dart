// File: ultil.dart

import 'package:cloud_firestore/cloud_firestore.dart';

// Hàm làm tròn số đến 1 chữ số thập phân
double roundToOneDecimal(double number) {
  return double.parse(number.toStringAsFixed(2));
}

// Hàm lấy thông tin người dùng từ Firestore
Future<Map<String, dynamic>?> getUserInfo(String id, String collection) async {
  try {
    // Truy cập vào collection
    CollectionReference users = FirebaseFirestore.instance.collection(collection);

    // Lấy document với id được cung cấp
    DocumentSnapshot userDoc = await users.doc(id).get();

    // Kiểm tra nếu document tồn tại
    if (userDoc.exists) {
      // Trả về dữ liệu dưới dạng Map
      print(userDoc.data());
      return userDoc.data() as Map<String, dynamic>;
    } else {
      print('User với id $id không tồn tại.');
      return null;
    }
  } catch (e) {
    // Xử lý lỗi
    print('Lỗi khi lấy thông tin người dùng: $e');
    return null;
  }
}