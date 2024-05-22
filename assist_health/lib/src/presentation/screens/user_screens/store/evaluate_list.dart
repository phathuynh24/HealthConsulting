import 'package:assist_health/src/others/theme.dart';
import 'package:assist_health/src/presentation/screens/user_screens/store/evaluation_detail.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';

class EvaluatePage extends StatefulWidget {
  @override
  _EvaluatePageState createState() => _EvaluatePageState();
}

class _EvaluatePageState extends State<EvaluatePage>
    with SingleTickerProviderStateMixin {
  TabController? _tabController;
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;
  Future<Set<String>>? reviewedProductNamesFuture;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(vsync: this, length: 2);
    reviewedProductNamesFuture = fetchReviewedProducts();
  }

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }

  Future<Set<String>> fetchReviewedProducts() async {
    final reviewsSnapshot = await _firestore
        .collection('product_review')
        .where('userId', isEqualTo: _auth.currentUser?.uid)
        .get();

    return reviewsSnapshot.docs
        .map((doc) => doc['productName'] as String)
        .toSet();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Đánh giá',
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
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          labelStyle: TextStyle(fontSize: 18),
          unselectedLabelColor: Colors.white,
          tabs: [
            Tab(text: 'Chưa đánh giá'),
            Tab(text: 'Đã đánh giá'),
          ],
        ),
      ),
      body: FutureBuilder<Set<String>>(
        future: reviewedProductNamesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Có lỗi xảy ra'));
          }

          final reviewedProductNames = snapshot.data ?? {};

          return TabBarView(
            controller: _tabController,
            children: [
              StreamBuilder<QuerySnapshot>(
                stream: _firestore
                    .collection('orders')
                    .where('userId', isEqualTo: _auth.currentUser?.uid)
                    .where('status', isEqualTo: 'Đã giao')
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return Center(child: Text('Không có sản phẩm nào đã mua'));
                  }

                  Set<String> uniqueProductNames = Set();

                  return ListView.builder(
                    itemCount: snapshot.data?.docs.length,
                    itemBuilder: (context, index) {
                      final order = snapshot.data?.docs[index];
                      final userCart = order?['userCart'] as List<dynamic>?;

                      if (userCart == null || userCart.isEmpty) {
                        return ListTile(
                          title: Text('No products in this order'),
                        );
                      }

                      final uniqueProducts = userCart.where((product) {
                        return uniqueProductNames.add(product['productName']) &&
                            !reviewedProductNames
                                .contains(product['productName']);
                      }).toList();

                      if (uniqueProducts.isEmpty) {
                        return SizedBox
                            .shrink(); // Return an empty widget if no unique products
                      }

                      return Column(
                        children: uniqueProducts.map((product) {
                          return Card(
                            margin: EdgeInsets.all(10),
                            child: ListTile(
                              leading: Image.network(product['imageUrls'][0],
                                  width: 90, height: 80),
                              title: Text(product['productName'],
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18)),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text('Giá mới: '),
                                      Text(
                                        '${NumberFormat('#,###').format(product['productPrice'])}',
                                        style: TextStyle(
                                            color: Themes.gradientLightClr,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Text('Giá cũ:'),
                                      Text(
                                        '${NumberFormat('#,###').format(product['productOldPrice'])}',
                                        style: TextStyle(
                                          color: Themes.gradientLightClr,
                                          fontWeight: FontWeight.bold,
                                          decoration:
                                              TextDecoration.lineThrough,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        ProductEvaluationPage(product: product),
                                  ),
                                );
                              },
                            ),
                          );
                        }).toList(),
                      );
                    },
                  );
                },
              ),
              StreamBuilder<QuerySnapshot>(
                stream: _firestore
                    .collection('product_review')
                    .where('userId', isEqualTo: _auth.currentUser?.uid)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return Center(
                        child: Text('Không có sản phẩm nào đã đánh giá'));
                  }

                  return ListView.builder(
                    itemCount: snapshot.data?.docs.length,
                    itemBuilder: (context, index) {
                      final review = snapshot.data!.docs[index];
                      return ListTile(
                        leading: Image.network(review['imageUrls'][0],
                            width: 80, height: 80),
                        title: Text(
                          review['productName'],
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Column(
                              children: [
                                Row(
                                  children: [
                                    Text('Giá:',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16)),
                                    SizedBox(width: 10),
                                    Text(
                                        '${NumberFormat('#,###').format(review['productPrice'])}',
                                        style: TextStyle(
                                            color: Themes.gradientLightClr,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 18)),
                                    SizedBox(
                                      width: 10,
                                    ),
                                    Text(
                                      '${NumberFormat('#,###').format(review['productOldPrice'])}',
                                      style: TextStyle(
                                        fontSize: 16,
                                        decoration: TextDecoration.lineThrough,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                Text(
                                  'Đánh giá: ',
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold),
                                ),
                                Text(review['review']),
                              ],
                            ),
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '${review['rating']}',
                              style: TextStyle(fontSize: 14),
                            ),
                            Icon(Icons.star, color: Colors.yellow),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ],
          );
        },
      ),
    );
  }
}
