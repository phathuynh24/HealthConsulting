import 'package:assist_health/src/presentation/screens/user_screens/store/evaluate_list.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

class ProductEvaluationPage extends StatefulWidget {
  final dynamic product;

  ProductEvaluationPage({required this.product});

  @override
  _ProductEvaluationPageState createState() => _ProductEvaluationPageState();
}

class _ProductEvaluationPageState extends State<ProductEvaluationPage> {
  double _rating = 0;
  final _reviewController = TextEditingController();

  @override
  void dispose() {
    _reviewController.dispose();
    super.dispose();
  }

  void _submitReview() async {
    if (_rating == 0 || _reviewController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please provide a rating and a review')),
      );
      return;
    }
    await FirebaseFirestore.instance.collection('product_review').add({
      'productName': widget.product['productName'],
      'productPrice': widget.product['productPrice'],
      'productOldPrice': widget.product['productOldPrice'],
      'imageUrls': widget.product['imageUrls'],
      // 'productId': widget.product['productId'],
      'rating': _rating,
      'review': _reviewController.text,
      'userId': FirebaseAuth.instance.currentUser?.uid,
      'timestamp': FieldValue.serverTimestamp(),
    });

    // Show a confirmation message and navigate back
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Đánh giá đã được gửi')),
    );
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (context) => EvaluatePage()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Đánh giá sản phẩm'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.product['productName'],
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Image.network(
              widget.product['imageUrls'][0],
              width: 100,
              height: 100,
            ),
            SizedBox(height: 10),
            Text('Giá mới: ${widget.product['productPrice']}'),
            Text(
              'Giá cũ: ${widget.product['productOldPrice']}',
              style: TextStyle(decoration: TextDecoration.lineThrough),
            ),
            SizedBox(height: 20),
            Text('Đánh giá của bạn', style: TextStyle(fontSize: 16)),
            SizedBox(height: 10),
            RatingBar.builder(
              initialRating: 0,
              minRating: 1,
              direction: Axis.horizontal,
              allowHalfRating: true,
              itemCount: 5,
              itemBuilder: (context, _) => Icon(
                Icons.star,
                color: Colors.amber,
              ),
              onRatingUpdate: (rating) {
                setState(() {
                  _rating = rating;
                });
              },
            ),
            SizedBox(height: 20),
            TextField(
              controller: _reviewController,
              decoration: InputDecoration(
                labelText: 'Viết đánh giá của bạn',
                border: OutlineInputBorder(),
              ),
              maxLines: 5,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _submitReview,
              child: Text('Gửi đánh giá'),
            ),
          ],
        ),
      ),
    );
  }
}
