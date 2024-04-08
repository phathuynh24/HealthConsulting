import 'dart:convert'; // Import for jsonDecode

import 'package:assist_health/src/others/theme.dart';
import 'package:assist_health/src/presentation/screens/user_screens/store/product_detail_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class CartScreen extends StatefulWidget {
  final List<CartItem> cartItems;

  CartScreen({required this.cartItems});

  @override
  _CartScreenState createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  int totalPrice = 0;
  late List<CartItem> cartItems = [];

  @override
  void initState() {
    super.initState();
    fetchCartItems();
    calculateTotalPrice();
  }

  void fetchCartItems() {
    FirebaseFirestore.instance
        .collection('user_carts')
        .get()
        .then((QuerySnapshot querySnapshot) {
      querySnapshot.docs.forEach((DocumentSnapshot document) {
        Map<String, dynamic> data = document.data() as Map<String, dynamic>;
        setState(() {
          cartItems.add(CartItem.fromJson(data)); // Parse JSON data to CartItem
        });
      });
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
        .where('productName', isEqualTo: cartItems[index].productName)
        .get()
        .then((QuerySnapshot querySnapshot) {
      querySnapshot.docs.forEach((DocumentSnapshot document) {
        document.reference.delete();
      });
    });

    setState(() {
      cartItems.removeAt(index);
      calculateTotalPrice(); // Update total price after removing item
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        foregroundColor: Colors.white,
        title: Text(
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
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              '${cartItems[index].productPrice} VNĐ',
              style: TextStyle(color: Colors.grey),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'x${cartItems[index].quantity}',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: Icon(Icons.remove_shopping_cart),
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
                'Tổng tiền: ${totalPrice.toString()} VNĐ',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              ElevatedButton(
                onPressed: () {
                  // Xử lý thanh toán ở đây
                },
                style: ElevatedButton.styleFrom(
                  primary: Themes.gradientLightClr,
                ),
                child: Text(
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
