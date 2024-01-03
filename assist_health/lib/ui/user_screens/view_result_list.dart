import 'dart:async';

import 'package:assist_health/models/other/result.dart';
import 'package:assist_health/others/methods.dart';
import 'package:assist_health/others/theme.dart';
import 'package:assist_health/ui/user_screens/view_result.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class ViewResultListScreen extends StatefulWidget {
  const ViewResultListScreen({super.key});

  @override
  State<ViewResultListScreen> createState() => _ViewResultListScreenState();
}

class _ViewResultListScreenState extends State<ViewResultListScreen> {
  FirebaseAuth _auth = FirebaseAuth.instance;

  final TextEditingController _searchController = TextEditingController();
  StreamController<List<Result>>? _resultController =
      StreamController<List<Result>>.broadcast();

  String _searchText = '';

  @override
  void initState() {
    super.initState();
    _resultController!.addStream(getResultAppointment(_auth.currentUser!.uid));
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
                  stream: _resultController!.stream,
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return Text('Đã xảy ra lỗi: ${snapshot.error}');
                    }

                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    List<Result> sesults = snapshot.data!;

                    // Nếu mục trống
                    if (sesults.isEmpty) {
                      return Center(
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 20),
                          height: 500,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Image.asset(
                                'assets/empty-box.png',
                                width: 250,
                                height: 250,
                                fit: BoxFit.contain,
                              ),
                              const SizedBox(
                                height: 12,
                              ),
                              const Text(
                                'Bạn chưa có lịch khám ở mục này',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blueGrey,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(
                                height: 6,
                              ),
                              const Text(
                                'Lịch khám của bạn sẽ được hiển thị tại đây.',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.blueGrey,
                                  height: 1.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }
                    //--------------------------------

                    // Lọc theo search
                    List<Result> sesultsSearch = [];
                    if (_searchText == '') {
                      sesultsSearch = sesults;
                    } else {
                      String searchText = _searchText.trim().toLowerCase();
                      sesultsSearch = sesults
                          .where((element) =>
                              element.doctorName!
                                  .toLowerCase()
                                  .contains(searchText) ||
                              element.nameProfile!
                                  .toLowerCase()
                                  .contains(searchText) ||
                              element.idAppointment!
                                  .toLowerCase()
                                  .contains(searchText))
                          .toList();
                    }
                    // Xử lý không tìm ra kết quả
                    if (sesultsSearch.isEmpty) {
                      return SingleChildScrollView(
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 20),
                          height: 350,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Image.asset(
                                'assets/no_result_search_icon.png',
                                width: 250,
                                height: 250,
                                fit: BoxFit.contain,
                              ),
                              const Text(
                                'Không tìm thấy kết quả',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              const Text(
                                'Rất tiếc, chúng tôi không tìm thấy kết quả mà bạn mong muốn, hãy thử lại xem sao.',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey,
                                  height: 1.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }
                    //--------------------------------

                    return ListView.builder(
                      shrinkWrap: true,
                      itemCount: sesultsSearch.length,
                      itemBuilder: (context, index) {
                        Result result = sesults[index];
                        return Container(
                          margin: EdgeInsets.only(
                            top: 15,
                            bottom: (index == sesults.length - 1) ? 15 : 0,
                            left: 5,
                            right: 5,
                          ),
                          padding: const EdgeInsets.symmetric(
                            vertical: 10,
                            horizontal: 12,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: Colors.white,
                          ),
                          child: InkWell(
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => ViewResultsScreen(
                                            result: result,
                                          )));
                            },
                            child: Row(
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        const Icon(
                                          FontAwesomeIcons.briefcaseMedical,
                                          color: Color(0xFF2EF76F),
                                          size: 20,
                                        ),
                                        const SizedBox(
                                          width: 8,
                                        ),
                                        Text(
                                          result.idAppointment!,
                                          style: const TextStyle(
                                            fontSize: 16,
                                            color: Colors.black,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(
                                      height: 8,
                                    ),
                                    Text(
                                      'Bác sĩ: ${result.doctorName!}',
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: Colors.black54,
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 8,
                                    ),
                                    Text(
                                      'Bệnh nhân: ${result.nameProfile!}',
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: Colors.black54,
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 8,
                                    ),
                                    Text(
                                      'Ngày trả kết quả: ${result.timeResult!}',
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: Colors.black54,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  }),
            ],
          ),
        ),
      ),
    );
  }
}
