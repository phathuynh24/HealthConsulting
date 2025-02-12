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
  double? selectedRating;
  final TextEditingController _searchController = TextEditingController();
  Map<String, String> doctorNameCache = {};

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> getFeedbackDocumentStream() {
    return FirebaseFirestore.instance.collection('feedback').snapshots();
  }

  Future<String> getDoctorName(String doctorId) async {
    if (doctorNameCache.containsKey(doctorId)) {
      return doctorNameCache[doctorId]!;
    }
    final docSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(doctorId)
        .get();
    final doctorName = docSnapshot.data()?['name'] ?? 'Không rõ';
    doctorNameCache[doctorId] = doctorName;
    return doctorName;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                hintText: 'Tìm kiếm theo tên bác sĩ...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                ),
              ),
              onChanged: (value) {
                setState(() {});
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: RatingBar.builder(
              initialRating: selectedRating ?? 0,
              minRating: 1,
              direction: Axis.horizontal,
              allowHalfRating: true,
              itemCount: 5,
              itemSize: 50,
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
                _searchController.clear();
              });
            },
            child: const Text(
              'Xóa bộ lọc',
              style: TextStyle(color: Colors.red),
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: getFeedbackDocumentStream(),
              builder: (BuildContext context, snapshot) {
                if (snapshot.hasData) {
                  List<FeedbackDoctor> feedback = snapshot.data!.docs
                      .map((doc) => FeedbackDoctor.fromJson(doc.data()))
                      .toList();

                  if (selectedRating != null) {
                    feedback = feedback
                        .where((f) => f.rating == selectedRating)
                        .toList();
                  }

                  if (_searchController.text.isNotEmpty) {
                    feedback = feedback.where((f) {
                      final doctorName = doctorNameCache[f.idDoctor] ?? '';
                      return doctorName
                          .toLowerCase()
                          .contains(_searchController.text.toLowerCase());
                    }).toList();
                  }

                  feedback.sort((a, b) => b.rateDate!.compareTo(a.rateDate!));

                  if (feedback.isEmpty) {
                    return const Center(
                      child: Text(
                        'Không có phản hồi với bộ lọc hiện tại.',
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    );
                  }

                  return FutureBuilder<Map<String, String>>(
                    future: Future.wait(
                      feedback.map((f) async {
                        final name = await getDoctorName(f.idDoctor!);
                        return MapEntry(f.idDoctor!, name);
                      }),
                    ).then((entries) => Map.fromEntries(entries)),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      final doctorNames = snapshot.data!;

                      return ListView.builder(
                        itemCount: feedback.length,
                        itemBuilder: (BuildContext context, int index) {
                          final feedbackDoctor = feedback[index];
                          String formattedDate =
                              DateFormat('HH:mm:ss, dd/MM/yyyy')
                                  .format(feedbackDoctor.rateDate!);

                          return Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 10),
                            margin: const EdgeInsets.symmetric(
                                horizontal: 15, vertical: 5),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Bác sĩ: ${doctorNames[feedbackDoctor.idDoctor] ?? "Không rõ"}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  feedbackDoctor.username
                                      .toString()
                                      .toUpperCase(),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w500,
                                    fontSize: 13,
                                  ),
                                ),
                                const SizedBox(height: 5),
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
                                const SizedBox(height: 10),
                                Text(
                                  feedbackDoctor.content!,
                                  style: const TextStyle(
                                    fontSize: 14,
                                  ),
                                  maxLines: 3,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  formattedDate,
                                  style: const TextStyle(
                                      fontSize: 12, color: Colors.grey),
                                ),
                              ],
                            ),
                          );
                        },
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
        ],
      ),
    );
  }
}
