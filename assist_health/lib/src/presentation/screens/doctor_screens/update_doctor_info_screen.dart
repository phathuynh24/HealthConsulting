import 'package:assist_health/src/others/theme.dart';
import 'package:assist_health/src/presentation/screens/user_screens/meals/widgets/custom_snackbar.dart';
import 'package:assist_health/src/presentation/screens/user_screens/meals/widgets/loading_indicator.dart';
import 'package:assist_health/src/widgets/doctor_navbar.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:intl/intl.dart';

class UpdateDoctorInfoScreen extends StatefulWidget {
  final bool isEditScreen;

  const UpdateDoctorInfoScreen({Key? key, this.isEditScreen = false})
      : super(key: key);

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
  final TextEditingController _serviceFeeController = TextEditingController();

  File? _image;
  String? _imageUrl;

  bool isSaving = false;
  bool isEditing = false;

  @override
  void initState() {
    super.initState();
    _loadDoctorInfo();
    _serviceFeeController.addListener(_formatServiceFee);
    isEditing = !widget.isEditScreen; // Default to editable if not in view mode
  }

  Future<void> _loadDoctorInfo() async {
    String uid = FirebaseAuth.instance.currentUser!.uid;
    DocumentSnapshot doc =
        await FirebaseFirestore.instance.collection('users').doc(uid).get();

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
        _serviceFeeController.text = data['serviceFee']?.toString() ?? '';
        _imageUrl = data['imageURL'];
      });
    }
  }

  void _formatServiceFee() {
    String text = _serviceFeeController.text.replaceAll('.', '');
    if (text.isNotEmpty) {
      final number = int.tryParse(text);
      if (number != null) {
        final formattedText =
            NumberFormat('#,###', 'vi_VN').format(number).replaceAll(',', '.');
        _serviceFeeController.value = TextEditingValue(
          text: formattedText,
          selection: TextSelection.collapsed(offset: formattedText.length),
        );
      }
    }
  }

  Future<void> _pickImage() async {
    if (!isEditing) return;

    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  Future<String> _uploadImage(File image) async {
    String uid = FirebaseAuth.instance.currentUser!.uid;
    Reference storageRef =
        FirebaseStorage.instance.ref().child('doctor_profiles/$uid.jpg');
    SettableMetadata metadata = SettableMetadata(
      contentType: 'image/jpeg',
    );
    UploadTask uploadTask = storageRef.putFile(image, metadata);
    TaskSnapshot snapshot = await uploadTask;
    return await snapshot.ref.getDownloadURL();
  }

  Future<void> _updateInfo() async {
    if (_formKey.currentState!.validate()) {
      if (_image == null && _imageUrl == null) {
        CustomSnackbar.show(context, 'Vui lòng chọn ảnh đại diện',
            isSuccess: false);
        return;
      }

      setState(() {
        isSaving = true;
      });

      String uid = FirebaseAuth.instance.currentUser!.uid;
      String imageUrl =
          _image != null ? await _uploadImage(_image!) : _imageUrl!;

      await FirebaseFirestore.instance.collection('users').doc(uid).update({
        'name': _nameController.text.trim(),
        'phone': _phoneController.text.trim(),
        'address': _addressController.text.trim(),
        'careerTitiles': _careerTitleController.text.trim(),
        'description': _descriptionController.text.trim(),
        'experienceText': _experienceController.text.trim(),
        'studyText': _studyController.text.trim(),
        'workplace': _workplaceController.text.trim(),
        'serviceFee': int.parse(_serviceFeeController.text.replaceAll('.', '')),
        'imageURL': imageUrl,
        'isFirstLogin': false,
      });

      setState(() {
        isSaving = false;
        isEditing = false;
      });

      if (!mounted) return;

      CustomSnackbar.show(context, 'Cập nhật thông tin thành công');

      if (!widget.isEditScreen) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const DoctorNavBar()),
          (Route<dynamic> route) => false,
        );
      }
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
              'Thông tin bác sĩ',
              style: TextStyle(fontSize: 20),
            ),
            centerTitle: true,
            actions: widget.isEditScreen
                ? [
                    IconButton(
                      icon: Row(
                        children: [
                          Icon(isEditing ? Icons.save : Icons.edit),
                          const SizedBox(width: 4),
                          Text(
                            isEditing ? 'Lưu' : 'Sửa',
                            style: const TextStyle(color: Colors.white),
                          ),
                          const SizedBox(width: 8),
                        ],
                      ),
                      onPressed: () {
                        if (isEditing) {
                          _updateInfo();
                        } else {
                          setState(() {
                            isEditing = true;
                          });
                        }
                      },
                    )
                  ]
                : [
                    IconButton(
                      icon: const Row(
                        children: [
                          Icon(Icons.save),
                          SizedBox(width: 4),
                          Text(
                            'Lưu',
                            style: TextStyle(color: Colors.white),
                          ),
                          SizedBox(width: 8),
                        ],
                      ),
                      onPressed: () => _updateInfo(),
                    )
                  ],
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
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 20),
                    GestureDetector(
                      onTap: isEditing ? _pickImage : null,
                      child: CircleAvatar(
                        radius: 50,
                        backgroundImage: _image != null
                            ? FileImage(_image!)
                            : (_imageUrl != null
                                ? NetworkImage(_imageUrl!)
                                : null) as ImageProvider?,
                        child: _image == null && _imageUrl == null
                            ? const Icon(Icons.camera_alt, size: 50)
                            : null,
                      ),
                    ),
                    const SizedBox(height: 20),
                    _buildTextField(_nameController, 'Tên bác sĩ',
                        hintText: 'Nhập tên đầy đủ'),
                    _buildTextField(_phoneController, 'Số điện thoại',
                        hintText: 'Ví dụ: 0901234567'),
                    _buildTextField(_addressController, 'Địa chỉ',
                        hintText: 'Nhập địa chỉ làm việc'),
                    _buildTextField(
                        _careerTitleController, 'Chức danh nghề nghiệp',
                        hintText: 'Ví dụ: Bác sĩ chuyên khoa'),
                    _buildTextField(_descriptionController, 'Mô tả',
                        hintText: 'Mô tả ngắn gọn về bản thân', maxLines: 3),
                    _buildTextField(_experienceController, 'Kinh nghiệm',
                        hintText: 'Nhập kinh nghiệm làm việc', maxLines: 2),
                    _buildTextField(_studyController, 'Học vấn',
                        hintText: 'Nhập trình độ học vấn'),
                    _buildTextField(_workplaceController, 'Nơi làm việc',
                        hintText: 'Nhập tên cơ sở làm việc'),
                    _buildTextField(
                      _serviceFeeController,
                      'Phí dịch vụ (VNĐ)',
                      hintText: 'Ví dụ: 1.000.000 VNĐ',
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
        enabled: isEditing,
        keyboardType: labelText == 'Phí dịch vụ'
            ? TextInputType.number
            : TextInputType.text,
        onChanged:
            labelText == 'Phí dịch vụ' ? (_) => _formatServiceFee() : null,
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
          if (labelText == 'Số điện thoại' &&
              !RegExp(r'^0[0-9]{9}$').hasMatch(value)) {
            return 'Số điện thoại không hợp lệ';
          }
          return null;
        },
      ),
    );
  }
}
