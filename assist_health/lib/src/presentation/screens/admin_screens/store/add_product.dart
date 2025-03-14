import 'dart:io';
import 'package:assist_health/src/others/theme.dart';
import 'package:assist_health/src/presentation/screens/admin_screens/store/product.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

//Format
class PriceInputFormatter extends TextInputFormatter {
  static final _formatter = NumberFormat("#,###");

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final newText =
        _formatter.format(int.parse(newValue.text.replaceAll(",", "")));
    return TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: newText.length),
    );
  }
}

class AddProductScreen extends StatefulWidget {
  const AddProductScreen({super.key});

  @override
  _AddProductScreenState createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
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

  Future<void> _pickImages(int index) async {
    final imagePicker = ImagePicker();
    final List<XFile> pickedImages = await imagePicker.pickMultiImage();

    List<String> imagePaths = pickedImages.map((image) => image.path).toList();
    setState(() {
      _imageUrls = [..._imageUrls, ...imagePaths];
      _selectedImageIndex = index;
      print('Selected image index: $_imageUrls');
    });
  }

  Future<void> _saveProduct() async {
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

        for (String imagePath in _imageUrls) {
          try {
            print('Uploading image: $imagePath');
            final Reference storageRef = FirebaseStorage.instance
                .ref()
                .child('product_images')
                .child(DateTime.now().toString());
            final File imageFile = File(imagePath);

            if (!imageFile.existsSync()) {
              print('Tệp không tồn tại: $imagePath');
              continue;
            }

            SettableMetadata metadata = SettableMetadata(
              contentType: 'image/jpeg',
              customMetadata: {'uploaded_by': 'admin'},
            );

            final UploadTask uploadTask =
                storageRef.putFile(imageFile, metadata);
            final TaskSnapshot storageSnapshot =
                await uploadTask.whenComplete(() {});

            final String imageUrl = await storageSnapshot.ref.getDownloadURL();
            imageUrls.add(imageUrl);
          } catch (e) {
            print('Lỗi khi tải ảnh: $e');
            Navigator.pop(context); // Đóng Loading Indicator
            return;
          }
        }

        final Product newProduct = Product(
          name: name,
          price: price,
          oldPrice: oldPrice,
          quantity: quantity,
          imageUrls: imageUrls,
          id: '',
          category: _selectedCategory,
          description: _descriptionController.text.trim(),
        );

        try {
          final productRef = await FirebaseFirestore.instance
              .collection('products')
              .add(newProduct.toMap());
          await productRef.update({'category': _selectedCategory});

          setState(() {
            _nameController.clear();
            _priceController.clear();
            _oldPriceController.clear();
            _quantityController.clear();
            _descriptionController.clear();
            _imageUrls.clear();
            _selectedCategory = '';
            _selectedImageIndex = -1;
          });

          Navigator.pop(context); // Đóng Loading Indicator
          Navigator.pop(context); // Quay lại màn hình trước
        } catch (e) {
          print('Lỗi khi lưu sản phẩm vào Firestore: $e');
          Navigator.pop(context); // Đóng Loading Indicator
          _showErrorDialog('Lỗi khi lưu sản phẩm. Vui lòng thử lại sau.');
        }
      } catch (e) {
        print('Error saving product: $e');
        Navigator.pop(context); // Đóng Loading Indicator
        _showErrorDialog(
            'Đã xảy ra lỗi khi lưu sản phẩm. Vui lòng thử lại sau.');
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
              child: const Text('Close'),
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
    print('Selected image index: ${_imageUrls.length}');
    return Scaffold(
      appBar: AppBar(
        foregroundColor: Colors.white,
        title: const Text(
          'Thêm sản phẩm',
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
                // inputFormatters: [PriceInputFormatter()],
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
                // inputFormatters: [PriceInputFormatter()],
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
                value: _selectedCategory,
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
                          image:
                              _imageUrls.isNotEmpty && index < _imageUrls.length
                                  ? DecorationImage(
                                      image: FileImage(File(_imageUrls[index])),
                                      fit: BoxFit.cover,
                                    )
                                  : null,
                        ),
                        child: _imageUrls.isNotEmpty &&
                                index < _imageUrls.length
                            ? null // Không hiển thị Icon nếu có ảnh được chọn
                            : const Icon(Icons.add_a_photo, size: 40.0),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16.0),
              //Canh giua
              Center(
                child: ElevatedButton(
                  onPressed: _saveProduct,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 32.0, vertical: 12.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    backgroundColor:
                        Themes.gradientLightClr, // Đặt màu nền của nút
                    foregroundColor: Colors.white, // Đặt màu chữ của nút
                  ),
                  child: const Text(
                    'Lưu',
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
