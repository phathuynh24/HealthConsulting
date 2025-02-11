import 'dart:io';

import 'package:assist_health/src/presentation/screens/user_screens/meals/widgets/loading_indicator.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:assist_health/src/others/theme.dart';
import 'package:assist_health/src/models/other/question.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';

class CommunityScreen extends StatefulWidget {
  final Question? questionToEdit; // Thêm tham số này để nhận dữ liệu chỉnh sửa

  const CommunityScreen({Key? key, this.questionToEdit}) : super(key: key);

  @override
  State<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen> {
  bool isMaleSelected = true;
  int age = 18;
  String gender = 'Nam';

  final List<String> selectedCategories = [];
  final List<String> categories = [
    "Tay mũi họng",
    "Bệnh nhiệt đới",
    "Nội thần kinh",
    "Mắt",
    "Nha khoa",
    "Chấn thương chỉnh hình",
    "Tim mạch",
    "Tiêu hóa",
    "Hô hấp",
    "Huyết học",
    "Nội tiết",
  ];

  final List<Question> questions = [];
  final TextEditingController titleController = TextEditingController();
  final TextEditingController contentController = TextEditingController();
  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  List<File> _selectedImages = [];
  List<String> _existingImageUrls = [];
  bool isSaving = false;

  // Validation function to check if all required fields are filled
  bool _validateFields() {
    if (titleController.text.isEmpty || contentController.text.isEmpty) {
      _showSnackBar('Vui lòng hập đầy đủ thông tin!');
      return false;
    }
    if (selectedCategories.isEmpty) {
      _showSnackBar('Vui lòng chọn chủ đề!');
      return false;
    }
    // Additional validation checks can be added if needed
    return true;
  }

  Future<void> _showCategoryDialog() async {
    List<String> selectedCategoriesCopy = List.from(selectedCategories);

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            'Chọn chủ đề',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
          content: SizedBox(
            height: 400,
            width: 400,
            child: SingleChildScrollView(
              child: StatefulBuilder(
                builder: (BuildContext context, StateSetter setState) {
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: categories.map((category) {
                      final isSelected =
                          selectedCategoriesCopy.contains(category);
                      return CheckboxListTile(
                        title: Row(
                          children: [
                            SizedBox(width: 160, child: Text(category)),
                            const SizedBox(
                              width: 5,
                            ),
                            if (isSelected) const Icon(Icons.check),
                          ],
                        ),
                        value: isSelected,
                        onChanged: (bool? value) {
                          setState(() {
                            if (value != null) {
                              if (value) {
                                selectedCategoriesCopy.add(category);
                              } else {
                                selectedCategoriesCopy.remove(category);
                              }
                            }
                          });
                        },
                      );
                    }).toList(),
                  );
                },
              ),
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Hủy'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  selectedCategories.clear();
                  selectedCategories.addAll(selectedCategoriesCopy);
                });
                Navigator.of(context).pop();
              },
              child: const Text('Xác nhận'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _pickImages() async {
    final List<XFile>? pickedFiles = await ImagePicker().pickMultiImage();
    if (pickedFiles != null && pickedFiles.isNotEmpty) {
      setState(() {
        _selectedImages = pickedFiles.map((file) => File(file.path)).toList();
      });
    }
  }

  Future<List<String>> _uploadImages(List<File> images) async {
    List<String> imageUrls = [];
    SettableMetadata metadata = SettableMetadata(
      contentType: 'image/jpeg',
    );
    try {
      for (var image in images) {
        final ref = FirebaseStorage.instance.ref().child(
            'question_images/${DateTime.now().millisecondsSinceEpoch}_${image.path.split('/').last}');
        await ref.putFile(image, metadata);
        final downloadUrl = await ref.getDownloadURL();
        imageUrls.add(downloadUrl);
      }
    } catch (e) {
      debugPrint('Error uploading images: $e');
    }
    return imageUrls;
  }

  @override
  void initState() {
    super.initState();
    if (widget.questionToEdit != null) {
      titleController.text = widget.questionToEdit!.title;
      contentController.text = widget.questionToEdit!.content;
      selectedCategories.addAll(widget.questionToEdit!.categories);
      gender = widget.questionToEdit!.gender;
      age = widget.questionToEdit!.age;
      _existingImageUrls = widget.questionToEdit!.imageUrls;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          backgroundColor: Themes.backgroundClr,
          appBar: AppBar(
            foregroundColor: Colors.white,
            title: const Text('Đặt câu hỏi'),
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
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text(
                        'Giới tính',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(
                        height: 15,
                      ),
                      _genderToggleGender(),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      const Text(
                        'Tuổi',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Expanded(
                        child: _sliderAge(),
                      ),
                      Text(
                        '${age.toString()} tuổi',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                Container(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 15,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text(
                        'Chủ đề',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      ElevatedButton(
                        onPressed: _showCategoryDialog,
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              Themes.gradientLightClr, // Đặt màu nền là màu đỏ
                          foregroundColor: Colors.white,
                          // primary: Themes.gradientLightClr, // Đặt màu nền là màu đỏ
                          // onPrimary: Colors.white, // Đặt màu chữ là màu trắng
                        ),
                        child: const Text(
                          'Chọn chủ đề',
                          style: TextStyle(
                            fontSize: 18,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Wrap(
                        children: selectedCategories.map((category) {
                          return Container(
                            margin: const EdgeInsets.only(right: 5),
                            child: Chip(
                              label: Text(category),
                              onDeleted: () {
                                setState(() {
                                  selectedCategories.remove(category);
                                });
                              },
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                Container(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 15,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Row(
                        children: [
                          Text(
                            'Tiêu đề',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            ' *',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                              color: Colors.red,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      TextFormField(
                        controller: titleController,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          hintText: "Nhập tiêu đề...",
                        ),
                        maxLines: 1,
                      ),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                Container(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 15,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Row(
                        children: [
                          Text(
                            'Nội dung',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            ' *',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                              color: Colors.red,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      ElevatedButton.icon(
                        onPressed: _pickImages,
                        icon: const Icon(
                          Icons.image,
                          color: Colors.white,
                        ),
                        label: const Text(
                          'Chọn ảnh',
                          style: TextStyle(color: Colors.white),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Themes.gradientLightClr,
                        ),
                      ),
                      if (_existingImageUrls.isNotEmpty ||
                          _selectedImages.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              // Hiển thị ảnh đã có từ Firestore
                              ..._existingImageUrls.map((url) => Stack(
                                    children: [
                                      Image.network(
                                        url,
                                        height: 150,
                                        width: 150,
                                        fit: BoxFit.cover,
                                      ),
                                      Positioned(
                                        top: 4,
                                        right: 4,
                                        child: GestureDetector(
                                          onTap: () {
                                            setState(() {
                                              _existingImageUrls.remove(url);
                                            });
                                          },
                                          child: Container(
                                            decoration: const BoxDecoration(
                                              color: Colors.black54,
                                              shape: BoxShape.circle,
                                            ),
                                            child: const Icon(
                                              Icons.close,
                                              color: Colors.white,
                                              size: 20,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  )),

                              // Hiển thị ảnh mới chọn
                              ..._selectedImages.map((image) => Stack(
                                    children: [
                                      Image.file(
                                        image,
                                        height: 150,
                                        width: 150,
                                        fit: BoxFit.cover,
                                      ),
                                      Positioned(
                                        top: 4,
                                        right: 4,
                                        child: GestureDetector(
                                          onTap: () {
                                            setState(() {
                                              _selectedImages.remove(image);
                                            });
                                          },
                                          child: Container(
                                            decoration: const BoxDecoration(
                                              color: Colors.black54,
                                              shape: BoxShape.circle,
                                            ),
                                            child: const Icon(
                                              Icons.close,
                                              color: Colors.white,
                                              size: 20,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  )),
                            ],
                          ),
                        ),
                      const SizedBox(
                        height: 10,
                      ),
                      TextFormField(
                        controller: contentController,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          hintText: "Nhập nội dung...",
                        ),
                        maxLines: 5,
                      ),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 30,
                ),
                ActionChip(
                  onPressed: () async {
                    if (!_validateFields()) return;

                    setState(() {
                      isSaving = true;
                    });

                    User? user = FirebaseAuth.instance.currentUser;
                    List<String> imageUrls = [];

                    if (_selectedImages.isNotEmpty) {
                      imageUrls = await _uploadImages(_selectedImages);
                    }

                    imageUrls.addAll(
                        _existingImageUrls); // Giữ lại các ảnh cũ không bị xóa

                    if (user != null) {
                      Map<String, dynamic> updatedQuestion = {
                        'title': titleController.text,
                        'content': contentController.text,
                        'categories': selectedCategories,
                        'gender': gender,
                        'age': age,
                        'imageUrls': imageUrls,
                      };

                      if (widget.questionToEdit != null) {
                        // Chỉnh sửa
                        await FirebaseFirestore.instance
                            .collection('questions')
                            .doc(widget.questionToEdit!.id)
                            .update(updatedQuestion);

                        updatedQuestion['id'] = widget.questionToEdit!.id;
                      } else {
                        // Tạo mới
                        String currentUserId = user.uid;
                        final id =
                            DateTime.now().millisecondsSinceEpoch.toString();

                        updatedQuestion.addAll({
                          'questionUserId': currentUserId,
                          'date': DateTime.now(),
                        });

                        await FirebaseFirestore.instance
                            .collection('questions')
                            .doc(id)
                            .set(updatedQuestion);

                        updatedQuestion['id'] = id;
                      }

                      setState(() {
                        isSaving = false;
                      });

                      Navigator.pop(context,
                          updatedQuestion); // Trả về dữ liệu câu hỏi đã cập nhật
                    }
                  },
                  avatar: const Icon(Icons.send, color: Colors.white),
                  backgroundColor: Themes.gradientDeepClr,
                  label: Text(
                    widget.questionToEdit != null ? 'Cập nhật' : 'Gửi',
                    style: const TextStyle(color: Colors.white, fontSize: 18),
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
              ],
            ),
          ),
        ),
        if (isSaving)
          Container(
            color: Colors.black.withOpacity(0.3),
            child: const Center(
              child: LoadingIndicator(),
            ),
          ),
      ],
    );
  }

  Widget _genderToggleGender() {
    return Container(
      height: 40,
      width: 300,
      margin: const EdgeInsets.symmetric(horizontal: 50),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20.0),
        color: Colors.grey[300],
      ),
      child: Row(
        children: [
          Expanded(
            child: InkWell(
              onTap: () {
                setState(() {
                  gender = 'Nam';
                  isMaleSelected = true;
                });
              },
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(10.0),
                bottomLeft: Radius.circular(10.0),
              ),
              child: Container(
                height: 40,
                decoration: BoxDecoration(
                  color: isMaleSelected ? Colors.blue : Colors.transparent,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20.0),
                    bottomLeft: Radius.circular(20.0),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.male,
                      color: isMaleSelected ? Colors.white : Colors.black,
                    ),
                    const SizedBox(width: 4.0),
                    Text(
                      'Nam',
                      style: TextStyle(
                        color: isMaleSelected ? Colors.white : Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: InkWell(
              onTap: () {
                setState(() {
                  gender = 'Nữ';
                  isMaleSelected = false;
                });
              },
              borderRadius: const BorderRadius.only(
                topRight: Radius.circular(10.0),
                bottomRight: Radius.circular(10.0),
              ),
              child: Container(
                height: 40,
                decoration: BoxDecoration(
                  color: !isMaleSelected ? Colors.blue : Colors.transparent,
                  borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(20.0),
                    bottomRight: Radius.circular(20.0),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.female,
                      color: !isMaleSelected ? Colors.white : Colors.black,
                    ),
                    const SizedBox(width: 4.0),
                    Text(
                      'Nữ',
                      style: TextStyle(
                        color: !isMaleSelected ? Colors.white : Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sliderAge() {
    return SliderTheme(
      data: const SliderThemeData(
        trackHeight: 10,
      ),
      child: Slider(
        value: age.toDouble(),
        min: 0,
        max: 100,
        activeColor: Themes.gradientLightClr,
        divisions: 100,
        label: '${age.round().toString()} tuổi',
        onChanged: (newValue) {
          setState(() {
            age = newValue.toInt();
          });
        },
      ),
    );
  }
}
