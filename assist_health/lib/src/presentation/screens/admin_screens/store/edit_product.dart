import 'dart:io';
import 'package:assist_health/src/others/theme.dart';
import 'package:assist_health/src/presentation/screens/admin_screens/store/product.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

class EditProductScreen extends StatefulWidget {
  final Product product;

  const EditProductScreen({super.key, required this.product});

  @override
  _EditProductScreenState createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _oldPriceController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  List<String> _imageUrls = [];
  String? _selectedCategory;
  int _selectedImageIndex = -1;
  final List<String> _categories = [
    'Hỗ trợ hô hấp',
    'Dinh dưỡng',
    'Hỗ trợ làm đẹp',
    'Hỗ trợ tiêu hóa',
    'Phát triển trẻ nhỏ',
    'Vitamin - khoáng chất'
  ];

  @override
  void initState() {
    super.initState();
    // Load thông tin sản phẩm vào các trường nhập liệu
    _nameController.text = widget.product.name;
    _priceController.text = widget.product.price.toString();
    _oldPriceController.text = widget.product.oldPrice.toString();
    _quantityController.text = widget.product.quantity.toString();
    _descriptionController.text = widget.product.description.toString();
    _selectedCategory = widget.product.category;
    _imageUrls = widget.product.imageUrls;
  }

  Future<void> _pickImages(int index) async {
    final imagePicker = ImagePicker();
    final List<XFile> pickedImages = await imagePicker.pickMultiImage();

    if (pickedImages.isNotEmpty) {
      List<String> imagePaths =
          pickedImages.map((image) => image.path).toList();
      setState(() {
        // Thay thế ảnh tại vị trí index bằng ảnh mới
        if (index < _imageUrls.length) {
          _imageUrls[index] = imagePaths[0]; // Chỉ lấy ảnh đầu tiên
        } else {
          _imageUrls.add(imagePaths[0]); // Thêm ảnh mới nếu index vượt quá
        }
        _selectedImageIndex = index;
      });
    }
  }

  Future<void> _deleteOldImage(String imageUrl) async {
    try {
      final Reference storageRef =
          FirebaseStorage.instance.refFromURL(imageUrl);
      await storageRef.delete();
      print('Đã xóa ảnh cũ: $imageUrl');
    } catch (e) {
      print('Lỗi khi xóa ảnh cũ: $e');
    }
  }

  Future<String> _uploadImage(String imagePath) async {
    try {
      final Reference storageRef = FirebaseStorage.instance
          .ref()
          .child('product_images')
          .child(DateTime.now().toString());
      final File imageFile = File(imagePath);

      if (!imageFile.existsSync()) {
        print('Tệp không tồn tại: $imagePath');
        return '';
      }

      SettableMetadata metadata = SettableMetadata(
        contentType: 'image/jpeg',
        customMetadata: {'uploaded_by': 'admin'},
      );

      final UploadTask uploadTask = storageRef.putFile(imageFile, metadata);
      final TaskSnapshot storageSnapshot = await uploadTask.whenComplete(() {});

      final String imageUrl = await storageSnapshot.ref.getDownloadURL();
      return imageUrl;
    } catch (e) {
      print('Lỗi khi tải ảnh: $e');
      return '';
    }
  }

