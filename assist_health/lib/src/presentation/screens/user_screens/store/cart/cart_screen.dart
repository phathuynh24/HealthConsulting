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
  bool isSnackBarVisible = false;

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

  void fetchCartItems() async {
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('user_carts')
          .where('userId', isEqualTo: currentUserId)
          .orderBy('timestamp', descending: true)
          .get();

      if (querySnapshot.docs.isEmpty) {
        print("Không có sản phẩm nào trong giỏ hàng.");
      }

      List<CartItem> fetchedItems = querySnapshot.docs
          .map((doc) => CartItem.fromJson(doc.data()))
          .toList();

      setState(() {
        cartItems.clear(); // Xóa danh sách cũ để tránh trùng lặp
        cartItems.addAll(fetchedItems);
        calculateTotalPrice();
      });
    } catch (error) {
      print('Lỗi khi lấy dữ liệu giỏ hàng: $error');
    }
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

  void updateCartItemQuantity(CartItem item) {
    FirebaseFirestore.instance
        .collection('user_carts')
        .where('id', isEqualTo: item.id)
        .get()
        .then((QuerySnapshot querySnapshot) {
      for (var document in querySnapshot.docs) {
        document.reference
            .update({'quantity': item.quantity}).catchError((error) {
          print("Failed to update quantity: $error");
        });
      }
    });

    // Cập nhật lại trạng thái UI
    setState(() {
      calculateTotalPrice();
    });
  }

  Future<int> fetchAvailableQuantity(String productName) async {
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('products')
          .where('name', isEqualTo: productName)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final data = querySnapshot.docs.first.data();
        return data['quantity'] ?? 0;
      }
    } catch (error) {
      print('Lỗi khi lấy số lượng sản phẩm: $error');
    }
    return 0;
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

          return Dismissible(
            key: Key(cartItems[index].id),
            direction:
                DismissDirection.endToStart, // Vuốt từ phải sang trái để xóa
            background: Container(
              color: Colors.red,
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: const Icon(Icons.delete, color: Colors.white, size: 30),
            ),
            onDismissed: (direction) {
              removeItem(index);
            },
            child: ListTile(
              leading: SizedBox(
                width: 80,
                child: Row(
                  children: [
                    Text(
                      '${index + 1}',
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                    const SizedBox(width: 10),
                    CachedNetworkImage(
                      imageUrl: cartItems[index].imageUrls[0],
                      width: 60,
                      height: 60,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => const Center(
                        child: CircularProgressIndicator(),
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
                style: const TextStyle(
                    color: Themes.gradientDeepClr, fontSize: 16),
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.remove),
                    onPressed: () {
                      setState(() {
                        if (cartItems[index].quantity > 1) {
                          cartItems[index].quantity--;
                          updateCartItemQuantity(cartItems[index]);
                          calculateTotalPrice();
                        } else {
                          removeItem(index);
                        }
                      });
                    },
                  ),
                  Text(
                    '${cartItems[index].quantity}',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: () async {
                      int availableQuantity = await fetchAvailableQuantity(
                          cartItems[index].productName);

                      if (cartItems[index].quantity < availableQuantity) {
                        setState(() {
                          cartItems[index].quantity++;
                          updateCartItemQuantity(cartItems[index]);
                          calculateTotalPrice();
                        });
                      } else if (!isSnackBarVisible) {
                        isSnackBarVisible = true;
                        ScaffoldMessenger.of(context)
                            .showSnackBar(
                              const SnackBar(
                                content:
                                    Text('Số lượng sản phẩm đã đạt tối đa.'),
                                duration: Duration(seconds: 2),
                                behavior: SnackBarBehavior.floating,
                              ),
                            )
                            .closed
                            .then((_) {
                          isSnackBarVisible =
                              false; // Reset lại trạng thái khi SnackBar đóng
                        });
                      }
                    },
                  ),
                ],
              ),
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
                        const Text(
                          'Tổng tiền:',
                          style: TextStyle(
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
