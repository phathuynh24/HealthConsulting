import 'package:assist_health/src/others/theme.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:assist_health/src/presentation/screens/user_screens/store/cart/cart_screen.dart';
import 'package:assist_health/src/presentation/screens/user_screens/store/product_detail_screen.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_xlider/flutter_xlider.dart';
import 'package:intl/intl.dart';

class HomeStoreScreen extends StatefulWidget {
  const HomeStoreScreen({Key? key}) : super(key: key);

  @override
  State<HomeStoreScreen> createState() => _HomeStoreScreenState();
}

class _HomeStoreScreenState extends State<HomeStoreScreen> {
  late Stream<QuerySnapshot> _productStream;
  final TextEditingController _searchController = TextEditingController();

  List<CartItem> cartItems = [];
  final List<String> categories = [
    'Hỗ trợ hô hấp',
    'Dinh dưỡng',
    'Hỗ trợ làm đẹp',
    'Hỗ trợ tiêu hóa',
    'Phát triển trẻ nhỏ',
    'Vitamin - khoáng chất'
  ];

  String selectedCategory = '';
  double _lowerValue = 0;
  double _upperValue = 1000000;

  @override
  void initState() {
    super.initState();
    _productStream =
        FirebaseFirestore.instance.collection('products').snapshots();
    _updateProductRatings();
  }

