import 'package:assist_health/src/others/theme.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';

class CreateBlogPostPage extends StatefulWidget {
  @override
  _CreateBlogPostPageState createState() => _CreateBlogPostPageState();
}

class _CreateBlogPostPageState extends State<CreateBlogPostPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  String? _category;
  DateTime? _verifiedDay;
  bool _status = false;
  File? _image;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  final List<String> categories = [
    "Ăn uống và dinh dưỡng",
    "Vấn đề sức khỏe tâm lý",
    "Mẹ và bé",
    "Hỏi đáp về sức khỏe",
  ];

  Future<void> _pickImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  Future<void> _uploadBlogPost() async {
    if (_formKey.currentState!.validate()) {
      String? imageUrl;
      if (_image != null) {
        final imagePath =
            'blog_images/${DateTime.now().millisecondsSinceEpoch}.png';
        SettableMetadata metadata = SettableMetadata(
          contentType: 'image/png',
        );
        final uploadTask = _storage.ref(imagePath).putFile(_image!, metadata);
        final snapshot = await uploadTask.whenComplete(() => null);
        imageUrl = await snapshot.ref.getDownloadURL();
      }

      final blogPost = {
        'title': _titleController.text,
        'category': _category,
        'verifiedDay': _verifiedDay,
        'status': _status,
        'imageTitle': imageUrl,
      };

      await _firestore.collection('blog').add(blogPost);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        foregroundColor: Colors.white,
        title: const Text(
          'Tạo bài viết mới',
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
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                TextFormField(
                  controller: _titleController,
                  decoration: InputDecoration(labelText: 'Tiêu đề bài viết'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Nhập tiêu đề';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  decoration: InputDecoration(labelText: 'Category'),
                  value: _category,
                  items: categories.map((String category) {
                    return DropdownMenuItem<String>(
                      value: category,
                      child: Text(category),
                    );
                  }).toList(),
                  onChanged: (newValue) {
                    setState(() {
                      _category = newValue;
                    });
                  },
                  validator: (value) {
                    if (value == null) {
                      return 'Chọn loại bài viết';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        _verifiedDay == null
                            ? 'Chọn ngày'
                            : DateFormat.yMd().format(_verifiedDay!),
                      ),
                    ),
                    TextButton(
                      onPressed: () async {
                        DateTime? pickedDate = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2101),
                        );
                        if (pickedDate != null) {
                          setState(() {
                            _verifiedDay = pickedDate;
                          });
                        }
                      },
                      child: Text('Chọn ngày'),
                    ),
                  ],
                ),
                SizedBox(height: 10),
                SwitchListTile(
                  title: Text('Status'),
                  value: _status,
                  onChanged: (bool value) {
                    setState(() {
                      _status = value;
                    });
                  },
                ),
                SizedBox(height: 10),
                if (_image != null) Image.file(_image!),
                TextButton(
                  onPressed: _pickImage,
                  child: Text('Thêm ảnh'),
                ),
                SizedBox(height: 20),
                Center(
                  child: ElevatedButton(
                    onPressed: () {
                      _uploadBlogPost();
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 0, vertical: 12.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      minimumSize: const Size(double.infinity, 0),
                      backgroundColor:
                          Themes.gradientDeepClr, // Đặt màu nền của nút
                      foregroundColor: Colors.white, // Đặt màu chữ của nút
                      // primary: Themes.gradientLightClr,
                      // onPrimary: Colors.white,
                    ),
                    child: const Text(
                      'Tạo mới',
                      style: TextStyle(
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
