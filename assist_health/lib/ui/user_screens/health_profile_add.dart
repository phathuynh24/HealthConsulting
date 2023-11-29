// ignore_for_file: use_build_context_synchronously

import 'dart:io';

import 'package:assist_health/others/theme.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

class AddProfileScreen extends StatefulWidget {
  const AddProfileScreen({super.key});

  @override
  State<AddProfileScreen> createState() => _AddProfileScreenState();
}

class _AddProfileScreenState extends State<AddProfileScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  String? _selectedGender;
  String? _selectedRelationship;
  DateTime? _selectedDate;
  File? _selectedImage;
  String? _uid;

  bool _avtError = false;
  bool _nameError = false;
  bool _dobError = false;
  bool _genderError = false;
  bool _relationshipError = false;

  bool _isSaving = false;

  final List<String> _genderOptions = ['Nam', 'Nữ'];
  final List<String> _relationshipOptions = [
    'Con',
    'Bố/mẹ',
    'Anh/chị/em',
    'Vợ/chồng',
    'Ông/bà'
  ];

  @override
  initState() {
    _uid = _auth.currentUser!.uid;
    super.initState();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _dobController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AbsorbPointer(
      absorbing: _isSaving,
      child: Stack(
        children: [
          Scaffold(
            appBar: AppBar(
              title: const Text('Thêm hồ sơ người thân'),
              centerTitle: true,
              flexibleSpace: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Themes.leftClr, Themes.rightClr],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                ),
              ),
            ),
            body: SingleChildScrollView(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 25, horizontal: 16),
                child: Column(
                  children: [
                    // Avt
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        GestureDetector(
                          onTap: () {
                            _pickImage();
                          },
                          child: Stack(
                            children: [
                              Container(
                                width: 120,
                                height: 120,
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Themes.primaryColor,
                                ),
                                child: _selectedImage != null
                                    ? ClipRRect(
                                        borderRadius: BorderRadius.circular(60),
                                        child: Image.file(_selectedImage!,
                                            fit: BoxFit.cover),
                                      )
                                    : const SizedBox.shrink(),
                              ),
                              const Positioned(
                                bottom: 0,
                                right: 0,
                                child: CircleAvatar(
                                  backgroundColor: Themes.iconClr,
                                  child: Icon(Icons.camera_alt,
                                      color: Colors.white),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Họ tên
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 8, horizontal: 5),
                      child: Row(
                        children: [
                          Text(
                            "Họ tên",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            ' *',
                            style: TextStyle(color: Colors.red),
                          ),
                        ],
                      ),
                    ),
                    TextField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        hintText: 'Nhập họ tên đầy đủ',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        errorText: _nameError ? 'Bắt buộc' : null,
                        contentPadding: const EdgeInsets.symmetric(
                            vertical: 10.0, horizontal: 12),
                      ),
                    ),
                    const SizedBox(height: 5),
                    // Ngày sinh
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 8, horizontal: 5),
                      child: Row(
                        children: [
                          Text(
                            "Ngày sinh",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            ' *',
                            style: TextStyle(color: Colors.red),
                          )
                        ],
                      ),
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _dobController,
                            readOnly: true,
                            decoration: InputDecoration(
                              hintText: 'Chọn ngày sinh',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              errorText: _dobError ? 'Bắt buộc' : null,
                              contentPadding: const EdgeInsets.symmetric(
                                  vertical: 10.0, horizontal: 12),
                            ),
                          ),
                        ),
                        const SizedBox(height: 5),
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8.0),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: () {
                                  _selectDate(context);
                                },
                                splashColor: Themes.highlightClr,
                                child: const Padding(
                                  padding: EdgeInsets.all(5.0),
                                  child: Icon(
                                    Icons.calendar_month_sharp,
                                    size: 40,
                                    color: Themes.iconClr,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                    const SizedBox(height: 5),
                    // Giới tính
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 8, horizontal: 5),
                      child: Row(
                        children: [
                          Text(
                            "Giới tính",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            ' *',
                            style: TextStyle(color: Colors.red),
                          )
                        ],
                      ),
                    ),
                    DropdownButtonFormField<String>(
                      value: _selectedGender,
                      decoration: InputDecoration(
                        hintText: 'Chọn giới tính',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        errorText: _genderError ? 'Bắt buộc' : null,
                        contentPadding: const EdgeInsets.symmetric(
                            vertical: 10.0, horizontal: 12),
                      ),
                      onChanged: (value) {
                        setState(() {
                          _selectedGender = value;
                        });
                      },
                      items: _genderOptions.map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 5),
                    // Mối quan hệ
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 8, horizontal: 5),
                      child: Row(
                        children: [
                          Text(
                            "Mối quan hệ",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            ' *',
                            style: TextStyle(color: Colors.red),
                          )
                        ],
                      ),
                    ),
                    DropdownButtonFormField<String>(
                      value: _selectedRelationship,
                      decoration: InputDecoration(
                        hintText: 'Chọn mối quan hệ với bạn',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        errorText: _relationshipError ? 'Bắt buộc' : null,
                        contentPadding: const EdgeInsets.symmetric(
                            vertical: 10.0, horizontal: 12),
                      ),
                      onChanged: (value) {
                        setState(() {
                          _selectedRelationship = value;
                        });
                      },
                      items: _relationshipOptions.map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 20),
                    // Lưu ý
                    Row(
                      children: [
                        Container(
                          height: 20,
                          width: 20,
                          margin: const EdgeInsets.symmetric(
                            horizontal: 5,
                          ),
                          child: CircleAvatar(
                            backgroundColor: (_selectedImage != null)
                                ? Colors.green
                                : Colors.grey,
                            child: const Icon(
                              Icons.check,
                              color: Colors.white,
                              size: 15,
                            ),
                          ),
                        ),
                        const Text(
                          'Bắt buộc chọn ảnh đại diện',
                          style: TextStyle(
                              color: Colors.black45,
                              fontSize: 15,
                              wordSpacing: 1.2),
                        )
                      ],
                    ),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
            // Nút lưu
            bottomNavigationBar: Container(
              margin: const EdgeInsets.symmetric(
                vertical: 10,
                horizontal: 15,
              ),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                onPressed: _saveDataToFirestore,
                child: const Padding(
                  padding: EdgeInsets.all(12.0),
                  child: Text(
                    'Lưu',
                    style: TextStyle(fontSize: 20),
                  ),
                ),
              ),
            ),
          ),
          // Trạng thái saving
          if (_isSaving)
            Container(
              color: Colors.black54,
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }

  _validateInputs() {
    setState(() {
      _nameError = _nameController.text.isEmpty;
      _dobError = _dobController.text.isEmpty;
      _genderError = (_selectedGender == '' || _selectedGender == null);
      _relationshipError =
          (_selectedRelationship == '' || _selectedRelationship == null);
      _avtError = _selectedImage == null;
    });

    if (!_avtError &&
        !_nameError &&
        !_dobError &&
        !_genderError &&
        !_relationshipError) {
      return true;
    }
    return false;
  }

  _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _dobController.text = DateFormat('dd/MM/yyyy').format(picked);
      });
    }
  }

  _pickImage() async {
    final picker = ImagePicker();
    final pickedImage = await picker.pickImage(source: ImageSource.gallery);
    if (pickedImage != null) {
      setState(() {
        _selectedImage = File(pickedImage.path);
      });
    }
  }

  _saveDataToFirestore() async {
    if (!_validateInputs()) return;

    setState(() {
      _isSaving = true;
    });
    try {
      String name = _nameController.text;
      String dob = _dobController.text;
      String gender = _selectedGender!;
      String relationship = _selectedRelationship!;
      String idDoc = '${DateTime.now()}';

      final userDocumentRef = _firestore
          .collection('users')
          .doc(_uid)
          .collection('health_profiles')
          .doc(idDoc);

      // Tạo doc để lưu dữ liệu
      await userDocumentRef.set(
        {
          'name': name,
          'doB': dob,
          'gender': gender,
          'relationship': relationship,
          'idDoc': idDoc,
        },
      );

      // Lưu ảnh lên Storage
      final imageReference =
          _storage.ref().child('images/${DateTime.now()}.png');
      final uploadTask = imageReference.putFile(_selectedImage!);
      final storageTaskSnapshot = await uploadTask.whenComplete(() => null);

      // Lưu đường dẫn ảnh
      String imageURL = await storageTaskSnapshot.ref.getDownloadURL();
      await userDocumentRef.update({'imageURL': imageURL});
    } catch (error) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Lỗi'),
            content: const Text(
                'Trong quá trình lưu đã xảy ra lỗi. Bạn vui lòng thử lại sau!'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
    } finally {
      setState(() {
        _isSaving = false;
      });

      //Quay trở lại màn hình trước đó
      Navigator.pop(context, true);
    }
  }
}
