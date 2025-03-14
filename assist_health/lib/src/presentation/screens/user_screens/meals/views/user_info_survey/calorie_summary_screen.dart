import 'package:assist_health/src/presentation/screens/user_screens/meals/core/calorie_calculator/calorie_calculator.dart';
import 'package:assist_health/src/presentation/screens/user_screens/meals/core/firebase/firebase_constants.dart';
import 'package:assist_health/src/presentation/screens/user_screens/meals/views/main_screen.dart';
import 'package:assist_health/src/presentation/screens/user_screens/meals/widgets/custom_app_bar.dart';
import 'package:assist_health/src/presentation/screens/user_screens/meals/widgets/custom_snackbar.dart';
import 'package:assist_health/src/presentation/screens/user_screens/meals/widgets/loading_indicator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CalorieSummaryScreen extends StatefulWidget {
  final Map<String, dynamic> surveyData;

  const CalorieSummaryScreen({super.key, required this.surveyData});

  @override
  State<CalorieSummaryScreen> createState() => _CalorieSummaryScreenState();
}

class _CalorieSummaryScreenState extends State<CalorieSummaryScreen> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final double adjustedCalories = CalorieCalculator.calculateDailyCalories(
      gender: widget.surveyData[UserFields.gender],
      weight: widget.surveyData[UserFields.weight],
      height: widget.surveyData[UserFields.height],
      age: widget.surveyData[UserFields.age],
      activityLevel: widget.surveyData[UserFields.activityLevel],
      goal: widget.surveyData[UserFields.goal],
      weightChangeRate: widget.surveyData[UserFields.weightChangeRate],
    );

    return Stack(
      children: [
        Scaffold(
          backgroundColor: Colors.green[50],
          appBar: const CustomAppBar(title: "Kết Quả Tính Toán"),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 10),
                const Text(
                  "Chỉ số calo hàng ngày của bạn",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                Text(
                  "Dựa trên thông tin bạn đã cung cấp, đây là mức calo đề xuất để đạt mục tiêu của bạn.",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                ),
                const SizedBox(height: 20),

                // Total Calories
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.orange[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.local_fire_department,
                              color: Colors.deepOrange),
                          SizedBox(width: 8),
                          Text(
                            "Tổng lượng calo/ngày",
                            style: TextStyle(
                                fontSize: 16, color: Colors.deepOrange),
                          ),
                        ],
                      ),
                      Text(
                        "${adjustedCalories.toStringAsFixed(0)} Cal",
                        style: const TextStyle(
                            fontSize: 22, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),
                // Time to Re-survey
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.greenAccent[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    "Bạn có thể làm lại khảo sát lại ở mục 'Cài đặt' để cập nhật mục tiêu và thể trạng của mình.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.green),
                  ),
                ),
                const SizedBox(height: 20),
                // Info Summary
                _buildSummaryItem(
                    "Giới tính",
                    widget.surveyData[UserFields.gender] == "Male"
                        ? "Nam"
                        : "Nữ"),
                _buildSummaryItem(
                    "Tuổi", widget.surveyData[UserFields.age].toString()),
                _buildSummaryItem(
                    "Chiều cao", "${widget.surveyData[UserFields.height]} cm"),
                _buildSummaryItem("Cân nặng hiện tại",
                    "${widget.surveyData[UserFields.weight]} kg"),
                _buildSummaryItem("Cân nặng mục tiêu",
                    "${widget.surveyData[UserFields.targetWeight]} kg"),
                _buildSummaryItem("Mức độ vận động",
                    widget.surveyData[UserFields.activityLevel]),
                _buildSummaryItem(
                    "Mục tiêu", widget.surveyData[UserFields.goal]),
                if (widget.surveyData[UserFields.weightChangeRate] != null &&
                    widget.surveyData[UserFields.goal] != "Duy trì cân nặng")
                  _buildSummaryItem(
                    "Mức độ ${widget.surveyData[UserFields.goal] == "Giảm cân" ? "giảm" : "tăng"} cân/tuần",
                    "${widget.surveyData[UserFields.weightChangeRate]} kg/tuần",
                  ),

                const Spacer(),

                // Save & Finish Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => _saveSurveyData(context, adjustedCalories),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text(
                      "Lưu và Kết Thúc",
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        if (_isLoading)
          Container(
            color: Colors.black.withOpacity(0.3),
            child: const Center(
              child: LoadingIndicator(),
            ),
          ),
      ],
    );
  }

  Future<void> _saveSurveyData(
      BuildContext context, double adjustedCalories) async {
    setState(() {
      _isLoading = true;
    });

    try {
      String uid = FirebaseAuth.instance.currentUser!.uid;
      Timestamp currentTimestamp = Timestamp.now();
      int roundedCalories = adjustedCalories.round();

      // Cập nhật thông tin chính của người dùng
      await FirebaseFirestore.instance
          .collection(FirebaseConstants.usersCollection)
          .doc(uid)
          .update({
        UserFields.gender: widget.surveyData[UserFields.gender],
        UserFields.age: widget.surveyData[UserFields.age],
        UserFields.height: widget.surveyData[UserFields.height],
        UserFields.weight: widget.surveyData[UserFields.weight],
        UserFields.targetWeight: widget.surveyData[UserFields.targetWeight],
        UserFields.activityLevel: widget.surveyData[UserFields.activityLevel],
        UserFields.goal: widget.surveyData[UserFields.goal],
        UserFields.calories: roundedCalories,
        UserFields.updatedAt: currentTimestamp,
        UserFields.isFirstLogin: false,
        UserFields.weightChangeRate:
            widget.surveyData[UserFields.weightChangeRate],
      });

      // Lưu lịch sử khảo sát
      DateTime now = DateTime.now();
      String dateKey = DateFormat('dd-MM-yyyy').format(now);

      // Lấy lịch sử khảo sát hiện tại
      DocumentSnapshot userDoc =
          await FirebaseFirestore.instance.collection(FirebaseConstants.usersCollection).doc(uid).get();

      List<dynamic> surveyHistory = userDoc[UserFields.surveyHistory] ?? [];

      // Kiểm tra xem đã có dữ liệu cho ngày hiện tại chưa
      int existingIndex = surveyHistory.indexWhere(
        (entry) => entry['date'] == dateKey,
      );

      if (existingIndex != -1) {
        surveyHistory[existingIndex]['calories'] = roundedCalories;
        surveyHistory[existingIndex]['timestamp'] = currentTimestamp;
      } else {
        surveyHistory.add({
          'date': dateKey,
          'calories': roundedCalories,
          'timestamp': currentTimestamp,
        });
      }

      // Lưu lại dữ liệu lịch sử khảo sát đã cập nhật
      await FirebaseFirestore.instance.collection(FirebaseConstants.usersCollection).doc(uid).update({
        'surveyHistory': surveyHistory,
      });

      // Hiển thị thông báo thành công
      if (context.mounted) {
        CustomSnackbar.show(context, "Lưu thông tin thành công!",
            isSuccess: true);
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const MainScreen()),
          (route) => false,
        );
      }
    } catch (e) {
      if (context.mounted) {
        CustomSnackbar.show(context, "Lỗi: ${e.toString()}", isSuccess: false);
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Widget _buildSummaryItem(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(fontSize: 16)),
          Text(value,
              style:
                  const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
