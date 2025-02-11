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
  DateTime? startDate;
  DateTime? endDate;
  String? errorMessage;

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isStartDate ? startDate ?? DateTime.now() : endDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      setState(() {
        if (isStartDate) {
          startDate = picked;
        } else {
          endDate = picked;
        }
        _validateDates();
      });
    }
  }

  void _validateDates() {
    if (startDate != null && endDate != null && startDate!.isAfter(endDate!)) {
      errorMessage = "Ngày bắt đầu không được lớn hơn ngày kết thúc!";
    } else {
      errorMessage = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        foregroundColor: Colors.white,
        title: const Text('Thống kê đơn hàng', style: TextStyle(fontWeight: FontWeight.bold)),
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
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _selectDate(context, true),
                    child: Text(
                      startDate == null
                          ? "Chọn ngày bắt đầu"
                          : "Bắt đầu: ${DateFormat('dd/MM/yyyy').format(startDate!)}",
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _selectDate(context, false),
                    child: Text(
                      endDate == null
                          ? "Chọn ngày kết thúc"
                          : "Kết thúc: ${DateFormat('dd/MM/yyyy').format(endDate!)}",
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (errorMessage != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              child: Text(errorMessage!, style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
            ),
          Expanded(
            child: OrderList(startDate: startDate, endDate: endDate),
          ),
        ],
      ),
    );
  }
}


class OrderList extends StatelessWidget {
  final DateTime? startDate;
  final DateTime? endDate;

  const OrderList({super.key, required this.startDate, required this.endDate});

  @override
  Widget build(BuildContext context) {
    return buildOrderList();
  }

  Widget buildOrderList() {
    if (startDate == null || endDate == null) {
      return const Center(child: Text("Vui lòng chọn khoảng thời gian"));
    }

    if (startDate!.isAfter(endDate!)) {
      return const Center(child: Text("Lỗi: Ngày bắt đầu không được lớn hơn ngày kết thúc!", style: TextStyle(color: Colors.red)));
    }

    Timestamp startTimestamp = Timestamp.fromDate(startDate!);
    Timestamp endTimestamp = Timestamp.fromDate(endDate!.add(const Duration(days: 1)));

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('orders')
          .where('status', isEqualTo: 'Đã giao')
          .where('time', isGreaterThanOrEqualTo: startTimestamp)
          .where('time', isLessThan: endTimestamp)
          .orderBy('time', descending: true)
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
        double totalPriceFinal = 0.0;

        snapshot.data!.docs.forEach((DocumentSnapshot document) {
          for (var cartItem in (document['userCart'] as List<dynamic>)) {
            totalQuantity += (cartItem['quantity'] as num).toInt();
            totalPrice += (cartItem['quantity'] as num) *
                (cartItem['productPrice'] as num);
          }
          totalPriceFinal += document['totalPrice'] as num;
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
                        title: Center(
                          child: const Text(
                            'Thống kê theo tháng',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                                color: Colors.red),
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  'Tổng số lượng: ',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                Text(
                                  '$totalQuantity',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: Themes.gradientDeepClr),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                Text(
                                  'Tổng giá: ',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                Text(
                                  '${NumberFormat('#,###').format(totalPrice)}đ',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: Themes.gradientDeepClr,
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                Text(
                                  'Thành tiền:',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
                                ),
                                Text(
                                  '${NumberFormat('#,###').format(totalPriceFinal)}đ',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20,
                                      // color: Themes.gradientDeepClr,
                                      color: Colors.red),
                                ),
                              ],
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
