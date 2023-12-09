import 'dart:io';

import 'package:assist_health/others/theme.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';

class AddDoctorScreen extends StatefulWidget {
  const AddDoctorScreen({Key? key}) : super(key: key);

  @override
  State<AddDoctorScreen> createState() => _AddDoctorScreenState();
}

class _AddDoctorScreenState extends State<AddDoctorScreen> {
  TextEditingController _nameController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _descriptionController = TextEditingController();
  TextEditingController _experienceController = TextEditingController();
  File? _selectedImage;
  String _selectedSpecialty = 'Tai mũi họng'; // Default value
  final List<String> _specialties = [
    'Tai mũi họng',
    'Nội thần kinh',
    'Mắt',
    'Nha khoa',
    'Chấn thương chỉnh hình'
  ];
  List<WorkExperience> _workExperiences = [
    WorkExperience()
  ]; // Default value with an empty WorkExperience

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _emailController = TextEditingController();
    _descriptionController = TextEditingController();
    _experienceController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _descriptionController.dispose();
    _experienceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Thêm Bác sĩ'),
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
                            child: Icon(Icons.camera_alt, color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Họ tên bác sĩ',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedSpecialty,
                onChanged: (newValue) {
                  setState(() {
                    _selectedSpecialty = newValue!;
                  });
                },
                items:
                    _specialties.map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                decoration: InputDecoration(
                  labelText: 'Chuyên khoa',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  labelText: 'Mô tả',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              // Work experience input for each entry
              for (int i = 0; i < _workExperiences.length; i++)
                _buildWorkExperienceInput(i),

              const SizedBox(height: 16),
              TextField(
                controller: _experienceController,
                decoration: InputDecoration(
                  labelText: 'Kinh nghiệm làm việc',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
                readOnly: true,
              ),

              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  _saveDataToFirestore();
                },
                child: const Text('Thêm'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWorkExperienceInput(int index) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Kinh nghiệm làm việc'),
        const SizedBox(height: 15),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              flex: 1,
              child: DropdownButtonFormField<String>(
                value: _workExperiences[index].startYear,
                onChanged: (newValue) {
                  setState(() {
                    _workExperiences[index].startYear = newValue!;
                  });
                },
                items: _generateYearItems(),
                decoration: InputDecoration(
                  labelText: 'Bắt đầu',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            const SizedBox(width: 16),
            // Dropdown for end year
            Expanded(
              flex: 1,
              child: DropdownButtonFormField<String>(
                value: _workExperiences[index].endYear,
                onChanged: (newValue) {
                  setState(() {
                    _workExperiences[index].endYear = newValue!;
                  });
                },
                items: _generateYearItems(),
                decoration: InputDecoration(
                  labelText: 'Kết thúc',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _workExperiences[index].workplaceController,
                decoration: InputDecoration(
                  labelText: 'Nơi làm việc',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            IconButton(
              onPressed: () {
                _addTimelineDescription(index);
              },
              icon: Icon(Icons.send),
            ),
          ],
        ),
      ],
    );
  }

  List<DropdownMenuItem<String>> _generateYearItems() {
    final List<String> years =
        List.generate(30, (index) => (2023 - index).toString());
    return years
        .map<DropdownMenuItem<String>>(
          (String value) => DropdownMenuItem<String>(
            value: value,
            child: Text(value),
          ),
        )
        .toList();
  }

  void _addTimelineDescription(int index) {
    final currentExperience = _workExperiences[index];
    final timelineDescription =
        '${currentExperience.startYear} - ${currentExperience.endYear}: ${currentExperience.workplaceController.text}';

    // Add the timeline description to the general description
    _experienceController.text =
        '${_experienceController.text}\n$timelineDescription';
  }

  Future<String?> _uploadImageToFirebase(File imageFile, String uid) async {
    try {
      // Access Firebase Storage instance
      FirebaseStorage storage = FirebaseStorage.instance;

      // Create a reference to the image file
      Reference storageReference = storage.ref().child('images/$uid.jpg');

      // Upload the image file to Firebase Storage
      UploadTask uploadTask = storageReference.putFile(imageFile);
      TaskSnapshot taskSnapshot = await uploadTask;

      // Get the download URL of the uploaded image
      String downloadURL = await taskSnapshot.ref.getDownloadURL();
      return downloadURL;
    } catch (e) {
      print('Error uploading image to Firebase Storage: $e');
      return null;
    }
  }

  void _saveDataToFirestore() async {
    try {
      String uid = Uuid().v4();
      String name = _nameController.text.trim();
      String email = _emailController.text.trim();
      String description = _descriptionController.text.trim();
      String experience = _experienceController.text.trim();

      // Validate that all required fields are filled
      if (name.isEmpty ||
          email.isEmpty ||
          description.isEmpty ||
          experience.isEmpty ||
          _selectedImage == null) {
        _showErrorSnackBar('Please fill in all fields and select an image.');
        return;
      }

      // Access Firestore instance
      FirebaseFirestore firestore = FirebaseFirestore.instance;

      // Check if an account with the provided email already exists
      QuerySnapshot existingAccounts = await firestore
          .collection('users')
          .where('email', isEqualTo: email)
          .get();

      if (existingAccounts.docs.isNotEmpty) {
        // An account with the same email already exists
        _showErrorSnackBar('An account with this email already exists.');
        return;
      }

      // Create a new document in the 'users' collection with the generated UID
      DocumentReference doctorRef =
          await firestore.collection('users').doc(uid);
      String? downloadURL;
      if (_selectedImage != null) {
        downloadURL = await _uploadImageToFirebase(_selectedImage!, uid);
      }
      // Set data for the doctor document
      await doctorRef.set({
        'uid': uid,
        'name': _nameController.text,
        'email': email,
        'specialty': _selectedSpecialty,
        'role': 'doctor',
        'imageURL': downloadURL,
      });

      // Save work experiences
      for (int i = 0; i < _workExperiences.length; i++) {
        WorkExperience experience = _workExperiences[i];

        // Add each work experience as a subcollection under the doctor's document
        await doctorRef.collection('experience').add({
          'startYear': experience.startYear,
          'endYear': experience.endYear,
          'workplace': experience.workplaceController.text,
        });
      }
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text,
        password: '123456',
      );
      _showSuccessSnackBar('Doctor information saved successfully!');
    } catch (e) {
      print('Error saving data to Firestore: $e');
      _showErrorSnackBar('Error saving data to Firestore');
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

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green, // Customize the background color
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red, // Customize the background color
      ),
    );
  }
}

class WorkExperience {
  String startYear = '2020';
  String endYear = '2022';
  TextEditingController workplaceController = TextEditingController();
}
