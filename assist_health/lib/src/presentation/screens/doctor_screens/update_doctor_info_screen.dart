import 'package:assist_health/src/others/theme.dart';
import 'package:assist_health/src/presentation/screens/user_screens/meals/widgets/loading_indicator.dart';
import 'package:assist_health/src/widgets/doctor_navbar.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class UpdateDoctorInfoScreen extends StatefulWidget {
  const UpdateDoctorInfoScreen({Key? key}) : super(key: key);

  @override
  State<UpdateDoctorInfoScreen> createState() => _UpdateDoctorInfoScreenState();
}

class _UpdateDoctorInfoScreenState extends State<UpdateDoctorInfoScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _careerTitleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _experienceController = TextEditingController();
  final TextEditingController _studyController = TextEditingController();
  final TextEditingController _workplaceController = TextEditingController();

  File? _image;

  bool isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadDoctorInfo();
  }

  Future<void> _loadDoctorInfo() async {
    String uid = FirebaseAuth.instance.currentUser!.uid;
    DocumentSnapshot doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();

    if (doc.exists) {
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      setState(() {
        _nameController.text = data['name'] ?? '';
        _phoneController.text = data['phone'] ?? '';
        _addressController.text = data['address'] ?? '';
        _careerTitleController.text = data['careerTitiles'] ?? '';
        _descriptionController.text = data['description'] ?? '';
        _experienceController.text = data['experienceText'] ?? '';
        _studyController.text = data['studyText'] ?? '';
        _workplaceController.text = data['workplace'] ?? '';
      });
    }
  }

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  Future<void> _updateInfo() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        isSaving = true;
      });
      String uid = FirebaseAuth.instance.currentUser!.uid;

      await FirebaseFirestore.instance.collection('users').doc(uid).update({
        'name': _nameController.text.trim(),
        'phone': _phoneController.text.trim(),
        'address': _addressController.text.trim(),
        'careerTitiles': _careerTitleController.text.trim(),
        'description': _descriptionController.text.trim(),
        'experienceText': _experienceController.text.trim(),
        'studyText': _studyController.text.trim(),
        'workplace': _workplaceController.text.trim(),
        'isFirstLogin': false,
      });

      setState(() {
        isSaving = false;
      });

      if (!mounted) return;

      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (_) => const DoctorNavBar()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          appBar: AppBar(
              foregroundColor: Colors.white,
              title: const Text(
                'Cập nhật thông tin',
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
              ))),
          body: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 20),
                    GestureDetector(
                      onTap: _pickImage,
                      child: CircleAvatar(
                        radius: 50,
                        backgroundImage: _image != null ? FileImage(_image!) : null,
                        child: _image == null
                            ? const Icon(Icons.camera_alt, size: 50)
                            : null,
                      ),
                    ),
                    const SizedBox(height: 20),
                    _buildTextField(_nameController, 'Tên bác sĩ', hintText: 'Nhập tên đầy đủ'),
                    _buildTextField(_phoneController, 'Số điện thoại', hintText: 'Ví dụ: 0901234567'),
                    _buildTextField(_addressController, 'Địa chỉ', hintText: 'Nhập địa chỉ làm việc'),
                    _buildTextField(
                        _careerTitleController, 'Chức danh nghề nghiệp', hintText: 'Ví dụ: Bác sĩ chuyên khoa'),
                    _buildTextField(_descriptionController, 'Mô tả', hintText: 'Mô tả ngắn gọn về bản thân', maxLines: 3),
                    _buildTextField(_experienceController, 'Kinh nghiệm', hintText: 'Nhập kinh nghiệm làm việc', maxLines: 2),
                    _buildTextField(_studyController, 'Học vấn', hintText: 'Nhập trình độ học vấn'),
                    _buildTextField(_workplaceController, 'Nơi làm việc', hintText: 'Nhập tên cơ sở làm việc'),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 30),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: _updateInfo,
                      child: const Text(
                        'Cập nhật thông tin',
                        style: TextStyle(fontSize: 16, color: Colors.white),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ),
        if (isSaving)
          Container(
            color: Colors.black.withOpacity(0.5),
            child: const Center(
              child: LoadingIndicator(),
            ),
          ),
      ],
    );
  }

  Widget _buildTextField(TextEditingController controller, String labelText,
      {String hintText = '', int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: labelText,
          hintText: hintText,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Vui lòng nhập $labelText';
          }
          if (labelText == 'Số điện thoại' && !RegExp(r'^0[0-9]{8}\$').hasMatch(value)) {
            return 'Số điện thoại không hợp lệ';
          }
          return null;
        },
      ),
    );
  }
}
