import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

import '../../../../../models/doctor/doctor_info.dart';
import '../../../../../others/methods.dart';
import '../../doctor_detail.dart';
import '../utils/disease_classifier.dart';

class RecommendedResultsScreen extends StatefulWidget {
  final List<dynamic> diagnosis;
  const RecommendedResultsScreen({Key? key, required this.diagnosis})
      : super(key: key);

  @override
  _RecommendedResultsScreenState createState() =>
      _RecommendedResultsScreenState();
}

class _RecommendedResultsScreenState extends State<RecommendedResultsScreen> {
  List<dynamic> diagnosis = [];
  List<DoctorInfo> filterDoctorWithGroupDisease = [];
  final classifier = DiseaseClassifier();
  bool isExpanded = false; // Trạng thái hiển thị (đóng/mở) của mô tả bệnh

  @override
  void initState() {
    super.initState();
    diagnosis = widget.diagnosis;
    print(diagnosis);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Image section
            Container(
              height: 490,
              child: Stack(
                children: [
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      height: 320,
                      decoration: const BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage('assets/slider2.jpg'),
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      height: 320,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.black.withOpacity(0.8),
                            Colors.black12.withOpacity(0.4),
                          ],
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    left: 20,
                    child: Container(
                      height: 50,
                      width: 50,
                      decoration: BoxDecoration(
                        color: Colors.white38,
                        borderRadius: BorderRadius.circular(22),
                      ),
                      child: Icon(
                        Icons.arrow_back_rounded,
                        color: Colors.black.withOpacity(0.8),
                        size: 30,
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: -0.5,
                    left: 0,
                    right: 0,
                    child: Container(
                      height: 310,
                      child: Stack(
                        children: [
                          Positioned(
                            top: 0,
                            left: 0,
                            right: 0,
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 8),
                                    decoration: BoxDecoration(
                                      color: Colors.white38,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      'Tỉ lệ dự đoán ' +
                                          double.parse(diagnosis[2]
                                                  .replaceAll('%', ''))
                                              .toString() +
                                          '%',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    diagnosis[1],
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: 0,
                            left: 0,
                            right: 0,
                            child: Container(
                              height: 220,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 20),
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(32),
                                  topRight: Radius.circular(32),
                                ),
                              ),
                              child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        const Text(
                                          'Thông tin bệnh',
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        TextButton(
                                          onPressed: () {
                                            showDialog(
                                              context: context,
                                              builder: (BuildContext context) {
                                                return AlertDialog(
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            16.0),
                                                  ),
                                                  title: const Text(
                                                    'Thông tin chi tiết',
                                                    style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 18.0,
                                                    ),
                                                  ),
                                                  content: Text(
                                                    diagnosis[3],
                                                    style: const TextStyle(
                                                      fontSize: 16.0,
                                                    ),
                                                  ),
                                                  actions: [
                                                    TextButton(
                                                      onPressed: () {
                                                        Navigator.of(context)
                                                            .pop();
                                                      },
                                                      child: const Text(
                                                        'Đóng',
                                                        style: TextStyle(
                                                          color: Colors.blue,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                );
                                              },
                                            );
                                          },
                                          child: const Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.end,
                                            children: [
                                              Text(
                                                'Xem thêm',
                                                style: TextStyle(
                                                  color: Colors.blue,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              Icon(
                                                Icons.arrow_forward_sharp,
                                                color: Colors.blue,
                                                size: 14,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    Align(
                                      alignment: Alignment.center,
                                      child: Text(
                                        diagnosis[3],
                                        style: const TextStyle(
                                          fontSize: 14,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        maxLines: 6,
                                      ),
                                    ),
                                  ]),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    top: 50,
                    left: 20,
                    child: GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: Container(
                        height: 50,
                        width: 50,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.6),
                          borderRadius: BorderRadius.circular(22),
                        ),
                        child: Icon(
                          Icons.arrow_back_rounded,
                          color: Colors.black.withOpacity(0.8),
                          size: 26,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Divider(
              thickness: 1,
              indent: 16,
              endIndent: 16,
              height: 0,
              color: Colors.grey[300],
            ),
            Container(
              // Body section
              padding: EdgeInsets.all(16),
              child: Column(
                children: [
                  // Introduction row
                  const Row(
                    children: [
                      Text(
                        'Danh sách bác sĩ khuyến nghị',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  // ListView
                  StreamBuilder<List<DoctorInfo>>(
                    stream: getInfoDoctors(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (snapshot.hasError) {
                        return Center(
                          child: Text(
                            'Đã xảy ra lỗi: ${snapshot.error}',
                            style: const TextStyle(
                                fontSize: 16, color: Colors.red),
                          ),
                        );
                      }

                      if (snapshot.hasData) {
                        filterDoctorWithGroupDisease = snapshot.data!
                            .where((doctor) => classifier.isDiseaseInGroup(
                                diagnosis[0].toLowerCase(),
                                doctor.groupDisease))
                            .toList();

                        // Sort with rating
                        filterDoctorWithGroupDisease
                            .sort((a, b) => b.rating.compareTo(a.rating));

                        if (filterDoctorWithGroupDisease.isEmpty) {
                          return Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Image.asset(
                                  'assets/no_result_search_icon.png',
                                  width: 200,
                                  height: 200,
                                  fit: BoxFit.contain,
                                ),
                                const SizedBox(height: 10),
                                const Text(
                                  'Hệ thống chưa có bác sĩ điều trị bệnh này',
                                  style: TextStyle(
                                      fontSize: 18, color: Colors.grey),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 5),
                                const Text(
                                  'Vui lòng thử lại với một nhóm bệnh khác!',
                                  style: TextStyle(
                                      fontSize: 14, color: Colors.grey),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          );
                        }

                        return ListView.builder(
                          shrinkWrap: true,
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: filterDoctorWithGroupDisease.length,
                          itemBuilder: (context, index) {
                            DoctorInfo doctor =
                                filterDoctorWithGroupDisease[index];
                            return GestureDetector(
                              onTap: () {
                                // Điều hướng đến màn hình chi tiết bác sĩ
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        DoctorDetailScreen(doctorInfo: doctor),
                                  ),
                                );
                              },
                              child: Container(
                                margin: const EdgeInsets.symmetric(vertical: 4),
                                child: ListTile(
                                  contentPadding:
                                      const EdgeInsets.symmetric(vertical: 4),
                                  leading: ClipRRect(
                                    borderRadius: BorderRadius.circular(24),
                                    child: Container(
                                      width: 60,
                                      height: 60,
                                      decoration: BoxDecoration(
                                        color: const Color.fromARGB(
                                                255, 211, 231, 248)
                                            .withOpacity(0.3),
                                      ),
                                      child: Image.network(doctor.imageURL,
                                          fit: BoxFit.cover),
                                    ),
                                  ),
                                  title: Text(
                                    'BS ${doctor.name}',
                                    style: const TextStyle(
                                      fontSize: 17,
                                      color: Colors.black87,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  subtitle: Text(
                                    classifier.classifyDisease(diagnosis[0]),
                                    style: TextStyle(
                                      fontSize: 15,
                                      color: Colors.blueGrey.withOpacity(0.8),
                                    ),
                                  ),
                                  trailing: Padding(
                                    padding: const EdgeInsets.only(right: 12),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        RatingBarIndicator(
                                          rating: doctor.rating.toDouble(),
                                          itemBuilder: (context, index) =>
                                              const Icon(
                                            Icons.star,
                                            color: Colors.amber,
                                          ),
                                          itemCount: 1,
                                          itemSize: 20.0,
                                          direction: Axis.horizontal,
                                        ),
                                        Text(
                                          '${doctor.rating}/5',
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: Colors.black54,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        );
                      }

                      return const Center(
                        child: Text(
                          'Không có dữ liệu',
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
