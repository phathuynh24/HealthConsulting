import 'package:assist_health/src/presentation/screens/user_screens/meals/product_screen.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class ProductScanScreen extends StatefulWidget {
  @override
  _ProductScanScreenState createState() => _ProductScanScreenState();
}

class _ProductScanScreenState extends State<ProductScanScreen> {
  File? _image;

  Future<void> _pickImageFromCamera() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.camera);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
      _navigateToScreen2();
    }
  }

  Future<void> _pickImageFromGallery() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
      _navigateToScreen2();
    }
  }

  void _navigateToScreen2() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Screen2(image: _image!),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Select or Capture Image")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: _pickImageFromCamera,
              child: Text("Capture Image"),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _pickImageFromGallery,
              child: Text("Select from Gallery"),
            ),
          ],
        ),
      ),
    );
  }
}
