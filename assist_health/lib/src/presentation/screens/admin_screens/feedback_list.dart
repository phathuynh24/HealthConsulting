import 'package:assist_health/src/models/other/feedback_doctor.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:intl/intl.dart';

class FeedbackList extends StatefulWidget {
  @override
  _FeedbackListState createState() => _FeedbackListState();
}

class _FeedbackListState extends State<FeedbackList> {
  @override
  void initState() {
    super.initState();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> getFeedbackDocumentStream() {
    return FirebaseFirestore.instance.collection('feedback').snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        // Đánh giá bác sĩ
        child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: getFeedbackDocumentStream(),
          builder: (BuildContext context,
              AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
            if (snapshot.hasData) {
              List<FeedbackDoctor> feedback = snapshot.data!.docs
                  .map((doc) => FeedbackDoctor.fromJson(doc.data()))
                  .toList();
              feedback.sort((a, b) => b.rateDate!.compareTo(a.rateDate!));
              return ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: feedback.length,
                itemBuilder: (BuildContext context, int index) {
                  final feedbackDoctor = feedback[index];
                  String formattedDate =
                      DateFormat('dd/MM/yyyy').format(feedbackDoctor.rateDate!);

                  return Stack(
                    children: [
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 10),
                        margin: const EdgeInsets.only(
                          top: 10,
                          bottom: 10,
                          left: 15,
                          right: 15,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.5),
                              spreadRadius: 2,
                              blurRadius: 5,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            Text(
                              feedbackDoctor.username.toString().toUpperCase(),
                              style: const TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 13,
                                height: 1.3,
                              ),
                            ),
                            const SizedBox(
                              height: 5,
                            ),
                            RatingBar.builder(
                              initialRating: feedbackDoctor.rating!,
                              minRating: 1,
                              direction: Axis.horizontal,
                              allowHalfRating: true,
                              itemCount: 5,
                              itemSize: 20,
                              itemPadding:
                                  const EdgeInsets.symmetric(horizontal: 1),
                              itemBuilder: (context, _) => const Icon(
                                Icons.star,
                                color: Colors.amber,
                              ),
                              ignoreGestures: true,
                              onRatingUpdate: (rating) {},
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            Text(
                              feedbackDoctor.content!,
                              style: const TextStyle(
                                fontSize: 14,
                                height: 1.5,
                              ),
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            Text(
                              formattedDate,
                              style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey,
                                  fontStyle: FontStyle.italic),
                            ),
                          ],
                        ),
                      ),
                      Positioned(
                        top: 20,
                        right: 30,
                        child: GestureDetector(
                          onTap: () {
                            _showDeleteConfirmationDialog(
                                context, feedbackDoctor.idDoc!);
                          },
                          child: Icon(
                            Icons.delete,
                            color: Colors.red,
                          ),
                        ),
                      )
                    ],
                  );
                },
              );
            } else if (snapshot.hasError) {
              return Text('Đã xảy ra lỗi: ${snapshot.error}');
            } else {
              return const Center(child: CircularProgressIndicator());
            }
          },
        ),
      ),
    );
  }

  void _showDeleteConfirmationDialog(BuildContext context, String id) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Xác nhận xóa đánh giá'),
          content: const Text('Bạn có chắc chắn muốn xóa đánh giá này?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Hủy'),
            ),
            TextButton(
              onPressed: () {
                _deleteFeedback(id);
                Navigator.of(context).pop();
              },
              child: const Text('Xóa'),
            ),
          ],
        );
      },
    );
  }

  void _deleteFeedback(String id) async {
    try {
      await FirebaseFirestore.instance.collection('feedback').doc(id).delete();
    } catch (e) {
      print('Error deleting doctor: $e');
    }
  }
}
