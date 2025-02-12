import 'package:assist_health/src/others/theme.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:intl/intl.dart';

class DoctorFeedbackScreen extends StatefulWidget {
  const DoctorFeedbackScreen({super.key});

  @override
  State<DoctorFeedbackScreen> createState() => _DoctorFeedbackScreenState();
}

class _DoctorFeedbackScreenState extends State<DoctorFeedbackScreen> {
  final String doctorId = FirebaseAuth.instance.currentUser!.uid;
  double? selectedRating;

  void _deleteFeedback(String feedbackId) {
    FirebaseFirestore.instance.collection('feedback').doc(feedbackId).delete();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        foregroundColor: Colors.white,
        title: const Text('Phản hồi từ bệnh nhân'),
        centerTitle: true,
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
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: RatingBar.builder(
              initialRating: selectedRating ?? 0,
              minRating: 1,
              direction: Axis.horizontal,
              allowHalfRating: true,
              itemCount: 5,
              itemSize: 60,
              itemPadding: const EdgeInsets.symmetric(horizontal: 3.0),
              itemBuilder: (context, _) => const Icon(
                Icons.star,
                color: Colors.amber,
              ),
              onRatingUpdate: (rating) {
                setState(() {
                  selectedRating = rating;
                });
              },
            ),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                selectedRating = null;
              });
            },
            child: const Text(
              'Xóa bộ lọc',
              style: TextStyle(color: Colors.red),
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('feedback')
                  .where('idDoctor', isEqualTo: doctorId)
                  .orderBy('rateDate', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const Center(
                      child: Text('Đã xảy ra lỗi khi tải dữ liệu.'));
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(
                    child: Text(
                      'Chưa có phản hồi nào từ bệnh nhân.',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  );
                }

                var feedbackList = snapshot.data!.docs.where((doc) {
                  var feedback = doc.data() as Map<String, dynamic>;
                  return selectedRating == null ||
                      feedback['rating'] == selectedRating;
                }).toList();

                if (feedbackList.isEmpty) {
                  return const Center(
                    child: Text(
                      'Không có phản hồi với số sao đã chọn.',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  );
                }

                return ListView.builder(
                  itemCount: feedbackList.length,
                  itemBuilder: (context, index) {
                    var feedbackDoc = feedbackList[index];
                    var feedback = feedbackDoc.data() as Map<String, dynamic>;
                    var formattedDate =
                        DateFormat('HH:mm:ss, dd/MM/yyyy').format(
                      DateTime.fromMillisecondsSinceEpoch(
                        feedback['rateDate'].millisecondsSinceEpoch,
                      ).toLocal(),
                    );

                    return Container(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.3),
                            blurRadius: 5,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CircleAvatar(
                            child: Text(
                              feedback['username'][0],
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  feedback['username'],
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(feedback['content'] ?? ''),
                                const SizedBox(height: 4),
                                RatingBarIndicator(
                                  rating: feedback['rating'].toDouble(),
                                  itemBuilder: (context, index) => const Icon(
                                    Icons.star,
                                    color: Colors.amber,
                                  ),
                                  itemCount: 5,
                                  itemSize: 20,
                                  direction: Axis.horizontal,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Ngày đánh giá: $formattedDate',
                                  style: const TextStyle(
                                      fontSize: 12, color: Colors.grey),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _deleteFeedback(feedbackDoc.id),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
