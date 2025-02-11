import 'package:assist_health/src/others/theme.dart';
import 'package:assist_health/src/presentation/screens/user_screens/home.dart';
import 'package:assist_health/src/presentation/screens/user_screens/store/home_store.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class OrderDetailsPage extends StatelessWidget {
  const OrderDetailsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 6,
      child: Scaffold(
        appBar: AppBar(
          foregroundColor: Colors.white,
          title: const Text(
            'Đơn Mua',
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
          bottom: const TabBar(
            isScrollable: true,
            indicatorColor: Colors.white,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white,
            tabs: [
              Tab(text: 'Chờ xác nhận'),
              Tab(text: 'Chờ lấy hàng'),
              Tab(text: 'Chờ giao hàng'),
              Tab(text: 'Đã giao'),
              Tab(text: 'Đã hủy'),
              Tab(text: 'Trả hàng'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            buildOrderList('Chờ xác nhận'),
            buildOrderList('Chờ lấy hàng'),
            buildOrderList('Chờ giao hàng'),
            buildOrderList('Đã giao'),
            buildOrderList('Đã hủy'),
            buildOrderList('Trả hàng'),
          ],
        ),
      ),
    );
  }

  Widget buildOrderList(String status) {
    String currentUserId = FirebaseAuth.instance.currentUser!.uid;

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('orders')
          .where('status', isEqualTo: status)
          .where('userId', isEqualTo: currentUserId)
          .orderBy('time', descending: true)
          .snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasError) {
          return Text('Đã xảy ra lỗi: ${snapshot.error}');
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        }
        if (snapshot.data!.docs.isEmpty) {
          // Nếu không có tài liệu, hiển thị hình ảnh và văn bản
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
        return SingleChildScrollView(
          child: Column(
            children: snapshot.data!.docs.map((DocumentSnapshot document) {
              int totalQuantity = 0;

              for (var cartItem in (document['userCart'] as List<dynamic>)) {
                totalQuantity +=
                    (cartItem['quantity'] as num).toInt(); // Ép kiểu sang int
              }

              Color statusColor;

              switch (document['status']) {
                case 'Chờ lấy hàng':
                  statusColor = Colors.blue;
                  break;
                case 'Chờ giao hàng':
                  statusColor = Colors.orange;
                  break;
                case 'Đã giao':
                  statusColor = Colors.green;
                  break;
                case 'Đã hủy':
                  statusColor = Colors.red;
                  break;
                default:
                  statusColor = Colors.grey;
                  break;
              }

              return GestureDetector(
                // onTap: () {
                //   Navigator.push(
                //       context,
                //       MaterialPageRoute(
                //         builder: (context) => const HomeStoreScreen(),
                //       ));
                // },
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
                      Container(
                        height: 5,
                        color: statusColor,
                      ),
                      Column(
                        children: (document['userCart'] as List<dynamic>)
                            .map((cartItem) {
                          return ListTile(
                            leading: Image.network(
                              cartItem['imageUrls']
                                  [0], // Lấy URL hình ảnh đầu tiên
                              width: 80,
                              height: 80,
                              fit: BoxFit.cover,
                            ),
                            title: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                SizedBox(
                                  width: 150,
                                  child: Text(
                                    cartItem['productName'],
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      overflow: TextOverflow.ellipsis,
                                    ),
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
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text('x${cartItem['quantity']}'),
                                Text(
                                  'đ${NumberFormat('#,###').format(
                                    cartItem['productPrice'],
                                  )}',
                                  style: const TextStyle(
                                      fontSize: 14,
                                      color: Colors.blue,
                                      fontWeight: FontWeight.bold),
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
                                    'Tổng số lượng: $totalQuantity',
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
                            _buildStatusInfo(status),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        );
      },
    );
  }

  Widget _buildStatusInfo(String status) {
    IconData iconData;
    String statusText;

    switch (status) {
      case 'Chờ xác nhận':
        iconData = Icons.pending;
        statusText = 'Đơn hàng đang chờ được xác nhận';
        break;
      case 'Chờ lấy hàng':
        iconData = Icons.timer;
        statusText = 'Đang hàng đang được chuẩn bị';
        break;
      case 'Chờ giao hàng':
        iconData = Icons.local_shipping;
        statusText = 'Đơn hàng đang được giao';
        break;
      case 'Đã giao':
        iconData = Icons.done;
        statusText = 'Đơn hàng đã được giao thành công';
        break;
      case 'Đã hủy':
        iconData = Icons.cancel;
        statusText = 'Đã hủy tự động bởi hệ thống';
        break;
      case 'Trả hàng':
        iconData = Icons.undo;
        statusText = 'Đơn hàng đã được trả lại';
        break;
      default:
        iconData = Icons.error_outline;
        statusText = 'Trạng thái không xác định';
        break;
    }

    return Padding(
      padding: const EdgeInsets.only(left: 20.0),
      child: Row(
        children: [
          Icon(
            iconData,
            color: const Color(0xFF53A799),
          ),
          const SizedBox(width: 8.0),
          Text(
            statusText,
            style: const TextStyle(
              color: Color(0xFF53A799),
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
