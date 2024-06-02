import 'package:assist_health/src/others/theme.dart';
import 'package:assist_health/src/presentation/screens/user_screens/store/product_detail_screen.dart';
import 'package:assist_health/src/presentation/screens/user_screens/store/purchase_screen.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CartScreen extends StatefulWidget {
  final List<CartItem> cartItems;

  const CartScreen({super.key, required this.cartItems});

  @override
  _CartScreenState createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  int totalPrice = 0;
  late List<CartItem> cartItems = [];
  late String currentUserId = '';

  @override
  void initState() {
    super.initState();
    getCurrentUserId();
    fetchCartItems();
    calculateTotalPrice();
  }

  void getCurrentUserId() {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      currentUserId = user.uid;
    }
  }

  void fetchCartItems() {
    FirebaseFirestore.instance
        .collection('user_carts')
        .where('userId', isEqualTo: currentUserId)
        .get()
        .then((QuerySnapshot querySnapshot) {
      for (var document in querySnapshot.docs) {
        Map<String, dynamic> data = document.data() as Map<String, dynamic>;
        setState(() {
          cartItems.add(CartItem.fromJson(data));
          calculateTotalPrice();
        });
      }
    });
  }

  void calculateTotalPrice() {
    int total = 0;

    // Tính toán giá cho tất cả các sản phẩm trong giỏ hàng
    for (var item in cartItems) {
      total += item.quantity * item.productPrice;
    }

    setState(() {
      totalPrice = total;
    });
  }

  void removeItem(int index) {
    FirebaseFirestore.instance
        .collection('user_carts')
        .where('id', isEqualTo: cartItems[index].id)
        .get()
        .then((QuerySnapshot querySnapshot) {
      for (var document in querySnapshot.docs) {
        document.reference.delete();
      }
    });

    setState(() {
      cartItems.removeAt(index);
      calculateTotalPrice();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        foregroundColor: Colors.white,
        title: const Text(
          'Giỏ Hàng',
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
      body: ListView.builder(
        itemCount: cartItems.isEmpty ? 1 : cartItems.length,
        itemBuilder: (context, index) {
          if (cartItems.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  SizedBox(
                      height: 400,
                      width: 300,
                      child: Image.asset('assets/empty-cart.png')),
                  const Text(
                    'Chưa có đơn hàng trong giỏ',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            );
          }
          return ListTile(
            leading: Container(
              width: 80,
              child: Row(
                children: [
                  Text(
                    '${index + 1}',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                  SizedBox(width: 10),
                  CachedNetworkImage(
                    imageUrl: cartItems[index].imageUrls[0],
                    width: 60,
                    height: 60,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Center(
                      child:
                          CircularProgressIndicator(), // Hiển thị vòng tròn xoay khi tải ảnh
                    ),
                    errorWidget: (context, url, error) =>
                        const Icon(Icons.error),
                  ),
                ],
              ),
            ),
            title: Text(cartItems[index].productName),
            subtitle: Text(
              '${NumberFormat('#,###').format(cartItems[index].productPrice)} VNĐ',
              style:
                  const TextStyle(color: Themes.gradientDeepClr, fontSize: 16),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'x${cartItems[index].quantity}',
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 18),
                ),
                IconButton(
                  icon: const Icon(
                    Icons.remove_shopping_cart,
                  ),
                  onPressed: () => removeItem(index),
                ),
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: (cartItems.isNotEmpty)
          ? BottomAppBar(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Text(
                          'Tổng tiền:',
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        Text(
                          ' ${NumberFormat('#,###').format(totalPrice)} VNĐ',
                          style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color: Colors.red),
                        ),
                      ],
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                const PurchaseScreen(address: null),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Themes.gradientDeepClr,
                      ),
                      child: const Text(
                        'Thanh toán',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            fontSize: 16),
                      ),
                    ),
                  ],
                ),
              ),
            )
          : null,
    );
  }
}