  Future<void> _updateProduct() async {
    final String name = _nameController.text.trim();
    final int price = int.tryParse(_priceController.text.trim()) ?? 0;
    final int oldPrice = int.tryParse(_oldPriceController.text.trim()) ?? 0;
    final int quantity = int.tryParse(_quantityController.text.trim()) ?? 0;

    if (name.isNotEmpty &&
        price > 0 &&
        oldPrice > 0 &&
        quantity > 0 &&
        _imageUrls.length == 3 &&
        _selectedCategory != null) {
      try {
        // Hiển thị Loading Indicator
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          },
        );

        List<String> imageUrls = [];
        if (_imageUrls.isEmpty) {
          print('Danh sách ảnh trống.');
          Navigator.pop(context); // Đóng Loading Indicator
          return;
        }

        // Tải ảnh mới lên Firebase Storage và lấy URL
        for (int i = 0; i < _imageUrls.length; i++) {
          if (_imageUrls[i].startsWith('http')) {
            // Nếu là URL cũ, giữ nguyên
            imageUrls.add(_imageUrls[i]);
          } else {
            // Nếu là ảnh mới, tải lên và lấy URL
            final String imageUrl = await _uploadImage(_imageUrls[i]);
            if (imageUrl.isNotEmpty) {
              imageUrls.add(imageUrl);
            }
          }
        }

        // Xóa ảnh cũ khỏi Firebase Storage (nếu cần)
        for (String oldImageUrl in widget.product.imageUrls) {
          if (!imageUrls.contains(oldImageUrl)) {
            await _deleteOldImage(oldImageUrl);
          }
        }

        final Product updatedProduct = Product(
          name: name,
          price: price,
          oldPrice: oldPrice,
          quantity: quantity,
          imageUrls: imageUrls,
          id: widget.product.id,
          category: _selectedCategory!,
          description: _descriptionController.text.trim(),
        );

        try {
          await FirebaseFirestore.instance
              .collection('products')
              .doc(widget.product.id)
              .update(updatedProduct.toMap());

          setState(() {
            _nameController.clear();
            _priceController.clear();
            _oldPriceController.clear();
            _quantityController.clear();
            _descriptionController.clear();
            _imageUrls.clear();
            _selectedCategory = null;
            _selectedImageIndex = -1;
          });

          Navigator.pop(context); // Đóng Loading Indicator
          Navigator.pop(context); // Quay lại màn hình trước
        } catch (e) {
          print('Lỗi khi cập nhật sản phẩm vào Firestore: $e');
          Navigator.pop(context); // Đóng Loading Indicator
          _showErrorDialog('Lỗi khi cập nhật sản phẩm. Vui lòng thử lại sau.');
        }
      } catch (e) {
        print('Error updating product: $e');
        Navigator.pop(context); // Đóng Loading Indicator
        _showErrorDialog(
            'Đã xảy ra lỗi khi cập nhật sản phẩm. Vui lòng thử lại sau.');
      }
    } else {
      _showErrorDialog('Hãy điền đầy đủ các thông tin và ảnh.');
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Thông báo'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Đóng'),
            ),
          ],
        );
      },
    );
  }

  void _onCategoryChanged(String? newValue) {
    if (newValue != null) {
      setState(() {
        _selectedCategory = newValue;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        foregroundColor: Colors.white,
        title: const Text(
          'Chỉnh sửa sản phẩm',
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
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Tên sản phẩm',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.shopping_bag),
                ),
              ),
              const SizedBox(height: 16.0),
              TextField(
                controller: _priceController,
                decoration: const InputDecoration(
                  labelText: 'Giá sản phẩm',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.attach_money),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16.0),
              TextField(
                controller: _oldPriceController,
                decoration: const InputDecoration(
                  labelText: 'Giá cũ sản phẩm',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.money),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16.0),
              TextField(
                controller: _quantityController,
                decoration: const InputDecoration(
                  labelText: 'Số lượng',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.format_list_numbered),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16.0),
              TextField(
                controller: _descriptionController,
                maxLines: null,
                decoration: const InputDecoration(
                  labelText: 'Mô tả sản phẩm',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.description),
                ),
              ),
              const SizedBox(height: 16.0),
              DropdownButton<String>(
                value: _selectedCategory ?? _categories.first,
                onChanged: _onCategoryChanged,
                items:
                    _categories.map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16.0),
              Row(
                children: List.generate(
                  3,
                  (index) => Expanded(
                    child: GestureDetector(
                      onTap: () {
                        _pickImages(index);
                      },
                      child: Container(
                        margin: const EdgeInsets.only(right: 8.0),
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          border: Border.all(),
                          borderRadius: BorderRadius.circular(8.0),
                          image: index < _imageUrls.length
                              ? DecorationImage(
                                  image: _imageUrls[index].startsWith('http')
                                      ? NetworkImage(
                                          _imageUrls[index]) // Ảnh từ Firebase
                                      : FileImage(File(_imageUrls[index]))
                                          as ImageProvider<
                                              Object>, // Ảnh cục bộ
                                  fit: BoxFit.cover,
                                )
                              : null,
                        ),
                        child: index < _imageUrls.length
                            ? null
                            : const Icon(Icons.add_a_photo, size: 40.0),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24.0),
              Center(
                child: ElevatedButton(
                  onPressed: _updateProduct,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 32.0, vertical: 12.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    backgroundColor: Themes.gradientLightClr,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text(
                    'Cập nhật',
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
    );
  }
}
