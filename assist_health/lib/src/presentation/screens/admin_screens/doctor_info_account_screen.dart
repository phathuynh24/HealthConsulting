import 'package:assist_health/src/others/theme.dart';
import 'package:assist_health/src/widgets/my_separator.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DoctorInfoAccountScreen extends StatefulWidget {
  final String doctorId;

  const DoctorInfoAccountScreen({super.key, required this.doctorId});

  @override
  State<DoctorInfoAccountScreen> createState() =>
      _DoctorInfoAccountScreenState();
}

class _DoctorInfoAccountScreenState extends State<DoctorInfoAccountScreen> {
  bool _isImageError = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Thông Tin Bác Sĩ'),
        centerTitle: true,
        foregroundColor: Colors.white,
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
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance
            .collection('users')
            .doc(widget.doctorId)
            .get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(
                child: Text('Không tìm thấy thông tin bác sĩ.'));
          }

          var doctorData = snapshot.data!.data() as Map<String, dynamic>;
          bool isFirstLogin = doctorData['isFirstLogin'] ?? true;
          String imageUrl = doctorData['imageURL'] ?? '';

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  if (isFirstLogin)
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.orange.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.orange),
                      ),
                      child: const Text(
                        'Bác sĩ mới - Chưa đăng nhập',
                        style: TextStyle(
                          color: Colors.orange,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [
                          Themes.gradientDeepClr,
                          Themes.gradientLightClr
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: CircleAvatar(
                      radius: 70,
                      backgroundColor: Colors.white,
                      backgroundImage: imageUrl.isNotEmpty
                          ? NetworkImage(imageUrl)
                          : null, // Đặt null khi không có ảnh
                      onBackgroundImageError: imageUrl.isNotEmpty
                          ? (_, __) {
                              setState(() {
                                _isImageError = true;
                              });
                            }
                          : null, // Đặt null nếu không có ảnh để tránh lỗi
                      child: (imageUrl.isEmpty || _isImageError)
                          ? const Icon(Icons.person,
                              size: 70, color: Colors.grey)
                          : null,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "Bác sĩ ${doctorData['name']}",
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    "Chức danh: ${(doctorData['careerTitiles'] != '' ? doctorData['careerTitiles'] : 'Chưa cập nhật')}",
                    style: TextStyle(fontSize: 18, color: Colors.grey[700]),
                  ),
                  const SizedBox(height: 16),
                  const MySeparator(color: Colors.grey, height: 1),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.blue, width: 1),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        buildInfoRow('Email', doctorData['email']),
                        buildInfoRow('Số điện thoại', doctorData['phone']),
                        buildInfoRow('Địa chỉ', doctorData['address']),
                        buildInfoRow(
                            'Năm tốt nghiệp', doctorData['graduationYear']),
                        buildInfoRow(
                            'Bệnh lý chuyên khoa',
                            (doctorData['groupdisease'] as List<dynamic>?)
                                ?.join(", ")),
                        buildInfoRow(
                            'Chuyên ngành',
                            (doctorData['specialty'] as List<dynamic>?)
                                ?.join(", ")),
                        buildInfoRow('Nơi làm việc', doctorData['workplace']),
                        buildInfoRow(
                            'Phí dịch vụ',
                            doctorData['serviceFee'] != null
                                ? '${doctorData['serviceFee']} VND'
                                : 'Chưa cập nhật'),
                        buildInfoRow('Mô tả', doctorData['description']),
                        buildInfoRow(
                            'Kinh nghiệm', doctorData['experienceText']),
                        buildInfoRow('Học vấn', doctorData['studyText']),
                        buildInfoRow(
                            'Đánh giá',
                            doctorData['rating'] != null
                                ? '${doctorData['rating']}/5'
                                : 'Chưa có đánh giá'),
                        buildInfoRow('Trạng thái', doctorData['status']),
                      ],
                    ),
                  )
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget buildInfoRow(String title, dynamic value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.chevron_right, size: 24, color: Colors.teal),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.black87),
                ),
                const SizedBox(height: 4),
                Text(
                  value != null && value.toString().isNotEmpty
                      ? value.toString()
                      : 'Chưa cập nhật',
                  style: TextStyle(
                    fontSize: 15,
                    color: value != null && value.toString().isNotEmpty
                        ? Colors.grey[800]
                        : Colors.red,
                    fontStyle: value != null && value.toString().isNotEmpty
                        ? FontStyle.normal
                        : FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
