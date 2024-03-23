import 'dart:async';

import 'package:assist_health/src/others/theme.dart';
import 'package:assist_health/src/presentation/screens/user_screens/store/cart_screen.dart';
import 'package:assist_health/src/presentation/screens/user_screens/store/product_detail_screen.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class HomeStoreScreen extends StatefulWidget {
  const HomeStoreScreen({Key? key}) : super(key: key);

  @override
  State<HomeStoreScreen> createState() => _HomeStoreScreenState();
}

class _HomeStoreScreenState extends State<HomeStoreScreen> {
  List<CartItem> cartItems = [];
  final List<String> categories = [
    'Thuốc tim mạch',
    'Thuốc bôi ngoài da',
    'Thuốc giảm đau',
    'Thuốc kháng sinh',
    'Thuốc dạ dày'
  ];

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
       appBar: AppBar(
        foregroundColor: Colors.white,
        title: const Text(
          'Nhà Thuốc Trực Tuyến',
          style: TextStyle(fontSize: 20),
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
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Container(
              color: Colors.white, // Màu nền của phần tìm kiếm
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: 'Tìm kiếm sản phẩm...',
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(horizontal: 16),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 10),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      onPressed: () {},
                      icon: Icon(Icons.search),
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(width: 10),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.orange,
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      onPressed: () {
                        Navigator.push(context,
                         MaterialPageRoute(
                                    builder: (context) => CartScreen( cartItems: cartItems,),
                                  ), 
                            );
                      },
                      icon: Icon(Icons.shopping_cart),
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ), 
           Container(
                  // color: Colors.blueGrey, // Màu nền mới của phần slider
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: CarouselSlider(
                    items: [
                      Image.asset('assets/image.png', fit: BoxFit.cover),
                      Image.asset('assets/slider2.jpg', fit: BoxFit.cover),
                    ],
                    options: CarouselOptions(
                      height: 250.0, // Chiều cao của slider
                      viewportFraction: 1.0, // Ảnh chiếm toàn bộ chiều rộng của màn hình
                      initialPage: 0,
                      enableInfiniteScroll: true,
                      reverse: false,
                      autoPlay: true,
                      autoPlayInterval: Duration(seconds: 3),
                      autoPlayCurve: Curves.fastOutSlowIn,
                      pauseAutoPlayOnTouch: true,
                      enlargeCenterPage: true,
                    ),
                  ),
                ),
            Container(
              height: 50, // Độ cao của danh mục
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () {
                      // Xử lý khi người dùng chọn một danh mục
                    },
                    child: Card(
                      color: Themes.gradientLightClr,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          categories[index],
                          style:TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          )
                          ),
                      ),
                    ),
                  );
                },
              ),
            ),
            
            Expanded(
              child: GridView.count(
                crossAxisCount: 2, // Đặt số cột là 2
                children: <Widget>[
                  for (int i = 0; i < 4; i++)
                    SizedBox(
                      height: 200, // Đặt chiều cao của mỗi Card
                      child: Card(
                        child: Column(
                          children: <Widget>[
                          SizedBox(
                            height: 100,
                            child:Image.asset('assets/empty-box.png',
                            fit: BoxFit.cover,
                            ),
                          ),
                           
                            Text('Sản phẩm $i'),
                            Text('${10000 * (i + 1)} VNĐ'),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                primary: Themes.gradientLightClr, // Màu nền của nút
                                onPrimary: Colors.white, // Màu chữ của nút
                              ),
                              child: Text('Thêm vào giỏ hàng'),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ProductDetailScreen(
                                      productName: 'Sản phẩm $i', // Thay đổi thông tin sản phẩm tương ứng
                                      productPrice: 10000 * (i + 1), // Thay đổi thông tin sản phẩm tương ứng
                                    ),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
