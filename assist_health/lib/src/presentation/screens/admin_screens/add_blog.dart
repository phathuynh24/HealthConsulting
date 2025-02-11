import 'package:assist_health/src/others/theme.dart';
import 'package:assist_health/src/presentation/screens/admin_screens/admin_blog_list.dart';
import 'package:assist_health/src/presentation/screens/user_screens/blog_detail.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';

class CreateBlogPostPage extends StatefulWidget {
  const CreateBlogPostPage({super.key});

  @override
  _CreateBlogPostPageState createState() => _CreateBlogPostPageState();
}

class _CreateBlogPostPageState extends State<CreateBlogPostPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
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
        'content': _contentController.text,
        'category': _category,
        'verifiedDay': _verifiedDay,
        'status': _status,
        'imageTitle': imageUrl,
        'createdAt': FieldValue.serverTimestamp(),
      };

      await _firestore.collection('blog').add(blogPost);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Tạo bài viết thành công!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  const AdminBlog()), // Điều hướng sang BlogPage
        );
      }
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
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                // Tiêu đề bài viết
                TextFormField(
                  controller: _titleController,
                  decoration: InputDecoration(
                    labelText: 'Tiêu đề bài viết',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    filled: true,
                    fillColor: Colors.grey[100],
                  ),
                  validator: (value) => value!.isEmpty ? 'Nhập tiêu đề' : null,
                ),
                const SizedBox(height: 15),

                // Loại bài viết
                DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    labelText: 'Loại bài viết',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    filled: true,
                    fillColor: Colors.grey[100],
                  ),
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
                  validator: (value) =>
                      value == null ? 'Chọn loại bài viết' : null,
                ),
                const SizedBox(height: 15),

                // Chọn ngày
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        _verifiedDay == null
                            ? 'Chưa chọn ngày'
                            : 'Ngày: ${DateFormat('dd/MM/yyyy').format(_verifiedDay!)}',
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                    ElevatedButton.icon(
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
                      icon: const Icon(Icons.calendar_today),
                      label: const Text("Chọn ngày"),
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: Themes.gradientDeepClr,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 15),

                // Trạng thái bài viết
                SwitchListTile(
                  title: const Text('Trạng thái bài viết'),
                  value: _status,
                  onChanged: (bool value) {
                    setState(() {
                      _status = value;
                    });
                  },
                ),
                const SizedBox(height: 15),

                // Nội dung bài viết
                TextFormField(
                  controller: _contentController,
                  maxLines: 6,
                  decoration: InputDecoration(
                    labelText: 'Nội dung bài viết',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    filled: true,
                    fillColor: Colors.grey[100],
                  ),
                  validator: (value) =>
                      value!.isEmpty ? 'Nhập nội dung bài viết' : null,
                ),
                const SizedBox(height: 15),

                // Hình ảnh bài viết
                if (_image != null)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.file(_image!, height: 200, fit: BoxFit.cover),
                  ),
                const SizedBox(height: 10),

                ElevatedButton.icon(
                  onPressed: _pickImage,
                  icon: const Icon(Icons.image),
                  label: const Text('Thêm ảnh'),
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Themes.gradientLightClr,
                  ),
                ),
                const SizedBox(height: 20),

                // Nút tạo bài viết
                Center(
                  child: ElevatedButton(
                    onPressed: _uploadBlogPost,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      backgroundColor: Themes.gradientDeepClr,
                      minimumSize:
                          const Size(double.infinity, 50), // Làm nút rộng ra
                    ),
                    child: const Text(
                      'Tạo bài viết',
                      style: TextStyle(fontSize: 18, color: Colors.white),
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
