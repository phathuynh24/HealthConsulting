import 'package:assist_health/src/others/theme.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class AdminOrderManagementScreen extends StatelessWidget {
  const AdminOrderManagementScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 6,
      child: Scaffold(
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
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection('orders')
          .where('status', isEqualTo: status)
          .orderBy('time', descending: true)
          .snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Đã xảy ra lỗi: ${snapshot.error}'));
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.data == null || snapshot.data!.docs.isEmpty) {
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

        return ListView(
          children: snapshot.data!.docs.map((DocumentSnapshot document) {
            Map<String, dynamic> data = document.data() as Map<String, dynamic>;

            return Card(
              margin:
                  const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
              child: Column(
                children: [
                  Container(
                    color: _getStatusColor(status),
                    height: 5,
                  ),
                  ListTile(
                    leading:
                        Image.asset('assets/bill.png', width: 50, height: 50),
                    title: Text(
                      'Mã đơn hàng: ${document.id}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Khách hàng: ${data['address']['name']}'),
                        Text(
                            'Tổng tiền: ${NumberFormat("#,###").format(data['totalPrice'])}đ'),
                      ],
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.remove_red_eye),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => OrderDetailScreen(
                              orderId: document.id,
                              initialStatus: data['status'],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        );
      },
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Chờ lấy hàng':
        return Colors.blue;
      case 'Chờ giao hàng':
        return Colors.orange;
      case 'Đã giao':
        return Colors.green;
      case 'Đã hủy':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}

class OrderDetailScreen extends StatefulWidget {
  final String orderId;
  final String initialStatus;

  const OrderDetailScreen(
      {Key? key, required this.orderId, required this.initialStatus})
      : super(key: key);

  @override
  _OrderDetailScreenState createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  late String selectedStatus;
  bool isLoading = false; // Biến trạng thái loading

  @override
  void initState() {
    super.initState();
    selectedStatus = widget.initialStatus;
  }

  void updateStatus(String newStatus) {
    setState(() {
      selectedStatus = newStatus;
    });
  }

  void _confirmOrder() async {
    setState(() {
      isLoading = true; // Bật trạng thái loading
    });

    try {
      await FirebaseFirestore.instance
          .collection('orders')
          .doc(widget.orderId)
          .update({'status': selectedStatus});

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đã cập nhật trạng thái đơn hàng.')),
        );

        // Đợi 1 giây để hiển thị Snackbar rồi chuyển màn hình
        await Future.delayed(const Duration(seconds: 1));

        if (mounted) {
          Navigator.pop(context); // Quay lại màn hình trước đó
        }
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi cập nhật trạng thái: $error')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false; // Tắt loading
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        foregroundColor: Colors.white,
        title: const Text('Chi tiết sản phẩm'),
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
      body: FutureBuilder(
        future: FirebaseFirestore.instance
            .collection('orders')
            .doc(widget.orderId)
            .get(),
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
                  'Mã đơn hàng: ${widget.orderId}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18.0,
                  ),
                ),
                const SizedBox(height: 8.0),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Tên khách hàng:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16.0,
                        color: Colors.black87,
                      ),
                    ),
                    Text(
                      data['address']['name'],
                      style: const TextStyle(
                        fontSize: 16.0,
                        color: Colors.black54,
                      ),
                    ),
                    const SizedBox(height: 8.0),
                    const Text(
                      'Địa chỉ:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16.0,
                        color: Colors.black87,
                      ),
                    ),
                    Text(
                      data['address']['fullAddress'],
                      style: const TextStyle(
                        fontSize: 16.0,
                        color: Colors.black54,
                      ),
                    ),
                    const SizedBox(height: 8.0),
                    const Text(
                      'Tổng tiền:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16.0,
                        color: Colors.black87,
                      ),
                    ),
                    Text(
                      '${NumberFormat('#,###').format(data['totalPrice'])} VNĐ',
                      style: const TextStyle(
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16.0),
                const Text(
                  'Sản phẩm đã đặt hàng:',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16.0,
                  ),
                ),
                const SizedBox(height: 8.0),
                Column(
                  children: (data['userCart'] as List<dynamic>).map((cartItem) {
                    return ListTile(
                      leading: Image.network(
                        cartItem['imageUrls'][0], // Lấy URL hình ảnh đầu tiên
                        width: 80,
                        height: 80,
                        fit: BoxFit.cover,
                      ),
                      title: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            cartItem['productName'],
                            style: const TextStyle(fontWeight: FontWeight.bold),
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
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16.0),
                const Text(
                  'Trạng thái',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16.0,
                  ),
                ),
                const SizedBox(height: 8.0),
                StatusDropdown(
                  initialStatus: selectedStatus,
                  onUpdateStatus: updateStatus,
                ),
                const SizedBox(height: 16.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: isLoading
                          ? null
                          : _confirmOrder, // Vô hiệu hóa khi loading
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(250, 50),
                        backgroundColor: Themes.gradientDeepClr,
                        foregroundColor: Colors.white,
                      ),
                      child: isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                              'Xác nhận đơn hàng',
                              style: TextStyle(fontSize: 20),
                            ),
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

class StatusDropdown extends StatefulWidget {
  final String initialStatus;
  final Function(String) onUpdateStatus;

  const StatusDropdown(
      {Key? key, required this.initialStatus, required this.onUpdateStatus})
      : super(key: key);

  @override
  _StatusDropdownState createState() => _StatusDropdownState();
}

class _StatusDropdownState extends State<StatusDropdown> {
  late String selectedStatus;

  @override
  void initState() {
    super.initState();
    selectedStatus = widget.initialStatus;
  }

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      value: selectedStatus,
      onChanged: (newValue) {
        setState(() {
          selectedStatus = newValue!;
        });
        widget.onUpdateStatus(newValue!);
      },
      items: <String>[
        'Chờ xác nhận',
        'Chờ lấy hàng',
        'Chờ giao hàng',
        'Đã giao',
        'Đã hủy',
        'Trả hàng',
      ].map((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
    );
  }
}
