import 'dart:async';

import 'package:assist_health/src/models/other/result.dart';
import 'package:assist_health/src/others/methods.dart';
import 'package:assist_health/src/others/theme.dart';
import 'package:assist_health/src/presentation/screens/user_screens/view_result.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';

class ViewResultListScreen extends StatefulWidget {
  const ViewResultListScreen({super.key});

  @override
  State<ViewResultListScreen> createState() => _ViewResultListScreenState();
}

class _ViewResultListScreenState extends State<ViewResultListScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final TextEditingController _searchController = TextEditingController();
  final StreamController<List<Result>> _resultController =
      StreamController<List<Result>>.broadcast();

  String _searchText = '';

  @override
  void initState() {
    super.initState();
    _resultController.addStream(getResultAppointment(_auth.currentUser!.uid));
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade200,
      appBar: AppBar(
        foregroundColor: Colors.white,
        toolbarHeight: 80,
        title: Column(
          children: [
            const Text(
              'Kết quả khám',
              style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.9),
            ),
            const SizedBox(
              height: 10,
            ),
            Container(
              height: 38,
              decoration: BoxDecoration(
                color: Colors.blueGrey.shade800.withOpacity(0.7),
                borderRadius: BorderRadius.circular(30),
              ),
              child: TextFormField(
                controller: _searchController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.all(10),
                  hintText: 'Tên bác sĩ, bệnh nhân, mã phiếu khám',
                  hintStyle: const TextStyle(
                    color: Colors.white70,
                    fontSize: 15,
                  ),
                  prefixIcon: const Icon(
                    Icons.search,
                    color: Colors.white70,
                    size: 23,
                  ),
                  border: InputBorder.none,
                  suffixIconConstraints:
                      const BoxConstraints(maxHeight: 30, maxWidth: 30),
                  suffixIcon: GestureDetector(
                    onTap: () {
                      setState(() {
                        _searchText = '';
                        _searchController.text = _searchText;
                      });
                    },
                    child: Container(
                      width: 16,
                      height: 16,
                      margin: const EdgeInsets.only(
                        right: 10,
                      ),
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white70,
                      ),
                      child: Center(
                        child: Icon(
                          Icons.clear,
                          size: 15,
                          color: Colors.blueGrey.shade700,
                        ),
                      ),
                    ),
                  ),
                ),
                onChanged: (value) {
                  setState(() {
                    _searchText = value;
                  });
                },
              ),
            ),
          ],
        ),
        centerTitle: true,
        automaticallyImplyLeading: false,
        elevation: 0,
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
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 15,
          ),
          child: Column(
            children: [
              StreamBuilder<List<Result>>(
                stream: _resultController.stream,
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Text('Đã xảy ra lỗi: ${snapshot.error}');
                  }

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  List<Result> sesults = snapshot.data ?? [];

                  // Nếu không có dữ liệu
                  if (sesults.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset('assets/empty-box.png',
                              width: 250, height: 250),
                          const SizedBox(height: 12),
                          const Text('Bạn chưa có kết quả khám',
                              style: TextStyle(fontWeight: FontWeight.bold)),
                          const Text('Hãy chờ kết quả khám từ bác sĩ!',
                              textAlign: TextAlign.center),
                        ],
                      ),
                    );
                  }

                  // Lọc theo từ khóa tìm kiếm
                  List<Result> sesultsSearch = _searchText.isEmpty
                      ? sesults
                      : sesults
                          .where((element) =>
                              (element.doctorName
                                      ?.toLowerCase()
                                      .contains(_searchText.toLowerCase()) ??
                                  false) ||
                              (element.nameProfile
                                      ?.toLowerCase()
                                      .contains(_searchText.toLowerCase()) ??
                                  false) ||
                              (element.appointmentCode
                                      ?.toLowerCase()
                                      .contains(_searchText.toLowerCase()) ??
                                  false))
                          .toList();

                  // Xử lý không tìm thấy kết quả
                  if (sesultsSearch.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset('assets/no_result_search_icon.png',
                              width: 250, height: 250),
                          const Text('Không tìm thấy kết quả',
                              style: TextStyle(fontWeight: FontWeight.bold)),
                          const Text('Hãy thử lại với từ khóa khác.',
                              textAlign: TextAlign.center),
                        ],
                      ),
                    );
                  }

                  // Sắp xếp theo ngày trả kết quả (gần nhất lên đầu)
                  sesultsSearch.sort((a, b) {
                    if (a.timeResult == null && b.timeResult == null) return 0;
                    if (a.timeResult == null) return 1;
                    if (b.timeResult == null) return -1;
                    return b.timeResult!.compareTo(a.timeResult!);
                  });

                  // Hiển thị danh sách kết quả
                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: sesultsSearch.length,
                    itemBuilder: (context, index) {
                      Result result = sesultsSearch[index];
                      final formattedTimeResult = result.timeResult != null
                          ? DateFormat('HH:mm dd-MM-yyyy')
                              .format(result.timeResult!)
                          : 'Chưa có kết quả';

                      return InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    ViewResultsScreen(result: result)),
                          );
                        },
                        child: Container(
                          margin: const EdgeInsets.symmetric(
                              vertical: 8, horizontal: 10),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                  color: Colors.grey.shade200,
                                  blurRadius: 5,
                                  offset: const Offset(0, 3))
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                  'Mã phiếu: ${result.appointmentCode ?? 'Không xác định'}',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold)),
                              const SizedBox(height: 5),
                              Text(
                                  'Bác sĩ: ${result.doctorName ?? 'Không rõ'}'),
                              Text(
                                  'Bệnh nhân: ${result.nameProfile ?? 'Không rõ'}'),
                              Text('Ngày trả kết quả: $formattedTimeResult'),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
