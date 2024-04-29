import 'package:assist_health/src/others/theme.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminOrderManagementScreen extends StatelessWidget {
  const AdminOrderManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        foregroundColor: Colors.white,
        title: const Text(
          'Quản lý đơn đặt hàng',
          style: TextStyle(fontSize: 20),
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
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('orders').snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Đã xảy ra lỗi: ${snapshot.error}'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.data == null || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('Không có đơn đặt hàng nào.'));
          }

          return ListView(
            children: snapshot.data!.docs.map((DocumentSnapshot document) {
              Map<String, dynamic> data =
                  document.data() as Map<String, dynamic>;

              return Card(
                margin:
                    const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                child: ListTile(
                  title: Text(
                    'Mã đơn hàng: ${document.id}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text('Tổng tiền: ${data['totalPrice']} đ'),
                  trailing: IconButton(
                    icon: const Icon(Icons.remove_red_eye),
                    onPressed: () {
                      // Hiển thị chi tiết đơn hàng khi nhấp vào
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              OrderDetailScreen(orderId: document.id),
                        ),
                      );
                    },
                  ),
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }
}

class OrderDetailScreen extends StatelessWidget {
  final String orderId;

  const OrderDetailScreen({Key? key, required this.orderId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chi tiết đơn hàng'),
      ),
      body: FutureBuilder(
        future:
            FirebaseFirestore.instance.collection('orders').doc(orderId).get(),
        builder:
            (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Đã xảy ra lỗi: ${snapshot.error}'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data == null) {
            return const Center(child: Text('Không tìm thấy đơn hàng.'));
          }

          Map<String, dynamic> data =
              snapshot.data!.data() as Map<String, dynamic>;

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Mã đơn hàng: $orderId',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18.0,
                  ),
                ),
                const SizedBox(height: 8.0),
                Text('Tên khách hàng: ${data['customerName']}'),
                Text('Địa chỉ: ${data['address']}'),
                Text('Tổng tiền: ${data['totalPrice']} đ'),
                const SizedBox(height: 16.0),
                const Text(
                  'Sản phẩm đã đặt hàng:',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16.0,
                  ),
                ),
                const SizedBox(height: 8.0),
                ListView.builder(
                  shrinkWrap: true,
                  itemCount: data['products'].length,
                  itemBuilder: (BuildContext context, int index) {
                    return ListTile(
                      title: Text(
                        data['products'][index]['name'],
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        'Số lượng: ${data['products'][index]['quantity']}',
                      ),
                    );
                  },
                ),
                const SizedBox(height: 16.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        // Xử lý xác nhận đơn hàng
                      },
                      style:
                          ElevatedButton.styleFrom(backgroundColor: Colors.green
                              // primary: Colors.green,
                              ),
                      child: const Text('Xác nhận đơn hàng'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        // Xử lý xóa đơn hàng
                      },
                      style:
                          ElevatedButton.styleFrom(backgroundColor: Colors.red
                              // primary: Colors.red,
                              ),
                      child: const Text('Xóa đơn hàng'),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
