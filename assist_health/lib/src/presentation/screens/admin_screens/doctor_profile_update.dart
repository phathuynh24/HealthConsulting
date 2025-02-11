// ignore_for_file: avoid_print

import 'dart:io';

import 'package:assist_health/src/others/theme.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:multi_select_flutter/dialog/multi_select_dialog_field.dart';
import 'package:multi_select_flutter/util/multi_select_item.dart';

class UpdateDoctorScreen extends StatefulWidget {
  final String doctorId;

  const UpdateDoctorScreen({super.key, required this.doctorId});

  @override
  State<UpdateDoctorScreen> createState() => _UpdateDoctorScreenState();
}

class _UpdateDoctorScreenState extends State<UpdateDoctorScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _workplaceController = TextEditingController();
  final TextEditingController _experiencetextController =
      TextEditingController();
  final TextEditingController _studytextController = TextEditingController();
  File? _selectedImage;
  String? _imageURL;
  List<String> _selectedSpecialties = [];
  final List<String> _specialties = [
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
  @override
  void initState() {
    super.initState();
    _loadDoctorData();
  }

  void _loadDoctorData() async {
    try {
      DocumentSnapshot doctorSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.doctorId)
          .get();

      if (doctorSnapshot.exists) {
        setState(() {
          _nameController.text = doctorSnapshot['name'];
          _emailController.text = doctorSnapshot['email'];
          _descriptionController.text = doctorSnapshot['description'];
          _workplaceController.text = doctorSnapshot['workplace'];
          _experiencetextController.text = doctorSnapshot['experienceText'];
          _studytextController.text = doctorSnapshot['studyText'];
          _imageURL = doctorSnapshot['imageURL'];
          _selectedSpecialties =
              List<String>.from(doctorSnapshot['specialty'] ?? []);
        });
      }
    } catch (e) {
      print('Error loading doctor data from Firestore: $e');
    }
  }

  void _updateDataToFirestore() async {
    try {
      DocumentReference doctorRef =
          FirebaseFirestore.instance.collection('users').doc(widget.doctorId);

      // Validate and update data
      if (_nameController.text.isEmpty ||
          _emailController.text.isEmpty ||
          _descriptionController.text.isEmpty ||
          _workplaceController.text.isEmpty) {
        _showErrorSnackBar('Hãy điền đầy đủ tất cả thông tin');
        return;
      }

      // Upload and get image URL if a new image is selected
      String? downloadURL;
      if (_selectedImage != null) {
        downloadURL =
            await _uploadImageToFirebase(_selectedImage!, widget.doctorId);
      }

      // Update Firestore document with new data
      await doctorRef.update({
        'name': _nameController.text,
        'email': _emailController.text,
        'description': _descriptionController.text,
        'workplace': _workplaceController.text,
        'imageURL': downloadURL ?? _imageURL,
        'specialty': _selectedSpecialties,

        // Use the new URL if available, otherwise keep the old one
      });

      _showSuccessSnackBar('Cập nhật thông tin bác sĩ thành công');
      // ignore: use_build_context_synchronously
      Navigator.pop(context);
    } catch (e) {
      print('Error updating data to Firestore: $e');
      _showErrorSnackBar('Error updating data to Firestore');
    }
  }

  Future<String?> _uploadImageToFirebase(
      File imageFile, String doctorId) async {
    try {
      FirebaseStorage storage = FirebaseStorage.instance;
      Reference storageReference = storage.ref().child('images/$doctorId.jpg');
      SettableMetadata metadata = SettableMetadata(
        contentType: 'image/jpeg',
      );
      UploadTask uploadTask = storageReference.putFile(imageFile, metadata);
      TaskSnapshot taskSnapshot = await uploadTask;
      return await taskSnapshot.ref.getDownloadURL();
    } catch (e) {
      print('Error uploading image to Firebase Storage: $e');
      return null;
    }
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Themes.backgroundClr,
      appBar: AppBar(
        foregroundColor: Colors.white,
        title: const Text(
          'Cập Nhật Thông Tin Bác Sĩ',
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
          padding: const EdgeInsets.symmetric(vertical: 25, horizontal: 16),
          child: Column(
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
                          : _imageURL != null
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(60),
                                  child: Image.network(
                                    _imageURL!,
                                    fit: BoxFit.cover,
                                  ),
                                )
                              : const SizedBox.shrink(),
                    ),
                    const Positioned(
                      bottom: 0,
                      right: 0,
                      child: CircleAvatar(
                        backgroundColor: Themes.iconClr,
                        child: Icon(Icons.camera_alt, color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Họ tên bác sĩ',
                  border: OutlineInputBorder(),
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z ]')),
                ],
              ),
              const SizedBox(height: 16),
              MultiSelectDialogField(
                items: _specialties
                    .map(
                        (String value) => MultiSelectItem<String>(value, value))
                    .toList(),
                initialValue: _selectedSpecialties,
                onConfirm: (values) {
                  setState(() {
                    _selectedSpecialties = values.cast<String>().toList();
                  });
                },
                title: const Text('Chuyên khoa'),
                dialogHeight: 300,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Mô tả',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _workplaceController,
                decoration: const InputDecoration(
                  labelText: 'Nơi công tác',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _experiencetextController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Kinh nghiệm làm việc',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _studytextController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Học vấn',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  _updateDataToFirestore();
                },
                child: const Text('Cập Nhật'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedImage = await picker.pickImage(source: ImageSource.gallery);
    if (pickedImage != null) {
      setState(() {
        _selectedImage = File(pickedImage.path);
      });
    }
  }
}
