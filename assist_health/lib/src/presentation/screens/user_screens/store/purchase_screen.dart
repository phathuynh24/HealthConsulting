import 'package:assist_health/src/others/theme.dart';
import 'package:assist_health/src/presentation/screens/user_screens/store/address/add_address.dart';
import 'package:assist_health/src/presentation/screens/user_screens/store/address/list_addresses.dart';
import 'package:assist_health/src/presentation/screens/user_screens/store/online_payment.dart';
import 'package:assist_health/src/presentation/screens/user_screens/store/payment_method.dart';
import 'package:assist_health/src/presentation/screens/user_screens/store/voucher/voucher_screen.dart';
import 'package:assist_health/src/widgets/top_snackbar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

class CustomContainerPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Vẽ đường viền container
    final paint = Paint()
      ..color = Colors.grey[300]!
      ..strokeWidth = 4;

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, size.width, size.height),
        const Radius.circular(0),
      ),
      paint,
    );

    // Vẽ các lỗ hổng ở giữa thân container
    final holePaint = Paint()..color = Colors.white;

    const holeRadius = 15.0;

    // Vẽ lỗ hổng bên trái
    canvas.drawCircle(
      Offset(size.width, size.height / 2),
      holeRadius,
      holePaint,
    );

    // Vẽ lỗ hổng bên phải
    canvas.drawCircle(
      Offset(0, size.height / 2),
      holeRadius,
      holePaint,
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}

class PurchaseScreen extends StatefulWidget {
  final DocumentSnapshot<Object?>? address;

  const PurchaseScreen({
    Key? key,
    required this.address,
  }) : super(key: key);

  @override
  State<PurchaseScreen> createState() => _PurchaseScreenState();
}