  Future<void> _updateProductRatings() async {
    final productSnapshot =
        await FirebaseFirestore.instance.collection('products').get();
    for (var productDoc in productSnapshot.docs) {
      final productId = productDoc.id;
      final reviewsSnapshot = await FirebaseFirestore.instance
          .collection('product_review')
          .where('productName', isEqualTo: productDoc['name'])
          .get();

      int totalReviews = reviewsSnapshot.docs.length;
      double totalRating = 0;

      for (var reviewDoc in reviewsSnapshot.docs) {
        totalRating += reviewDoc['rating'];
      }

      double averageRating = totalReviews > 0 ? totalRating / totalReviews : 0;

      await FirebaseFirestore.instance
          .collection('products')
          .doc(productId)
          .update({
        'rating': averageRating,
        'voteCount': totalReviews,
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        resizeToAvoidBottomInset: false,
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
          actions: [
            IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CartScreen(cartItems: cartItems),
                  ),
                );
              },
              icon: const Icon(Icons.shopping_cart),
            ),
            IconButton(
              onPressed: _openFilterScreen,
              icon: const Icon(Icons.filter_list),
            )
          ],
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Row(
                children: [
                  const SizedBox(width: 6),
                  Expanded(
                    child: Container(
                      height: 35,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                      child: TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: 'Tìm kiếm sản phẩm...',
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(horizontal: 16),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Container(
                    decoration: const BoxDecoration(
                      color: Colors.blue,
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      onPressed: () {
                        // showSearch(
                        //   context: context,
                        //   delegate: ProductSearch(_searchController.text),
                        // );
                      },
                      icon: const Icon(Icons.search),
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              child: CarouselSlider(
                items: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: AspectRatio(
                        aspectRatio: 3 / 1,
                        child:
                            Image.asset('assets/image.png', fit: BoxFit.cover),
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: AspectRatio(
                        aspectRatio: 3 / 1,
                        child: Image.asset('assets/slider2.jpg',
                            fit: BoxFit.cover),
                      ),
                    ),
                  ),
                ],
                options: CarouselOptions(
                  height: 200,
                  viewportFraction: 1.0,
                  initialPage: 0,
                  enableInfiniteScroll: true,
                  reverse: false,
                  autoPlay: true,
                  autoPlayInterval: const Duration(seconds: 3),
                  autoPlayCurve: Curves.fastOutSlowIn,
                  pauseAutoPlayOnTouch: true,
                  enlargeCenterPage: true,
                ),
              ),
            ),
            SizedBox(
              height: 50,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        if (selectedCategory == categories[index]) {
                          selectedCategory = '';
                        } else {
                          selectedCategory = categories[index];
                        }
                      });
                    },
                    child: Card(
                      color: selectedCategory == categories[index]
                          ? Themes.gradientDeepClr
                          : Themes.gradientLightClr,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          categories[index],
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: _productStream,
                builder: (BuildContext context,
                    AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (snapshot.hasError) {
                    return Text('Đã xảy ra lỗi: ${snapshot.error}');
                  }

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final products = snapshot.data!.docs
                      .where((doc) =>
                          selectedCategory.isEmpty ||
                          doc['category'] == selectedCategory)
                      .where((doc) {
                    final price = doc['price'] as num;
                    return price >= _lowerValue && price <= _upperValue;
                  }).toList();

                  return GridView.builder(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.535,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                    ),
                    padding: const EdgeInsets.all(5),
                    itemCount: products.length,
                    itemBuilder: (context, index) {
                      final doc = products[index];
                      final data = doc.data() as Map<String, dynamic>;
                      final List<String> imageUrls =
                          List<String>.from(data['imageUrls']);
                      final String firstImageUrl =
                          imageUrls.isNotEmpty ? imageUrls[0] : '';

                      return Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                              color: Colors.grey), // Change color as needed
                        ),
                        child: Card(
                          child: Column(
                            children: <Widget>[
                              ClipRRect(
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(10),
                                  topRight: Radius.circular(10),
                                ),
                                child: AspectRatio(
                                  aspectRatio: 0.9,
                                  child: firstImageUrl.isNotEmpty
                                      ? Image.network(
                                          firstImageUrl,
                                          fit: BoxFit.cover,
                                        )
                                      : const Placeholder(),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  children: [
                                    Text(
                                      data['name'],
                                      style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          '${NumberFormat('#,###').format(data['price'])} VNĐ',
                                          style: const TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              color: Themes.gradientLightClr),
                                        ),
                                        Row(
                                          children: [
                                            const Icon(Icons.star,
                                                color: Colors.amber, size: 22),
                                            Text(
                                              '${data['rating'] ?? 0.0} (${data['voteCount'] ?? 0})',
                                              style:
                                                  const TextStyle(fontSize: 12),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    Align(
                                      alignment: Alignment.centerLeft,
                                      child: Text(
                                        '${NumberFormat('#,###').format(data['old_price'])} VNĐ',
                                        style: const TextStyle(
                                          fontSize: 16,
                                          decoration:
                                              TextDecoration.lineThrough,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor:
                                            Themes.gradientLightClr,
                                        foregroundColor: Colors.white,
                                      ),
                                      child: const Text('Thêm vào giỏ hàng'),
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                ProductDetailScreen(
                                              productName: data['name'],
                                              productPrice: data['price'],
                                              productOldPrice:
                                                  data['old_price'],
                                              imageUrls: (data['imageUrls']
                                                      as List<dynamic>)
                                                  .cast<String>(),
                                              category: data['category'],
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openFilterScreen() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            FilterScreen(lowerValue: _lowerValue, upperValue: _upperValue),
      ),
    );
    if (result != null && result is List<double> && result.length == 2) {
      setState(() {
        _lowerValue = result[0];
        _upperValue = result[1];
      });
    }
  }
}

class FilterScreen extends StatefulWidget {
  final double lowerValue;
  final double upperValue;

  const FilterScreen(
      {Key? key, required this.lowerValue, required this.upperValue})
      : super(key: key);

  @override
  _FilterScreenState createState() => _FilterScreenState();
}

class _FilterScreenState extends State<FilterScreen> {
  late double _lowerValue;
  late double _upperValue;

  @override
  void initState() {
    super.initState();
    _lowerValue = widget.lowerValue;
    _upperValue = widget.upperValue;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        foregroundColor: Colors.white,
        title: const Text(
          'Chọn khoảng giá',
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
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FlutterSlider(
            values: [_lowerValue, _upperValue],
            rangeSlider: true,
            max: 1000000,
            min: 0,
            onDragging: (handlerIndex, lowerValue, upperValue) {
              setState(() {
                _lowerValue = lowerValue;
                _upperValue = upperValue;
              });
            },
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _lowerValue = 0;
                    _upperValue = 1000000;
                  });
                },
                style: ButtonStyle(
                  minimumSize: MaterialStateProperty.all(const Size(150, 40)),
                  backgroundColor:
                      MaterialStateProperty.all(Themes.gradientDeepClr),
                  foregroundColor: MaterialStateProperty.all(Colors.white),
                ),
                child: const Text('Reset'),
              ),
              ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context, [_lowerValue, _upperValue]);
                  },
                  style: ButtonStyle(
                    minimumSize: MaterialStateProperty.all(const Size(150, 40)),
                    backgroundColor:
                        MaterialStateProperty.all(Themes.gradientDeepClr),
                    foregroundColor: MaterialStateProperty.all(Colors.white),
                  ),
                  child: const Text('OK')),
            ],
          ),
        ],
      ),
    );
  }
}
