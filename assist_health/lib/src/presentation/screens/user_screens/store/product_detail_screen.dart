import 'package:assist_health/src/others/theme.dart';
import 'package:assist_health/src/presentation/screens/user_screens/store/cart_screen.dart';
import 'package:flutter/material.dart';

class ProductDetailScreen extends StatefulWidget {
  final String productName;
  final int productPrice;

  ProductDetailScreen({required this.productName, required this.productPrice});

  @override
  _ProductDetailScreenState createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  int quantity = 0;
  List<CartItem> cartItems = [];

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

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CartScreen(
          cartItems: cartItems,
        ),
      ),
    );
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
                  SizedBox(
                    height: 200,
                    width: 200,
                    child: Image.asset(
                      'assets/empty-box.png',
                      fit: BoxFit.cover,
                    ),
                  ),
                  SizedBox(width: 20),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        height: 80,
                        width: 80,
                        child: Image.asset(
                          'assets/empty-box.png',
                          fit: BoxFit.cover,
                        ),
                      ),
                      SizedBox(height: 10),
                      Container(
                        height: 80,
                        width: 80,
                        child: Image.asset(
                          'assets/empty-box.png',
                          fit: BoxFit.cover,
                        ),
                      ),
                      SizedBox(height: 10),
                      Container(
                        height: 80,
                        width: 80,
                        child: Image.asset(
                          'assets/empty-box.png',
                          fit: BoxFit.cover,
                        ),
                      ),
                    ],
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
              Align(
                alignment: Alignment.center,
                child: ElevatedButton(
                  onPressed: addToCart,
                  style: ElevatedButton.styleFrom(
                    primary: Themes.gradientLightClr,
                    padding:
                        EdgeInsets.symmetric(horizontal: 40, vertical: 16),
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
}
