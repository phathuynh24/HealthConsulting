import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:percent_indicator/percent_indicator.dart';

class RecommendedResultsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Image section
            Container(
              height: 470,
              child: Stack(
                children: [
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      height: 320,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage('assets/slider2.jpg'),
                          fit: BoxFit.cover,
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
                      height: 260,
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
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 8),
                                    decoration: BoxDecoration(
                                      color: Colors.white38,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      'Tỉ lệ dự đoán 40%',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    'Có khả năng mắc bệnh viêm gan C',
                                    style: TextStyle(
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
                              height: 170,
                              padding: EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 20),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(32),
                                  topRight: Radius.circular(32),
                                ),
                              ),
                              child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Thông tin bệnh',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    SizedBox(
                                      height: 12,
                                    ),
                                    Align(
                                      alignment: Alignment.center,
                                      child: Text(
                                        'Viêm gan C (HCV) lây qua tiếp xúc với máu nhiễm virus hoặc quá trình truyền máu không an toàn. Triệu chứng bao gồm mệt mỏi, đau cơ, buồn nôn, vàng da và sự suy giảm chức năng gan.',
                                        style: TextStyle(
                                          fontSize: 14,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        maxLines: 4,
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
                  Row(
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
                  ListView.builder(
                    shrinkWrap: true,
                    padding: EdgeInsets.symmetric(vertical: 4),
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: 10,
                    itemBuilder: (context, index) {
                      return GestureDetector(
                        onTap: () {
                          // Điều hướng đến màn hình chi tiết bác sĩ
                          // Navigator.push(
                          //   context,
                          //   MaterialPageRoute(
                          //     builder: (context) => RecommendedResultsScreen(),
                          //   ),
                          // );
                        },
                        child: Container(
                          margin: EdgeInsets.symmetric(vertical: 4),
                          child: ListTile(
                            contentPadding: EdgeInsets.symmetric(vertical: 4),
                            leading: Container(
                              width: 60,
                              height: 60,
                              decoration: BoxDecoration(
                                color: Color.fromARGB(255, 211, 231, 248)
                                    .withOpacity(0.3),
                                borderRadius: BorderRadius.circular(22),
                                image: DecorationImage(
                                  image: AssetImage(
                                      'assets/recommendation/avt_test.png'),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            title: Text(
                              'BS Nguyễn Minh Anh',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.black87,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Text(
                              'Khoa Nội tổng quát',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.blueGrey.withOpacity(0.8),
                              ),
                            ),
                            trailing: Padding(
                              padding: const EdgeInsets.only(right: 12),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  RatingBarIndicator(
                                    rating: 4.5,
                                    itemBuilder: (context, index) => Icon(
                                      Icons.star,
                                      color: Colors.amber,
                                    ),
                                    itemCount: 1,
                                    itemSize: 20.0,
                                    direction: Axis.horizontal,
                                  ),
                                  Text(
                                    '4.5/5',
                                    style: TextStyle(
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
