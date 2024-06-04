import 'package:assist_health/src/others/theme.dart';
import 'package:assist_health/src/presentation/screens/user_screens/home.dart';
import 'package:assist_health/src/presentation/screens/user_screens/store/home_store.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class ShopChart extends StatefulWidget {
  const ShopChart({super.key});

  @override
  _ShopChartState createState() => _ShopChartState();
}

class _ShopChartState extends State<ShopChart> {
  int selectedMonth = DateTime.now().month;
  int selectedYear = DateTime.now().year;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        foregroundColor: Colors.white,
        title: const Text(
          'Thống kê đơn hàng',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
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
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                DropdownButton<int>(
                  value: selectedMonth,
                  items: List.generate(12, (index) {
                    return DropdownMenuItem(
                      value: index + 1,
                      child: Text('Tháng ${index + 1}'),
                    );
                  }),
                  onChanged: (value) {
                    setState(() {
                      selectedMonth = value!;
                    });
                  },
                ),
                const SizedBox(width: 16),
                DropdownButton<int>(
                  value: selectedYear,
                  items: List.generate(10, (index) {
                    int year = DateTime.now().year - 5 + index;
                    return DropdownMenuItem(
                      value: year,
                      child: Text('$year'),
                    );
                  }),
                  onChanged: (value) {
                    setState(() {
                      selectedYear = value!;
                    });
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: OrderList(
                selectedMonth: selectedMonth, selectedYear: selectedYear),
          ),
        ],
      ),
    );
  }
}

class OrderList extends StatelessWidget {
  final int selectedMonth;
  final int selectedYear;

  const OrderList(
      {super.key, required this.selectedMonth, required this.selectedYear});

  @override
  Widget build(BuildContext context) {
    return buildOrderList();
  }

  Widget buildOrderList() {
    DateTime startOfMonth = DateTime(selectedYear, selectedMonth, 1);
    DateTime endOfMonth = DateTime(selectedYear, selectedMonth + 1, 1)
        .subtract(Duration(days: 1));

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('orders')
          .where('status', isEqualTo: 'Đã giao')
          .where('time', isGreaterThanOrEqualTo: startOfMonth)
          .where('time', isLessThanOrEqualTo: endOfMonth)
          .snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Đã xảy ra lỗi: ${snapshot.error}'));
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.data!.docs.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                SizedBox(
                    width: 300, child: Image.asset('assets/empty-order.png')),
                const Text(
                  'Không có đơn hàng nào',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                ),
              ],
            ),
          );
        }

        int totalQuantity = 0;
        double totalPrice = 0.0;

        snapshot.data!.docs.forEach((DocumentSnapshot document) {
          for (var cartItem in (document['userCart'] as List<dynamic>)) {
            totalQuantity += (cartItem['quantity'] as num).toInt();
            totalPrice += (cartItem['quantity'] as num) *
                (cartItem['productPrice'] as num);
          }
        });

        return SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Card(
                  elevation: 5,
                  margin: const EdgeInsets.all(8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                    side: BorderSide(
                      color: Colors.grey[300]!,
                      width: 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ListTile(
                        title: const Text(
                          'Thống kê theo tháng',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Tổng số lượng: $totalQuantity',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            Text(
                              'Thành tiền: đ${NumberFormat('#,###').format(totalPrice)}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              ...snapshot.data!.docs.map((DocumentSnapshot document) {
                int documentTotalQuantity = 0;
                for (var cartItem in (document['userCart'] as List<dynamic>)) {
                  documentTotalQuantity +=
                      (cartItem['quantity'] as num).toInt();
                }
                return Card(
                  elevation: 5,
                  margin: const EdgeInsets.all(8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                    side: BorderSide(
                      color: Colors.grey[300]!,
                      width: 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Column(
                        children: (document['userCart'] as List<dynamic>)
                            .map((cartItem) {
                          return Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: 80,
                                  height: 80,
                                  child: CachedNetworkImage(
                                    imageUrl: cartItem['imageUrls']
                                        [0], // Lấy URL hình ảnh đầu tiên
                                    fit: BoxFit.cover,
                                    placeholder: (context, url) =>
                                        CircularProgressIndicator(), // Optional placeholder widget
                                    errorWidget: (context, url, error) => Icon(
                                        Icons.error), // Optional error widget
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        cartItem['productName'],
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'x${cartItem['quantity']}',
                                        style: const TextStyle(fontSize: 14),
                                      ),
                                      Text(
                                        'đ${NumberFormat('#,###').format(cartItem['productPrice'])}',
                                        style: const TextStyle(
                                            fontSize: 14,
                                            color: Colors.blue,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                ),
                                Text(
                                  '${document['status']}',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                      Container(
                        margin: const EdgeInsets.symmetric(vertical: 10.0),
                        child: Column(
                          children: [
                            const Divider(
                              color: Colors.grey,
                              thickness: 1.0,
                              height: 20.0,
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 20.0),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    'Tổng số lượng: $documentTotalQuantity',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14.0,
                                    ),
                                  ),
                                  Text(
                                    'Thành tiền: đ${NumberFormat('#,###').format(document['totalPrice'])}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14.0,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Divider(
                              color: Colors.grey,
                              thickness: 1.0,
                              height: 20.0,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ],
          ),
        );
      },
    );
  }
}