class _PurchaseScreenState extends State<PurchaseScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late String currentUserId;
  List<QueryDocumentSnapshot> cartItems = [];
  List<QueryDocumentSnapshot> vouchers = [];
  // String? _selectedPaymentMethod;
  final ValueNotifier<int> _selectedPaymentMethodNotifier =
      ValueNotifier<int>(0);

  int calculateTotalPrice() {
    int totalPrice = 0;

    for (var item in cartItems) {
      int quantity = item['quantity'];
      int productPrice = item['productPrice'];
      totalPrice += quantity * productPrice;
    }

    return totalPrice;
  }

  int calculateFinalPrice() {
    int finalPrice = calculateTotalPrice();

    if (vouchers.isNotEmpty) {
      int totalDiscount = vouchers
          .map<int>((voucher) => voucher['discount'] as int)
          .reduce((a, b) => a + b);

      finalPrice -= (finalPrice * totalDiscount ~/ 100);
    }

    return finalPrice;
  }

  @override
  void initState() {
    super.initState();
    getCurrentUser();
    getVouchers();
  }

  void getCurrentUser() {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        currentUserId = user.uid;
      });
    }
  }

  void getVouchers() {
    _firestore
        .collection('applied_voucher')
        .where('userId', isEqualTo: currentUserId)
        .snapshots()
        .listen((snapshot) {
      setState(() {
        vouchers = snapshot.docs;
      });
    });
  }

  @override
  void dispose() {
    _selectedPaymentMethodNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        foregroundColor: Colors.white,
        title: const Text(
          'Thanh toán',
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
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            StreamBuilder<QuerySnapshot>(
              stream: _firestore
                  .collection('addresses')
                  .where('userId', isEqualTo: currentUserId)
                  .snapshots(),
              builder: (BuildContext context,
                  AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.hasError) {
                  return const Text('Something went wrong');
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Text("Loading");
                }
                bool hasAddress = snapshot.data!.docs.isNotEmpty;

                return Column(
                  children: <Widget>[
                    !hasAddress
                        ? Padding(
                            padding: const EdgeInsets.all(10),
                            child: ElevatedButton.icon(
                              icon: const Icon(Icons.add,
                                  color: Colors.white), // Add this line
                              label: const Text(
                                'Thêm địa chỉ nhận hàng',
                                style: TextStyle(
                                    color: Colors.white, fontSize: 16),
                              ),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const AddAddressScreen(),
                                  ),
                                );
                              },
                              style: ButtonStyle(
                                fixedSize: WidgetStateProperty.all(const Size(
                                    300,
                                    0)), // Adjust the width and height here
                                backgroundColor: WidgetStateProperty.all(
                                    Themes.gradientLightClr),
                              ),
                            ),
                          )
                        : Padding(
                            padding: const EdgeInsets.only(
                              top: 20,
                              left: 20,
                            ),
                            child: Column(
                              children: [
                                const Row(
                                  children: [
                                    Icon(Icons.location_on,
                                        color: Themes.gradientLightClr),
                                    SizedBox(width: 10),
                                    Text(
                                      'Địa chỉ nhận hàng',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16),
                                    ),
                                  ],
                                ),
                                InkWell(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                const SavedAddressesScreen()),
                                      );
                                    },
                                    child: (widget.address != null)
                                        ? ListTile(
                                            title: Text(
                                              '${widget.address?['name'] ?? snapshot.data!.docs.first['name']} - ${widget.address?['phone'] ?? snapshot.data!.docs.first['phone']}',
                                              style: const TextStyle(
                                                  fontWeight: FontWeight.bold),
                                            ),
                                            subtitle: Text(widget
                                                    .address?['fullAddress'] ??
                                                snapshot.data!.docs
                                                    .first['fullAddress']),
                                          )
                                        : Container(
                                            padding: const EdgeInsets.all(10),
                                            child: Text(
                                              'Chọn địa chỉ',
                                              style: TextStyle(
                                                fontSize: 16,
                                                color: Colors.grey[700],
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ))),
                              ],
                            ),
                          ),
                    Container(
                      width: double.infinity,
                      height: 10,
                      color: Colors.grey[300],
                    ),
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.shopping_cart,
                                  color: Themes.gradientLightClr),
                              SizedBox(width: 10),
                              Text(
                                'Đơn hàng của bạn',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                            ],
                          ),
                          StreamBuilder<QuerySnapshot>(
                            stream: _firestore
                                .collection('user_carts')
                                .where('userId', isEqualTo: currentUserId)
                                .snapshots(),
                            builder: (BuildContext context,
                                AsyncSnapshot<QuerySnapshot> cartSnapshot) {
                              if (cartSnapshot.hasError) {
                                return const Text('Something went wrong');
                              }

                              if (cartSnapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return const Text("Loading");
                              }

                              cartItems = cartSnapshot.data!.docs;

                              if (cartItems.isEmpty) {
                                return const Text('No items in cart');
                              }

                              return Column(
                                  children: cartItems.map((item) {
                                String productName = item['productName'];
                                int quantity = item['quantity'];
                                int productPrice = item['productPrice'];
                                int productOldPrice = item['productOldPrice'];
                                List<dynamic> imageUrl = item['imageUrls'];

                                return ListTile(
                                  leading: Container(
                                    width: 50,
                                    height: 50,
                                    decoration: BoxDecoration(
                                      border: Border.all(color: Colors.grey),
                                    ),
                                    child: ClipRRect(
                                      child: Image.network(
                                        imageUrl[0],
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                  title: Text(
                                    productName,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold),
                                  ),
                                  subtitle: Row(
                                    children: [
                                      Text(
                                        '${NumberFormat('#,###').format(productPrice)} VNĐ',
                                        style: const TextStyle(
                                            color: Themes.gradientLightClr,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      const SizedBox(width: 10),
                                      Text(
                                        '${NumberFormat('#,###').format(productOldPrice)} VNĐ',
                                        style: const TextStyle(
                                          color: Colors.grey,
                                          decoration:
                                              TextDecoration.lineThrough,
                                        ),
                                      ),
                                    ],
                                  ),
                                  trailing: Text('x$quantity'),
                                );
                              }).toList());
                            },
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: double.infinity,
                      height: 10,
                      color: Colors.grey[300],
                    ),
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.local_offer,
                                  color: Themes.gradientLightClr),
                              const SizedBox(width: 10),
                              const Text(
                                'Mã giảm giá',
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                              const Spacer(),
                              IconButton(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              const VoucherScreen()),
                                    );
                                  },
                                  icon: const Icon(Icons.arrow_forward_ios)),
                            ],
                          ),
                          ListView.builder(
                              shrinkWrap: true,
                              itemCount: vouchers.length,
                              itemBuilder: (context, index) {
                                var voucher = vouchers[index];
                                return GestureDetector(
                                  onDoubleTap: () {
                                    _showDeleteConfirmationDialog(voucher);
                                  },
                                  child: Container(
                                    margin: const EdgeInsets.all(5),
                                    decoration: BoxDecoration(
                                      color: Colors.white, // Màu của Container
                                      border: Border.all(
                                        color: Colors.blue, // Màu của viền
                                        width: 2, // Độ dày của viền
                                      ),
                                    ),
                                    child: CustomPaint(
                                      painter: CustomContainerPainter(),
                                      child: ListTile(
                                        leading: Image.asset(
                                          'assets/coupon.png',
                                          width: 100,
                                          height: 100,
                                        ),
                                        title: Text(
                                          voucher['voucherCode'],
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold),
                                        ),
                                        subtitle: Text(
                                          'Discount : ${voucher['discount']}%',
                                          style: const TextStyle(
                                              fontSize: 18,
                                              color: Themes.gradientDeepClr,
                                              fontWeight: FontWeight
                                                  .bold), // Thêm "Discount : " trước giá trị discount
                                        ),
                                        onTap: () {
                                          // Thực hiện hành động khi chọn voucher
                                        },
                                      ),
                                    ),
                                  ),
                                );
                              })
                        ],
                      ),
                    ),
                    Container(
                      width: double.infinity,
                      height: 10,
                      color: Colors.grey[300],
                    ),
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.payment,
                                  color: Themes.gradientLightClr),
                              SizedBox(width: 10),
                              Text(
                                'Phương thức thanh toán',
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          PaymentMethodSelection(
                            selectedPaymentMethodNotifier:
                                _selectedPaymentMethodNotifier,
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
      bottomNavigationBar: IntrinsicHeight(
        child: Container(
          width: double.infinity,
          color: Colors.grey[200],
          // margin: const EdgeInsets.all(10),
          // padding: const EdgeInsets.symmetric(horizontal: 20),
          padding: const EdgeInsets.all(10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              StreamBuilder<QuerySnapshot>(
                stream: _firestore
                    .collection('user_carts')
                    .where('userId', isEqualTo: currentUserId)
                    .snapshots(),
                builder: (BuildContext context,
                    AsyncSnapshot<QuerySnapshot> cartSnapshot) {
                  if (cartSnapshot.hasError) {
                    return const Text('Something went wrong');
                  }

                  if (cartSnapshot.connectionState == ConnectionState.waiting) {
                    return const Text("Loading");
                  }

                  var cartItems = cartSnapshot.data!.docs;

                  if (cartItems.isEmpty) {
                    return const Text('No items in cart');
                  }

                  int totalPrice = 0;
                  int discount = 0;
                  int discountPrice = 0;
                  for (var item in cartItems) {
                    int quantity = item['quantity'];
                    int productPrice = item['productPrice'];
                    totalPrice += quantity * productPrice;
                  }
                  if (vouchers.isNotEmpty) {
                    discount = vouchers
                        .map<int>((voucher) => voucher['discount'] as int)
                        .reduce((a, b) => a + b);
                    discountPrice = totalPrice * discount ~/ 100;
                  }
                  int totalPriceAfterDiscount = totalPrice - discountPrice;

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        children: [
                          const Text(
                            'Tổng tiền: ',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          Text(
                            '${NumberFormat('#,###').format(totalPrice)} VNĐ',
                            style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Themes.gradientDeepClr),
                          )
                        ],
                      ),
                      if (discount > 0)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Giảm giá: ',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 14),
                            ),
                            Text(
                              '-${NumberFormat('#,###').format(discountPrice)} VNĐ',
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                  color: Colors.red),
                            )
                          ],
                        ),
                      if (discount > 0)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Tổng thanh toán: ',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            Text(
                              '${NumberFormat('#,###').format(totalPriceAfterDiscount)} VNĐ',
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: Themes.gradientDeepClr),
                            )
                          ],
                        ),
                    ],
                  );
                },
              ),
              ElevatedButton(
                onPressed: () {
                  // if (widget.address != null &&
                  //     _selectedPaymentMethodNotifier.value != 0) {
                  //   if (_selectedPaymentMethodNotifier.value == 1) {
                  //     Navigator.pushReplacement(
                  //       context,
                  //       MaterialPageRoute(
                  //         builder: (context) => OnLinePaymentScreen(
                  //           totalPriceAfterDiscount:
                  //               calculateFinalPrice(), // Pass the appropriate value
                  //         ),
                  //       ),
                  //     );
                  //   } else if (_selectedPaymentMethodNotifier.value == 2) {
                  //     // Handle COD payment logic here
                  //     // Navigator.pop(context);
                  //     placeOrder();
                  //   }
                  if (widget.address != null) {
                    placeOrder();
                  } else {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Lỗi'),
                        content: const Text(
                            'Vui lòng chọn địa chỉ nhận hàng trước khi đặt hàng.'),
                        actions: <Widget>[
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: const Text('OK'),
                          ),
                        ],
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Themes.gradientDeepClr,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10), // Rounded corners
                  ),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20, vertical: 12), // Padding
                ),
                child: const Text('Đặt hàng',
                    style: TextStyle(fontSize: 18, color: whiteClr)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> clearUserCart() async {
    final cartCollection = FirebaseFirestore.instance.collection('user_carts');

    final userCartItems =
        await cartCollection.where('userId', isEqualTo: currentUserId).get();

    for (final item in userCartItems.docs) {
      await cartCollection.doc(item.id).delete();
    }
  }

  void placeOrder() async {
    // Tạo đơn hàng
    Order order = Order(
      userId: currentUserId,
      orderId: const Uuid().v4(),
      userCart: cartItems,
      address: widget.address!,
      totalPrice: calculateFinalPrice(),
      status: "Chờ xác nhận",
      time: Timestamp.now(),
    );

    // Lưu đơn hàng vào Firestore
    await saveOrderToFirestore(order);

    // Cập nhật số lượng sản phẩm trong Firestore
    await updateProductQuantities();
  }

  Future<void> updateProductQuantities() async {
    try {
      for (var item in cartItems) {
        String productName = item['productName'];
        int orderedQuantity = item['quantity'];

        // Lấy thông tin sản phẩm từ Firestore
        final productQuery = await FirebaseFirestore.instance
            .collection('products')
            .where('name', isEqualTo: productName)
            .get();

        if (productQuery.docs.isNotEmpty) {
          final productDoc = productQuery.docs.first;
          int currentQuantity = productDoc['quantity'];

          // Tính toán số lượng mới
          int newQuantity = currentQuantity - orderedQuantity;
          print('Số lượng mới của sản phẩm $productName: $newQuantity');

          // Cập nhật số lượng mới vào Firestore
          await FirebaseFirestore.instance
              .collection('products')
              .doc(productDoc.id)
              .update({'quantity': newQuantity});
        }
      }
    } catch (error) {
      print('Lỗi khi cập nhật số lượng sản phẩm: $error');
    }
  }

  Future<void> saveOrderToFirestore(Order order) async {
    try {
      await FirebaseFirestore.instance
          .collection('orders')
          .add(order.toMap())
          .then((value) async {
        print('Đơn hàng đã được lưu vào Firestore');
        await updateProductQuantities();

        // Xóa giỏ hàng sau khi đặt hàng thành công
        await clearUserCart();

        // Cập nhật số lượng sản phẩm

        // Hiển thị thông báo thành công
        _showSnackBar('Đặt đơn hàng thành công', Colors.green);

        // Quay về màn hình chính
        Navigator.popUntil(context, (route) => route.isFirst);
      });
    } catch (error) {
      print('Đã xảy ra lỗi khi lưu đơn hàng: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Đã xảy ra lỗi khi lưu đơn hàng. Vui lòng thử lại.'),
          duration: Duration(seconds: 3),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showSnackBar(String message, Color color) {
    final overlay = Overlay.of(context);
    final mediaQuery = MediaQuery.of(context);
    TopSnackBar.show(overlay, mediaQuery, message, color);
  }

  void _showDeleteConfirmationDialog(QueryDocumentSnapshot voucher) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Xác nhận xóa mã giảm giá"),
          content:
              const Text("Bạn có chắc chắn muốn xóa mã giảm giá này không?"),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("Hủy"),
            ),
            TextButton(
              onPressed: () {
                _firestore
                    .collection('applied_voucher')
                    .doc(voucher.id)
                    .delete()
                    .then((value) {
                  setState(() {
                    vouchers.remove(voucher);
                  });
                  Navigator.of(context).pop(); // Đóng dialog
                }).catchError((error) {
                  print("Lỗi khi xóa voucher: $error");
                });
              },
              child: const Text("Xác nhận"),
            ),
          ],
        );
      },
    );
  }
}

class Order {
  final String status;
  final String orderId;
  final List<QueryDocumentSnapshot> userCart;
  final DocumentSnapshot<Object?> address;
  final int totalPrice;
  final String userId;
  final Timestamp time;

  Order({
    required this.orderId,
    required this.userId,
    required this.userCart,
    required this.address,
    required this.totalPrice,
    required this.status,
    required this.time,
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'orderId': orderId,
      'userCart': userCart.map((item) => item.data()).toList(),
      'address': address.data(),
      'totalPrice': totalPrice,
      'status': status,
      'time': time,
    };
  }
}
