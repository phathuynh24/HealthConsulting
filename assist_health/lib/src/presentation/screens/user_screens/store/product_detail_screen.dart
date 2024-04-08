import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:assist_health/src/others/theme.dart';
import 'package:assist_health/src/presentation/screens/user_screens/store/cart_screen.dart';

class ProductDetailScreen extends StatefulWidget {
  final String productName;
  final int productPrice;
  final List<String> imageUrls;
  final String category; // Thêm category cho sản phẩm
  static const String defaultImageUrl = 'assets/empty-box.png';
  ProductDetailScreen({
    required this.productName,
    required this.productPrice,
    required this.imageUrls,
    required this.category, // Thêm category vào constructor
  });

  @override
  _ProductDetailScreenState createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  int quantity = 0;
  List<CartItem> cartItems = [];
  late String selectedImageUrl;

  @override
  void initState() {
    super.initState();
    if (widget.imageUrls.isNotEmpty) {
      selectedImageUrl = widget.imageUrls.first;
    } else {
      selectedImageUrl = ProductDetailScreen.defaultImageUrl;
    }
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

  void addToCart() {
    CartItem newItem = CartItem(
      productName: widget.productName,
      productPrice: widget.productPrice,
      quantity: quantity,
    );
    cartItems.add(newItem);
    // Lưu thông tin sản phẩm vào Firestore
    FirebaseFirestore.instance.collection('user_carts').add({
      'productName': widget.productName,
      'productPrice': widget.productPrice,
      'quantity': quantity,
      // Thêm các thông tin khác của sản phẩm nếu cần
    });
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
    // Lấy thông tin của sản phẩm từ Firestore dựa trên productId
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
        title: Text('Chi tiết sản phẩm'),
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
                          offset: Offset(0, 3),
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
                  SizedBox(width: 20),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: List.generate(widget.imageUrls.length, (index) {
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedImageUrl = widget.imageUrls[index];
                          });
                        },
                        child: Container(
                          margin: EdgeInsets.only(bottom: 10),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.5),
                                spreadRadius: 2,
                                blurRadius: 5,
                                offset: Offset(0, 3),
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
                ],
              ),
              SizedBox(height: 20),
              Text(
                widget.productName,
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              Text(
                '${widget.productPrice} VNĐ',
                style: TextStyle(fontSize: 18, color: Colors.blue),
              ),
              SizedBox(height: 20),
              Text(
                'Mô tả sản phẩm:',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              Text(
                'Đây là mô tả chi tiết về sản phẩm.',
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 20),
              Row(
                children: [
                  Text(
                    'Số lượng:',
                    style: TextStyle(fontSize: 18),
                  ),
                  SizedBox(width: 10),
                  IconButton(
                    onPressed: decreaseQuantity,
                    icon: Icon(Icons.remove),
                  ),
                  SizedBox(width: 10),
                  Text(
                    quantity.toString(),
                    style: TextStyle(fontSize: 18),
                  ),
                  SizedBox(width: 10),
                  IconButton(
                    onPressed: increaseQuantity,
                    icon: Icon(Icons.add),
                  ),
                ],
              ),
              SizedBox(height: 20),
              Text(
                'Sản phẩm cùng loại',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              // Hiển thị danh sách các sản phẩm cùng loại
              // Hiển thị danh sách các sản phẩm cùng loại
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
                    return Center(child: CircularProgressIndicator());
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
                          // Gọi hàm điều hướng đến trang chi tiết sản phẩm
                          navigateToProductDetail(doc.id);
                        },
                        child: Container(
                          margin: EdgeInsets.symmetric(
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
                              SizedBox(height: 10),
                              Text(
                                data['name'],
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                              SizedBox(height: 5),
                              Text(
                                '${data['price']} VNĐ',
                                style:
                                    TextStyle(fontSize: 14, color: Colors.blue),
                              ),
                            ],
                          ),
                        ),
                      );
                    } else {
                      return SizedBox(); // Trả về widget trống nếu là sản phẩm hiện tại
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

              SizedBox(height: 20),
              Align(
                alignment: Alignment.center,
                child: ElevatedButton(
                  onPressed: addToCart,
                  style: ElevatedButton.styleFrom(
                    primary: Themes.gradientLightClr,
                    padding: EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                  ),
                  child: Text(
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
  final String productName;
  final int productPrice;
  int quantity;

  CartItem(
      {required this.productName,
      required this.productPrice,
      this.quantity = 1});
      factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      productName: json['productName'],
      productPrice: json['productPrice'],
      quantity: json['quantity'] ?? 1,
    );
  }
}
