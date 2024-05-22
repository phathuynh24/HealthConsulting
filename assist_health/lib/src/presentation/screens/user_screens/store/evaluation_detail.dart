import 'package:assist_health/src/others/theme.dart';
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
        foregroundColor: Colors.white,
        title: const Text(
          'Đánh giá sản phẩm',
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
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Image.network(
                  widget.product['imageUrls'][0],
                  width: 250,
                  height: 250,
                ),
              ),
              SizedBox(height: 10),
              Text(
                widget.product['productName'],
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              Row(
                children: [
                  Text(
                    'Giá mới: ',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  Text(
                    '${widget.product['productPrice']}',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                        color: Themes.gradientLightClr),
                  ),
                ],
              ),
              Row(
                children: [
                  Text('Giá mới: '),
                  Text(
                    '${widget.product['productOldPrice']}',
                    style: TextStyle(
                        decoration: TextDecoration.lineThrough,
                        color: Themes.gradientLightClr,
                        fontSize: 16),
                  ),
                ],
              ),
              SizedBox(height: 20),
              Text('Đánh giá của bạn',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
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
                maxLines: 3,
                style: TextStyle(
                  fontSize: 16.0, // Change the font size
                  color: Colors.black, // Change the text color
                ),
                decoration: InputDecoration(
                  labelText: 'Viết đánh giá của bạn',
                  labelStyle: TextStyle(
                    color: Themes.gradientDeepClr, // Change the label color
                  ),
                  floatingLabelBehavior: FloatingLabelBehavior.always,
                  border: OutlineInputBorder(),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                        color: Colors.grey,
                        // color: Themes.gradientLightClr,
                        width:
                            2), // Change the border color and width when enabled
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                        color: Colors.blue,
                        width:
                            2.0), // Change the border color and width when focused
                  ),
                  contentPadding: EdgeInsets.symmetric(
                      horizontal: 10, vertical: 20), // Change the padding
                ),
              ),
              SizedBox(height: 20),
              Container(
                height: 60,
                child: Align(
                  alignment: Alignment.center,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Themes.gradientDeepClr,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 40, vertical: 16),
                    ),
                    onPressed: _submitReview,
                    child: Text(
                      'Gửi đánh giá',
                      style: TextStyle(
                          fontSize: 18,
                          color: Colors.white,
                          fontWeight: FontWeight.bold),
                    ),
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
