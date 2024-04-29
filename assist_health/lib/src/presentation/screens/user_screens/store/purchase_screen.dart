import 'package:assist_health/src/others/theme.dart';
import 'package:assist_health/src/presentation/screens/user_screens/store/add_address.dart';
import 'package:assist_health/src/presentation/screens/user_screens/store/product_detail_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class PurchaseScreen extends StatefulWidget {
  final List<CartItem> cartItems;

  const PurchaseScreen({Key? key, required this.cartItems}) : super(key: key);

  @override
  State<PurchaseScreen> createState() => _PurchaseScreenState();
}

class _PurchaseScreenState extends State<PurchaseScreen> {
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
            Padding(
              padding: const EdgeInsets.all(10),
              child: Center(
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.add,
                      color: Colors.white), // Add this line
                  label: const Text(
                    'Thêm địa chỉ nhận hàng',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AddAddressScreen(),
                      ),
                    );
                  },
                  style: ButtonStyle(
                    fixedSize: MaterialStateProperty.all(
                        const Size(300, 0)), // Adjust the width and height here
                    backgroundColor:
                        MaterialStateProperty.all(Themes.gradientLightClr),
                  ),
                ),
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
                      Icon(Icons.shopping_cart, color: Themes.gradientLightClr),
                      SizedBox(width: 10),
                      Text(
                        'Đơn hàng của bạn',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                    ],
                  ),
                  Column(
                    children: _buildProductList(widget.cartItems),
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
                  const Row(
                    children: [
                      Icon(Icons.local_offer, color: Themes.gradientLightClr),
                      SizedBox(width: 10),
                      Text(
                        'Mã giảm giá',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Row(
                    children: [
                      const Expanded(
                        child: SizedBox(
                          height: 50,
                          child: TextField(
                            decoration: InputDecoration(
                              border: OutlineInputBorder(),
                              hintText: 'Nhập mã giảm giá của bạn',
                            ),
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          // Xử lý khi văn bản "Áp dụng" được nhấp
                        },
                        child: const Text(
                          'Áp dụng',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Themes.gradientLightClr,
                          ),
                        ),
                      ),
                    ],
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
                  const Row(
                    children: [
                      Icon(Icons.payment, color: Themes.gradientLightClr),
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Nút cho VNPay
                      ElevatedButton.icon(
                        onPressed: () {
                          // Xử lý sự kiện cho VNPay
                        },
                        icon: Image.asset(
                          'assets/vnpay_logo.png',
                          width: 24,
                          height: 24,
                        ),
                        label: const Text(
                          'VNPay',
                          style: TextStyle(
                            color: Colors
                                .black, // Add this line to change the text color
                          ),
                        ),
                        // style: Sty
                      ),
                      // Nút cho Ship COD
                      ElevatedButton.icon(
                        onPressed: () {
                          // Xử lý sự kiện cho Ship COD
                        },
                        icon: Image.asset('assets/ship_cod_logo.png',
                            width: 24, height: 24),
                        label: const Text(
                          'Ship COD',
                          style: TextStyle(
                            color: Colors
                                .black, // Add this line to change the text color
                          ),
                        ),
                      ),
                      // Nút cho Momo
                      ElevatedButton.icon(
                        onPressed: () {
                          // Xử lý sự kiện cho Momo
                        },
                        icon: Image.asset('assets/momo_logo.png',
                            width: 24, height: 24),
                        label: const Text(
                          'Momo',
                          style: TextStyle(
                            color: Colors
                                .black, // Add this line to change the text color
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildProductList(List<CartItem> cartItems) {
    return cartItems.map((item) => _buildProductItem(item)).toList();
  }

  Widget _buildProductItem(CartItem item) {
    return ListTile(
      title: Text(
        item.productName,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitle: Text(
        '${NumberFormat('#,###').format(item.productPrice)} VNĐ',
        style: const TextStyle(color: Colors.grey),
      ),
      trailing: Text('x${item.quantity}'),
    );
  }
}
