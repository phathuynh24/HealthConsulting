import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:assist_health/src/others/theme.dart';
import 'package:assist_health/src/presentation/screens/user_screens/store/cart/cart_screen.dart';
import 'package:intl/intl.dart';

class ProductDetailScreen extends StatefulWidget {
  final String productName;
  final int productPrice;
  final int productOldPrice;

  final List<String> imageUrls;
  final String category;
  static const String defaultImageUrl = 'assets/empty-box.png';
  const ProductDetailScreen({
    super.key,
    required this.productName,
    required this.productPrice,
    required this.productOldPrice,
    required this.imageUrls,
    required this.category,
  });

  @override
  _ProductDetailScreenState createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  int quantity = 1;
  List<CartItem> cartItems = [];
  late String selectedImageUrl;
  late String currentUserId;

  @override
  void initState() {
    super.initState();
    if (widget.imageUrls.isNotEmpty) {
      selectedImageUrl = widget.imageUrls.first;
    } else {
      selectedImageUrl = ProductDetailScreen.defaultImageUrl;
    }
    getCurrentUserId();
  }

  void getCurrentUserId() {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      currentUserId = user.uid;
    } else {}
  }

  void decreaseQuantity() {
    if (quantity > 0) {
      setState(() {
        quantity--;
      });
    }
  }

  void increaseQuantity() {
    setState(() {
      quantity++;
    });
  }

  void addToCart() async {
    final cartCollection = FirebaseFirestore.instance.collection('user_carts');

    // Kiểm tra xem sản phẩm đã tồn tại trong giỏ hàng hay chưa
    final existingCartItem = await cartCollection
        .where('userId', isEqualTo: currentUserId)
        .where('productName', isEqualTo: widget.productName)
        .get();

    if (existingCartItem.docs.isNotEmpty) {
      // Nếu sản phẩm đã tồn tại trong giỏ hàng, cập nhật số lượng
      final docId = existingCartItem.docs.first.id;
      cartCollection.doc(docId).update({
        'quantity': FieldValue.increment(quantity),
      });
    } else {
      // Nếu sản phẩm chưa tồn tại trong giỏ hàng, thêm vào
      CartItem newItem = CartItem(
        id: UniqueKey().toString(),
        productName: widget.productName,
        productPrice: widget.productPrice,
        productOldPrice: widget.productOldPrice,
        quantity: quantity,
        imageUrls: widget.imageUrls,
        category: widget.category,
      );
      cartItems.add(newItem);
      cartCollection.add({
        'id': newItem.id,
        'productName': widget.productName,
        'productPrice': widget.productPrice,
        'productOldPrice': widget.productOldPrice,
        'quantity': quantity,
        'userId': currentUserId,
        'imageUrls': newItem.imageUrls,
        'category': newItem.category,
      });
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CartScreen(
          cartItems: cartItems,
        ),
      ),
    );
  }

  void navigateToProductDetail(String productId) {
    FirebaseFirestore.instance
        .collection('products')
        .doc(productId)
        .get()
        .then((DocumentSnapshot documentSnapshot) {
      if (documentSnapshot.exists) {
        // Lấy dữ liệu của sản phẩm từ DocumentSnapshot
        Map<String, dynamic> data =
            documentSnapshot.data() as Map<String, dynamic>;

        // Chuyển đến trang chi tiết sản phẩm với các thông tin của sản phẩm
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProductDetailScreen(
              productOldPrice: data['old_price'],
              productName: data['name'],
              productPrice: data['price'],
              imageUrls: (data['imageUrls'] as List<dynamic>).cast<String>(),
              category: data['category'],
            ),
          ),
        );
      } else {
        print('Document does not exist');
      }
    }).catchError((error) {
      print('Error getting document: $error');
    });
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
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    height: 265,
                    width: 275,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.5),
                          spreadRadius: 2,
                          blurRadius: 5,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.network(
                        selectedImageUrl.isNotEmpty
                            ? selectedImageUrl
                            : ProductDetailScreen.defaultImageUrl,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: List.generate(widget.imageUrls.length, (index) {
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              selectedImageUrl = widget.imageUrls[index];
                            });
                          },
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 10),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.5),
                                  spreadRadius: 2,
                                  blurRadius: 5,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: SizedBox(
                              height: 80,
                              width: 80,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: Image.network(
                                  widget.imageUrls[index],
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Text(
                widget.productName,
                style:
                    const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              Text(
                '${NumberFormat('#,###').format(widget.productPrice)} VNĐ',
                style: const TextStyle(
                    fontSize: 20,
                    color: Colors.blue,
                    fontWeight: FontWeight.w600),
              ),
              const SizedBox(width: 10),
              Text(
                '${NumberFormat('#,###').format(widget.productOldPrice)} VNĐ',
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                  decoration: TextDecoration.lineThrough,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Mô tả sản phẩm:',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              const Text(
                'Đây là mô tả chi tiết về sản phẩm.',
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  const Text(
                    'Số lượng:',
                    style: TextStyle(fontSize: 18),
                  ),
                  const SizedBox(width: 10),
                  IconButton(
                    onPressed: decreaseQuantity,
                    icon: const Icon(Icons.remove),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    quantity.toString(),
                    style: const TextStyle(fontSize: 18),
                  ),
                  const SizedBox(width: 10),
                  IconButton(
                    onPressed: increaseQuantity,
                    icon: const Icon(Icons.add),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const Text(
                'Sản phẩm cùng loại',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('products')
                    .where('category', isEqualTo: widget.category)
                    .snapshots(),
                builder: (BuildContext context,
                    AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (snapshot.hasError) {
                    return Text('Đã xảy ra lỗi: ${snapshot.error}');
                  }
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final List<Widget> productWidgets =
                      snapshot.data!.docs.map((DocumentSnapshot doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    if (data['name'] != widget.productName) {
                      // Kiểm tra xem sản phẩm có trùng với sản phẩm hiện tại không
                      String firstImageUrl =
                          (data['imageUrls'] as List<dynamic>).isEmpty
                              ? ProductDetailScreen.defaultImageUrl
                              : (data['imageUrls'] as List<dynamic>).first;
                      return GestureDetector(
                        onTap: () {
                          navigateToProductDetail(doc.id);
                        },
                        child: Container(
                          margin: const EdgeInsets.symmetric(
                              horizontal: 8), // Khoảng cách giữa các sản phẩm
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Image.network(
                                firstImageUrl, // Sử dụng hình ảnh đầu tiên trong danh sách
                                height: 100,
                                width: 100, // Đảm bảo kích thước của ảnh
                                fit: BoxFit.cover,
                              ),
                              const SizedBox(height: 10),
                              Text(
                                data['name'],
                                style: const TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 5),
                              Text(
                                '${NumberFormat('#,###').format(
                                  data['price'],
                                )} VNĐ',
                                style: const TextStyle(
                                    fontSize: 18, color: Colors.blue),
                              ),
                            ],
                          ),
                        ),
                      );
                    } else {
                      return const SizedBox(); // Trả về widget trống nếu là sản phẩm hiện tại
                    }
                  }).toList();
                  return SingleChildScrollView(
                    scrollDirection: Axis.horizontal, // Cuộn theo chiều ngang
                    child: Row(
                      children: productWidgets,
                    ),
                  );
                },
              ),
              const SizedBox(height: 20),
              Align(
                alignment: Alignment.center,
                child: ElevatedButton(
                  onPressed: addToCart,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Themes.gradientLightClr,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 40, vertical: 16),
                  ),
                  child: const Text(
                    'Thêm vào giỏ hàng',
                    style: TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                        fontWeight: FontWeight.bold),
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

class CartItem {
  final String id;
  final String productName;
  final int productPrice;
  final int productOldPrice;
  int quantity;
  final List<String> imageUrls;
  final String category;

  CartItem(
      {required this.id,
      required this.productName,
      required this.productPrice,
      required this.productOldPrice,
      required this.imageUrls,
      required this.category,
      this.quantity = 1});
  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      id: json['id'],
      productName: json['productName'],
      productPrice: json['productPrice'],
      productOldPrice: json['productOldPrice'],
      imageUrls: List<String>.from(json['imageUrls']),
      category: json['category'],
      quantity: json['quantity'] ?? 1,
    );
  }
}
