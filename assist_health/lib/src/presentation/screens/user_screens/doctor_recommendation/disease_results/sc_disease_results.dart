import 'package:assist_health/src/others/theme.dart';
import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

import '../recommended_results/sc_recommended_results.dart';

class DiseaseResultsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        foregroundColor: Colors.white,
        backgroundColor: Themes.gradientDeepClr,
        toolbarHeight: 50,
        title: const Text('Kết quả chẩn đoán bệnh'),
        titleTextStyle: const TextStyle(fontSize: 16),
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(45),
          child: Container(
            width: double.infinity,
            height: 45,
            color: Colors.white,
            child: Container(
              height: 45,
              padding: const EdgeInsets.symmetric(
                horizontal: 10,
              ),
              color: Colors.blueAccent.withOpacity(0.1),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.blueAccent.shade700,
                      ),
                      child: const Text(
                        '1',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(
                      width: 5,
                    ),
                    Text(
                      'Nhập triệu chứng',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.blueAccent.shade700,
                      ),
                    ),
                    const SizedBox(
                      width: 5,
                    ),
                    Icon(
                      Icons.arrow_right_alt_outlined,
                      size: 30,
                      color: Colors.blueAccent.shade700,
                    ),
                    const SizedBox(
                      width: 5,
                    ),
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.blueAccent.shade700,
                      ),
                      child: const Text(
                        '2',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(
                      width: 5,
                    ),
                    Text(
                      'Chọn biểu hiện bệnh',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.blueAccent.shade700,
                      ),
                    ),
                    const SizedBox(
                      width: 5,
                    ),
                    Row(
                      children: [
                        Icon(
                          Icons.arrow_right_alt_outlined,
                          size: 30,
                          color: Colors.blueAccent.shade700,
                        ),
                        const SizedBox(
                          width: 5,
                        ),
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.blueAccent.shade700,
                          ),
                          child: const Text(
                            '3',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(
                          width: 5,
                        ),
                        Text(
                          'Đề xuất bác sĩ phù hợp',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.blueAccent.shade700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(
                      width: 5,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 18),
            Container(
              height: 170,
              padding: const EdgeInsets.symmetric(horizontal: 18),
              child: Stack(
                children: [
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      height: 150,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage(
                              'assets/recommendation/bg_gradient.png'),
                          fit: BoxFit.cover,
                        ),
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            spreadRadius: 2,
                            blurRadius: 10,
                            offset: Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 32, vertical: 24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Hi Phát!",
                              style: TextStyle(
                                fontSize: 24,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                height: 1,
                              ),
                            ),
                            SizedBox(height: 10),
                            SizedBox(
                              width: 180,
                              child: Text(
                                "Bác sĩ AI đã chẩn đoán bệnh của bạn.",
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.white,
                                  overflow: TextOverflow.ellipsis,
                                  height: 1.3,
                                ),
                                maxLines: 2,
                              ),
                            ),
                            SizedBox(height: 10),
                            SizedBox(
                              width: 180,
                              child: Text(
                                "Hãy xem kết quả nhé!",
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  height: 1,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 0,
                    right: 0,
                    child: Padding(
                      padding: const EdgeInsets.only(right: 18),
                      child: Image.asset(
                        'assets/recommendation/doctor_3D.png',
                        height: 170,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Lời khuyên hữu ích',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 12),
                  Container(
                    height: 200,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image:
                            AssetImage('assets/recommendation/tip_sleep.png'),
                        fit: BoxFit.cover,
                      ),
                      borderRadius: BorderRadius.circular(32),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          spreadRadius: 2,
                          blurRadius: 5,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Stack(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: Color.fromARGB(255, 41, 90, 112)
                                .withOpacity(0.8),
                            borderRadius: BorderRadius.circular(32),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 32, vertical: 24),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Ngủ đủ giấc',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 6),
                              Text(
                                'Hãy cố gắng ngủ đủ giấc để cơ thể có thể phục hồi sau một ngày làm việc mệt mỏi.',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.white.withOpacity(0.9),
                                ),
                              ),
                              SizedBox(height: 20),
                              Container(
                                decoration: BoxDecoration(
                                  color: Color.fromARGB(255, 64, 80, 184),
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black12.withOpacity(0.3),
                                      spreadRadius: 4,
                                      blurRadius: 10,
                                      offset: Offset(0, 3),
                                    ),
                                  ],
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 14, vertical: 12),
                                  child: Text(
                                    'Tiếp theo',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 28),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Kết quả chẩn đoán',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: 10,
                      itemBuilder: (context, index) {
                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    RecommendedResultsScreen(),
                              ),
                            );
                          },
                          child: Container(
                            child: ListTile(
                              contentPadding: EdgeInsets.symmetric(vertical: 4),
                              leading: Container(
                                width: 60,
                                height: 60,
                                decoration: BoxDecoration(
                                  color: Color.fromARGB(255, 211, 231, 248)
                                      .withOpacity(0.3),
                                  borderRadius: BorderRadius.circular(22),
                                ),
                                child: Center(
                                  child: Text(
                                    (index + 1).toString(),
                                    style: TextStyle(
                                      color: Colors.black87,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                              title: Text('Bệnh nấm da',
                                  style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.black87,
                                      fontWeight: FontWeight.bold)),
                              subtitle: Text('Fungal skin disease',
                                  style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.blueGrey.withOpacity(0.8))),
                              trailing: Container(
                                height: 60,
                                width: 60,
                                alignment: Alignment.center,
                                child: CircularPercentIndicator(
                                  radius: 28,
                                  lineWidth: 7,
                                  percent: index == 0
                                      ? 0.68
                                      : index == 1
                                          ? 0.21
                                          : index == 2
                                              ? 0.08
                                              : 0.03,
                                  center: Text(
                                    index == 0
                                        ? '68%'
                                        : index == 1
                                            ? '21%'
                                            : index == 2
                                                ? '8%'
                                                : '3%',
                                    style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  animation: true,
                                  animationDuration: 1000,
                                  progressColor:
                                      Color.fromARGB(255, 30, 41, 238),
                                  backgroundColor: Colors.grey.shade200,
                                  circularStrokeCap: CircularStrokeCap.round,
                                ),
                              ),
                            ),
                          ),
                        );
                      }),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
