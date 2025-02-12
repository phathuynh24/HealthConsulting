import 'package:cached_network_image/cached_network_image.dart';
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
  final String description;
  static const String defaultImageUrl = 'assets/empty-box.png';

  const ProductDetailScreen({
    super.key,
    required this.productName,
    required this.productPrice,
    required this.productOldPrice,
    required this.imageUrls,
    required this.description,
    required this.category,
  });

  @override
  _ProductDetailScreenState createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  final ValueNotifier<int> quantityNotifier = ValueNotifier<int>(1);
  List<CartItem> cartItems = [];
  late String selectedImageUrl;
  late String currentUserId;
  double averageRating = 0.0;
  int voteCount = 0;
  int availableQuantity = 1;

  Future<String> getUserName(String userId) async {
    DocumentSnapshot userDoc =
        await FirebaseFirestore.instance.collection('users').doc(userId).get();
    if (userDoc.exists) {
      return userDoc['name'];
    } else {
      return 'Unknown User';
    }
  }

  @override
  void initState() {
    super.initState();
    if (widget.imageUrls.isNotEmpty) {
      selectedImageUrl = widget.imageUrls.first;
    } else {
      selectedImageUrl = ProductDetailScreen.defaultImageUrl;
    }
    getCurrentUserId();
    fetchProductRatingAndVoteCount();
    fetchAvailableQuantity();
  }

  void getCurrentUserId() {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      currentUserId = user.uid;
    }
  }

  void fetchAvailableQuantity() {
    FirebaseFirestore.instance
        .collection('products')
        .where('name', isEqualTo: widget.productName)
        .get()
        .then((QuerySnapshot querySnapshot) {
      if (querySnapshot.docs.isNotEmpty) {
        final data = querySnapshot.docs.first.data() as Map<String, dynamic>;
        setState(() {
          availableQuantity = data['quantity'];
        });
      }
    }).catchError((error) {
      print('Error fetching available quantity: $error');
    });
  }

  void decreaseQuantity() {
    if (quantityNotifier.value > 0) {
      quantityNotifier.value--;
    }
  }

  bool isSnackBarVisible = false;

  void increaseQuantity() {
    if (quantityNotifier.value < availableQuantity) {
      quantityNotifier.value++;
    } else if (!isSnackBarVisible) {
      isSnackBarVisible = true;
      ScaffoldMessenger.of(context)
          .showSnackBar(
            const SnackBar(
              content: Text('Số lượng sản phẩm đã đạt tối đa.'),
              duration: Duration(seconds: 2), // Đặt thời gian tự động ẩn
              behavior: SnackBarBehavior.floating,
            ),
          )
          .closed
          .then((_) {
        isSnackBarVisible = false; // Reset khi SnackBar biến mất
      });
    }
  }

  void addToCart() async {
    final cartCollection = FirebaseFirestore.instance.collection('user_carts');

    final existingCartItem = await cartCollection
        .where('userId', isEqualTo: currentUserId)
        .where('productName', isEqualTo: widget.productName)
        .get();

    if (existingCartItem.docs.isNotEmpty) {
      final docId = existingCartItem.docs.first.id;
      cartCollection.doc(docId).update({
        'quantity': FieldValue.increment(quantityNotifier.value),
      });
    } else {
      CartItem newItem = CartItem(
        id: UniqueKey().toString(),
        productName: widget.productName,
        productPrice: widget.productPrice,
        productOldPrice: widget.productOldPrice,
        quantity: quantityNotifier.value,
        imageUrls: widget.imageUrls,
        category: widget.category,
      );
      cartItems.add(newItem);
      cartCollection.add({
        'id': newItem.id,
        'productName': widget.productName,
        'productPrice': widget.productPrice,
        'productOldPrice': widget.productOldPrice,
        'quantity': quantityNotifier.value,
        'userId': currentUserId,
        'imageUrls': newItem.imageUrls,
        'category': newItem.category,
        'timestamp': FieldValue.serverTimestamp(),
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
        Map<String, dynamic> data =
            documentSnapshot.data() as Map<String, dynamic>;

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProductDetailScreen(
              productOldPrice: data['old_price'],
              productName: data['name'],
              productPrice: data['price'],
              imageUrls: (data['imageUrls'] as List<dynamic>).cast<String>(),
              category: data['category'],
              description: data['description'],
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

  void fetchProductRatingAndVoteCount() {
    FirebaseFirestore.instance
        .collection('products')
        .where('name', isEqualTo: widget.productName)
        .get()
        .then((QuerySnapshot querySnapshot) {
      if (querySnapshot.docs.isNotEmpty) {
        final data = querySnapshot.docs.first.data() as Map<String, dynamic>;
        setState(() {
          averageRating = data['rating'];
          voteCount = data['voteCount'];
        });
      }
    }).catchError((error) {
      print('Error fetching rating and vote count: $error');
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
              _buildProductImageSection(),
              const SizedBox(height: 20),
              _buildProductInfoSection(),
              const SizedBox(height: 20),
              _buildQuantitySection(),
              const SizedBox(height: 20),
              _buildRelatedProductsSection(),
              const SizedBox(height: 20),
              _buildProductReviewsSection(),
              const SizedBox(height: 20),
              _buildAddToCartButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProductImageSection() {
    return Row(
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
            child: CachedNetworkImage(
              imageUrl: selectedImageUrl.isNotEmpty
                  ? selectedImageUrl
                  : ProductDetailScreen.defaultImageUrl,
              fit: BoxFit.cover,
              placeholder: (context, url) => const Center(
                child: CircularProgressIndicator(),
              ),
              errorWidget: (context, url, error) => const Icon(Icons.error),
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
                      child: CachedNetworkImage(
                        imageUrl: widget.imageUrls[index],
                        fit: BoxFit.cover,
                        placeholder: (context, url) => const Center(
                          child: CircularProgressIndicator(),
                        ),
                        errorWidget: (context, url, error) =>
                            const Icon(Icons.error),
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ],
    );
  }

  Widget _buildProductInfoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.productName,
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(width: 10),
        Row(
          children: [
            Text(
              averageRating.toStringAsFixed(1),
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const Icon(Icons.star, color: Colors.yellow),
            Text(
              '($voteCount đánh giá)',
              style: const TextStyle(fontSize: 20),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Text(
          '${NumberFormat('#,###').format(widget.productPrice)} VNĐ',
          style: const TextStyle(
              fontSize: 20, color: Colors.blue, fontWeight: FontWeight.w600),
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
        Text(
          'Số lượng tồn kho: $availableQuantity',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        const Text(
          'Mô tả sản phẩm:',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        Text(
          widget.description,
          style: const TextStyle(fontSize: 16),
        ),
      ],
    );
  }

  Widget _buildQuantitySection() {
    return ValueListenableBuilder<int>(
      valueListenable: quantityNotifier,
      builder: (context, value, child) {
        return Row(
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
              value.toString(),
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(width: 10),
            IconButton(
              onPressed: increaseQuantity,
              icon: const Icon(Icons.add),
            ),
          ],
        );
      },
    );
  }

  Widget _buildRelatedProductsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
          builder:
              (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
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
                String firstImageUrl =
                    (data['imageUrls'] as List<dynamic>).isEmpty
                        ? ProductDetailScreen.defaultImageUrl
                        : (data['imageUrls'] as List<dynamic>).first;
                return GestureDetector(
                  onTap: () {
                    navigateToProductDetail(doc.id);
                  },
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CachedNetworkImage(
                          imageUrl: firstImageUrl,
                          height: 100,
                          width: 100,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => const Center(
                            child: CircularProgressIndicator(),
                          ),
                          errorWidget: (context, url, error) =>
                              const Icon(Icons.error),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          data['name'],
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          '${NumberFormat('#,###').format(data['price'])} VNĐ',
                          style:
                              const TextStyle(fontSize: 18, color: Colors.blue),
                        ),
                      ],
                    ),
                  ),
                );
              } else {
                return const SizedBox();
              }
            }).toList();
            return SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: productWidgets,
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildProductReviewsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Đánh giá sản phẩm',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('product_review')
              .where('productName', isEqualTo: widget.productName)
              .snapshots(),
          builder:
              (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (snapshot.hasError) {
              return Text('Đã xảy ra lỗi: ${snapshot.error}');
            }
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            final List<Widget> reviewWidgets =
                snapshot.data!.docs.map((DocumentSnapshot doc) {
              final data = doc.data() as Map<String, dynamic>;
              final DateTime reviewDate =
                  (data['timestamp'] as Timestamp).toDate();
              final formattedDate = DateFormat('dd/MM/yyyy').format(reviewDate);

              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.grey),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Ngày: $formattedDate',
                          style:
                              const TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                        Row(
                          children: [
                            Text(
                              '${data['rating']}',
                              style: const TextStyle(fontSize: 16),
                            ),
                            const Icon(Icons.star, color: Colors.yellow),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 5),
                    Text(
                      data['review'],
                      style: const TextStyle(fontSize: 18),
                    ),
                  ],
                ),
              );
            }).toList();
            return SizedBox(
              height: 150,
              child: SingleChildScrollView(
                child: Column(
                  children: reviewWidgets,
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildAddToCartButton() {
    return Align(
      alignment: Alignment.center,
      child: ElevatedButton(
        onPressed: addToCart,
        style: ElevatedButton.styleFrom(
          backgroundColor: Themes.gradientLightClr,
          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
        ),
        child: const Text(
          'Thêm vào giỏ hàng',
          style: TextStyle(
              fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold),
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

  CartItem({
    required this.id,
    required this.productName,
    required this.productPrice,
    required this.productOldPrice,
    required this.imageUrls,
    required this.category,
    this.quantity = 1,
  });

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
