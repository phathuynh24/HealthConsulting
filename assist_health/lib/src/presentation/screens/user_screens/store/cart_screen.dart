import 'package:assist_health/src/others/theme.dart';
import 'package:assist_health/src/presentation/screens/user_screens/store/product_detail_screen.dart';
import 'package:assist_health/src/presentation/screens/user_screens/store/purchase_screen.dart';
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
          cartItems.add(CartItem.fromJson(data)); // Parse JSON data to CartItem
        });
      }
    });
  }

  void calculateTotalPrice() {
    int total = 0;
    for (var item in widget.cartItems) {
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
        itemCount: cartItems.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(
              cartItems[index].productName,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              '${NumberFormat('#,###').format(cartItems[index].productPrice)} VNĐ',
              style: const TextStyle(color: Colors.grey),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'x${cartItems[index].quantity}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.remove_shopping_cart),
                  onPressed: () => removeItem(index),
                ),
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: BottomAppBar(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Tổng tiền: ${NumberFormat('#,###').format(totalPrice)} VNĐ',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          PurchaseScreen(cartItems: widget.cartItems),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Themes.gradientLightClr,
                ),
                child: const Text(
                  'Thanh toán',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
